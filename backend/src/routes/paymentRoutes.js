const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/paymentController');
const { authenticate: protect, isAdmin } = require('../middlewares/authMiddleware');

router.use(protect);

router.post('/create-order', paymentController.createPaymentOrder);
router.post('/verify', paymentController.verifyPayment);
router.post('/refund', paymentController.processRefund);

module.exports = router;
