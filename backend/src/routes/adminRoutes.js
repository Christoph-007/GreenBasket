const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const { authenticate, isAdmin } = require('../middlewares/authMiddleware');

router.use(authenticate, isAdmin);

router.get('/merchants/pending', adminController.getPendingMerchants);
router.patch('/merchants/:id/verify', adminController.verifyMerchant);
router.get('/merchants/all', adminController.getAllMerchants);

router.get('/users', adminController.getUsers);
router.patch('/users/:id/block', adminController.toggleUserBlock);

router.get('/stats', adminController.getPlatformStats);
router.get('/subscriptions/all', adminController.getAllSubscriptions);

module.exports = router;
