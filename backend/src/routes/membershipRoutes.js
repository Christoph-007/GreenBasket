const express = require('express');
const router = express.Router();
const membershipController = require('../controllers/membershipController');
const { protect, restrictTo } = require('../middlewares/authMiddleware');

// Public routes
router.get('/plans', membershipController.getPlans);

// Protected routes (User)
router.use(protect);

router.post('/initiate', restrictTo('user'), membershipController.initiateMembership);
router.post('/activate', restrictTo('user'), membershipController.activateMembership);
router.post('/subscribe', restrictTo('user'), membershipController.initiateMembership); // Alias

router.get('/', membershipController.getMembership);
router.post('/cancel', restrictTo('user'), membershipController.cancelMembership);
router.get('/premium-products', restrictTo('user'), membershipController.getPremiumProducts);
router.get('/check-benefit', restrictTo('user'), membershipController.checkBenefit);
router.get('/history', restrictTo('user'), membershipController.getMembershipHistory);

// Admin routes
router.get('/admin/all', restrictTo('admin'), membershipController.getAllMemberships);

module.exports = router;
