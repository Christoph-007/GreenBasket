const express = require('express');
const router = express.Router();
const productController = require('../controllers/productController');
const { authenticate, isMerchant, optionalAuthenticate } = require('../middlewares/authMiddleware');
const { uploadProductImages } = require('../middlewares/uploadMiddleware');

// Merchant routes (Moved up to prevent collision with :id)
router.get('/merchant/my-products', authenticate, isMerchant, productController.getMyProducts);

// Public routes
router.get('/', optionalAuthenticate, productController.getAllProducts);
router.get('/search', optionalAuthenticate, productController.searchProducts);
router.get('/:id', optionalAuthenticate, productController.getProductById);

// Protected routes (Merchant only)
router.post('/', authenticate, isMerchant, uploadProductImages, productController.createProduct);
router.put('/:id', authenticate, isMerchant, uploadProductImages, productController.updateProduct);
router.delete('/:id', authenticate, isMerchant, productController.deleteProduct);
router.patch('/:id/stock', authenticate, isMerchant, productController.updateStock);

module.exports = router;
