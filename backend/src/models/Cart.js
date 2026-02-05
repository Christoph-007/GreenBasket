const mongoose = require('mongoose');

const cartSchema = new mongoose.Schema({
    user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
        unique: true
    },
    items: [{
        product: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Product',
            required: true
        },
        quantity: {
            type: Number,
            required: true,
            min: 1
        },
        preparation: {
            type: String,
            enum: ['whole', 'cut', 'chopped', 'diced', 'sliced']
        },
        price: Number,
        addedAt: {
            type: Date,
            default: Date.now
        }
    }],
    total: {
        type: Number,
        default: 0
    }
}, { timestamps: true });

// Calculate cart total
cartSchema.methods.calculateTotal = async function () {
    await this.populate('items.product');

    let total = 0;
    this.items.forEach(item => {
        if (item.product) {
            total += item.product.price * item.quantity;
        }
    });

    this.total = total;
    return total;
};

module.exports = mongoose.model('Cart', cartSchema);
