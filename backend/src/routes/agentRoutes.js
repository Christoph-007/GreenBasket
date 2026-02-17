const express = require('express');
const router = express.Router();
const agentAuthController = require('../controllers/agentAuthController');
const agentDeliveryController = require('../controllers/agentDeliveryController');
const { requireAgent, requireVerifiedAgent } = require('../middlewares/agentAuthMiddleware');

// ============================================
// PUBLIC ROUTES (No authentication required)
// ============================================

/**
 * @route   POST /api/agents/register
 * @desc    Register new delivery agent
 * @access  Public
 */
router.post('/register', agentAuthController.register);

/**
 * @route   POST /api/agents/login
 * @desc    Login delivery agent
 * @access  Public
 */
router.post('/login', agentAuthController.login);

// ============================================
// PROTECTED ROUTES (Agent authentication required)
// ============================================

// Apply agent authentication middleware to all routes below
router.use(requireAgent);

/**
 * @route   GET /api/agents/me
 * @desc    Get current agent profile
 * @access  Private (Agent)
 */
router.get('/me', agentAuthController.getProfile);

/**
 * @route   PUT /api/agents/me
 * @desc    Update agent profile
 * @access  Private (Agent)
 */
router.put('/me', agentAuthController.updateProfile);

/**
 * @route   PUT /api/agents/me/status
 * @desc    Update agent status (available/offline)
 * @access  Private (Agent)
 */
router.put('/me/status', agentAuthController.updateStatus);

/**
 * @route   POST /api/agents/me/location
 * @desc    Update agent location (for future tracking)
 * @access  Private (Agent)
 */
router.post('/me/location', agentAuthController.updateLocation);

// ============================================
// DELIVERY ASSIGNMENT ROUTES
// ============================================

/**
 * @route   GET /api/agents/assignments/current
 * @desc    Get agent's current active assignment
 * @access  Private (Agent)
 */
router.get('/assignments/current', agentDeliveryController.getCurrentAssignment);

/**
 * @route   GET /api/agents/assignments
 * @desc    Get all assignments for agent (history)
 * @access  Private (Agent)
 */
router.get('/assignments', agentDeliveryController.getMyAssignments);

/**
 * @route   GET /api/agents/assignments/:id
 * @desc    Get assignment by ID
 * @access  Private (Agent)
 */
router.get('/assignments/:id', agentDeliveryController.getAssignmentById);

/**
 * @route   PUT /api/agents/assignments/:id/status
 * @desc    Update delivery assignment status
 * @access  Private (Agent)
 */
router.put('/assignments/:id/status', agentDeliveryController.updateAssignmentStatus);

/**
 * @route   GET /api/agents/earnings
 * @desc    Get agent earnings summary
 * @access  Private (Agent)
 */
router.get('/earnings', agentDeliveryController.getEarnings);

module.exports = router;
