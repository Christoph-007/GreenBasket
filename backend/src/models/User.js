const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
    // Basic Information
    name: {
        type: String,
        required: [true, 'Name is required'],
        trim: true,
        minlength: 2,
        maxlength: 50
    },
    email: {
        type: String,
        required: [true, 'Email is required'],
        unique: true,
        lowercase: true,
        trim: true,
        match: [/^\S+@\S+\.\S+$/, 'Please enter a valid email']
    },
    phone: {
        type: String,
        required: [true, 'Phone number is required'],
        unique: true,
        match: [/^[0-9]{10}$/, 'Please enter a valid 10-digit phone number']
    },
    password: {
        type: String,
        required: [true, 'Password is required'],
        minlength: 6,
        select: false
    },

    // Profile Information
    profileImage: {
        type: String,
        default: null
    },

    // Authentication
    authProvider: {
        type: String,
        enum: ['local', 'google', 'facebook'],
        default: 'local'
    },
    googleId: String,
    facebookId: String,
    isEmailVerified: {
        type: Boolean,
        default: false
    },
    isPhoneVerified: {
        type: Boolean,
        default: false
    },

    // Preferences
    dietaryPreferences: [{
        type: String,
        enum: ['vegetarian', 'vegan', 'non-vegetarian', 'gluten-free', 'organic-only']
    }],
    allergies: [{
        type: String
    }],

    // Premium Membership
    isPremium: {
        type: Boolean,
        default: false
    },
    premiumExpiresAt: Date,

    // Loyalty & Rewards
    loyaltyPoints: {
        type: Number,
        default: 0
    },
    loyaltyTier: {
        type: String,
        enum: ['bronze', 'silver', 'gold', 'platinum'],
        default: 'bronze'
    },

    // Wallet
    walletBalance: {
        type: Number,
        default: 0
    },

    // Settings
    notificationSettings: {
        email: { type: Boolean, default: true },
        sms: { type: Boolean, default: true },
        push: { type: Boolean, default: true },
        orderUpdates: { type: Boolean, default: true },
        offers: { type: Boolean, default: true }
    },

    // Status
    isActive: {
        type: Boolean,
        default: true
    },
    isBlocked: {
        type: Boolean,
        default: false
    },
    blockedReason: String,

    // Timestamps
    lastLoginAt: Date,
    passwordChangedAt: Date
}, {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true }
});

// Virtual for addresses
userSchema.virtual('addresses', {
    ref: 'Address',
    localField: '_id',
    foreignField: 'user'
});

// Hash password before saving
userSchema.pre('save', async function (next) {
    if (!this.isModified('password')) return next();
    this.password = await bcrypt.hash(this.password, 12);
    next();
});

// Compare password method
userSchema.methods.comparePassword = async function (candidatePassword) {
    return await bcrypt.compare(candidatePassword, this.password);
};

module.exports = mongoose.model('User', userSchema);
