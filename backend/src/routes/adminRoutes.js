const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const adminAgentController = require('../controllers/adminAgentController');
const { authenticate, isAdmin } = require('../middlewares/authMiddleware');

router.use(authenticate, isAdmin);

router.get('/merchants/pending', adminController.getPendingMerchants);
router.patch('/merchants/:id/verify', adminController.verifyMerchant);
router.get('/merchants/all', adminController.getAllMerchants);

router.get('/users', adminController.getUsers);
router.patch('/users/:id/block', adminController.toggleUserBlock);

router.get('/stats', adminController.getPlatformStats);
router.get('/subscriptions/all', adminController.getAllSubscriptions);

// Delivery Agent Management Routes
router.get('/agents', adminAgentController.getAllAgents);
router.get('/agents/analytics', adminAgentController.getDeliveryAnalytics);
router.get('/agents/:id', adminAgentController.getAgentById);
router.get('/agents/:id/assignments', adminAgentController.getAgentAssignments);
router.patch('/agents/:id/verify', adminAgentController.verifyAgent);
router.patch('/agents/:id/toggle-active', adminAgentController.toggleAgentActive);

// Order Assignment Routes
router.post('/orders/:orderId/assign/:agentId', adminAgentController.manualAssign);
router.get('/orders/unassigned', adminAgentController.getUnassignedOrders);
router.get('/assignments', adminAgentController.getAllAssignments);

module.exports = router;

