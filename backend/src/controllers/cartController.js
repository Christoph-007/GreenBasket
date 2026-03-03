const Cart = require('../models/Cart');
const Product = require('../models/Product');
const Recipe = require('../models/Recipe');
const recipeCalculator = require('../services/recipeCalculator');

// Get Cart
exports.getCart = async (req, res) => {
    try {
        const userId = req.user.id;

        let cart = await Cart.findOne({ user: userId }).populate('items.product');

        if (!cart) {
            cart = await Cart.create({ user: userId, items: [], total: 0 });
        }

        // Calculate total
        await cart.calculateTotal();
        await cart.save();

        res.json({
            success: true,
            data: { cart }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching cart',
            error: error.message
        });
    }
};

// Add to Cart
exports.addToCart = async (req, res) => {
    try {
        const userId = req.user.id;
        const { productId, quantity, preparation } = req.body;

        // Check if product exists and is available
        const product = await Product.findById(productId);
        if (!product) {
            return res.status(404).json({
                success: false,
                message: 'Product not found'
            });
        }

        if (product.stock < quantity) {
            return res.status(400).json({
                success: false,
                message: 'Insufficient stock'
            });
        }

        let cart = await Cart.findOne({ user: userId });

        if (!cart) {
            cart = await Cart.create({
                user: userId,
                items: [{
                    product: productId,
                    quantity,
                    preparation,
                    price: product.price
                }]
            });
        } else {
            // Check if product with same preparation already in cart
            const existingItemIndex = cart.items.findIndex(
                item => item.product.toString() === productId &&
                    (item.preparation || 'whole') === (preparation || 'whole')
            );

            if (existingItemIndex > -1) {
                // Update quantity
                cart.items[existingItemIndex].quantity += quantity;
            } else {
                // Add new item
                cart.items.push({
                    product: productId,
                    quantity,
                    preparation,
                    price: product.price
                });
            }
        }

        await cart.calculateTotal();
        await cart.save();
        await cart.populate('items.product');

        res.json({
            success: true,
            message: 'Product added to cart',
            data: { cart }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error adding to cart',
            error: error.message
        });
    }
};

// Update Cart Item
exports.updateCartItem = async (req, res) => {
    try {
        const userId = req.user.id;
        const { productId } = req.params;
        const { quantity, preparation } = req.body;

        const cart = await Cart.findOne({ user: userId });

        if (!cart) {
            return res.status(404).json({
                success: false,
                message: 'Cart not found'
            });
        }

        const itemIndex = cart.items.findIndex(
            item => item.product.toString() === productId &&
                (item.preparation || 'whole') === (preparation || 'whole')
        );

        if (itemIndex === -1) {
            return res.status(404).json({
                success: false,
                message: 'Item not found in cart'
            });
        }

        if (quantity === 0) {
            cart.items.splice(itemIndex, 1);
        } else {
            cart.items[itemIndex].quantity = quantity;
        }

        await cart.calculateTotal();
        await cart.save();
        await cart.populate('items.product');

        res.json({
            success: true,
            message: 'Cart updated',
            data: { cart }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error updating cart',
            error: error.message
        });
    }
};

// Remove from Cart
exports.removeFromCart = async (req, res) => {
    try {
        const userId = req.user.id;
        const { productId } = req.params;
        const { preparation } = req.query; // Use query param for preparation in DELETE

        const cart = await Cart.findOne({ user: userId });

        if (!cart) {
            return res.status(404).json({
                success: false,
                message: 'Cart not found'
            });
        }

        cart.items = cart.items.filter(
            item => !(item.product.toString() === productId &&
                (item.preparation || 'whole') === (preparation || 'whole'))
        );

        await cart.calculateTotal();
        await cart.save();
        await cart.populate('items.product');

        res.json({
            success: true,
            message: 'Item removed from cart',
            data: { cart }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error removing from cart',
            error: error.message
        });
    }
};

// Clear Cart
exports.clearCart = async (req, res) => {
    try {
        const userId = req.user.id;

        const cart = await Cart.findOneAndUpdate(
            { user: userId },
            { items: [], total: 0 },
            { new: true }
        );

        res.json({
            success: true,
            message: 'Cart cleared',
            data: { cart }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error clearing cart',
            error: error.message
        });
    }
};

// Add Recipe to Cart
exports.addRecipeToCart = async (req, res) => {
    try {
        const userId = req.user.id;
        const { recipeId, servings } = req.body;

        const recipe = await Recipe.findById(recipeId).populate('ingredients.product');

        if (!recipe) {
            return res.status(404).json({
                success: false,
                message: 'Recipe not found'
            });
        }

        // Scale ingredients
        const scaledIngredients = recipeCalculator.scaleIngredients(
            recipe.ingredients,
            recipe.servings,
            servings
        );

        let cart = await Cart.findOne({ user: userId });
        if (!cart) {
            cart = await Cart.create({ user: userId, items: [] });
        }

        // Add ingredients to cart
        for (let ingredient of scaledIngredients) {
            if (ingredient.product) {
                const product = await Product.findById(ingredient.product._id || ingredient.product);

                if (product && product.stock >= ingredient.scaledQuantity) {
                    const existingItemIndex = cart.items.findIndex(
                        item => item.product.toString() === product._id.toString()
                    );

                    if (existingItemIndex > -1) {
                        cart.items[existingItemIndex].quantity += ingredient.scaledQuantity;
                    } else {
                        cart.items.push({
                            product: product._id,
                            quantity: ingredient.scaledQuantity,
                            price: product.price
                        });
                    }
                }
            }
        }

        await cart.calculateTotal();
        await cart.save();
        await cart.populate('items.product');

        res.json({
            success: true,
            message: 'Recipe ingredients added to cart',
            data: { cart }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error adding recipe to cart',
            error: error.message
        });
    }
};
