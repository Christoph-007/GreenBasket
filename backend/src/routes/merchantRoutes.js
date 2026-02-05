const express = require('express');
const router = express.Router();
const merchantController = require('../controllers/merchantController');
const { authenticate, isMerchant } = require('../middlewares/authMiddleware');

router.use(authenticate, isMerchant);

router.get('/profile', merchantController.getProfile);
router.put('/profile', merchantController.updateProfile);
router.patch('/toggle-store', merchantController.toggleStoreStatus);
router.get('/dashboard-stats', merchantController.getDashboardStats);

module.exports = router;
