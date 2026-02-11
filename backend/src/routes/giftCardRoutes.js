const express = require('express');
const router = express.Router();
const giftCardController = require('../controllers/giftCardController');
const { protect, restrictTo, isAdmin } = require('../middlewares/authMiddleware');

// Public routes
router.get('/balance/:code', giftCardController.checkBalance);

// Protected user routes
router.use(protect);
router.post('/validate', giftCardController.validateGiftCard);
router.post('/redeem', restrictTo('user'), giftCardController.redeemGiftCard);
router.get('/my-cards', restrictTo('user'), giftCardController.getMyGiftCards);
router.post('/purchase/initiate', restrictTo('user'), giftCardController.initiatePurchase);
router.post('/purchase/verify', restrictTo('user'), giftCardController.verifyPurchase);

// Admin routes
router.post('/admin/generate', isAdmin, giftCardController.generateGiftCard);
router.get('/admin/all', isAdmin, giftCardController.getAllGiftCards);
router.patch('/admin/:id/cancel', isAdmin, giftCardController.cancelGiftCard);

module.exports = router;
