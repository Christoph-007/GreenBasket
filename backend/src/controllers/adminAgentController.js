const Driver = require('../models/Driver');
const DeliveryAssignment = require('../models/DeliveryAssignment');
const Order = require('../models/Order');
const { manualAssignOrder } = require('../services/assignmentService');

/**
 * @desc    Get all delivery agents
 * @route   GET /api/admin/agents
 * @access  Private (Admin)
 */
exports.getAllAgents = async (req, res) => {
    try {
        const { status, isVerified, isActive, page = 1, limit = 20 } = req.query;

        const query = {};
        if (status) query.status = status;
        if (isVerified !== undefined) query.isVerified = isVerified === 'true';
        if (isActive !== undefined) query.isActive = isActive === 'true';

        const drivers = await Driver.find(query)
            .select('-password')
            .sort({ createdAt: -1 })
            .limit(limit * 1)
            .skip((page - 1) * limit);

        const total = await Driver.countDocuments(query);

        res.json({
            success: true,
            data: {
                drivers,
                pagination: {
                    total,
                    page: parseInt(page),
                    pages: Math.ceil(total / limit)
                }
            }
        });
    } catch (error) {
        console.error('Get all agents error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch agents',
            error: error.message
        });
    }
};

/**
 * @desc    Get agent by ID with full details
 * @route   GET /api/admin/agents/:id
 * @access  Private (Admin)
 */
exports.getAgentById = async (req, res) => {
    try {
        const { id } = req.params;

        const driver = await Driver.findById(id).select('-password');

        if (!driver) {
            return res.status(404).json({
                success: false,
                message: 'Agent not found'
            });
        }

        // Get assignment stats
        const totalAssignments = await DeliveryAssignment.countDocuments({ driver: id });
        const completedAssignments = await DeliveryAssignment.countDocuments({
            driver: id,
            status: 'delivered'
        });
        const failedAssignments = await DeliveryAssignment.countDocuments({
            driver: id,
            status: 'failed'
        });

        res.json({
            success: true,
            data: {
                driver,
                stats: {
                    totalAssignments,
                    completedAssignments,
                    failedAssignments,
                    successRate: totalAssignments > 0
                        ? ((completedAssignments / totalAssignments) * 100).toFixed(2)
                        : 0
                }
            }
        });
    } catch (error) {
        console.error('Get agent error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch agent',
            error: error.message
        });
    }
};

/**
 * @desc    Get agent's assignment history
 * @route   GET /api/admin/agents/:id/assignments
 * @access  Private (Admin)
 */
exports.getAgentAssignments = async (req, res) => {
    try {
        const { id } = req.params;
        const { status, page = 1, limit = 20 } = req.query;

        const query = { driver: id };
        if (status) query.status = status;

        const assignments = await DeliveryAssignment.find(query)
            .populate('order', 'orderId totalAmount deliveryAddress status customer')
            .sort({ assignedAt: -1 })
            .limit(limit * 1)
            .skip((page - 1) * limit);

        const total = await DeliveryAssignment.countDocuments(query);

        res.json({
            success: true,
            data: {
                assignments,
                pagination: {
                    total,
                    page: parseInt(page),
                    pages: Math.ceil(total / limit)
                }
            }
        });
    } catch (error) {
        console.error('Get agent assignments error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch assignments',
            error: error.message
        });
    }
};

/**
 * @desc    Verify/approve delivery agent
 * @route   PATCH /api/admin/agents/:id/verify
 * @access  Private (Admin)
 */
exports.verifyAgent = async (req, res) => {
    try {
        const { id } = req.params;
        const { isVerified } = req.body;

        if (isVerified === undefined) {
            return res.status(400).json({
                success: false,
                message: 'Please provide isVerified status'
            });
        }

        const driver = await Driver.findById(id);

        if (!driver) {
            return res.status(404).json({
                success: false,
                message: 'Agent not found'
            });
        }

        driver.isVerified = isVerified;
        await driver.save();

        res.json({
            success: true,
            message: `Agent ${isVerified ? 'verified' : 'unverified'} successfully`,
            data: { driver }
        });
    } catch (error) {
        console.error('Verify agent error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to verify agent',
            error: error.message
        });
    }
};

/**
 * @desc    Toggle agent active status
 * @route   PATCH /api/admin/agents/:id/toggle-active
 * @access  Private (Admin)
 */
exports.toggleAgentActive = async (req, res) => {
    try {
        const { id } = req.params;

        const driver = await Driver.findById(id);

        if (!driver) {
            return res.status(404).json({
                success: false,
                message: 'Agent not found'
            });
        }

        driver.isActive = !driver.isActive;

        // If deactivating, set status to offline
        if (!driver.isActive) {
            driver.status = 'offline';
        }

        await driver.save();

        res.json({
            success: true,
            message: `Agent ${driver.isActive ? 'activated' : 'deactivated'} successfully`,
            data: { driver }
        });
    } catch (error) {
        console.error('Toggle agent active error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to toggle agent status',
            error: error.message
        });
    }
};

/**
 * @desc    Manually assign order to specific agent
 * @route   POST /api/admin/orders/:orderId/assign/:agentId
 * @access  Private (Admin)
 */
exports.manualAssign = async (req, res) => {
    try {
        const { orderId, agentId } = req.params;

        const result = await manualAssignOrder(orderId, agentId);

        res.json({
            success: true,
            message: result.message,
            data: {
                assignment: result.assignment,
                driver: result.driver
            }
        });
    } catch (error) {
        console.error('Manual assign error:', error);
        res.status(500).json({
            success: false,
            message: error.message || 'Failed to assign order',
            error: error.message
        });
    }
};

/**
 * @desc    Get all unassigned orders
 * @route   GET /api/admin/orders/unassigned
 * @access  Private (Admin)
 */
exports.getUnassignedOrders = async (req, res) => {
    try {
        const { page = 1, limit = 20 } = req.query;

        const orders = await Order.find({
            needsManualAssignment: true,
            status: { $nin: ['delivered', 'cancelled'] }
        })
            .populate('customer', 'name phone')
            .populate('merchant', 'businessName')
            .populate('deliveryAddress')
            .sort({ createdAt: -1 })
            .limit(limit * 1)
            .skip((page - 1) * limit);

        const total = await Order.countDocuments({
            needsManualAssignment: true,
            status: { $nin: ['delivered', 'cancelled'] }
        });

        res.json({
            success: true,
            data: {
                orders,
                pagination: {
                    total,
                    page: parseInt(page),
                    pages: Math.ceil(total / limit)
                }
            }
        });
    } catch (error) {
        console.error('Get unassigned orders error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch unassigned orders',
            error: error.message
        });
    }
};

/**
 * @desc    Get all delivery assignments (admin view)
 * @route   GET /api/admin/assignments
 * @access  Private (Admin)
 */
exports.getAllAssignments = async (req, res) => {
    try {
        const { status, driverId, page = 1, limit = 20 } = req.query;

        const query = {};
        if (status) query.status = status;
        if (driverId) query.driver = driverId;

        const assignments = await DeliveryAssignment.find(query)
            .populate('driver', 'name phone vehicleType status')
            .populate('order', 'orderId totalAmount status customer')
            .populate({
                path: 'order',
                populate: { path: 'customer', select: 'name phone' }
            })
            .sort({ assignedAt: -1 })
            .limit(limit * 1)
            .skip((page - 1) * limit);

        const total = await DeliveryAssignment.countDocuments(query);

        res.json({
            success: true,
            data: {
                assignments,
                pagination: {
                    total,
                    page: parseInt(page),
                    pages: Math.ceil(total / limit)
                }
            }
        });
    } catch (error) {
        console.error('Get all assignments error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch assignments',
            error: error.message
        });
    }
};

/**
 * @desc    Get delivery analytics
 * @route   GET /api/admin/agents/analytics
 * @access  Private (Admin)
 */
exports.getDeliveryAnalytics = async (req, res) => {
    try {
        const totalDrivers = await Driver.countDocuments();
        const activeDrivers = await Driver.countDocuments({ status: 'available' });
        const busyDrivers = await Driver.countDocuments({ status: 'busy' });
        const verifiedDrivers = await Driver.countDocuments({ isVerified: true });

        const totalAssignments = await DeliveryAssignment.countDocuments();
        const completedDeliveries = await DeliveryAssignment.countDocuments({ status: 'delivered' });
        const failedDeliveries = await DeliveryAssignment.countDocuments({ status: 'failed' });
        const activeDeliveries = await DeliveryAssignment.countDocuments({
            status: { $in: ['assigned', 'picked_up', 'in_transit'] }
        });

        const unassignedOrders = await Order.countDocuments({
            needsManualAssignment: true,
            status: { $nin: ['delivered', 'cancelled'] }
        });

        res.json({
            success: true,
            data: {
                drivers: {
                    total: totalDrivers,
                    active: activeDrivers,
                    busy: busyDrivers,
                    verified: verifiedDrivers
                },
                deliveries: {
                    total: totalAssignments,
                    completed: completedDeliveries,
                    failed: failedDeliveries,
                    active: activeDeliveries,
                    successRate: totalAssignments > 0
                        ? ((completedDeliveries / totalAssignments) * 100).toFixed(2)
                        : 0
                },
                unassignedOrders
            }
        });
    } catch (error) {
        console.error('Get analytics error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch analytics',
            error: error.message
        });
    }
};
