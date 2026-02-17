const express = require('express');
const router = express.Router();
const adminAgentController = require('../controllers/adminAgentController');
const { protect, isAdmin } = require('../middlewares/authMiddleware');

// Apply admin authentication to all routes
router.use(protect);
router.use(isAdmin);

// ============================================
// AGENT MANAGEMENT ROUTES
// ============================================

/**
 * @route   GET /api/admin/agents
 * @desc    Get all delivery agents with filters
 * @access  Private (Admin)
 */
router.get('/', adminAgentController.getAllAgents);

/**
 * @route   GET /api/admin/agents/analytics
 * @desc    Get delivery analytics
 * @access  Private (Admin)
 */
router.get('/analytics', adminAgentController.getDeliveryAnalytics);

/**
 * @route   GET /api/admin/agents/:id
 * @desc    Get agent by ID with full details
 * @access  Private (Admin)
 */
router.get('/:id', adminAgentController.getAgentById);

/**
 * @route   GET /api/admin/agents/:id/assignments
 * @desc    Get agent's assignment history
 * @access  Private (Admin)
 */
router.get('/:id/assignments', adminAgentController.getAgentAssignments);

/**
 * @route   PATCH /api/admin/agents/:id/verify
 * @desc    Verify/approve delivery agent
 * @access  Private (Admin)
 */
router.patch('/:id/verify', adminAgentController.verifyAgent);

/**
 * @route   PATCH /api/admin/agents/:id/toggle-active
 * @desc    Toggle agent active status
 * @access  Private (Admin)
 */
router.patch('/:id/toggle-active', adminAgentController.toggleAgentActive);

module.exports = router;
