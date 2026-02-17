const mongoose = require('mongoose');

const deliveryAssignmentSchema = new mongoose.Schema({
    order: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Order',
        required: true,
        index: true
    },
    driver: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Driver',
        required: true,
        index: true
    },
    status: {
        type: String,
        enum: ['assigned', 'picked_up', 'in_transit', 'delivered', 'failed', 'cancelled'],
        default: 'assigned',
        index: true
    },
    assignedAt: {
        type: Date,
        default: Date.now,
        index: true
    },
    pickedUpAt: {
        type: Date
    },
    inTransitAt: {
        type: Date
    },
    deliveredAt: {
        type: Date
    },
    failedAt: {
        type: Date
    },
    cancelledAt: {
        type: Date
    },
    notes: {
        type: String,
        trim: true
    },
    failureReason: {
        type: String,
        trim: true
    },
    cancellationReason: {
        type: String,
        trim: true
    },
    // Tracking information
    pickupLocation: {
        type: {
            type: String,
            enum: ['Point'],
            default: 'Point'
        },
        coordinates: [Number], // [lng, lat]
        address: String
    },
    deliveryLocation: {
        type: {
            type: String,
            enum: ['Point'],
            default: 'Point'
        },
        coordinates: [Number], // [lng, lat]
        address: String
    },
    estimatedDistance: {
        type: Number, // in kilometers
        default: 0
    },
    actualDistance: {
        type: Number, // in kilometers
        default: 0
    },
    deliveryFee: {
        type: Number,
        default: 0
    },
    // Status history for tracking
    statusHistory: [{
        status: {
            type: String,
            enum: ['assigned', 'picked_up', 'in_transit', 'delivered', 'failed', 'cancelled']
        },
        timestamp: {
            type: Date,
            default: Date.now
        },
        location: {
            type: {
                type: String,
                enum: ['Point']
            },
            coordinates: [Number]
        },
        note: String
    }]
}, {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true }
});

// Indexes
deliveryAssignmentSchema.index({ order: 1, driver: 1 });
deliveryAssignmentSchema.index({ status: 1, assignedAt: -1 });
deliveryAssignmentSchema.index({ driver: 1, status: 1 });

// Virtual for duration
deliveryAssignmentSchema.virtual('duration').get(function () {
    if (this.deliveredAt && this.assignedAt) {
        return Math.floor((this.deliveredAt - this.assignedAt) / 1000 / 60); // in minutes
    }
    return null;
});

// Method to update status
deliveryAssignmentSchema.methods.updateStatus = function (newStatus, location = null, note = '') {
    this.status = newStatus;

    // Update timestamp based on status
    const timestamp = new Date();
    switch (newStatus) {
        case 'picked_up':
            this.pickedUpAt = timestamp;
            break;
        case 'in_transit':
            this.inTransitAt = timestamp;
            break;
        case 'delivered':
            this.deliveredAt = timestamp;
            break;
        case 'failed':
            this.failedAt = timestamp;
            break;
        case 'cancelled':
            this.cancelledAt = timestamp;
            break;
    }

    // Add to status history
    this.statusHistory.push({
        status: newStatus,
        timestamp,
        location,
        note
    });

    return this.save();
};

module.exports = mongoose.model('DeliveryAssignment', deliveryAssignmentSchema);
