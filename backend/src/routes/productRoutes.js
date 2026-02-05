const express = require('express');
const router = express.Router();
const productController = require('../controllers/productController');
const { authenticate, isMerchant } = require('../middlewares/authMiddleware');
const { uploadProductImages } = require('../middlewares/uploadMiddleware');

// Public routes
router.get('/', productController.getAllProducts);
router.get('/search', productController.searchProducts);
router.get('/:id', productController.getProductById);

// Protected routes (Merchant only)
router.post('/', authenticate, isMerchant, uploadProductImages, productController.createProduct);
router.put('/:id', authenticate, isMerchant, uploadProductImages, productController.updateProduct);
router.delete('/:id', authenticate, isMerchant, productController.deleteProduct);
router.patch('/:id/stock', authenticate, isMerchant, productController.updateStock);
router.get('/merchant/my-products', authenticate, isMerchant, productController.getMyProducts);

module.exports = router;
