const GiftCard = require('../models/GiftCard');
const Order = require('../models/Order');
const Razorpay = require('razorpay');
const crypto = require('crypto');

const razorpay = new Razorpay({
    key_id: process.env.RAZORPAY_KEY_ID,
    key_secret: process.env.RAZORPAY_KEY_SECRET
});

/**
 * @desc    Generate gift card (Admin)
 * @route   POST /api/gift-cards/admin/generate
 * @access  Private (Admin)
 */
exports.generateGiftCard = async (req, res) => {
    try {
        const { amount, type, expiryDate, purchasedFor, message, minOrderValue, quantity = 1 } = req.body;

        if (!amount || !expiryDate) {
            return res.status(400).json({
                success: false,
                error: 'amount and expiryDate are required'
            });
        }

        if (amount <= 0) {
            return res.status(400).json({
                success: false,
                error: 'Amount must be greater than 0'
            });
        }

        if (quantity < 1 || quantity > 100) {
            return res.status(400).json({
                success: false,
                error: 'Quantity must be between 1 and 100'
            });
        }

        const giftCards = [];

        for (let i = 0; i < quantity; i++) {
            const giftCard = await GiftCard.create({
                amount,
                originalAmount: amount,
                type: type || 'gift_card',
                expiryDate: new Date(expiryDate),
                purchasedFor,
                message,
                minOrderValue: minOrderValue || 0
            });

            giftCards.push(giftCard);
        }

        res.status(201).json({
            success: true,
            message: `${quantity} gift card(s) generated successfully`,
            data: {
                giftCards: giftCards.map(gc => ({
                    _id: gc._id,
                    code: gc.code,
                    amount: gc.amount,
                    expiryDate: gc.expiryDate,
                    type: gc.type
                }))
            }
        });
    } catch (error) {
        console.error('Generate gift card error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to generate gift card',
            details: error.message
        });
    }
};

/**
 * @desc    Validate gift card
 * @route   POST /api/gift-cards/validate
 * @access  Private (User)
 */
exports.validateGiftCard = async (req, res) => {
    try {
        const { code } = req.body;

        if (!code) {
            return res.status(400).json({
                success: false,
                error: 'Gift card code is required'
            });
        }

        const giftCard = await GiftCard.findOne({ code: code.toUpperCase() });

        if (!giftCard) {
            return res.status(404).json({
                success: false,
                error: 'Invalid gift card code'
            });
        }

        // Check status
        if (giftCard.status === 'used') {
            return res.status(400).json({
                success: false,
                error: 'Gift card has already been fully used',
                data: { status: 'used', redeemedAt: giftCard.redeemedAt }
            });
        }

        if (giftCard.status === 'cancelled') {
            return res.status(400).json({
                success: false,
                error: 'Gift card has been cancelled'
            });
        }

        if (giftCard.status === 'expired' || giftCard.expiryDate < new Date()) {
            if (giftCard.status !== 'expired') {
                giftCard.status = 'expired';
                await giftCard.save();
            }
            return res.status(400).json({
                success: false,
                error: 'Gift card has expired',
                data: { expiryDate: giftCard.expiryDate }
            });
        }

        if (giftCard.amount === 0) {
            return res.status(400).json({
                success: false,
                error: 'Gift card balance is zero'
            });
        }

        res.json({
            success: true,
            message: 'Gift card is valid',
            data: {
                code: giftCard.code,
                balance: giftCard.amount,
                originalAmount: giftCard.originalAmount,
                minOrderValue: giftCard.minOrderValue,
                expiryDate: giftCard.expiryDate,
                type: giftCard.type
            }
        });
    } catch (error) {
        console.error('Validate gift card error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to validate gift card',
            details: error.message
        });
    }
};

/**
 * @desc    Redeem gift card
 * @route   POST /api/gift-cards/redeem
 * @access  Private (User)
 */
exports.redeemGiftCard = async (req, res) => {
    try {
        const { code, orderId } = req.body;

        if (!code || !orderId) {
            return res.status(400).json({
                success: false,
                error: 'code and orderId are required'
            });
        }

        const giftCard = await GiftCard.findOne({ code: code.toUpperCase() });

        if (!giftCard) {
            return res.status(404).json({
                success: false,
                error: 'Invalid gift card code'
            });
        }

        // Validate gift card
        if (giftCard.status !== 'active') {
            return res.status(400).json({
                success: false,
                error: `Gift card is ${giftCard.status}`
            });
        }

        if (giftCard.expiryDate < new Date()) {
            giftCard.status = 'expired';
            await giftCard.save();
            return res.status(400).json({
                success: false,
                error: 'Gift card has expired'
            });
        }

        if (giftCard.amount === 0) {
            return res.status(400).json({
                success: false,
                error: 'Gift card balance is zero'
            });
        }

        // Find order
        const order = await Order.findOne({ orderId, customer: req.user._id });

        if (!order) {
            return res.status(404).json({
                success: false,
                error: 'Order not found'
            });
        }

        // Check minimum order value
        if (giftCard.minOrderValue && order.totalAmount < giftCard.minOrderValue) {
            return res.status(400).json({
                success: false,
                error: `Minimum order value ₹${giftCard.minOrderValue} required to use this gift card`,
                currentTotal: order.totalAmount,
                required: giftCard.minOrderValue
            });
        }

        // Apply gift card (partial or full)
        const amountApplied = Math.min(giftCard.amount, order.totalAmount);
        const remainingBalance = giftCard.amount - amountApplied;

        // Update gift card
        giftCard.amount = remainingBalance;
        giftCard.status = remainingBalance === 0 ? 'used' : 'active';
        giftCard.redeemedBy = req.user._id;
        giftCard.redeemedAt = new Date();
        giftCard.orderId = order._id;
        await giftCard.save();

        // Update order with discount
        order.giftCardApplied = {
            code: giftCard.code,
            amountApplied
        };
        order.totalAmount = Math.max(0, order.totalAmount - amountApplied);
        await order.save();

        // Send notification
        try {
            const notificationService = require('../services/notification');
            await notificationService.send(
                req.user._id,
                'User',
                {
                    type: 'wallet_credit',
                    title: 'Gift Card Redeemed',
                    message: `₹${amountApplied} gift card applied to your order`,
                    channels: ['push'],
                    data: { code: giftCard.code, amountApplied }
                }
            );
        } catch (notifError) {
            console.error('Notification error:', notifError);
        }

        res.json({
            success: true,
            message: 'Gift card redeemed successfully',
            data: {
                amountApplied,
                remainingBalance,
                newOrderTotal: order.totalAmount
            }
        });
    } catch (error) {
        console.error('Redeem gift card error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to redeem gift card',
            details: error.message
        });
    }
};

/**
 * @desc    Check gift card balance
 * @route   GET /api/gift-cards/balance/:code
 * @access  Public
 */
exports.checkBalance = async (req, res) => {
    try {
        const { code } = req.params;

        if (!code) {
            return res.status(400).json({
                success: false,
                error: 'Gift card code is required'
            });
        }

        const giftCard = await GiftCard.findOne({ code: code.toUpperCase() })
            .select('code amount originalAmount status expiryDate type minOrderValue');

        if (!giftCard) {
            return res.status(404).json({
                success: false,
                error: 'Gift card not found'
            });
        }

        // Auto-expire if past expiry
        if (giftCard.status === 'active' && giftCard.expiryDate < new Date()) {
            giftCard.status = 'expired';
            await giftCard.save();
        }

        res.json({
            success: true,
            data: {
                code: giftCard.code,
                balance: giftCard.amount,
                originalAmount: giftCard.originalAmount,
                status: giftCard.status,
                expiryDate: giftCard.expiryDate,
                type: giftCard.type,
                minOrderValue: giftCard.minOrderValue
            }
        });
    } catch (error) {
        console.error('Check balance error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to check balance',
            details: error.message
        });
    }
};

/**
 * @desc    Get my gift cards
 * @route   GET /api/gift-cards/my-cards
 * @access  Private (User)
 */
exports.getMyGiftCards = async (req, res) => {
    try {
        const giftCards = await GiftCard.find({
            $or: [
                { purchasedBy: req.user._id },
                { redeemedBy: req.user._id },
                { purchasedFor: req.user.email }
            ]
        })
            .select('-__v')
            .sort({ createdAt: -1 });

        // Auto-expire past expiry date
        const now = new Date();
        for (const card of giftCards) {
            if (card.status === 'active' && card.expiryDate < now) {
                card.status = 'expired';
                await card.save();
            }
        }

        const activeCards = giftCards.filter(c => c.status === 'active');
        const totalBalance = activeCards.reduce((sum, c) => sum + c.amount, 0);

        res.json({
            success: true,
            data: {
                giftCards,
                totalBalance,
                activeCount: activeCards.length
            }
        });
    } catch (error) {
        console.error('Get my gift cards error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch gift cards',
            details: error.message
        });
    }
};

/**
 * @desc    Get all gift cards (Admin)
 * @route   GET /api/gift-cards/admin/all
 * @access  Private (Admin)
 */
exports.getAllGiftCards = async (req, res) => {
    try {
        const { status, type, page = 1, limit = 20 } = req.query;

        const query = {};
        if (status) query.status = status;
        if (type) query.type = type;

        const skip = (page - 1) * limit;

        const [giftCards, total, activeCards, usedCards] = await Promise.all([
            GiftCard.find(query)
                .populate('purchasedBy', 'name email')
                .populate('redeemedBy', 'name email')
                .sort({ createdAt: -1 })
                .skip(skip)
                .limit(parseInt(limit)),
            GiftCard.countDocuments(query),
            GiftCard.find({ status: 'active' }).select('amount'),
            GiftCard.find({ status: 'used' }).select('originalAmount')
        ]);

        const totalValueActive = activeCards.reduce((sum, c) => sum + c.amount, 0);
        const totalValueRedeemed = usedCards.reduce((sum, c) => sum + c.originalAmount, 0);

        res.json({
            success: true,
            data: {
                giftCards,
                stats: {
                    totalActive: activeCards.length,
                    totalUsed: usedCards.length,
                    totalValueActive,
                    totalValueRedeemed
                },
                pagination: {
                    page: parseInt(page),
                    limit: parseInt(limit),
                    total,
                    pages: Math.ceil(total / limit)
                }
            }
        });
    } catch (error) {
        console.error('Get all gift cards error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch gift cards',
            details: error.message
        });
    }
};

/**
 * @desc    Cancel gift card (Admin)
 * @route   PATCH /api/gift-cards/admin/:id/cancel
 * @access  Private (Admin)
 */
exports.cancelGiftCard = async (req, res) => {
    try {
        const { id } = req.params;
        const { reason } = req.body;

        if (!reason) {
            return res.status(400).json({
                success: false,
                error: 'Cancellation reason is required'
            });
        }

        const giftCard = await GiftCard.findById(id);

        if (!giftCard) {
            return res.status(404).json({
                success: false,
                error: 'Gift card not found'
            });
        }

        if (giftCard.status === 'used') {
            return res.status(400).json({
                success: false,
                error: 'Cannot cancel a used gift card'
            });
        }

        if (giftCard.status === 'cancelled') {
            return res.status(400).json({
                success: false,
                error: 'Gift card is already cancelled'
            });
        }

        giftCard.status = 'cancelled';
        await giftCard.save();

        // Notify the holder if purchased by someone
        if (giftCard.purchasedBy) {
            try {
                const notificationService = require('../services/notification');
                await notificationService.send(
                    giftCard.purchasedBy,
                    'User',
                    {
                        type: 'wallet_credit',
                        title: 'Gift Card Cancelled',
                        message: `Your gift card ${giftCard.code} has been cancelled. Reason: ${reason}`,
                        channels: ['push', 'email']
                    }
                );
            } catch (notifError) {
                console.error('Notification error:', notifError);
            }
        }

        res.json({
            success: true,
            message: 'Gift card cancelled successfully',
            data: {
                code: giftCard.code,
                status: giftCard.status
            }
        });
    } catch (error) {
        console.error('Cancel gift card error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to cancel gift card',
            details: error.message
        });
    }
};

/**
 * @desc    Initiate gift card purchase
 * @route   POST /api/gift-cards/purchase/initiate
 * @access  Private (User)
 */
exports.initiatePurchase = async (req, res) => {
    try {
        const { amount, currency = 'INR' } = req.body;

        if (!amount || amount < 100) {
            return res.status(400).json({
                success: false,
                error: 'Minimum amount is ₹100'
            });
        }

        const options = {
            amount: amount * 100, // paise
            currency,
            receipt: `gift_rcpt_${Date.now()}`,
            notes: {
                type: 'gift_card'
            }
        };

        const order = await razorpay.orders.create(options);

        res.json({
            success: true,
            orderId: order.id,
            amount: order.amount,
            currency: order.currency,
            key: process.env.RAZORPAY_KEY_ID
        });
    } catch (error) {
        console.error('Initiate purchase error:', error);
        res.status(500).json({ success: false, error: 'Failed to initiate purchase' });
    }
};

/**
 * @desc    Verify gift card purchase payment
 * @route   POST /api/gift-cards/purchase/verify
 * @access  Private (User)
 */
exports.verifyPurchase = async (req, res) => {
    try {
        const { razorpay_order_id, razorpay_payment_id, razorpay_signature, amount, recipientEmail, message } = req.body;

        const body = razorpay_order_id + "|" + razorpay_payment_id;
        const expectedSignature = crypto
            .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
            .update(body.toString())
            .digest('hex');

        if (expectedSignature === razorpay_signature) {
            const giftCard = await GiftCard.create({
                amount,
                originalAmount: amount,
                purchasedBy: req.user._id,
                purchasedFor: recipientEmail || req.user.email,
                message,
                expiryDate: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000) // 1 year validity
            });

            // Send notification
            const notificationService = require('../services/notification');
            await notificationService.send(req.user._id, 'User', {
                type: 'wallet_credit',
                title: 'Gift Card Purchased',
                message: `You purchased a gift card for ₹${amount}`,
                data: { code: giftCard.code }
            });

            res.json({
                success: true,
                message: 'Payment verified and Gift Card created',
                data: giftCard
            });
        } else {
            res.status(400).json({ success: false, error: 'Invalid payment signature' });
        }
    } catch (error) {
        console.error('Verify purchase error:', error);
        res.status(500).json({ success: false, error: 'Payment verification failed' });
    }
};

module.exports = exports;
