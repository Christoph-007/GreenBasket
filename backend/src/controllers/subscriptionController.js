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
        const subscription = await Subscription.findOne({ _id: req.params.id, user: req.user.id })
            .populate('items.product')
            .populate('merchant', 'businessName')
            .populate('deliveryAddress');

        if (!subscription) {
            return res.status(404).json({ success: false, error: 'Subscription not found' });
        }

        res.json({ success: true, data: subscription });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};
