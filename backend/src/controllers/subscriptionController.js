const Subscription = require('../models/Subscription');
const Product = require('../models/Product');

// Helper calculate next delivery date
const calculateNextDelivery = (frequency, startDate, deliveryDay) => {
    let nextDate = new Date(startDate);
    const dayMap = {
        'sunday': 0, 'monday': 1, 'tuesday': 2, 'wednesday': 3,
        'thursday': 4, 'friday': 5, 'saturday': 6
    };

    if (nextDate < new Date()) {
        nextDate = new Date(); // Start from today if startDate is past
    }

    if (frequency === 'daily') {
        nextDate.setDate(nextDate.getDate() + 1);
    } else if (frequency === 'weekly' || frequency === 'bi-weekly') {
        const targetDay = dayMap[deliveryDay.toLowerCase()];
        const currentDay = nextDate.getDay();
        let daysUntil = (targetDay - currentDay + 7) % 7;
        if (daysUntil === 0) daysUntil = 7; // Delivery is next occurrence, not today

        nextDate.setDate(nextDate.getDate() + daysUntil);

        if (frequency === 'bi-weekly') {
            nextDate.setDate(nextDate.getDate() + 7); // Skip one week? Or simply +14 days cycle? 
            // Usually bi-weekly means every 2 weeks. So +14 days from start? 
            // Logic: Find next correct day, then add 0 if it's first week, 7 if second. 
            // Simple approach: Next occurrence + 7 days.
        }
    } else if (frequency === 'monthly') {
        nextDate.setMonth(nextDate.getMonth() + 1);
    }

    return nextDate;
};

exports.createSubscription = async (req, res) => {
    try {
        const userId = req.user.id;
        const {
            name,
            items,
            frequency,
            deliveryDay,
            deliveryTime,
            deliveryAddress,
            startDate
        } = req.body;

        if (!items || items.length === 0) {
            return res.status(400).json({ success: false, error: 'Items required' });
        }

        // Validate products and calculate price
        let totalPrice = 0;
        const subscriptionItems = [];
        let merchantId = null;

        for (const item of items) {
            const product = await Product.findById(item.product);
            if (!product) {
                return res.status(400).json({ success: false, error: `Product ${item.product} not found` });
            }

            // Ensure single merchant (simplification)
            if (merchantId && merchantId.toString() !== product.merchant.toString()) {
                return res.status(400).json({ success: false, error: 'Subscription items must be from the same merchant' });
            }
            merchantId = product.merchant;

            totalPrice += product.price * item.quantity;
            subscriptionItems.push({
                product: product._id,
                quantity: item.quantity,
                preparation: item.preparation
            });
        }

        const start = startDate ? new Date(startDate) : new Date();
        const nextDelivery = calculateNextDelivery(frequency, start, deliveryDay || 'monday');

        const subscription = await Subscription.create({
            user: userId,
            merchant: merchantId,
            name,
            frequency,
            items: subscriptionItems,
            deliveryDay,
            deliveryTime,
            deliveryAddress,
            price: totalPrice,
            startDate: start,
            nextDelivery,
            status: 'active'
        });

        res.status(201).json({
            success: true,
            message: 'Subscription created successfully',
            data: subscription
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error creating subscription',
            error: error.message
        });
    }
};

exports.getMySubscriptions = async (req, res) => {
    try {
        const subscriptions = await Subscription.find({ user: req.user.id })
            .populate('merchant', 'businessName')
            .populate('items.product', 'name primaryImage price unit')
            .populate('deliveryAddress') // Ensure address populated
            .sort({ createdAt: -1 });

        res.json({
            success: true,
            data: subscriptions
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching subscriptions',
            error: error.message
        });
    }
};

exports.updateSubscriptionStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const { status, pausedUntil } = req.body;

        const subscription = await Subscription.findOne({ _id: id, user: req.user.id });
        if (!subscription) {
            return res.status(404).json({ message: 'Subscription not found' });
        }

        if (status === 'paused') {
            subscription.status = 'paused';
            if (pausedUntil) {
                subscription.pausedUntil = new Date(pausedUntil);
                // Should we clear nextDelivery? Usually kept or shifted.
                // Logic: nextDelivery should be after pausedUntil.
                if (subscription.nextDelivery < subscription.pausedUntil) {
                    subscription.nextDelivery = calculateNextDelivery(
                        subscription.frequency,
                        subscription.pausedUntil,
                        subscription.deliveryDay
                    );
                }
            } else {
                subscription.pausedUntil = null; // Paused indefinitely
                subscription.nextDelivery = null;
            }
        } else if (status === 'active') {
            subscription.status = 'active';
            subscription.pausedUntil = null;
            // Recalculate next delivery from today
            subscription.nextDelivery = calculateNextDelivery(
                subscription.frequency,
                new Date(),
                subscription.deliveryDay
            );
        } else if (status === 'cancelled') {
            subscription.status = 'cancelled';
            subscription.nextDelivery = null;
            subscription.pausedUntil = null;
        }

        await subscription.save();

        res.json({
            success: true,
            message: `Subscription ${status}`,
            data: subscription
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error updating subscription',
            error: error.message
        });
    }
};

exports.getSubscriptionById = async (req, res) => {
    try {
        const subscription = await Subscription.findById(req.params.id)
            .populate('items.product', 'name primaryImage price unit')
            .populate('merchant', 'businessName logo');

        if (!subscription) {
            return res.status(404).json({ success: false, error: 'Subscription not found' });
        }

        const isOwner = subscription.user.toString() === req.user._id.toString();
        const isMerchant = subscription.merchant._id.toString() === req.user._id.toString();
        const isAdmin = req.user.userType === 'admin';

        if (!isOwner && !isMerchant && !isAdmin) {
            return res.status(403).json({ success: false, error: 'Access denied' });
        }

        res.json({ success: true, data: { subscription } });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

/**
 * @desc    Update subscription
 * @route   PUT /api/subscriptions/:id
 * @access  Private (User)
 */
exports.updateSubscription = async (req, res) => {
    try {
        const { frequency, deliveryAddress, items, deliveryTime } = req.body;

        const subscription = await Subscription.findOne({
            _id: req.params.id,
            user: req.user._id
        });

        if (!subscription) {
            return res.status(404).json({ success: false, error: 'Subscription not found or access denied' });
        }

        if (subscription.status === 'cancelled') {
            return res.status(400).json({ success: false, error: 'Cannot update a cancelled subscription' });
        }

        if (frequency && ['daily', 'weekly', 'biweekly', 'monthly'].includes(frequency)) {
            subscription.frequency = frequency;

            // Recalculate next delivery date
            const frequencyDays = { daily: 1, weekly: 7, biweekly: 14, monthly: 30 };
            const nextDate = new Date();
            nextDate.setDate(nextDate.getDate() + frequencyDays[frequency]);
            subscription.nextDeliveryDate = nextDate;
        }

        if (deliveryAddress) {
            subscription.deliveryAddress = deliveryAddress;
        }

        if (deliveryTime) {
            subscription.deliveryTime = deliveryTime;
        }

        if (items && items.length > 0) {
            const Product = require('../models/Product');

            for (const item of items) {
                const product = await Product.findById(item.productId);
                if (!product) {
                    return res.status(400).json({ success: false, error: `Product ${item.productId} not found` });
                }
                if (product.merchant.toString() !== subscription.merchant.toString()) {
                    return res.status(400).json({ success: false, error: 'All products must be from the same merchant' });
                }
                if (item.quantity < 1) {
                    return res.status(400).json({ success: false, error: 'Quantity must be at least 1' });
                }
            }

            subscription.items = items.map(i => ({
                product: i.productId,
                quantity: i.quantity,
                preparationType: i.preparationType
            }));
        }

        await subscription.save();

        res.json({
            success: true,
            message: 'Subscription updated successfully',
            data: { subscription }
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

/**
 * @desc    Delete/Cancel subscription
 * @route   DELETE /api/subscriptions/:id
 * @access  Private (User)
 */
exports.deleteSubscription = async (req, res) => {
    try {
        const subscription = await Subscription.findOne({
            _id: req.params.id,
            user: req.user._id
        });

        if (!subscription) {
            return res.status(404).json({ success: false, error: 'Subscription not found or access denied' });
        }

        if (subscription.status === 'active') {
            // Soft-cancel active subscriptions
            subscription.status = 'cancelled';
            await subscription.save();

            return res.json({
                success: true,
                message: 'Subscription cancelled. It will not renew.'
            });
        }

        // Hard delete paused/cancelled subscriptions
        await subscription.deleteOne();

        res.json({
            success: true,
            message: 'Subscription deleted successfully'
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

/**
 * @desc    Get merchant's subscriptions
 * @route   GET /api/subscriptions/merchant/all
 * @access  Private (Merchant)
 */
exports.getMerchantSubscriptions = async (req, res) => {
    try {
        const { status, page = 1, limit = 20 } = req.query;

        const query = { merchant: req.user._id };
        if (status) query.status = status;

        const skip = (page - 1) * limit;

        const [subscriptions, total] = await Promise.all([
            Subscription.find(query)
                .populate('user', 'name email phone')
                .populate('items.product', 'name price unit')
                .sort({ createdAt: -1 })
                .skip(skip)
                .limit(parseInt(limit)),
            Subscription.countDocuments(query)
        ]);

        res.json({
            success: true,
            data: {
                subscriptions,
                pagination: { page: parseInt(page), limit: parseInt(limit), total, pages: Math.ceil(total / limit) }
            }
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

