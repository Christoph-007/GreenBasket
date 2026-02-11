const Dispute = require('../models/Dispute');
const Order = require('../models/Order');
const Wallet = require('../models/Wallet');

/**
 * @desc    Raise a dispute
 * @route   POST /api/disputes
 * @access  Private (User)
 */
exports.raiseDispute = async (req, res) => {
    try {
        const { orderId, category, description, images } = req.body;

        // Validation
        if (!orderId || !category || !description) {
            return res.status(400).json({
                success: false,
                error: 'orderId, category, and description are required'
            });
        }

        // Find order
        const order = await Order.findOne({ orderId });

        if (!order) {
            return res.status(404).json({
                success: false,
                error: 'Order not found'
            });
        }

        // Check ownership
        if (order.customer.toString() !== req.user._id.toString()) {
            return res.status(403).json({
                success: false,
                error: 'You can only raise disputes for your own orders'
            });
        }

        // Check if order is eligible for dispute
        const eligibleStatuses = ['delivered', 'cancelled'];
        if (!eligibleStatuses.includes(order.status)) {
            return res.status(400).json({
                success: false,
                error: 'Disputes can only be raised for delivered or cancelled orders'
            });
        }

        // Check if dispute already exists for this order
        const existingDispute = await Dispute.findOne({
            order: order._id,
            status: { $nin: ['resolved', 'closed'] }
        });

        if (existingDispute) {
            return res.status(400).json({
                success: false,
                error: 'An active dispute already exists for this order',
                data: {
                    existingDisputeId: existingDispute.disputeId,
                    status: existingDispute.status
                }
            });
        }

        // Determine priority based on category
        const highPriorityCategories = ['missing_item', 'payment_issue', 'damaged_item'];
        const urgentPriorityCategories = ['refund_issue'];
        let priority = 'medium';

        if (urgentPriorityCategories.includes(category)) {
            priority = 'urgent';
        } else if (highPriorityCategories.includes(category)) {
            priority = 'high';
        }

        // Create dispute
        const dispute = await Dispute.create({
            order: order._id,
            raisedBy: {
                user: req.user._id,
                userModel: 'User'
            },
            category,
            description,
            images: images || [],
            priority
        });

        // Notify user
        try {
            const notificationService = require('../services/notification');
            await notificationService.send(
                req.user._id,
                'User',
                {
                    type: 'order_placed',
                    title: 'Dispute Raised',
                    message: `Your dispute for order ${orderId} has been raised. We will review it within 24 hours.`,
                    channels: ['push', 'email'],
                    data: {
                        disputeId: dispute.disputeId,
                        orderId
                    }
                }
            );
        } catch (notifError) {
            console.error('Notification error:', notifError);
        }

        res.status(201).json({
            success: true,
            message: 'Dispute raised successfully',
            data: {
                disputeId: dispute.disputeId,
                _id: dispute._id,
                status: dispute.status,
                category: dispute.category,
                priority: dispute.priority
            }
        });
    } catch (error) {
        console.error('Raise dispute error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to raise dispute',
            details: error.message
        });
    }
};

/**
 * @desc    Get my disputes
 * @route   GET /api/disputes/my-disputes
 * @access  Private (User)
 */
exports.getMyDisputes = async (req, res) => {
    try {
        const { status, page = 1, limit = 10 } = req.query;

        const query = { 'raisedBy.user': req.user._id };

        if (status) {
            query.status = status;
        }

        const skip = (page - 1) * limit;

        const [disputes, total] = await Promise.all([
            Dispute.find(query)
                .populate('order', 'orderId totalAmount createdAt items')
                .sort({ createdAt: -1 })
                .skip(skip)
                .limit(parseInt(limit)),
            Dispute.countDocuments(query)
        ]);

        res.json({
            success: true,
            data: {
                disputes,
                pagination: {
                    page: parseInt(page),
                    limit: parseInt(limit),
                    total,
                    pages: Math.ceil(total / limit)
                }
            }
        });
    } catch (error) {
        console.error('Get my disputes error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch disputes',
            details: error.message
        });
    }
};

/**
 * @desc    Get dispute by ID
 * @route   GET /api/disputes/:id
 * @access  Private (User/Admin)
 */
exports.getDisputeById = async (req, res) => {
    try {
        const { id } = req.params;

        const dispute = await Dispute.findById(id)
            .populate('order', 'orderId totalAmount items createdAt')
            .populate('raisedBy.user', 'name email phone')
            .populate('resolution.resolvedBy', 'name')
            .populate('conversation.from', 'name');

        if (!dispute) {
            return res.status(404).json({
                success: false,
                error: 'Dispute not found'
            });
        }

        // Check access
        const isOwner = dispute.raisedBy.user._id.toString() === req.user._id.toString();
        const isAdmin = req.user.userType === 'admin';

        if (!isOwner && !isAdmin) {
            return res.status(403).json({
                success: false,
                error: 'Access denied'
            });
        }

        res.json({
            success: true,
            data: {
                dispute
            }
        });
    } catch (error) {
        console.error('Get dispute by ID error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch dispute',
            details: error.message
        });
    }
};

/**
 * @desc    Add message to dispute
 * @route   POST /api/disputes/:id/message
 * @access  Private (User/Admin)
 */
exports.addMessage = async (req, res) => {
    try {
        const { id } = req.params;
        const { message, attachments } = req.body;

        if (!message || message.trim().length === 0) {
            return res.status(400).json({
                success: false,
                error: 'Message is required'
            });
        }

        const dispute = await Dispute.findById(id);

        if (!dispute) {
            return res.status(404).json({
                success: false,
                error: 'Dispute not found'
            });
        }

        // Check access
        const isOwner = dispute.raisedBy.user.toString() === req.user._id.toString();
        const isAdmin = req.user.userType === 'admin';

        if (!isOwner && !isAdmin) {
            return res.status(403).json({
                success: false,
                error: 'Access denied'
            });
        }

        // Cannot add message to resolved/closed dispute
        if (['resolved', 'closed'].includes(dispute.status)) {
            return res.status(400).json({
                success: false,
                error: 'Cannot add message to a resolved or closed dispute'
            });
        }

        // Add message
        dispute.conversation.push({
            from: req.user._id,
            fromModel: req.user.userType === 'admin' ? 'Admin' : 'User',
            message: message.trim(),
            attachments: attachments || [],
            timestamp: new Date()
        });

        // If admin responds, update status to investigating
        if (isAdmin && dispute.status === 'open') {
            dispute.status = 'investigating';
        }

        await dispute.save();

        // Populate the conversation before returning
        await dispute.populate('conversation.from', 'name');

        // Notify the other party
        try {
            const notificationService = require('../services/notification');

            if (isAdmin) {
                // Notify user
                await notificationService.send(
                    dispute.raisedBy.user,
                    'User',
                    {
                        type: 'order_placed',
                        title: 'Dispute Update',
                        message: `Admin has responded to your dispute ${dispute.disputeId}`,
                        channels: ['push', 'email'],
                        data: { disputeId: dispute.disputeId }
                    }
                );
            }
        } catch (notifError) {
            console.error('Notification error:', notifError);
        }

        res.json({
            success: true,
            message: 'Message added to dispute',
            data: {
                conversation: dispute.conversation,
                status: dispute.status
            }
        });
    } catch (error) {
        console.error('Add message error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to add message',
            details: error.message
        });
    }
};

/**
 * @desc    Get all disputes (Admin)
 * @route   GET /api/disputes/admin/all
 * @access  Private (Admin)
 */
exports.getAllDisputes = async (req, res) => {
    try {
        const { status, priority, category, page = 1, limit = 20 } = req.query;

        const query = {};

        if (status) query.status = status;
        if (priority) query.priority = priority;
        if (category) query.category = category;

        const skip = (page - 1) * limit;

        const [disputes, total, openCount, investigatingCount, urgentCount] = await Promise.all([
            Dispute.find(query)
                .populate('raisedBy.user', 'name email phone')
                .populate('order', 'orderId totalAmount merchant')
                .sort({ priority: -1, createdAt: -1 })
                .skip(skip)
                .limit(parseInt(limit)),
            Dispute.countDocuments(query),
            Dispute.countDocuments({ status: 'open' }),
            Dispute.countDocuments({ status: 'investigating' }),
            Dispute.countDocuments({ priority: 'urgent', status: { $nin: ['resolved', 'closed'] } })
        ]);

        res.json({
            success: true,
            data: {
                disputes,
                stats: {
                    totalOpen: openCount,
                    totalInvestigating: investigatingCount,
                    totalUrgent: urgentCount
                },
                pagination: {
                    page: parseInt(page),
                    limit: parseInt(limit),
                    total,
                    pages: Math.ceil(total / limit)
                }
            }
        });
    } catch (error) {
        console.error('Get all disputes error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch disputes',
            details: error.message
        });
    }
};

/**
 * @desc    Resolve dispute (Admin)
 * @route   PUT /api/disputes/admin/:id/resolve
 * @access  Private (Admin)
 */
exports.resolveDispute = async (req, res) => {
    try {
        const { id } = req.params;
        const { resolutionType, amount, description } = req.body;

        if (!resolutionType || !description) {
            return res.status(400).json({
                success: false,
                error: 'resolutionType and description are required'
            });
        }

        const validResolutionTypes = ['refund', 'replacement', 'partial_refund', 'compensation', 'no_action'];
        if (!validResolutionTypes.includes(resolutionType)) {
            return res.status(400).json({
                success: false,
                error: `resolutionType must be one of: ${validResolutionTypes.join(', ')}`
            });
        }

        if (['refund', 'partial_refund', 'compensation'].includes(resolutionType) && !amount) {
            return res.status(400).json({
                success: false,
                error: 'Amount is required for refund/compensation resolutions'
            });
        }

        const dispute = await Dispute.findById(id)
            .populate('order')
            .populate('raisedBy.user', 'name email');

        if (!dispute) {
            return res.status(404).json({
                success: false,
                error: 'Dispute not found'
            });
        }

        if (['resolved', 'closed'].includes(dispute.status)) {
            return res.status(400).json({
                success: false,
                error: 'Dispute is already resolved'
            });
        }

        // Update dispute
        dispute.status = 'resolved';
        dispute.resolution = {
            type: resolutionType,
            amount: amount || 0,
            description,
            resolvedBy: req.user._id,
            resolvedAt: new Date()
        };

        await dispute.save();

        // Process refund/compensation to wallet if applicable
        if (['refund', 'partial_refund', 'compensation'].includes(resolutionType) && amount > 0) {
            let wallet = await Wallet.findOne({ user: dispute.raisedBy.user._id });

            if (!wallet) {
                wallet = await Wallet.create({
                    user: dispute.raisedBy.user._id,
                    balance: 0,
                    transactions: []
                });
            }

            const balanceBefore = wallet.balance;
            wallet.balance += amount;

            wallet.transactions.push({
                type: 'credit',
                amount,
                source: 'refund',
                description: `Dispute resolution - ${dispute.disputeId}: ${description}`,
                orderId: dispute.order._id,
                balanceBefore,
                balanceAfter: wallet.balance,
                status: 'completed'
            });

            await wallet.save();
        }

        // Notify user
        try {
            const notificationService = require('../services/notification');
            await notificationService.send(
                dispute.raisedBy.user._id,
                'User',
                {
                    type: 'order_delivered',
                    title: 'Dispute Resolved',
                    message: `Your dispute ${dispute.disputeId} has been resolved. ${amount > 0 ? `₹${amount} has been credited to your wallet.` : ''
                        }`,
                    channels: ['push', 'email'],
                    data: {
                        disputeId: dispute.disputeId,
                        resolution: resolutionType,
                        amount
                    }
                }
            );
        } catch (notifError) {
            console.error('Notification error:', notifError);
        }

        res.json({
            success: true,
            message: 'Dispute resolved successfully',
            data: {
                dispute: {
                    disputeId: dispute.disputeId,
                    status: dispute.status,
                    resolution: dispute.resolution
                }
            }
        });
    } catch (error) {
        console.error('Resolve dispute error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to resolve dispute',
            details: error.message
        });
    }
};

/**
 * @desc    Escalate dispute
 * @route   PATCH /api/disputes/:id/escalate
 * @access  Private (User)
 */
exports.escalateDispute = async (req, res) => {
    try {
        const { id } = req.params;

        const dispute = await Dispute.findById(id);

        if (!dispute) {
            return res.status(404).json({
                success: false,
                error: 'Dispute not found'
            });
        }

        // Check ownership
        if (dispute.raisedBy.user.toString() !== req.user._id.toString()) {
            return res.status(403).json({
                success: false,
                error: 'You can only escalate your own disputes'
            });
        }

        if (['resolved', 'closed'].includes(dispute.status)) {
            return res.status(400).json({
                success: false,
                error: 'Cannot escalate a resolved or closed dispute'
            });
        }

        if (dispute.status === 'escalated') {
            return res.status(400).json({
                success: false,
                error: 'Dispute is already escalated'
            });
        }

        dispute.status = 'escalated';
        dispute.priority = 'urgent';

        await dispute.save();

        res.json({
            success: true,
            message: 'Dispute escalated to urgent priority',
            data: {
                disputeId: dispute.disputeId,
                status: dispute.status,
                priority: dispute.priority
            }
        });
    } catch (error) {
        console.error('Escalate dispute error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to escalate dispute',
            details: error.message
        });
    }
};

/**
 * @desc    Update dispute status (Admin)
 * @route   PATCH /api/disputes/admin/:id/status
 * @access  Private (Admin)
 */
exports.updateDisputeStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body;

        const validStatuses = ['open', 'investigating', 'resolved', 'closed', 'escalated'];

        if (!status || !validStatuses.includes(status)) {
            return res.status(400).json({
                success: false,
                error: `status must be one of: ${validStatuses.join(', ')}`
            });
        }

        const dispute = await Dispute.findById(id);

        if (!dispute) {
            return res.status(404).json({
                success: false,
                error: 'Dispute not found'
            });
        }

        const previousStatus = dispute.status;
        dispute.status = status;

        await dispute.save();

        // Notify user of status change
        try {
            const notificationService = require('../services/notification');
            await notificationService.send(
                dispute.raisedBy.user,
                'User',
                {
                    type: 'order_placed',
                    title: 'Dispute Status Updated',
                    message: `Your dispute ${dispute.disputeId} status has been updated to ${status}`,
                    channels: ['push'],
                    data: {
                        disputeId: dispute.disputeId,
                        previousStatus,
                        newStatus: status
                    }
                }
            );
        } catch (notifError) {
            console.error('Notification error:', notifError);
        }

        res.json({
            success: true,
            message: `Dispute status updated to ${status}`,
            data: {
                disputeId: dispute.disputeId,
                status: dispute.status,
                previousStatus
            }
        });
    } catch (error) {
        console.error('Update dispute status error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to update dispute status',
            details: error.message
        });
    }
};

module.exports = exports;
