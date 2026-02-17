const mongoose = require('mongoose');

const membershipSchema = new mongoose.Schema({
    user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
        unique: true
    },
    plan: {
        type: String,
        enum: ['basic', 'premium', 'premium_plus'],
        default: 'basic'
    },
    status: {
        type: String,
        enum: ['active', 'cancelled', 'expired'],
        default: 'active'
    },
    startDate: {
        type: Date
    },
    endDate: {
        type: Date
    },
    autoRenew: {
        type: Boolean,
        default: true
    },
    stripePaymentIntentId: {
        type: String
    },
    stripeSubscriptionId: {
        type: String
    },
    // Payment history
    paymentHistory: [{
        amount: Number,
        stripePaymentIntentId: String, // Replaced paymentId
        date: {
            type: Date,
            default: Date.now
        },
        status: {
            type: String,
            enum: ['success', 'failed', 'pending'],
            default: 'success'
        }
    }]
}, {
    timestamps: true
});

// Index for faster queries
membershipSchema.index({ user: 1, status: 1 });
membershipSchema.index({ endDate: 1 });

// Virtual for checking if membership is active
membershipSchema.virtual('isActive').get(function () {
    if (this.status !== 'active') return false;
    if (this.plan === 'basic') return true;
    if (!this.endDate) return false;
    return new Date() <= this.endDate;
});

// Method to check if membership has expired
membershipSchema.methods.checkExpiry = function () {
    if (this.plan === 'basic') return false;
    if (this.endDate && new Date() > this.endDate && this.status === 'active') {
        this.status = 'expired';
        return true;
    }
    return false;
};

// Pre-save hook to validate dates
membershipSchema.pre('save', function (next) {
    if (this.plan !== 'basic' && this.status === 'active') {
        if (!this.startDate) {
            this.startDate = new Date();
        }
    }
    next();
});

module.exports = mongoose.model('Membership', membershipSchema);
