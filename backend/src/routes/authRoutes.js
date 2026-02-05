const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { validateSignup, validateLogin } = require('../utils/validators');
const { validate } = require('../middlewares/validationMiddleware');

// User Authentication
router.post('/user/signup', validateSignup, validate, authController.userSignup);
router.post('/user/login', validateLogin, validate, authController.userLogin);
router.post('/user/verify-email', authController.verifyEmail);
router.post('/user/forgot-password', authController.forgotPassword);
router.post('/user/reset-password', authController.resetPassword);

// Merchant Authentication
router.post('/merchant/signup', validateSignup, validate, authController.merchantSignup);
router.post('/merchant/login', validateLogin, validate, authController.merchantLogin);

// Admin Authentication
router.post('/admin/login', validateLogin, validate, authController.adminLogin);

// Token Management
router.post('/refresh-token', authController.refreshToken);
router.post('/logout', authController.logout);

module.exports = router;
