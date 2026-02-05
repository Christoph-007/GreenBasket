const Merchant = require('../models/Merchant');
const Order = require('../models/Order');
const Product = require('../models/Product');
const mongoose = require('mongoose');

exports.getProfile = async (req, res) => {
    try {
        const merchant = await Merchant.findById(req.user.id);
        res.json({
            success: true,
            data: merchant
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching profile',
            error: error.message
        });
    }
};

exports.updateProfile = async (req, res) => {
    try {
        const {
            businessName, businessDescription, address,
            operatingHours, deliveryRadius, minimumOrderValue,
            deliveryCharges, bankDetails
        } = req.body;

        const merchant = await Merchant.findByIdAndUpdate(
            req.user.id,
            {
                businessName, businessDescription, address,
                operatingHours, deliveryRadius, minimumOrderValue,
                deliveryCharges, bankDetails
            },
            { new: true, runValidators: true }
        );

        res.json({
            success: true,
            message: 'Merchant profile updated',
            data: merchant
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error updating profile',
            error: error.message
        });
    }
};

exports.toggleStoreStatus = async (req, res) => {
    try {
        const merchant = await Merchant.findById(req.user.id);
        merchant.isStoreOpen = !merchant.isStoreOpen;
        await merchant.save();

        res.json({
            success: true,
            message: `Store is now ${merchant.isStoreOpen ? 'Open' : 'Closed'}`,
            isStoreOpen: merchant.isStoreOpen
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error toggling store status',
            error: error.message
        });
    }
};

exports.getDashboardStats = async (req, res) => {
    try {
        const merchantId = req.user.id;

        const [totalOrders, totalRevenueData, lowStockProducts] = await Promise.all([
            Order.countDocuments({ merchant: merchantId }),
            Order.aggregate([
                { $match: { merchant: new mongoose.Types.ObjectId(merchantId), status: 'delivered' } },
                { $group: { _id: null, total: { $sum: '$totalAmount' } } }
            ]),
            Product.countDocuments({ merchant: merchantId, stock: { $lte: 10 } }) // Assuming 10 is low stock
        ]);

        const totalRevenue = totalRevenueData.length > 0 ? totalRevenueData[0].total : 0;

        res.json({
            success: true,
            data: {
                totalOrders,
                totalRevenue,
                lowStockProducts
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching stats',
            error: error.message
        });
    }
};
