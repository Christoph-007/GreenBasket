const Recipe = require('../models/Recipe');
const Product = require('../models/Product');
const recipeCalculator = require('../services/recipeCalculator');

// Get All Recipes
exports.getAllRecipes = async (req, res) => {
    try {
        const { page = 1, limit = 12, category, cuisine, difficulty, search } = req.query;

        const query = { status: 'published' };
        if (category) query.category = category;
        if (cuisine) query.cuisine = cuisine;
        if (difficulty) query.difficulty = difficulty;
        if (search) {
            query.$text = { $search: search };
        }

        const recipes = await Recipe.find(query)
            .sort({ createdAt: -1 })
            .limit(limit * 1)
            .skip((page - 1) * limit);

        const total = await Recipe.countDocuments(query);

        res.json({
            success: true,
            data: {
                recipes,
                pagination: {
                    page: parseInt(page),
                    limit: parseInt(limit),
                    total,
                    pages: Math.ceil(total / limit)
                }
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching recipes',
            error: error.message
        });
    }
};

// Get Recipe By ID
exports.getRecipeById = async (req, res) => {
    try {
        const { id } = req.params;

        const recipe = await Recipe.findById(id).populate('ingredients.product');

        if (!recipe) {
            return res.status(404).json({
                success: false,
                message: 'Recipe not found'
            });
        }

        res.json({
            success: true,
            data: { recipe }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching recipe',
            error: error.message
        });
    }
};

// Calculate Ingredients for Servings
exports.calculateIngredients = async (req, res) => {
    try {
        const { id } = req.params;
        const { servings } = req.body;

        const recipe = await Recipe.findById(id).populate('ingredients.product');

        if (!recipe) {
            return res.status(404).json({
                success: false,
                message: 'Recipe not found'
            });
        }

        // Calculate scaled ingredients
        const scaledIngredients = recipeCalculator.scaleIngredients(
            recipe.ingredients,
            recipe.servings,
            servings
        );

        // Find matching products for each ingredient
        const ingredientsWithProducts = await Promise.all(
            scaledIngredients.map(async (ingredient) => {
                let product = ingredient.product;

                // If no product linked, try to find one
                if (!product) {
                    product = await Product.findOne({
                        name: new RegExp(ingredient.name, 'i'),
                        status: 'active'
                    }).sort({ averageRating: -1 });
                }

                return {
                    name: ingredient.name,
                    quantity: ingredient.scaledQuantity,
                    unit: ingredient.unit,
                    product: product ? {
                        id: product._id,
                        name: product.name,
                        price: product.price,
                        image: product.primaryImage,
                        merchant: product.merchant,
                        stock: product.stock
                    } : null,
                    isAvailable: product && product.stock > 0
                };
            })
        );

        // Calculate total price
        const totalPrice = ingredientsWithProducts.reduce((sum, item) => {
            if (item.product && item.isAvailable) {
                return sum + (item.product.price * item.quantity);
            }
            return sum;
        }, 0);

        res.json({
            success: true,
            data: {
                recipe: {
                    id: recipe._id,
                    name: recipe.name,
                    servings: servings,
                    originalServings: recipe.servings
                },
                ingredients: ingredientsWithProducts,
                totalPrice,
                availableItemsCount: ingredientsWithProducts.filter(i => i.isAvailable).length,
                totalItemsCount: ingredientsWithProducts.length
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error calculating ingredients',
            error: error.message
        });
    }
};

// Search Recipes
exports.searchRecipes = async (req, res) => {
    try {
        const { q, category, cuisine } = req.query;

        const query = { status: 'published' };

        if (q) {
            query.$or = [
                { name: new RegExp(q, 'i') },
                { description: new RegExp(q, 'i') },
                { tags: new RegExp(q, 'i') }
            ];
        }

        if (category) query.category = category;
        if (cuisine) query.cuisine = cuisine;

        const recipes = await Recipe.find(query).limit(20);

        res.json({
            success: true,
            data: { recipes }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error searching recipes',
            error: error.message
        });
    }
};

// Create Recipe (Admin)
exports.createRecipe = async (req, res) => {
    try {
        const recipeData = req.body;

        const recipe = await Recipe.create({
            ...recipeData,
            createdBy: {
                userType: 'admin',
                userId: req.user.id
            }
        });

        res.status(201).json({
            success: true,
            message: 'Recipe created successfully',
            data: { recipe }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error creating recipe',
            error: error.message
        });
    }
};

// Update Recipe (Admin)
exports.updateRecipe = async (req, res) => {
    try {
        const { id } = req.params;
        const updates = req.body;

        const recipe = await Recipe.findByIdAndUpdate(id, updates, { new: true });

        if (!recipe) {
            return res.status(404).json({
                success: false,
                message: 'Recipe not found'
            });
        }

        res.json({
            success: true,
            message: 'Recipe updated successfully',
            data: { recipe }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error updating recipe',
            error: error.message
        });
    }
};

// Delete Recipe (Admin)
exports.deleteRecipe = async (req, res) => {
    try {
        const { id } = req.params;

        const recipe = await Recipe.findByIdAndDelete(id);

        if (!recipe) {
            return res.status(404).json({
                success: false,
                message: 'Recipe not found'
            });
        }

        res.json({
            success: true,
            message: 'Recipe deleted successfully'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error deleting recipe',
            error: error.message
        });
    }
};
