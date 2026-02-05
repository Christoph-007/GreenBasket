const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const merchantSchema = new mongoose.Schema({
    // Basic Information
    name: {
        type: String,
        required: true,
        trim: true
    },
    email: {
        type: String,
        required: true,
        unique: true,
        lowercase: true
    },
    phone: {
        type: String,
        required: true,
        unique: true
    },
    password: {
        type: String,
        required: true,
        select: false
    },

    // Business Information
    businessName: {
        type: String,
        required: true,
        trim: true
    },
    merchantType: {
        type: String,
        enum: ['home-grower', 'organic-farmer', 'local-farmer'],
        required: true
    },
    businessDescription: {
        type: String,
        maxlength: 500
    },

    // Location
    address: {
        street: String,
        city: String,
        state: String,
        pincode: String,
        landmark: String
    },
    location: {
        type: {
            type: String,
            enum: ['Point'],
            default: 'Point'
        },
        coordinates: {
            type: [Number],  // [longitude, latitude]
            index: '2dsphere'
        }
    },

    // Business Details
    fssaiLicense: {
        number: String,
        expiryDate: Date,
        document: String
    },
    gstNumber: String,
    panNumber: String,

    // Certifications
    certifications: [{
        name: String,
        issuedBy: String,
        issuedDate: Date,
        expiryDate: Date,
        document: String
    }],

    // Images
    profileImage: String,
    farmImages: [String],

    // Verification Status
    verificationStatus: {
        type: String,
        enum: ['pending', 'under-review', 'approved', 'rejected'],
        default: 'pending'
    },
    verifiedBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Admin'
    },
    verifiedAt: Date,
    rejectionReason: String,

    // Badges & Ratings
    badges: [{
        type: String,
        enum: ['verified', 'organic-certified', 'premium-seller', 'top-rated', 'fast-delivery']
    }],
    averageRating: {
        type: Number,
        default: 0,
        min: 0,
        max: 5
    },
    totalReviews: {
        type: Number,
        default: 0
    },

    // Business Metrics
    totalOrders: {
        type: Number,
        default: 0
    },
    totalRevenue: {
        type: Number,
        default: 0
    },

    // Operating Hours
    operatingHours: {
        monday: { open: String, close: String, isOpen: Boolean },
        tuesday: { open: String, close: String, isOpen: Boolean },
        wednesday: { open: String, close: String, isOpen: Boolean },
        thursday: { open: String, close: String, isOpen: Boolean },
        friday: { open: String, close: String, isOpen: Boolean },
        saturday: { open: String, close: String, isOpen: Boolean },
        sunday: { open: String, close: String, isOpen: Boolean }
    },

    // Store Status
    isStoreOpen: {
        type: Boolean,
        default: true
    },
    vacationMode: {
        isActive: Boolean,
        startDate: Date,
        endDate: Date,
        message: String
    },

    // Delivery Settings
    deliveryRadius: {
        type: Number,
        default: 10  // in kilometers
    },
    minimumOrderValue: {
        type: Number,
        default: 0
    },
    deliveryCharges: {
        type: Number,
        default: 0
    },
    freeDeliveryAbove: Number,

    // Bank Details
    bankDetails: {
        accountHolderName: String,
        accountNumber: String,
        ifscCode: String,
        bankName: String,
        branch: String
    },

    // Settings
    notificationSettings: {
        email: { type: Boolean, default: true },
        sms: { type: Boolean, default: true },
        newOrders: { type: Boolean, default: true },
        lowStock: { type: Boolean, default: true }
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

    lastLoginAt: Date
}, {
    timestamps: true
});

// Hash password
merchantSchema.pre('save', async function (next) {
    if (!this.isModified('password')) return next();
    this.password = await bcrypt.hash(this.password, 12);
    next();
});

// Compare password
merchantSchema.methods.comparePassword = async function (candidatePassword) {
    return await bcrypt.compare(candidatePassword, this.password);
};

module.exports = mongoose.model('Merchant', merchantSchema);
