const mongoose = require('mongoose');

const giftCardSchema = new mongoose.Schema({
    code: {
        type: String,
        required: true,
        unique: true,
        uppercase: true,
        index: true
    },
    type: {
        type: String,
        enum: ['gift_card', 'voucher', 'promotional'],
        default: 'gift_card'
    },
    amount: {
        type: Number,
        required: true,
        min: 0
    },
    originalAmount: {
        type: Number,
        required: true
    },
    status: {
        type: String,
        enum: ['active', 'used', 'expired', 'cancelled'],
        default: 'active',
        index: true
    },
    expiryDate: {
        type: Date,
        required: true
    },
    purchasedBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
    },
    purchasedFor: {
        type: String // Email or phone
    },
    redeemedBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
    },
    redeemedAt: Date,
    orderId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Order'
    },
    message: String,
    minOrderValue: {
        type: Number,
        default: 0
    }
}, { timestamps: true });

// Auto-generate code if not provided
giftCardSchema.pre('save', function (next) {
    if (!this.code) {
        this.code = `GB-GIFT-${Date.now()}-${Math.random().toString(36).substring(2, 8).toUpperCase()}`;
    }
    next();
});

giftCardSchema.index({ purchasedBy: 1, status: 1 });
giftCardSchema.index({ redeemedBy: 1 });
giftCardSchema.index({ expiryDate: 1 });

module.exports = mongoose.model('GiftCard', giftCardSchema);
