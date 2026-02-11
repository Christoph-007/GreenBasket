const MEMBERSHIP_PLANS = {
    basic: {
        name: 'Basic',
        price: 0,
        durationDays: 0,
        description: 'Free tier with standard features',
        benefits: {
            freeDelivery: false,
            freeDeliveryThreshold: 499,
            prioritySupport: false,
            exclusiveDeals: false,
            earlyAccess: false,
            bonusLoyaltyPointsPercent: 0,
            maxWalletBalance: 5000,
            couponLimit: 1
        }
    },
    premium: {
        name: 'Premium',
        price: 199,
        durationDays: 30,
        description: 'Monthly plan with enhanced benefits',
        benefits: {
            freeDelivery: true,
            freeDeliveryThreshold: 0,
            prioritySupport: true,
            exclusiveDeals: true,
            earlyAccess: false,
            bonusLoyaltyPointsPercent: 10,
            maxWalletBalance: 10000,
            couponLimit: 3
        },
        badge: 'PREMIUM',
        color: '#FFD700'
    },
    premium_plus: {
        name: 'Premium Plus',
        price: 499,
        durationDays: 90,
        description: 'Quarterly plan with all premium benefits',
        benefits: {
            freeDelivery: true,
            freeDeliveryThreshold: 0,
            prioritySupport: true,
            exclusiveDeals: true,
            earlyAccess: true,
            bonusLoyaltyPointsPercent: 20,
            maxWalletBalance: 25000,
            couponLimit: 5
        },
        badge: 'PREMIUM+',
        color: '#9B59B6'
    }
};

function getPlanConfig(planName) {
    return MEMBERSHIP_PLANS[planName] || MEMBERSHIP_PLANS.basic;
}

function getPlanBenefit(planName, benefit) {
    const plan = MEMBERSHIP_PLANS[planName] || MEMBERSHIP_PLANS.basic;
    return plan.benefits[benefit];
}

module.exports = {
    MEMBERSHIP_PLANS,
    getPlanConfig,
    getPlanBenefit
};
