const mongoose = require('mongoose');

const platformSettingsSchema = new mongoose.Schema({
    commission: {
        defaultRate: {
            type: Number,
            default: 5
        },
        premiumMerchantRate: {
            type: Number,
            default: 3
        },
        byCategory: [{
            category: {
                type: mongoose.Schema.Types.ObjectId,
                ref: 'Category'
            },
            rate: Number
        }]
    },
    payoutSchedule: {
        type: String,
        enum: ['daily', 'weekly', 'biweekly', 'monthly'],
        default: 'weekly'
    },
    minimumPayoutAmount: {
        type: Number,
        default: 1000
    },
    taxSettings: {
        gstRate: {
            type: Number,
            default: 18
        },
        gstNumber: String,
        companyName: String
    }
}, { timestamps: true });

module.exports = mongoose.model('PlatformSettings', platformSettingsSchema);
