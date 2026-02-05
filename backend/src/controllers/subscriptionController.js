const Subscription = require('../models/Subscription');

exports.createSubscription = async (req, res) => {
    try {
        const userId = req.user.id;
        // ... body validation ...
        const subscription = await Subscription.create({
            ...req.body,
            user: userId
        });

        res.status(201).json({
            success: true,
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
            .populate('items.product', 'name primaryImage');

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

        subscription.status = status;
        if (pausedUntil) subscription.pausedUntil = pausedUntil;

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
