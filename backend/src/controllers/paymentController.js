const { razorpay } = require('../config/razorpay');
const Order = require('../models/Order');
const crypto = require('crypto');

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

        if (order.totalAmount !== amount) {
            return res.status(400).json({
                success: false,
                error: 'Amount mismatch'
            });
        }

        const razorpayOrder = await razorpay.orders.create({
            amount: amount * 100,
            currency: 'INR',
            receipt: orderId,
            notes: {
                orderId: order._id.toString(),
                customerId: req.user._id.toString(),
                customerName: order.customer.name
            }
        });

        order.paymentGateway.provider = 'razorpay';
        order.paymentGateway.orderId = razorpayOrder.id;
        order.razorpayOrderId = razorpayOrder.id; // Added consistent ID for webhook
        order.paymentEvents.push({
            event: 'order_created',
            data: {
                razorpayOrderId: razorpayOrder.id,
                amount: razorpayOrder.amount,
                currency: razorpayOrder.currency
            }
        });
        await order.save();

        res.json({
            success: true,
            data: {
                razorpayOrderId: razorpayOrder.id,
                amount: razorpayOrder.amount,
                currency: razorpayOrder.currency,
                keyId: process.env.RAZORPAY_KEY_ID,
                order: {
                    orderId: order.orderId,
                    totalAmount: order.totalAmount,
                    items: order.items
                },
                prefill: {
                    name: order.customer.name,
                    email: order.customer.email,
                    contact: order.customer.phone
                }
            }
        });
    } catch (error) {
        console.error('Razorpay order creation error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to create payment order',
            details: error.message
        });
    }
};

exports.verifyPayment = async (req, res) => {
    try {
        const {
            razorpay_order_id,
            razorpay_payment_id,
            razorpay_signature,
            orderId
        } = req.body;

        if (!razorpay_order_id || !razorpay_payment_id || !razorpay_signature || !orderId) {
            return res.status(400).json({
                success: false,
                error: 'All payment details are required'
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

        if (order.paymentGateway.orderId !== razorpay_order_id) {
            return res.status(400).json({
                success: false,
                error: 'Order ID mismatch'
            });
        }

        const generatedSignature = crypto
            .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
            .update(`${razorpay_order_id}|${razorpay_payment_id}`)
            .digest('hex');

        if (generatedSignature !== razorpay_signature) {
            order.paymentEvents.push({
                event: 'payment_failed',
                data: {
                    reason: 'Invalid signature',
                    razorpay_order_id,
                    razorpay_payment_id
                }
            });
            await order.save();

            return res.status(400).json({
                success: false,
                error: 'Invalid payment signature'
            });
        }

        let paymentDetails;
        try {
            paymentDetails = await razorpay.payments.fetch(razorpay_payment_id);
        } catch (error) {
            return res.status(500).json({
                success: false,
                error: 'Failed to fetch payment details from Razorpay'
            });
        }

        order.paymentGateway.paymentId = razorpay_payment_id;
        order.paymentGateway.signature = razorpay_signature;
        order.paymentGateway.transactionId = paymentDetails.acquirer_data?.bank_transaction_id || '';

        // Ensure paymentDetails exists on order
        if (!order.paymentDetails) order.paymentDetails = {};

        order.paymentDetails.method = paymentDetails.method;
        order.paymentDetails.email = paymentDetails.email;
        order.paymentDetails.contact = paymentDetails.contact;

        if (paymentDetails.method === 'card') {
            order.paymentDetails.cardNetwork = paymentDetails.card?.network;
            order.paymentDetails.cardLast4 = paymentDetails.card?.last4;
        } else if (paymentDetails.method === 'upi') {
            order.paymentDetails.upiVpa = paymentDetails.vpa;
        } else if (paymentDetails.method === 'netbanking') {
            order.paymentDetails.bank = paymentDetails.bank;
        } else if (paymentDetails.method === 'wallet') {
            order.paymentDetails.wallet = paymentDetails.wallet;
        }

        order.paymentStatus = 'completed';
        order.status = 'confirmed';
        // paidAt logic handled in schema update if exists or manually here? Schema doesn't have paidAt directly in this update but status update logic might
        // The previous schema didn't have paidAt in the root, only in paymentDetails. 
        // The new schema doesn't explicitely add paidAt at root level but I see confirmedAt.
        // Let's add confirmedAt if missing
        if (!order.confirmedAt) order.confirmedAt = new Date();

        order.paymentEvents.push({
            event: 'payment_captured',
            data: {
                paymentId: razorpay_payment_id,
                method: paymentDetails.method,
                amount: paymentDetails.amount / 100
            }
        });

        await order.save();

        // Send notification email
        // Assuming sendEmail service exists or needs to be mocked for now.
        // const sendEmail = require('../services/email');
        // await sendEmail({ ... }); 
        // Commented out email service call as it might not be fully implemented yet based on PRD status.

        // Notify merchant
        const io = req.app.get('io');
        if (io) {
            io.to(`merchant_${order.merchant}`).emit('order_paid', {
                orderId: order.orderId,
                amount: order.totalAmount
            });
        }

        res.json({
            success: true,
            message: 'Payment verified successfully',
            data: {
                order: {
                    orderId: order.orderId,
                    paymentStatus: order.paymentStatus,
                    status: order.status,
                    paymentId: razorpay_payment_id,
                    totalAmount: order.totalAmount
                }
            }
        });
    } catch (error) {
        console.error('Payment verification error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to verify payment',
            details: error.message
        });
    }
};

exports.processRefund = async (req, res) => {
    try {
        const { orderId, amount, reason } = req.body;

        if (!orderId || !reason) {
            return res.status(400).json({
                success: false,
                error: 'Order ID and reason are required'
            });
        }

        const order = await Order.findOne({ orderId });

        if (!order) {
            return res.status(404).json({
                success: false,
                error: 'Order not found'
            });
        }

        if (req.user.userType !== 'admin' &&
            order.customer.toString() !== req.user._id.toString()) {
            return res.status(403).json({
                success: false,
                error: 'Not authorized to process refund'
            });
        }

        if (order.paymentStatus !== 'completed' && order.paymentStatus !== 'paid') {
            return res.status(400).json({
                success: false,
                error: 'Order not paid yet'
            });
        }

        if (order.paymentGateway.provider === 'cod') {
            return res.status(400).json({
                success: false,
                error: 'Cannot refund COD orders through payment gateway'
            });
        }

        if (order.refund && order.refund.status === 'completed') {
            return res.status(400).json({
                success: false,
                error: 'Order already refunded'
            });
        }

        const refundAmount = amount || order.totalAmount;

        if (refundAmount > order.totalAmount) {
            return res.status(400).json({
                success: false,
                error: 'Refund amount cannot exceed order total'
            });
        }

        if (refundAmount <= 0) {
            return res.status(400).json({
                success: false,
                error: 'Refund amount must be greater than 0'
            });
        }

        let refundResponse;
        try {
            refundResponse = await razorpay.payments.refund(
                order.paymentGateway.paymentId,
                {
                    amount: refundAmount * 100,
                    speed: 'normal',
                    notes: {
                        reason: reason,
                        orderId: order.orderId,
                        processedBy: req.user._id.toString()
                    },
                    receipt: `refund-${order.orderId}-${Date.now()}`
                }
            );
        } catch (error) {
            console.error('Razorpay refund error:', error);

            if (!order.refund) order.refund = {};
            order.refund.status = 'failed';
            order.refund.failureReason = error.message;
            await order.save();

            return res.status(500).json({
                success: false,
                error: 'Failed to process refund',
                details: error.message
            });
        }

        if (!order.refund) order.refund = {};
        order.refund.status = 'processing';
        order.refund.refundId = refundResponse.id;
        order.refund.amount = refundAmount;
        order.refund.reason = reason;
        order.refund.initiatedAt = new Date();

        order.paymentEvents.push({
            event: 'refund_initiated',
            data: {
                refundId: refundResponse.id,
                amount: refundAmount,
                reason: reason
            }
        });

        order.paymentStatus = 'refunded';

        await order.save();

        // Send notification email
        // const User = require('../models/User');
        // const customer = await User.findById(order.customer);
        // const sendEmail = require('../services/email');
        // await sendEmail({ ... });

        res.json({
            success: true,
            message: 'Refund initiated successfully',
            data: {
                refundId: refundResponse.id,
                amount: refundAmount,
                status: 'processing',
                orderId: order.orderId
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

exports.handleWebhook = async (req, res) => {
    try {
        const webhookSecret = process.env.RAZORPAY_WEBHOOK_SECRET;
        const signature = req.headers['x-razorpay-signature'];

        if (!signature) {
            return res.status(400).json({ success: false, error: 'Missing signature header' });
        }

        // Validate webhook signature
        const crypto = require('crypto');
        const expectedSignature = crypto
            .createHmac('sha256', webhookSecret)
            .update(req.body) // req.body is raw Buffer here
            .digest('hex');

        if (expectedSignature !== signature) {
            console.error('[WEBHOOK] Invalid signature received');
            return res.status(400).json({ success: false, error: 'Invalid webhook signature' });
        }

        const event = JSON.parse(req.body.toString());
        console.log('[WEBHOOK] Event received:', event.event);

        const Order = require('../models/Order');
        const notificationService = require('../services/notification');

        // Handle payment captured
        if (event.event === 'payment.captured') {
            const { order_id, id: payment_id, amount, method } = event.payload.payment.entity;

            const order = await Order.findOne({ razorpayOrderId: order_id });

            if (!order) {
                console.warn('[WEBHOOK] Order not found for razorpayOrderId:', order_id);
                return res.json({ success: true, received: true });
            }

            if (order.paymentStatus === 'completed') {
                return res.json({ success: true, received: true, note: 'Already processed' });
            }

            order.paymentStatus = 'completed';
            order.paymentId = payment_id;
            order.status = 'confirmed';
            order.paymentMethod = method || order.paymentMethod;

            if (!order.statusHistory) order.statusHistory = [];
            order.statusHistory.push({
                status: 'confirmed',
                timestamp: new Date(),
                note: 'Payment captured via Razorpay webhook',
                updatedByModel: 'System'
            });

            await order.save();

            // Notify customer
            await notificationService.send(
                order.customer,
                'User',
                {
                    type: 'order_placed',
                    title: 'Payment Confirmed',
                    message: `Your payment of ₹${amount / 100} for order ${order.orderId} has been confirmed`,
                    channels: ['push', 'email'],
                    data: { orderId: order.orderId, amount: amount / 100 }
                }
            );

            // Notify merchant
            await notificationService.send(
                order.merchant,
                'Merchant',
                {
                    type: 'new_order',
                    title: 'New Order Received',
                    message: `New order ${order.orderId} received for ₹${amount / 100}`,
                    channels: ['push'],
                    data: { orderId: order.orderId }
                }
            );

            console.log('[WEBHOOK] Payment captured for order:', order.orderId);
        }

        // Handle payment failed
        if (event.event === 'payment.failed') {
            const { order_id, error_description } = event.payload.payment.entity;

            const order = await Order.findOneAndUpdate(
                { razorpayOrderId: order_id },
                {
                    paymentStatus: 'failed',
                    $push: {
                        statusHistory: {
                            status: 'pending',
                            timestamp: new Date(),
                            note: `Payment failed: ${error_description || 'Unknown reason'}`,
                            updatedByModel: 'System'
                        }
                    }
                },
                { new: true }
            );

            if (order) {
                await notificationService.send(
                    order.customer,
                    'User',
                    {
                        type: 'order_placed',
                        title: 'Payment Failed',
                        message: `Your payment for order ${order.orderId} failed. Please retry.`,
                        channels: ['push', 'email'],
                        data: { orderId: order.orderId }
                    }
                );
                console.log('[WEBHOOK] Payment failed for order:', order.orderId);
            }
        }

        // Handle refund processed
        if (event.event === 'refund.processed') {
            const { payment_id, amount, id: refund_id } = event.payload.refund.entity;

            const order = await Order.findOneAndUpdate(
                { paymentId: payment_id },
                {
                    'refund.status': 'completed',
                    'refund.razorpayRefundId': refund_id,
                    'refund.processedAt': new Date()
                },
                { new: true }
            );

            if (order) {
                console.log('[WEBHOOK] Refund processed for order:', order.orderId);
            }
        }

        res.json({ success: true, received: true });
    } catch (error) {
        console.error('[WEBHOOK] Error processing webhook:', error);
        res.json({ success: true, received: true });
    }
};

exports.getPaymentMethods = async (req, res) => {
    try {
        const methods = [
            { id: 'cod', name: 'Cash on Delivery', icon: 'cash', available: true },
            { id: 'razorpay', name: 'UPI / Card / Net Banking', icon: 'card', available: true }
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

exports.getPaymentHistory = async (req, res) => {
    try {
        const { status, page = 1, limit = 10 } = req.query;

        const query = { customer: req.user._id };
        if (status) query.paymentStatus = status;

        const skip = (page - 1) * limit;

        const [orders, total] = await Promise.all([
            require('../models/Order').find(query)
                .select('orderId totalAmount paymentStatus paymentMethod paymentId razorpayOrderId createdAt status merchant')
                .populate('merchant', 'businessName')
                .sort({ createdAt: -1 })
                .skip(skip)
                .limit(parseInt(limit)),
            require('../models/Order').countDocuments(query)
        ]);

        res.json({
            success: true,
            data: {
                payments: orders.map(o => ({
                    orderId: o.orderId,
                    amount: o.totalAmount,
                    paymentStatus: o.paymentStatus,
                    paymentMethod: o.paymentMethod,
                    paymentId: o.paymentId,
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

        const order = await require('../models/Order').findOne({
            orderId,
            customer: req.user._id
        });

        if (!order) {
            return res.status(404).json({ success: false, error: 'Order not found' });
        }

        let razorpayStatus = null;

        if (order.razorpayOrderId && order.paymentStatus !== 'completed') {
            try {
                const { razorpay } = require('../config/razorpay');
                const rzpOrder = await razorpay.orders.fetch(order.razorpayOrderId);
                razorpayStatus = rzpOrder.status;

                if (rzpOrder.status === 'paid' && order.paymentStatus !== 'completed') {
                    order.paymentStatus = 'completed';
                    order.status = 'confirmed';
                    await order.save();
                }
            } catch (razorpayError) {
                console.error('Razorpay fetch error:', razorpayError.message);
            }
        }

        res.json({
            success: true,
            data: {
                orderId: order.orderId,
                paymentStatus: order.paymentStatus,
                orderStatus: order.status,
                amount: order.totalAmount,
                paymentMethod: order.paymentMethod,
                razorpayStatus
            }
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.retryPayment = async (req, res) => {
    try {
        const { orderId } = req.params;

        const order = await require('../models/Order').findOne({
            orderId,
            customer: req.user._id
        });

        if (!order) {
            return res.status(404).json({ success: false, error: 'Order not found' });
        }

        if (order.paymentStatus === 'completed') {
            return res.status(400).json({ success: false, error: 'Payment is already completed for this order' });
        }

        if (!['pending', 'failed'].includes(order.paymentStatus)) {
            return res.status(400).json({ success: false, error: `Cannot retry payment for status: ${order.paymentStatus}` });
        }

        const { razorpay } = require('../config/razorpay');

        const razorpayOrder = await razorpay.orders.create({
            amount: order.totalAmount * 100,
            currency: 'INR',
            receipt: `retry_${order.orderId}_${Date.now()}`,
            notes: { originalOrderId: order.orderId, userId: req.user._id.toString() }
        });

        order.razorpayOrderId = razorpayOrder.id;
        order.paymentStatus = 'pending';
        await order.save();

        res.json({
            success: true,
            message: 'New payment session created',
            data: {
                razorpayOrderId: razorpayOrder.id,
                amount: razorpayOrder.amount,
                currency: razorpayOrder.currency,
                keyId: process.env.RAZORPAY_KEY_ID,
                orderId: order.orderId
            }
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};
