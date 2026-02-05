const mongoose = require('mongoose');

const driverSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true
    },
    phone: {
        type: String,
        required: true,
        unique: true
    },
    email: {
        type: String,
        sparse: true
    },
    vehicleType: {
        type: String,
        enum: ['bike', 'scooter', 'van', 'truck'],
        required: true
    },
    vehicleNumber: String,
    licenseNumber: String,
    status: {
        type: String,
        enum: ['available', 'busy', 'offline'],
        default: 'offline'
    },
    currentLocation: {
        type: {
            type: String,
            enum: ['Point'],
            default: 'Point'
        },
        coordinates: [Number] // [lng, lat]
    },
    assignedZone: String, // Or polygon reference
    rating: {
        type: Number,
        default: 5
    },
    totalDeliveries: {
        type: Number,
        default: 0
    },
    isActive: {
        type: Boolean,
        default: true
    }
}, { timestamps: true });

driverSchema.index({ currentLocation: '2dsphere' });

module.exports = mongoose.model('Driver', driverSchema);
