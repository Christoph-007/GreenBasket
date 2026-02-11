const express = require('express');
const router = express.Router();
const subscriptionController = require('../controllers/subscriptionController');
const { authenticate, restrictTo } = require('../middlewares/authMiddleware');

router.use(authenticate);

router.post('/', subscriptionController.createSubscription);
router.get('/', subscriptionController.getMySubscriptions);
router.get('/:id', subscriptionController.getSubscriptionById);
router.put('/:id', restrictTo('user'), subscriptionController.updateSubscription);
router.delete('/:id', restrictTo('user'), subscriptionController.deleteSubscription);
router.patch('/:id/status', subscriptionController.updateSubscriptionStatus);

// Merchant routes
router.get('/merchant/all', restrictTo('merchant'), subscriptionController.getMerchantSubscriptions);

module.exports = router;
