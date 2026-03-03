const Membership = require('../models/Membership');
const Product = require('../models/Product');
const { stripe } = require('../config/stripe');
const paymentService = require('../services/paymentService');

// Plan configurations
const PLANS = {
    basic: {
        price: 0,
        durationDays: 0,
        benefits: {
            freeDelivery: false,
            bonusPoints: 0,
            exclusiveDeals: false,
            earlyAccess: false
        },
        description: 'Free basic membership'
    },
    premium: {
        price: 199,
        durationDays: 30,
        benefits: {
            freeDelivery: true,
            bonusPoints: 10,
            exclusiveDeals: true,
            earlyAccess: false
        },
        description: 'Monthly premium membership with free delivery and exclusive deals'
    },
    premium_plus: {
        price: 499,
        durationDays: 90,
        benefits: {
            freeDelivery: true,
            bonusPoints: 20,
            exclusiveDeals: true,
            earlyAccess: true,
            prioritySupport: true
        },
        description: 'Quarterly premium plus membership with all benefits'
    }
    // Note: Stripe Price IDs could be here if using Subscriptions API
};

/**
 * @desc    Get all membership plans
 * @route   GET /api/membership/plans
 * @access  Public
 */
exports.getPlans = async (req, res) => {
    try {
        res.json({
            success: true,
            data: {
                plans: PLANS
            }
        });
    } catch (error) {
        console.error('Get plans error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch membership plans',
            details: error.message
        });
    }
};

/**
 * @desc    Get user's current membership
 * @route   GET /api/membership
 * @access  Private (User)
 */
exports.getMembership = async (req, res) => {
    try {
        let membership = await Membership.findOne({ user: req.user._id });

        // Create basic membership if doesn't exist
        if (!membership) {
            membership = await Membership.create({
                user: req.user._id,
                plan: 'basic',
                status: 'active'
            });
        }

        // Check and update expiry
        if (membership.checkExpiry()) {
            await membership.save();
        }

        const planConfig = PLANS[membership.plan];

        res.json({
            success: true,
            data: {
                membership,
                planDetails: planConfig,
                isActive: membership.isActive
            }
        });
    } catch (error) {
        console.error('Get membership error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch membership',
            details: error.message
        });
    }
};

/**
 * @desc    Subscribe to a premium plan (Legacy/Manual entry)
 * @route   POST /api/membership/subscribe
 * @access  Private (User)
 */
exports.subscribeToPlan = async (req, res) => {
    try {
        const { plan, paymentIntentId, subscriptionId } = req.body;

        // Validate plan
        if (!PLANS[plan] || plan === 'basic') {
            return res.status(400).json({
                success: false,
                error: 'Invalid plan selected'
            });
        }

        // Verify payment intent status via Stripe if provided
        if (paymentIntentId) {
            const pi = await paymentService.getPaymentIntent(paymentIntentId);
            if (pi.status !== 'succeeded') {
                return res.status(400).json({ success: false, error: 'Payment not successful' });
            }
        }

        const planConfig = PLANS[plan];
        const startDate = new Date();
        const endDate = new Date(Date.now() + planConfig.durationDays * 24 * 60 * 60 * 1000);

        // Find or create membership
        let membership = await Membership.findOne({ user: req.user._id });

        if (membership) {
            // Update existing membership
            membership.plan = plan;
            membership.status = 'active';
            membership.startDate = startDate;
            membership.endDate = endDate;
            membership.stripePaymentIntentId = paymentIntentId;
            membership.stripeSubscriptionId = subscriptionId;
            membership.autoRenew = true;

            // Add to payment history
            membership.paymentHistory.push({
                amount: planConfig.price,
                stripePaymentIntentId: paymentIntentId,
                date: new Date(),
                status: 'success'
            });

            await membership.save();
        } else {
            // Create new membership
            membership = await Membership.create({
                user: req.user._id,
                plan,
                status: 'active',
                startDate,
                endDate,
                stripePaymentIntentId: paymentIntentId,
                stripeSubscriptionId: subscriptionId,
                autoRenew: true,
                paymentHistory: [{
                    amount: planConfig.price,
                    stripePaymentIntentId: paymentIntentId,
                    status: 'success'
                }]
            });
        }

        // Send notification
        try {
            const notificationService = require('../services/notification');
            await notificationService.send(req.user._id, 'User', {
                type: 'membership_activated',
                title: 'Premium Membership Activated!',
                message: `Your ${plan.replace('_', ' ')} membership is now active. Enjoy exclusive benefits!`,
                channels: ['push', 'email']
            });
        } catch (notifError) {
            console.error('Notification error:', notifError);
        }

        res.json({
            success: true,
            message: 'Subscribed successfully',
            data: {
                membership,
                planDetails: planConfig
            }
        });
    } catch (error) {
        console.error('Subscribe to plan error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to subscribe to plan',
            details: error.message
        });
    }
};

/**
 * @desc    Cancel membership
 * @route   POST /api/membership/cancel
 * @access  Private (User)
 */
exports.cancelMembership = async (req, res) => {
    try {
        const membership = await Membership.findOne({ user: req.user._id });

        if (!membership) {
            return res.status(404).json({
                success: false,
                error: 'Membership not found'
            });
        }

        if (membership.plan === 'basic') {
            return res.status(400).json({
                success: false,
                error: 'Cannot cancel basic membership'
            });
        }

        membership.status = 'cancelled';
        membership.autoRenew = false;
        await membership.save();

        if (membership.stripeSubscriptionId) {
            try {
                await stripe.subscriptions.cancel(membership.stripeSubscriptionId);
            } catch (err) {
                console.error('Stripe subscription cancel error:', err);
                // Continue anyway as local status is updated
            }
        }

        res.json({
            success: true,
            message: 'Membership cancelled successfully. You can continue using premium benefits until the end date.',
            data: {
                membership
            }
        });
    } catch (error) {
        console.error('Cancel membership error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to cancel membership',
            details: error.message
        });
    }
};

/**
 * @desc    Get premium exclusive products
 * @route   GET /api/membership/premium-products
 * @access  Private (User)
 */
exports.getPremiumProducts = async (req, res) => {
    try {
        const { page = 1, limit = 20 } = req.query;
        const skip = (page - 1) * limit;

        // Check user's membership
        const membership = await Membership.findOne({
            user: req.user._id,
            status: 'active'
        });

        const hasPremiumAccess = membership &&
            (membership.plan === 'premium' || membership.plan === 'premium_plus') &&
            membership.isActive;

        if (!hasPremiumAccess) {
            return res.status(403).json({
                success: false,
                error: 'Premium membership required to access exclusive products'
            });
        }

        const now = new Date();
        const premiumQuery = {
            isActive: true,
            premiumAccessStartDate: { $lte: now },
            $or: [
                { isPremiumExclusive: true },
                { premiumAccessEndDate: { $gt: now } }
            ]
        };

        const [products, total] = await Promise.all([
            Product.find(premiumQuery)
                .populate('merchant', 'businessName averageRating')
                .populate('category', 'name')
                .skip(skip)
                .limit(parseInt(limit))
                .sort({ createdAt: -1 }),
            Product.countDocuments(premiumQuery)
        ]);

        res.json({
            success: true,
            data: {
                products,
                pagination: {
                    page: parseInt(page),
                    limit: parseInt(limit),
                    total,
                    pages: Math.ceil(total / limit)
                }
            }
        });
    } catch (error) {
        console.error('Get premium products error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch premium products',
            details: error.message
        });
    }
};

/**
 * @desc    Check if user has a specific benefit
 * @route   GET /api/membership/check-benefit
 * @access  Private (User)
 */
exports.checkBenefit = async (req, res) => {
    try {
        const { benefit } = req.query;

        if (!benefit) {
            return res.status(400).json({
                success: false,
                error: 'Benefit parameter is required'
            });
        }

        const membership = await Membership.findOne({
            user: req.user._id,
            status: 'active'
        });

        if (!membership || !membership.isActive) {
            return res.json({
                success: true,
                data: {
                    hasBenefit: false,
                    membershipPlan: 'none'
                }
            });
        }

        const planConfig = PLANS[membership.plan];
        const hasBenefit = planConfig?.benefits[benefit] || false;

        res.json({
            success: true,
            data: {
                hasBenefit,
                membershipPlan: membership.plan,
                benefitValue: planConfig?.benefits[benefit]
            }
        });
    } catch (error) {
        console.error('Check benefit error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to check benefit',
            details: error.message
        });
    }
};

exports.initiateMembership = async (req, res) => {
    try {
        const { plan } = req.body;

        if (!plan || !['premium', 'premium_plus'].includes(plan)) {
            return res.status(400).json({
                success: false,
                error: 'plan must be premium or premium_plus'
            });
        }

        const { MEMBERSHIP_PLANS } = require('../config/membershipPlans');
        // Note: Check if membershipPlans exists, otherwise fallback to local PLANS
        const planConfig = PLANS[plan] || (MEMBERSHIP_PLANS ? MEMBERSHIP_PLANS[plan] : null);

        if (!planConfig) {
            return res.status(400).json({ success: false, error: 'Invalid plan config' });
        }

        // Check if user already has active membership of same plan
        const existingMembership = await Membership.findOne({
            user: req.user._id,
            plan,
            status: 'active',
            endDate: { $gt: new Date() }
        });

        if (existingMembership) {
            return res.status(400).json({
                success: false,
                error: `You already have an active ${planConfig.description || plan} membership`,
                endDate: existingMembership.endDate
            });
        }

        // Create Stripe Payment Intent
        const paymentIntent = await paymentService.createPaymentIntent(
            planConfig.price,
            `membership_${req.user._id}_${Date.now()}`,
            req.user._id.toString(),
            {
                plan,
                type: 'membership'
            }
        );

        res.json({
            success: true,
            message: 'Membership payment initiated',
            data: {
                paymentIntentId: paymentIntent.id,
                clientSecret: paymentIntent.client_secret,
                amount: planConfig.price,
                currency: 'INR',
                planDetails: {
                    name: plan,
                    price: planConfig.price,
                    durationDays: planConfig.durationDays,
                    benefits: planConfig.benefits
                }
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to initiate membership payment',
            details: error.message
        });
    }
};

exports.activateMembership = async (req, res) => {
    try {
        const {
            plan,
            paymentIntentId
        } = req.body;

        if (!plan || !paymentIntentId) {
            return res.status(400).json({
                success: false,
                error: 'plan and paymentIntentId are required'
            });
        }

        if (!['premium', 'premium_plus'].includes(plan)) {
            return res.status(400).json({ success: false, error: 'Invalid plan' });
        }

        // Check payment status with Stripe
        const paymentIntent = await paymentService.getPaymentIntent(paymentIntentId);

        if (paymentIntent.status !== 'succeeded') {
            return res.status(400).json({
                success: false,
                error: 'Payment not successful'
            });
        }

        const { MEMBERSHIP_PLANS } = require('../config/membershipPlans');
        // Fallback to local if config missing (though it likely exists)
        const planConfig = PLANS[plan]; // Use local constant for reliability in this snippet

        const startDate = new Date();
        const endDate = new Date(Date.now() + planConfig.durationDays * 24 * 60 * 60 * 1000);

        let membership = await Membership.findOne({ user: req.user._id });

        if (membership) {
            // Archive old plan to renewal history
            if (membership.plan !== 'basic') {
                if (!membership.renewalHistory) membership.renewalHistory = [];
                membership.renewalHistory.push({
                    plan: membership.plan,
                    startDate: membership.startDate,
                    endDate: membership.endDate,
                    stripePaymentIntentId: membership.stripePaymentIntentId,
                    amount: PLANS[membership.plan]?.price || 0,
                    renewedAt: new Date()
                });
            }

            membership.previousPlan = membership.plan;
            membership.plan = plan;
            membership.status = 'active';
            membership.startDate = startDate;
            membership.endDate = endDate;
            membership.stripePaymentIntentId = paymentIntentId;
            membership.autoRenew = true;

            await membership.save();
        } else {
            membership = await Membership.create({
                user: req.user._id,
                plan,
                status: 'active',
                startDate,
                endDate,
                stripePaymentIntentId: paymentIntentId,
                autoRenew: true
            });
        }

        const notificationService = require('../services/notification');
        await notificationService.send(
            req.user._id,
            'User',
            {
                type: 'wallet_credit', // Using generic type
                title: `${plan} Membership Activated!`,
                message: `Welcome to ${plan}! Your membership is active until ${endDate.toDateString()}`,
                channels: ['push', 'email'],
                data: { plan, endDate }
            }
        );

        res.json({
            success: true,
            message: `${plan} membership activated successfully`,
            data: {
                plan,
                startDate,
                endDate,
                daysRemaining: planConfig.durationDays,
                benefits: planConfig.benefits
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to activate membership',
            details: error.message
        });
    }
};

exports.getMembershipHistory = async (req, res) => {
    try {
        const membership = await Membership.findOne({ user: req.user._id });

        if (!membership) {
            return res.json({
                success: true,
                data: { currentPlan: 'basic', renewalHistory: [], totalSpent: 0 }
            });
        }

        const totalSpent = (membership.renewalHistory || []).reduce((sum, h) => sum + (h.amount || 0), 0);

        res.json({
            success: true,
            data: {
                currentPlan: membership.plan,
                status: membership.status,
                startDate: membership.startDate,
                endDate: membership.endDate,
                autoRenew: membership.autoRenew,
                renewalHistory: membership.renewalHistory,
                totalSpent
            }
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.getAllMemberships = async (req, res) => {
    try {
        const { plan, status, page = 1, limit = 20 } = req.query;

        const query = {};
        if (plan) query.plan = plan;
        if (status) query.status = status;

        const skip = (page - 1) * limit;

        const [memberships, total] = await Promise.all([
            Membership.find(query)
                .populate('user', 'name email phone')
                .sort({ createdAt: -1 })
                .skip(skip)
                .limit(parseInt(limit)),
            Membership.countDocuments(query)
        ]);

        // Simple calculation fallback
        const activeNow = await Membership.find({
            plan: { $in: ['premium', 'premium_plus'] },
            status: 'active',
            endDate: { $gt: new Date() }
        });

        const premiumCount = activeNow.filter(m => m.plan === 'premium').length;
        const premiumPlusCount = activeNow.filter(m => m.plan === 'premium_plus').length;

        const monthlyRevenue =
            (premiumCount * PLANS.premium.price) +
            (premiumPlusCount * (PLANS.premium_plus.price / 3));

        res.json({
            success: true,
            data: {
                memberships,
                stats: {
                    totalActivePremium: premiumCount,
                    totalActivePremiumPlus: premiumPlusCount,
                    estimatedMonthlyRevenue: Math.round(monthlyRevenue)
                },
                pagination: { page: parseInt(page), limit: parseInt(limit), total, pages: Math.ceil(total / limit) }
            }
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};
