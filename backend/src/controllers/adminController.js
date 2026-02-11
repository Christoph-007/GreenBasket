const Merchant = require('../models/Merchant');
const User = require('../models/User');
const Order = require('../models/Order');
const Subscription = require('../models/Subscription');

exports.getPendingMerchants = async (req, res) => {
    try {
        const merchants = await Merchant.find({ verificationStatus: 'pending' });
        res.json({
            success: true,
            data: merchants
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching pending merchants',
            error: error.message
        });
    }
};

exports.verifyMerchant = async (req, res) => {
    try {
        const { id } = req.params;
        const { status, rejectionReason } = req.body; // status: 'approved' or 'rejected'

        const merchant = await Merchant.findById(id);
        if (!merchant) {
            return res.status(404).json({
                success: false,
                message: 'Merchant not found'
            });
        }

        merchant.verificationStatus = status;
        merchant.verifiedBy = req.user.id;
        merchant.verifiedAt = new Date();

        if (status === 'rejected') {
            merchant.rejectionReason = rejectionReason;
        }

        await merchant.save();

        // Send email notification (todo)

        res.json({
            success: true,
            message: `Merchant ${status}`,
            data: merchant
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error updating merchant status',
            error: error.message
        });
    }
};

exports.getUsers = async (req, res) => {
    try {
        const { page = 1, limit = 20, search } = req.query;
        let query = {};

        if (search) {
            query = {
                $or: [
                    { name: { $regex: search, $options: 'i' } },
                    { email: { $regex: search, $options: 'i' } }
                ]
            };
        }

        const skip = (page - 1) * limit;

        const [users, total] = await Promise.all([
            User.find(query)
                .select('-password')
                .sort({ createdAt: -1 })
                .skip(skip)
                .limit(parseInt(limit)),
            User.countDocuments(query)
        ]);

        res.json({
            success: true,
            data: {
                users,
                pagination: {
                    page: parseInt(page),
                    limit: parseInt(limit),
                    total,
                    pages: Math.ceil(total / limit)
                }
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching users',
            error: error.message
        });
    }
};

exports.toggleUserBlock = async (req, res) => {
    try {
        const { id } = req.params;
        const { isBlocked, blockedReason } = req.body;

        const user = await User.findByIdAndUpdate(
            id,
            { isBlocked, blockedReason },
            { new: true }
        );

        res.json({
            success: true,
            message: `User ${isBlocked ? 'blocked' : 'unblocked'}`,
            data: user
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error updating user status',
            error: error.message
        });
    }
};

exports.getPlatformStats = async (req, res) => {
    try {
        const [userCount, merchantCount, orderCount] = await Promise.all([
            User.countDocuments(),
            Merchant.countDocuments(),
            Order.countDocuments()
        ]);

        res.json({
            success: true,
            data: {
                totalUsers: userCount,
                totalMerchants: merchantCount,
                totalOrders: orderCount
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching platform stats',
            error: error.message
        });
    }
};

exports.getAllMerchants = async (req, res) => {
    try {
        const { page = 1, limit = 20, status, search } = req.query;
        let query = {};

        if (status) query.verificationStatus = status;
        if (search) {
            query.$or = [
                { businessName: { $regex: search, $options: 'i' } },
                { email: { $regex: search, $options: 'i' } }
            ];
        }

        const skip = (page - 1) * limit;

        const [merchants, total] = await Promise.all([
            Merchant.find(query)
                .select('-password -bankDetails')
                .sort({ createdAt: -1 })
                .skip(skip)
                .limit(parseInt(limit)),
            Merchant.countDocuments(query)
        ]);

        res.json({
            success: true,
            data: {
                merchants,
                pagination: {
                    page: parseInt(page),
                    limit: parseInt(limit),
                    total,
                    pages: Math.ceil(total / limit)
                }
            }
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.getAllSubscriptions = async (req, res) => {
    try {
        const { page = 1, limit = 20, status } = req.query;
        let query = {};
        if (status) query.status = status;

        const skip = (page - 1) * limit;

        const [subscriptions, total] = await Promise.all([
            Subscription.find(query)
                .populate('user', 'name email')
                .populate('merchant', 'businessName')
                .sort({ createdAt: -1 })
                .skip(skip)
                .limit(parseInt(limit)),
            Subscription.countDocuments(query)
        ]);

        res.json({
            success: true,
            data: {
                subscriptions,
                pagination: {
                    page: parseInt(page),
                    limit: parseInt(limit),
                    total,
                    pages: Math.ceil(total / limit)
                }
            }
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};
