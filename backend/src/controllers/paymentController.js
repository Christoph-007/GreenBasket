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
