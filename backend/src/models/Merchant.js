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

    // Document Verification System
    documents: [{
        type: {
            type: String,
            enum: ['fssai', 'gst', 'pan', 'aadhaar', 'bank_details', 'organic_certificate', 'farm_ownership', 'other'],
            required: true
        },
        documentNumber: {
            type: String
        },
        documentUrl: {
            type: String,
            required: true
        },
        expiryDate: {
            type: Date
        },
        status: {
            type: String,
            enum: ['pending', 'verified', 'rejected', 'expired'],
            default: 'pending'
        },
        verifiedBy: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Admin'
        },
        verifiedAt: {
            type: Date
        },
        rejectionReason: {
            type: String
        },
        uploadedAt: {
            type: Date,
            default: Date.now
        },
        notes: {
            type: String,
            maxlength: 500
        }
    }],

    // Document History
    documentHistory: [{
        originalId: mongoose.Schema.Types.ObjectId,
        type: String,
        documentNumber: String,
        documentUrl: String,
        expiryDate: Date,
        status: String,
        verifiedBy: mongoose.Schema.Types.ObjectId,
        verifiedAt: Date,
        rejectionReason: String,
        uploadedAt: Date,
        notes: String,
        archivedAt: {
            type: Date,
            default: Date.now
        }
    }],

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

    // Delivery Zones (Advanced)
    deliveryZones: [{
        name: {
            type: String,
            trim: true
        },
        radiusKm: {
            type: Number,
            required: true,
            min: 0.1,
            max: 100
        },
        deliveryCharge: {
            type: Number,
            required: true,
            min: 0
        },
        minimumOrder: {
            type: Number,
            default: 0,
            min: 0
        },
        freeDeliveryAbove: {
            type: Number,
            min: 0
        },
        estimatedDeliveryTime: {
            type: String,
            default: '30-45 mins'
        },
        isActive: {
            type: Boolean,
            default: true
        }
    }],

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
