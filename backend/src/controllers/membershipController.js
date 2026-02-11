const Membership = require('../models/Membership');
const Product = require('../models/Product');

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
 * @desc    Subscribe to a premium plan
 * @route   POST /api/membership/subscribe
 * @access  Private (User)
 */
exports.subscribeToPlan = async (req, res) => {
    try {
        const { plan, paymentId, razorpaySubscriptionId } = req.body;

        // Validate plan
        if (!PLANS[plan] || plan === 'basic') {
            return res.status(400).json({
                success: false,
                error: 'Invalid plan selected'
            });
        }

        if (!paymentId) {
            return res.status(400).json({
                success: false,
                error: 'Payment ID is required'
            });
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
            membership.paymentId = paymentId;
            membership.razorpaySubscriptionId = razorpaySubscriptionId;
            membership.autoRenew = true;

            // Add to payment history
            membership.paymentHistory.push({
                amount: planConfig.price,
                paymentId,
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
                paymentId,
                razorpaySubscriptionId,
                autoRenew: true,
                paymentHistory: [{
                    amount: planConfig.price,
                    paymentId,
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

        const [products, total] = await Promise.all([
            Product.find({
                isPremiumExclusive: true,
                isActive: true
            })
                .populate('merchant', 'businessName averageRating')
                .populate('category', 'name')
                .skip(skip)
                .limit(parseInt(limit))
                .sort({ createdAt: -1 }),
            Product.countDocuments({
                isPremiumExclusive: true,
                isActive: true
            })
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


// Note: All functions are already exported using exports.functionName above
// No need for module.exports here

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
        const planConfig = MEMBERSHIP_PLANS[plan];

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
                error: `You already have an active ${planConfig.name} membership`,
                endDate: existingMembership.endDate
            });
        }

        // Create Razorpay order
        const { razorpay } = require('../config/razorpay');

        const razorpayOrder = await razorpay.orders.create({
            amount: planConfig.price * 100,
            currency: 'INR',
            receipt: `membership_${req.user._id}_${plan}_${Date.now()}`,
            notes: {
                userId: req.user._id.toString(),
                plan,
                type: 'membership'
            }
        });

        res.json({
            success: true,
            message: 'Membership payment initiated',
            data: {
                razorpayOrderId: razorpayOrder.id,
                amount: razorpayOrder.amount,
                currency: razorpayOrder.currency,
                keyId: process.env.RAZORPAY_KEY_ID,
                planDetails: {
                    name: planConfig.name,
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
            razorpay_order_id,
            razorpay_payment_id,
            razorpay_signature
        } = req.body;

        if (!plan || !razorpay_order_id || !razorpay_payment_id || !razorpay_signature) {
            return res.status(400).json({
                success: false,
                error: 'plan, razorpay_order_id, razorpay_payment_id, and razorpay_signature are all required'
            });
        }

        if (!['premium', 'premium_plus'].includes(plan)) {
            return res.status(400).json({ success: false, error: 'Invalid plan' });
        }

        // ─── CRITICAL: Verify Razorpay payment signature ───
        const crypto = require('crypto');
        const generatedSignature = crypto
            .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
            .update(`${razorpay_order_id}|${razorpay_payment_id}`)
            .digest('hex');

        if (generatedSignature !== razorpay_signature) {
            return res.status(400).json({
                success: false,
                error: 'Payment verification failed. Invalid signature.'
            });
        }
        // ───────────────────────────────────────────────────

        const { MEMBERSHIP_PLANS, getPlanConfig } = require('../config/membershipPlans');
        const planConfig = getPlanConfig(plan);

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
                    paymentId: membership.paymentId,
                    amount: getPlanConfig(membership.plan).price,
                    renewedAt: new Date()
                });
            }

            membership.previousPlan = membership.plan;
            membership.plan = plan;
            membership.status = 'active';
            membership.startDate = startDate;
            membership.endDate = endDate;
            membership.paymentId = razorpay_payment_id;
            membership.razorpayOrderId = razorpay_order_id;
            membership.autoRenew = true;

            await membership.save();
        } else {
            membership = await Membership.create({
                user: req.user._id,
                plan,
                status: 'active',
                startDate,
                endDate,
                paymentId: razorpay_payment_id,
                razorpayOrderId: razorpay_order_id,
                autoRenew: true
            });
        }

        const notificationService = require('../services/notification');
        await notificationService.send(
            req.user._id,
            'User',
            {
                type: 'wallet_credit', // Using generic type or specific if supported
                title: `${planConfig.name} Membership Activated!`,
                message: `Welcome to ${planConfig.name}! Your membership is active until ${endDate.toDateString()}`,
                channels: ['push', 'email'],
                data: { plan, endDate }
            }
        );

        res.json({
            success: true,
            message: `${planConfig.name} membership activated successfully`,
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

        const { MEMBERSHIP_PLANS } = require('../config/membershipPlans');

        const activeNow = await Membership.find({
            plan: { $in: ['premium', 'premium_plus'] },
            status: 'active',
            endDate: { $gt: new Date() }
        });

        const premiumCount = activeNow.filter(m => m.plan === 'premium').length;
        const premiumPlusCount = activeNow.filter(m => m.plan === 'premium_plus').length;

        const monthlyRevenue =
            (premiumCount * MEMBERSHIP_PLANS.premium.price) +
            (premiumPlusCount * (MEMBERSHIP_PLANS.premium_plus.price / 3));

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

