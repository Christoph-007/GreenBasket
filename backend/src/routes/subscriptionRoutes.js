const express = require('express');
const router = express.Router();
const subscriptionController = require('../controllers/subscriptionController');
const { authenticate } = require('../middlewares/authMiddleware');

router.use(authenticate);

router.post('/', subscriptionController.createSubscription);
router.get('/', subscriptionController.getMySubscriptions);
router.patch('/:id/status', subscriptionController.updateSubscriptionStatus);

module.exports = router;
