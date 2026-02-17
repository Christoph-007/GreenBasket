const DeliveryAssignment = require('../models/DeliveryAssignment');
const Order = require('../models/Order');
const Driver = require('../models/Driver');

/**
 * @desc    Get agent's current active assignment
 * @route   GET /api/agents/assignments/current
 * @access  Private (Agent)
 */
exports.getCurrentAssignment = async (req, res) => {
    try {
        const assignment = await DeliveryAssignment.findOne({
            driver: req.agent._id,
            status: { $in: ['assigned', 'picked_up', 'in_transit'] }
        })
            .populate('order', 'orderId items totalAmount deliveryAddress deliveryInstructions customer')
            .populate({
                path: 'order',
                populate: {
                    path: 'deliveryAddress',
                    select: 'fullAddress street city state pincode location'
                }
            })
            .populate({
                path: 'order',
                populate: {
                    path: 'customer',
                    select: 'name phone'
                }
            });

        if (!assignment) {
            return res.json({
                success: true,
                message: 'No active assignment',
                data: { assignment: null }
            });
        }

        res.json({
            success: true,
            data: { assignment }
        });
    } catch (error) {
        console.error('Get current assignment error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch current assignment',
            error: error.message
        });
    }
};

/**
 * @desc    Get all assignments for agent (history)
 * @route   GET /api/agents/assignments
 * @access  Private (Agent)
 */
exports.getMyAssignments = async (req, res) => {
    try {
        const { status, page = 1, limit = 20 } = req.query;

        const query = { driver: req.agent._id };

        if (status) {
            query.status = status;
        }

        const assignments = await DeliveryAssignment.find(query)
            .populate('order', 'orderId totalAmount deliveryAddress status')
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
        console.error('Get assignments error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch assignments',
            error: error.message
        });
    }
};

/**
 * @desc    Update delivery assignment status
 * @route   PUT /api/agents/assignments/:id/status
 * @access  Private (Agent)
 */
exports.updateAssignmentStatus = async (req, res) => {
    const session = await DeliveryAssignment.startSession();
    session.startTransaction();

    try {
        const { id } = req.params;
        const { status, note, latitude, longitude } = req.body;

        // Validate status
        const validStatuses = ['picked_up', 'in_transit', 'delivered', 'failed'];
        if (!validStatuses.includes(status)) {
            return res.status(400).json({
                success: false,
                message: `Invalid status. Must be one of: ${validStatuses.join(', ')}`
            });
        }

        // Find assignment
        const assignment = await DeliveryAssignment.findById(id)
            .populate('order')
            .session(session);

        if (!assignment) {
            await session.abortTransaction();
            return res.status(404).json({
                success: false,
                message: 'Assignment not found'
            });
        }

        // Verify agent owns this assignment
        if (assignment.driver.toString() !== req.agent._id.toString()) {
            await session.abortTransaction();
            return res.status(403).json({
                success: false,
                message: 'You can only update your own assignments'
            });
        }

        // Validate status transition
        const currentStatus = assignment.status;
        const validTransitions = {
            'assigned': ['picked_up', 'failed'],
            'picked_up': ['in_transit', 'failed'],
            'in_transit': ['delivered', 'failed']
        };

        if (!validTransitions[currentStatus]?.includes(status)) {
            await session.abortTransaction();
            return res.status(400).json({
                success: false,
                message: `Cannot transition from ${currentStatus} to ${status}`
            });
        }

        // Prepare location data
        let location = null;
        if (latitude !== undefined && longitude !== undefined) {
            location = {
                type: 'Point',
                coordinates: [longitude, latitude]
            };
        }

        // Update assignment status
        await assignment.updateStatus(status, location, note);

        // Handle status-specific logic
        if (status === 'delivered') {
            // 1. Update order status
            const order = await Order.findById(assignment.order._id).session(session);
            order.status = 'delivered';
            order.deliveredAt = new Date();
            await order.save({ session });

            // 2. Update driver status to available
            const driver = await Driver.findById(req.agent._id).session(session);
            driver.status = 'available';
            driver.totalDeliveries += 1;
            driver.totalEarnings += assignment.deliveryFee || 0;
            await driver.save({ session });

        } else if (status === 'failed') {
            // 1. Mark order for manual reassignment
            const order = await Order.findById(assignment.order._id).session(session);
            order.needsManualAssignment = true;
            order.deliveryAssignment = null;
            await order.save({ session });

            // 2. Set driver back to available
            const driver = await Driver.findById(req.agent._id).session(session);
            driver.status = 'available';
            await driver.save({ session });

            // 3. Update assignment failure reason
            if (note) {
                assignment.failureReason = note;
                await assignment.save({ session });
            }
        }

        await session.commitTransaction();

        // Fetch updated assignment
        const updatedAssignment = await DeliveryAssignment.findById(id)
            .populate('order', 'orderId status totalAmount');

        res.json({
            success: true,
            message: `Assignment status updated to ${status}`,
            data: { assignment: updatedAssignment }
        });

    } catch (error) {
        await session.abortTransaction();
        console.error('Update assignment status error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to update assignment status',
            error: error.message
        });
    } finally {
        session.endSession();
    }
};

/**
 * @desc    Get assignment by ID
 * @route   GET /api/agents/assignments/:id
 * @access  Private (Agent)
 */
exports.getAssignmentById = async (req, res) => {
    try {
        const { id } = req.params;

        const assignment = await DeliveryAssignment.findById(id)
            .populate('order')
            .populate({
                path: 'order',
                populate: [
                    { path: 'deliveryAddress' },
                    { path: 'customer', select: 'name phone' }
                ]
            });

        if (!assignment) {
            return res.status(404).json({
                success: false,
                message: 'Assignment not found'
            });
        }

        // Verify ownership
        if (assignment.driver.toString() !== req.agent._id.toString()) {
            return res.status(403).json({
                success: false,
                message: 'Access denied'
            });
        }

        res.json({
            success: true,
            data: { assignment }
        });
    } catch (error) {
        console.error('Get assignment error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch assignment',
            error: error.message
        });
    }
};

/**
 * @desc    Get agent earnings summary
 * @route   GET /api/agents/earnings
 * @access  Private (Agent)
 */
exports.getEarnings = async (req, res) => {
    try {
        const { startDate, endDate } = req.query;

        const query = {
            driver: req.agent._id,
            status: 'delivered'
        };

        if (startDate || endDate) {
            query.deliveredAt = {};
            if (startDate) query.deliveredAt.$gte = new Date(startDate);
            if (endDate) query.deliveredAt.$lte = new Date(endDate);
        }

        const assignments = await DeliveryAssignment.find(query);

        const totalEarnings = assignments.reduce((sum, a) => sum + (a.deliveryFee || 0), 0);
        const totalDeliveries = assignments.length;

        res.json({
            success: true,
            data: {
                totalEarnings,
                totalDeliveries,
                averagePerDelivery: totalDeliveries > 0 ? totalEarnings / totalDeliveries : 0,
                assignments
            }
        });
    } catch (error) {
        console.error('Get earnings error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch earnings',
            error: error.message
        });
    }
};
