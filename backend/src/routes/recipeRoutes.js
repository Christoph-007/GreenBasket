const express = require('express');
const router = express.Router();
const recipeController = require('../controllers/recipeController');
const { authenticate, isAdmin } = require('../middlewares/authMiddleware');
const { uploadRecipeImage } = require('../middlewares/uploadMiddleware');

// Public routes
router.get('/', recipeController.getAllRecipes);
router.get('/search', recipeController.searchRecipes);
router.get('/:id', recipeController.getRecipeById);
router.post('/:id/calculate-ingredients', recipeController.calculateIngredients);

// Admin routes
router.post('/', authenticate, isAdmin, uploadRecipeImage, recipeController.createRecipe);
router.put('/:id', authenticate, isAdmin, uploadRecipeImage, recipeController.updateRecipe);
router.delete('/:id', authenticate, isAdmin, recipeController.deleteRecipe);

module.exports = router;
