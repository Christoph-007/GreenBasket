const { stripe } = require('../config/stripe');
const Order = require('../models/Order');
const paymentService = require('../services/paymentService');
const notificationService = require('../services/notification');

exports.createPaymentOrder = async (req, res) => {
    try {
        const { orderId, amount } = req.body;

        if (!orderId || !amount) {
            return res.status(400).json({
                success: false,
                error: 'Order ID and amount are required'
            });
        }

        const order = await Order.findOne({
            orderId,
            customer: req.user._id
        }).populate('customer');

        if (!order) {
            return res.status(404).json({
                success: false,
                error: 'Order not found'
            });
        }

        if (order.paymentStatus === 'completed' || order.paymentStatus === 'paid') {
            return res.status(400).json({
                success: false,
                error: 'Order already paid'
            });
        }

        // Verify amount
        if (order.totalAmount !== amount) {
            return res.status(400).json({
                success: false,
                error: 'Amount mismatch'
            });
        }

        // Create Stripe Payment Intent
        const paymentIntent = await paymentService.createPaymentIntent(
            amount,
            order.orderId,
            req.user._id.toString(),
            {
                customerName: order.customer.name,
                customerEmail: order.customer.email
            }
        );

        order.paymentGateway.provider = 'stripe';
        order.paymentGateway.paymentIntentId = paymentIntent.id;
        order.paymentGateway.clientSecret = paymentIntent.client_secret;
        order.stripePaymentIntentId = paymentIntent.id;

        order.paymentEvents.push({
            event: 'order_created',
            data: {
                paymentIntentId: paymentIntent.id,
                amount: paymentIntent.amount,
                currency: paymentIntent.currency,
                status: paymentIntent.status
            }
        });
        await order.save();

        res.json({
            success: true,
            data: {
                clientSecret: paymentIntent.client_secret,
                publishableKey: process.env.STRIPE_PUBLISHABLE_KEY,
                paymentIntentId: paymentIntent.id,
                amount: amount,
                currency: 'INR',
                order: {
                    orderId: order.orderId,
                    totalAmount: order.totalAmount
                },
                customer: {
                    name: order.customer.name,
                    email: order.customer.email,
                    phone: order.customer.phone
                }
            }
        });
    } catch (error) {
        console.error('Stripe payment order creation error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to create payment order',
            details: error.message
        });
    }
};

// Verify payment is mostly redundant with Stripe as passing the client_secret to frontend 
// handles the confirmation. The backend confirms via webhook. 
// However, the frontend might call this to check status immediately after payment.
exports.verifyPayment = async (req, res) => {
    try {
        const { orderId, paymentIntentId } = req.body;

        if (!orderId || !paymentIntentId) {
            return res.status(400).json({
                success: false,
                error: 'Order ID and Payment Intent ID are required'
            });
        }

        const order = await Order.findOne({
            orderId,
            customer: req.user._id
        });

        if (!order) {
            return res.status(404).json({
                success: false,
                error: 'Order not found'
            });
        }

        // Retrieve latest status from Stripe
        const paymentIntent = await paymentService.getPaymentIntent(paymentIntentId);

        if (paymentIntent.status === 'succeeded') {
            if (order.paymentStatus !== 'completed') {
                order.paymentStatus = 'completed';
                order.status = 'confirmed';
                order.paymentGateway.paymentIntentId = paymentIntent.id;
                order.paymentGateway.transactionId = paymentIntent.charges?.data[0]?.balance_transaction || paymentIntent.id;

                // Update Method info if available
                const charge = paymentIntent.charges?.data[0];
                if (charge && charge.payment_method_details) {
                    const details = charge.payment_method_details;
                    if (!order.paymentDetails) order.paymentDetails = {};
                    order.paymentDetails.method = details.type;
                    order.paymentDetails.email = charge.receipt_email;
                }

                if (!order.confirmedAt) order.confirmedAt = new Date();

                order.paymentEvents.push({
                    event: 'payment_captured',
                    data: {
                        paymentIntentId: paymentIntent.id,
                        status: paymentIntent.status,
                        amount: paymentIntent.amount_received / 100
                    }
                });

                await order.save();

                // Notify merchant (using existing logic)
                const io = req.app.get('io');
                if (io) {
                    io.to(`merchant_${order.merchant}`).emit('order_paid', {
                        orderId: order.orderId,
                        amount: order.totalAmount
                    });
                }
            }

            return res.json({
                success: true,
                message: 'Payment verified successfully',
                data: {
                    order: {
                        orderId: order.orderId,
                        paymentStatus: order.paymentStatus,
                        status: order.status,
                        totalAmount: order.totalAmount
                    }
                }
            });
        } else if (paymentIntent.status === 'processing') {
            return res.json({
                success: true,
                message: 'Payment is processing',
                data: { status: 'processing' }
            });
        } else {
            return res.status(400).json({
                success: false,
                error: `Payment not succeeded. Status: ${paymentIntent.status}`
            });
        }

    } catch (error) {
        console.error('Payment verification error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to verify payment',
            details: error.message
        });
    }
};

exports.handleWebhook = async (req, res) => {
    const sig = req.headers['stripe-signature'];
    let event;

    try {
        const payload = req.body;
        // Note: In express apps, ensure you use raw body for stripe webhook verification
        // If bodyParser.json() is used globally, this might fail unless configured correctly.
        // Assuming req.rawBody or similar is available or avoiding body parsing for this route.
        // If using standard express.json(), construction might tricky.
        // For now, assuming the verification service handles the structure or we trust the event if secret is strictly managed?
        // Actually, Stripe REQUIRE raw body. 
        // We will assume `req.rawBody` is available (common middleware pattern) or `req.body` is buffer.

        // If req.body is already parsed JSON, we can't verify signature easily without raw buffer.
        // IMPORTANT: The user must ensure webhook route receives raw body.

        event = stripe.webhooks.constructEvent(req.rawBody || req.body, sig, process.env.STRIPE_WEBHOOK_SECRET);
    } catch (err) {
        console.error(`Webhook signature verification failed: ${err.message}`);
        return res.status(400).send(`Webhook Error: ${err.message}`);
    }

    try {
        console.log('[WEBHOOK] Event received:', event.type);

        if (event.type === 'payment_intent.succeeded') {
            const paymentIntent = event.data.object;
            const orderId = paymentIntent.metadata.orderId;

            const order = await Order.findOne({ stripePaymentIntentId: paymentIntent.id });

            if (order && order.paymentStatus !== 'completed') {
                order.paymentStatus = 'completed';
                order.status = 'confirmed';
                order.paymentGateway.paymentIntentId = paymentIntent.id;
                if (!order.confirmedAt) order.confirmedAt = new Date();

                order.statusHistory.push({
                    status: 'confirmed',
                    timestamp: new Date(),
                    note: 'Payment captured via Stripe webhook',
                    updatedByModel: 'System'
                });

                await order.save();

                // Notify logic
                await notificationService.send(
                    order.customer,
                    'User',
                    {
                        type: 'order_placed',
                        title: 'Payment Confirmed',
                        message: `Your payment of ₹${paymentIntent.amount / 100} for order ${order.orderId} has been confirmed`,
                        channels: ['push', 'email'],
                        data: { orderId: order.orderId }
                    }
                );
            }
        } else if (event.type === 'payment_intent.payment_failed') {
            const paymentIntent = event.data.object;
            const order = await Order.findOne({ stripePaymentIntentId: paymentIntent.id });

            if (order) {
                order.paymentStatus = 'failed';
                order.statusHistory.push({
                    status: 'pending',
                    timestamp: new Date(),
                    note: `Payment failed: ${paymentIntent.last_payment_error?.message || 'Unknown error'}`,
                    updatedByModel: 'System'
                });
                await order.save();
            }
        }

        res.json({ received: true });
    } catch (error) {
        console.error('[WEBHOOK] Error processing webhook:', error);
        res.status(500).json({ error: 'Webhook processing failed' });
    }
};

exports.processRefund = async (req, res) => {
    try {
        const { orderId, amount, reason } = req.body;

        if (!orderId || !reason) {
            return res.status(400).json({ success: false, error: 'Order ID and reason are required' });
        }

        const order = await Order.findOne({ orderId });
        if (!order) return res.status(404).json({ success: false, error: 'Order not found' });

        if (order.paymentGateway.provider !== 'stripe') {
            return res.status(400).json({ success: false, error: 'Order was not paid via Stripe' });
        }

        const refundAmount = amount || order.totalAmount;
        const paymentIntentId = order.paymentGateway.paymentIntentId;

        const refund = await paymentService.processRefund(paymentIntentId, refundAmount, reason);

        if (!order.refund) order.refund = {};
        order.refund.status = 'processing';
        order.refund.stripeRefundId = refund.id;
        order.refund.amount = refundAmount;
        order.refund.reason = reason;
        order.refund.initiatedAt = new Date();
        order.paymentStatus = 'refunded';

        await order.save();

        res.json({
            success: true,
            message: 'Refund initiated successfully',
            data: {
                refundId: refund.id,
                amount: refundAmount,
                status: refund.status
            }
        });

    } catch (error) {
        console.error('Refund processing error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to process refund',
            details: error.message
        });
    }
};

exports.getPaymentMethods = async (req, res) => {
    try {
        const methods = [
            { id: 'cod', name: 'Cash on Delivery', icon: 'cash', available: true },
            { id: 'stripe', name: 'Credit / Debit Card / UPI', icon: 'card', available: true }
        ];

        if (req.user) {
            const Wallet = require('../models/Wallet');
            const wallet = await Wallet.findOne({ user: req.user._id });
            const balance = wallet?.balance || 0;

            methods.push({
                id: 'wallet',
                name: 'Green Basket Wallet',
                icon: 'wallet',
                available: !wallet?.isLocked && balance > 0,
                balance,
                isLocked: wallet?.isLocked || false
            });
        }

        res.json({ success: true, data: { methods } });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

// ... keep getPaymentHistory as it queries DB generic fields ...
exports.getPaymentHistory = async (req, res) => {
    try {
        const { status, page = 1, limit = 10 } = req.query;

        const query = { customer: req.user._id };
        if (status) query.paymentStatus = status;

        const skip = (page - 1) * limit;

        const [orders, total] = await Promise.all([
            Order.find(query)
                .select('orderId totalAmount paymentStatus paymentGateway createdAt status merchant')
                .populate('merchant', 'businessName')
                .sort({ createdAt: -1 })
                .skip(skip)
                .limit(parseInt(limit)),
            Order.countDocuments(query)
        ]);

        res.json({
            success: true,
            data: {
                payments: orders.map(o => ({
                    orderId: o.orderId,
                    amount: o.totalAmount,
                    paymentStatus: o.paymentStatus,
                    paymentMethod: o.paymentGateway?.provider || 'unknown',
                    paymentId: o.paymentGateway?.paymentIntentId,
                    orderStatus: o.status,
                    merchant: o.merchant?.businessName,
                    date: o.createdAt
                })),
                pagination: {
                    page: parseInt(page),
                    limit: parseInt(limit),
                    total,
                    pages: Math.ceil(total / limit)
                }
            }
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.getPaymentStatus = async (req, res) => {
    try {
        const { orderId } = req.params;
        const order = await Order.findOne({ orderId, customer: req.user._id });

        if (!order) return res.status(404).json({ success: false, error: 'Order not found' });

        let stripeStatus = null;
        if (order.stripePaymentIntentId) {
            const pi = await paymentService.getPaymentIntent(order.stripePaymentIntentId);
            stripeStatus = pi.status;
        }

        res.json({
            success: true,
            data: {
                orderId: order.orderId,
                paymentStatus: order.paymentStatus,
                stripeStatus
            }
        });

    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.retryPayment = async (req, res) => {
    // Retry logic is essentially creating a new payment order/intent
    // Reuse createPaymentOrder logic or redirect
    return exports.createPaymentOrder(req, res);
};
