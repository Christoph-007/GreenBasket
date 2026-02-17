const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const driverSchema = new mongoose.Schema({
    name: {
        type: String,
        required: [true, 'Name is required'],
        trim: true
    },
    email: {
        type: String,
        required: [true, 'Email is required'],
        unique: true,
        lowercase: true,
        trim: true,
        match: [/^\S+@\S+\.\S+$/, 'Please provide a valid email']
    },
    password: {
        type: String,
        required: [true, 'Password is required'],
        minlength: 6,
        select: false // Don't include password in queries by default
    },
    phone: {
        type: String,
        required: [true, 'Phone number is required'],
        unique: true,
        trim: true
    },
    profilePhotoUrl: {
        type: String,
        default: null
    },
    vehicleType: {
        type: String,
        enum: ['bike', 'scooter', 'van', 'truck'],
        required: [true, 'Vehicle type is required']
    },
    vehicleNumber: {
        type: String,
        trim: true,
        uppercase: true
    },
    licenseNumber: {
        type: String,
        trim: true
    },
    status: {
        type: String,
        enum: ['available', 'busy', 'offline'],
        default: 'offline',
        index: true
    },
    currentLocation: {
        type: {
            type: String,
            enum: ['Point'],
            default: 'Point'
        },
        coordinates: {
            type: [Number], // [lng, lat]
            default: [0, 0]
        }
    },
    assignedZone: String,
    rating: {
        type: Number,
        default: 5.0,
        min: 0,
        max: 5
    },
    totalDeliveries: {
        type: Number,
        default: 0
    },
    totalEarnings: {
        type: Number,
        default: 0
    },
    isActive: {
        type: Boolean,
        default: true
    },
    isVerified: {
        type: Boolean,
        default: false
    },
    verificationDocuments: [{
        type: {
            type: String,
            enum: ['license', 'vehicle_registration', 'id_proof', 'address_proof']
        },
        url: String,
        uploadedAt: {
            type: Date,
            default: Date.now
        },
        verifiedAt: Date
    }]
}, {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true }
});

// Indexes
driverSchema.index({ currentLocation: '2dsphere' });
driverSchema.index({ email: 1 });
driverSchema.index({ phone: 1 });
driverSchema.index({ status: 1, isActive: 1 });

// Hash password before saving
driverSchema.pre('save', async function (next) {
    if (!this.isModified('password')) return next();

    try {
        const salt = await bcrypt.genSalt(10);
        this.password = await bcrypt.hash(this.password, salt);
        next();
    } catch (error) {
        next(error);
    }
});

// Method to compare passwords
driverSchema.methods.comparePassword = async function (candidatePassword) {
    try {
        return await bcrypt.compare(candidatePassword, this.password);
    } catch (error) {
        throw new Error('Password comparison failed');
    }
};

// Method to update location
driverSchema.methods.updateLocation = function (longitude, latitude) {
    this.currentLocation = {
        type: 'Point',
        coordinates: [longitude, latitude]
    };
    return this.save();
};

module.exports = mongoose.model('Driver', driverSchema);
