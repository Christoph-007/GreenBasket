const Merchant = require('../models/Merchant');
const User = require('../models/User');
const Order = require('../models/Order');

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
        const users = await User.find().select('-password');
        res.json({
            success: true,
            data: users
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
