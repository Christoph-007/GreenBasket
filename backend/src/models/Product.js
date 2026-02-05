const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
    // Basic Information
    name: {
        type: String,
        required: true,
        trim: true,
        index: 'text'
    },
    description: {
        type: String,
        required: true,
        maxlength: 1000
    },

    // Merchant
    merchant: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Merchant',
        required: true,
        index: true
    },

    // Category
    category: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Category',
        required: true
    },
    subCategory: String,

    // Pricing
    price: {
        type: Number,
        required: true,
        min: 0
    },
    comparePrice: {
        type: Number,  // Original price for discount display
        min: 0
    },
    unit: {
        type: String,
        enum: ['kg', 'g', 'piece', 'dozen', 'bundle', 'liter'],
        default: 'kg'
    },

    // Inventory
    stock: {
        type: Number,
        required: true,
        default: 0,
        min: 0
    },
    lowStockThreshold: {
        type: Number,
        default: 10
    },

    // Product Properties
    tags: [{
        type: String,
        enum: ['organic', 'farm-fresh', 'home-grown', 'seasonal', 'new-arrival', 'best-seller']
    }],

    // Preparation Options
    preparationOptions: [{
        type: {
            type: String,
            enum: ['whole', 'cut', 'chopped', 'diced', 'sliced']
        },
        additionalPrice: {
            type: Number,
            default: 0
        }
    }],

    // Images
    images: [{
        url: String,
        publicId: String
    }],
    primaryImage: {
        type: String,
        required: true
    },

    // Nutritional Information (per 100g/ml)
    nutritionalInfo: {
        calories: Number,
        protein: Number,
        carbohydrates: Number,
        fat: Number,
        fiber: Number,
        vitamins: [String]
    },

    // Origin & Quality
    origin: {
        farm: String,
        location: String,
        harvestDate: Date
    },
    qualityCertifications: [{
        name: String,
        document: String
    }],

    // Seasonal Information
    isSeasonal: {
        type: Boolean,
        default: false
    },
    availableMonths: [{
        type: Number,
        min: 1,
        max: 12
    }],

    // Status
    status: {
        type: String,
        enum: ['active', 'out-of-stock', 'coming-soon', 'discontinued'],
        default: 'active'
    },

    // Reviews & Ratings
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

    // Sales Metrics
    totalSales: {
        type: Number,
        default: 0
    },
    views: {
        type: Number,
        default: 0
    },

    // SEO
    slug: {
        type: String,
        unique: true
    }
}, {
    timestamps: true
});

// Create slug before saving
productSchema.pre('save', function (next) {
    if (this.isModified('name') && !this.slug) {
        this.slug = this.name.toLowerCase().replace(/[^a-z0-9]+/g, '-') + '-' + Date.now();
    }
    next();
});

// Indexes
productSchema.index({ name: 'text', description: 'text' });
productSchema.index({ merchant: 1, status: 1 });
productSchema.index({ category: 1, status: 1 });

module.exports = mongoose.model('Product', productSchema);
