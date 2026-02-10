const mongoose = require('mongoose');

const orderSchema = new mongoose.Schema({
    // Order ID
    orderId: {
        type: String,
        unique: true,
        required: true,
        default: () => 'GB' + Date.now() + Math.floor(Math.random() * 1000)
    },

    // Customer
    customer: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
        index: true
    },

    // Merchant
    merchant: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Merchant',
        required: true,
        index: true
    },

    // Order Items
    items: [{
        product: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Product',
            required: true
        },
        name: String,
        price: Number,
        quantity: {
            type: Number,
            required: true,
            min: 1
        },
        unit: String,
        preparation: {
            type: String,
            enum: ['whole', 'cut', 'chopped', 'diced', 'sliced']
        },
        subtotal: Number
    }],

    // Pricing
    itemsTotal: {
        type: Number,
        required: true
    },
    deliveryCharges: {
        type: Number,
        default: 0
    },
    discount: {
        type: Number,
        default: 0
    },
    totalAmount: {
        type: Number,
        required: true
    },

    // Discounts & Offers
    couponCode: String,
    couponDiscount: {
        type: Number,
        default: 0
    },

    // Delivery Details
    deliveryType: {
        type: String,
        enum: ['home-delivery', 'pickup'],
        default: 'home-delivery'
    },
    deliveryAddress: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Address'
    },
    deliveryInstructions: String,

    // Delivery Time Slot
    deliveryTimeSlot: {
        date: Date,
        startTime: String,
        endTime: String
    },

    // Payment
    // Payment Gateway Fields
    paymentGateway: {
        provider: {
            type: String,
            enum: ['razorpay', 'stripe', 'phonepe', 'cod'],
            default: 'razorpay'
        },
        orderId: String, // Razorpay order_id
        paymentId: String, // Razorpay payment_id
        signature: String, // Razorpay signature
        transactionId: String // Bank/UPI transaction ID
    },

    paymentDetails: {
        method: {
            type: String,
            enum: ['card', 'upi', 'netbanking', 'wallet', 'emi', 'cod']
        },
        cardNetwork: String,
        cardLast4: String,
        upiVpa: String,
        bank: String,
        wallet: String,
        email: String,
        contact: String
    },

    // Refund Fields
    refund: {
        status: {
            type: String,
            enum: ['none', 'initiated', 'processing', 'completed', 'failed'],
            default: 'none'
        },
        refundId: String,
        amount: Number,
        reason: String,
        initiatedAt: Date,
        completedAt: Date,
        failureReason: String
    },

    // Payment Events Log
    paymentEvents: [{
        event: {
            type: String,
            enum: ['order_created', 'payment_authorized', 'payment_captured',
                'payment_failed', 'refund_initiated', 'refund_completed']
        },
        data: mongoose.Schema.Types.Mixed,
        timestamp: {
            type: Date,
            default: Date.now
        }
    }],

    // Basic Payment Info (kept for compatibility)
    paymentMethod: {
        type: String,
        enum: ['cod', 'online', 'wallet'],
        required: true
    },
    paymentStatus: {
        type: String,
        enum: ['pending', 'completed', 'failed', 'refunded', 'paid'],
        default: 'pending'
    },

    // Order Status
    status: {
        type: String,
        enum: ['pending', 'confirmed', 'preparing', 'ready', 'out-for-delivery', 'delivered', 'cancelled', 'refunded'],
        default: 'pending',
        index: true
    },

    // Status History
    statusHistory: [{
        status: String,
        timestamp: {
            type: Date,
            default: Date.now
        },
        updatedBy: String,
        note: String
    }],

    // Cancellation
    cancellationReason: String,
    cancelledBy: {
        type: String,
        enum: ['customer', 'merchant', 'admin']
    },
    cancelledAt: Date,

    // Special Requests
    specialRequests: String,

    // Recipe Based Order
    isRecipeOrder: {
        type: Boolean,
        default: false
    },
    recipe: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Recipe'
    },
    servings: Number,

    // Ratings & Reviews
    rating: {
        type: Number,
        min: 1,
        max: 5
    },
    review: String,
    reviewedAt: Date,

    // Timestamps
    orderedAt: {
        type: Date,
        default: Date.now
    },
    confirmedAt: Date,
    deliveredAt: Date
}, {
    timestamps: true
});



// Add to status history
orderSchema.methods.updateStatus = function (newStatus, updatedBy, note) {
    this.status = newStatus;
    this.statusHistory.push({
        status: newStatus,
        timestamp: new Date(),
        updatedBy,
        note
    });
};

module.exports = mongoose.model('Order', orderSchema);
