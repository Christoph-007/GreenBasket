const Payout = require('../models/Payout');
const Order = require('../models/Order');
const PlatformSettings = require('../models/PlatformSettings');
const Merchant = require('../models/Merchant');

/**
 * @desc    Get merchant earnings
 * @route   GET /api/financial/merchants/earnings
 * @access  Private (Merchant)
 */
exports.getMerchantEarnings = async (req, res) => {
    try {
        const merchantId = req.user._id;

        // Get platform settings for commission rate
        const settings = await PlatformSettings.findOne() ||
            { commission: { defaultRate: 5 }, payoutSchedule: 'weekly', minimumPayoutAmount: 1000 };

        const commissionRate = settings.commission.defaultRate;

        // Calculate current period (this week)
        const now = new Date();
        const dayOfWeek = now.getDay();
        const startOfWeek = new Date(now);
        startOfWeek.setDate(now.getDate() - dayOfWeek);
        startOfWeek.setHours(0, 0, 0, 0);

        const endOfWeek = new Date(startOfWeek);
        endOfWeek.setDate(startOfWeek.getDate() + 6);
        endOfWeek.setHours(23, 59, 59, 999);

        // Get current period orders
        const currentPeriodOrders = await Order.find({
            merchant: merchantId,
            status: 'delivered',
            deliveredAt: {
                $gte: startOfWeek,
                $lte: endOfWeek
            }
        });

        const currentPeriodRevenue = currentPeriodOrders.reduce(
            (sum, o) => sum + o.totalAmount, 0
        );
        const currentPeriodCommission = (currentPeriodRevenue * commissionRate) / 100;
        const currentPeriodNet = currentPeriodRevenue - currentPeriodCommission;

        // Get all completed payouts
        const completedPayouts = await Payout.find({
            merchant: merchantId,
            status: 'completed'
        });

        const totalWithdrawn = completedPayouts.reduce(
            (sum, p) => sum + p.netAmount, 0
        );

        // Get all delivered orders (total earnings)
        const allOrders = await Order.find({
            merchant: merchantId,
            status: 'delivered'
        });

        const totalRevenue = allOrders.reduce((sum, o) => sum + o.totalAmount, 0);
        const totalCommission = (totalRevenue * commissionRate) / 100;
        const totalEarned = totalRevenue - totalCommission;

        const pendingAmount = totalEarned - totalWithdrawn;

        // Next payout date
        const nextPayoutDate = new Date(endOfWeek);
        nextPayoutDate.setDate(nextPayoutDate.getDate() + 1);

        res.json({
            success: true,
            data: {
                pendingAmount: Math.max(0, pendingAmount),
                totalEarned,
                totalWithdrawn,
                ordersCount: currentPeriodOrders.length,
                nextPayoutDate,
                estimatedPayout: currentPeriodNet >= settings.minimumPayoutAmount
                    ? currentPeriodNet
                    : 0,
                minimumPayoutAmount: settings.minimumPayoutAmount,
                commissionRate,
                currentPeriod: {
                    startDate: startOfWeek,
                    endDate: endOfWeek,
                    revenue: currentPeriodRevenue,
                    commission: currentPeriodCommission,
                    netAmount: currentPeriodNet,
                    ordersCount: currentPeriodOrders.length
                }
            }
        });
    } catch (error) {
        console.error('Get merchant earnings error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch merchant earnings',
            details: error.message
        });
    }
};

/**
 * @desc    Get merchant payouts
 * @route   GET /api/financial/merchants/payouts
 * @access  Private (Merchant)
 */
exports.getMerchantPayouts = async (req, res) => {
    try {
        const { status, page = 1, limit = 10 } = req.query;
        const merchantId = req.user._id;

        const query = { merchant: merchantId };
        if (status) query.status = status;

        const skip = (page - 1) * limit;

        const [payouts, total] = await Promise.all([
            Payout.find(query)
                .sort({ createdAt: -1 })
                .skip(skip)
                .limit(parseInt(limit)),
            Payout.countDocuments(query)
        ]);

        res.json({
            success: true,
            data: {
                payouts,
                pagination: {
                    page: parseInt(page),
                    limit: parseInt(limit),
                    total,
                    pages: Math.ceil(total / limit)
                }
            }
        });
    } catch (error) {
        console.error('Get merchant payouts error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch payout history',
            details: error.message
        });
    }
};

/**
 * @desc    Generate payouts (Admin)
 * @route   POST /api/financial/admin/payouts/generate
 * @access  Private (Admin)
 */
exports.generatePayouts = async (req, res) => {
    try {
        const { period } = req.body;

        if (!period || !period.startDate || !period.endDate) {
            return res.status(400).json({
                success: false,
                error: 'period.startDate and period.endDate are required'
            });
        }

        const startDate = new Date(period.startDate);
        const endDate = new Date(period.endDate);
        endDate.setHours(23, 59, 59, 999);

        if (startDate >= endDate) {
            return res.status(400).json({
                success: false,
                error: 'endDate must be after startDate'
            });
        }

        // Get platform settings
        const settings = await PlatformSettings.findOne() ||
            { commission: { defaultRate: 5 }, minimumPayoutAmount: 1000 };

        // Get all merchants with delivered orders in this period
        const merchants = await Merchant.find({ verificationStatus: 'approved' });

        const results = {
            payoutsGenerated: 0,
            totalAmount: 0,
            skipped: 0,
            skipReason: 'Below minimum payout amount'
        };

        for (const merchant of merchants) {
            // Get orders for this merchant in this period
            const orders = await Order.find({
                merchant: merchant._id,
                status: 'delivered',
                deliveredAt: {
                    $gte: startDate,
                    $lte: endDate
                }
            });

            if (orders.length === 0) continue;

            // Check for existing payout for this period
            const existingPayout = await Payout.findOne({
                merchant: merchant._id,
                'period.startDate': startDate,
                'period.endDate': endDate
            });

            if (existingPayout) continue;

            // Calculate amounts
            const grossRevenue = orders.reduce((sum, o) => sum + o.totalAmount, 0);
            const commissionRate = settings.commission.defaultRate;
            const commissionAmount = (grossRevenue * commissionRate) / 100;
            const refunds = orders
                .filter(o => o.refund?.status === 'completed')
                .reduce((sum, o) => sum + (o.refund?.amount || 0), 0);
            const netAmount = grossRevenue - commissionAmount - refunds;

            // Skip if below minimum payout amount
            if (netAmount < settings.minimumPayoutAmount) {
                results.skipped++;
                continue;
            }

            // Build breakdown
            const breakdown = orders.map(order => ({
                orderId: order.orderId,
                orderAmount: order.totalAmount,
                commissionAmount: (order.totalAmount * commissionRate) / 100,
                netAmount: order.totalAmount - (order.totalAmount * commissionRate) / 100
            }));

            // Create payout
            await Payout.create({
                merchant: merchant._id,
                period: { startDate, endDate },
                totalOrders: orders.length,
                grossRevenue,
                platformCommission: {
                    rate: commissionRate,
                    amount: commissionAmount
                },
                refunds,
                netAmount,
                breakdown,
                status: 'pending'
            });

            results.payoutsGenerated++;
            results.totalAmount += netAmount;
        }

        res.json({
            success: true,
            message: 'Payouts generated successfully',
            data: results
        });
    } catch (error) {
        console.error('Generate payouts error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to generate payouts',
            details: error.message
        });
    }
};

/**
 * @desc    Process payout (Admin)
 * @route   POST /api/financial/admin/payouts/:id/process
 * @access  Private (Admin)
 */
exports.processPayout = async (req, res) => {
    try {
        const { id } = req.params;
        const { method, transactionId, notes } = req.body;

        if (!method || !transactionId) {
            return res.status(400).json({
                success: false,
                error: 'method and transactionId are required'
            });
        }

        const payout = await Payout.findById(id)
            .populate('merchant', 'businessName email');

        if (!payout) {
            return res.status(404).json({
                success: false,
                error: 'Payout not found'
            });
        }

        if (payout.status === 'completed') {
            return res.status(400).json({
                success: false,
                error: 'Payout already processed'
            });
        }

        payout.status = 'completed';
        payout.paymentDetails = {
            method,
            transactionId,
            processedAt: new Date()
        };

        if (notes) payout.notes = notes;

        await payout.save();

        // Notify merchant
        try {
            const notificationService = require('../services/notification');
            await notificationService.send(
                payout.merchant._id,
                'Merchant',
                {
                    type: 'payment_received',
                    title: 'Payout Processed',
                    message: `Your payout of ₹${payout.netAmount} for the period ${payout.period.startDate.toDateString()
                        } - ${payout.period.endDate.toDateString()
                        } has been processed`,
                    channels: ['push', 'email'],
                    data: {
                        payoutId: payout.payoutId,
                        amount: payout.netAmount,
                        transactionId
                    }
                }
            );
        } catch (notifError) {
            console.error('Notification error:', notifError);
        }

        res.json({
            success: true,
            message: 'Payout processed successfully',
            data: {
                payoutId: payout.payoutId,
                status: payout.status,
                processedAt: payout.paymentDetails.processedAt
            }
        });
    } catch (error) {
        console.error('Process payout error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to process payout',
            details: error.message
        });
    }
};

/**
 * @desc    Get financial reports (Admin)
 * @route   GET /api/financial/admin/reports/financial
 * @access  Private (Admin)
 */
exports.getFinancialReports = async (req, res) => {
    try {
        const { period = 'month', year, month } = req.query;

        const now = new Date();
        let startDate, endDate;

        if (period === 'month') {
            const y = year ? parseInt(year) : now.getFullYear();
            const m = month ? parseInt(month) - 1 : now.getMonth();
            startDate = new Date(y, m, 1);
            endDate = new Date(y, m + 1, 0, 23, 59, 59, 999);
        } else if (period === 'quarter') {
            const y = year ? parseInt(year) : now.getFullYear();
            const currentQuarter = Math.floor(now.getMonth() / 3);
            startDate = new Date(y, currentQuarter * 3, 1);
            endDate = new Date(y, (currentQuarter + 1) * 3, 0, 23, 59, 59, 999);
        } else if (period === 'year') {
            const y = year ? parseInt(year) : now.getFullYear();
            startDate = new Date(y, 0, 1);
            endDate = new Date(y, 11, 31, 23, 59, 59, 999);
        }

        // Get all delivered orders in period
        const orders = await Order.find({
            status: 'delivered',
            deliveredAt: { $gte: startDate, $lte: endDate }
        }).populate('merchant', 'businessName');

        const totalGrossRevenue = orders.reduce((sum, o) => sum + o.totalAmount, 0);
        const settings = await PlatformSettings.findOne() ||
            { commission: { defaultRate: 5 } };
        const totalCommissionEarned = (totalGrossRevenue * settings.commission.defaultRate) / 100;

        const totalRefunds = orders
            .filter(o => o.refund?.status === 'completed')
            .reduce((sum, o) => sum + (o.refund?.amount || 0), 0);

        // Get payouts
        const payouts = await Payout.find({
            'period.startDate': { $gte: startDate },
            'period.endDate': { $lte: endDate }
        });

        const payoutsPaid = payouts
            .filter(p => p.status === 'completed')
            .reduce((sum, p) => sum + p.netAmount, 0);

        const payoutsPending = payouts
            .filter(p => p.status === 'pending')
            .reduce((sum, p) => sum + p.netAmount, 0);

        // Top merchants
        const merchantRevenue = {};
        orders.forEach(order => {
            const mId = order.merchant._id.toString();
            if (!merchantRevenue[mId]) {
                merchantRevenue[mId] = {
                    merchant: order.merchant,
                    revenue: 0,
                    orders: 0,
                    commission: 0
                };
            }
            merchantRevenue[mId].revenue += order.totalAmount;
            merchantRevenue[mId].orders++;
            merchantRevenue[mId].commission += (order.totalAmount * settings.commission.defaultRate) / 100;
        });

        const topMerchants = Object.values(merchantRevenue)
            .sort((a, b) => b.revenue - a.revenue)
            .slice(0, 10);

        res.json({
            success: true,
            data: {
                period: `${startDate.toDateString()} - ${endDate.toDateString()}`,
                summary: {
                    totalGrossRevenue,
                    totalCommissionEarned,
                    totalRefunds,
                    netRevenue: totalGrossRevenue - totalRefunds,
                    payoutsPaid,
                    payoutsPending,
                    totalOrders: orders.length
                },
                topMerchants
            }
        });
    } catch (error) {
        console.error('Get financial reports error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to generate financial report',
            details: error.message
        });
    }
};

/**
 * @desc    Update commission settings (Admin)
 * @route   PUT /api/financial/admin/settings/commission
 * @access  Private (Admin)
 */
exports.updateCommissionSettings = async (req, res) => {
    try {
        const { defaultRate, premiumMerchantRate, payoutSchedule, minimumPayoutAmount } = req.body;

        let settings = await PlatformSettings.findOne();

        if (!settings) {
            settings = new PlatformSettings();
        }

        if (defaultRate !== undefined) {
            if (defaultRate < 0 || defaultRate > 50) {
                return res.status(400).json({
                    success: false,
                    error: 'Commission rate must be between 0 and 50 percent'
                });
            }
            settings.commission.defaultRate = defaultRate;
        }

        if (premiumMerchantRate !== undefined) {
            settings.commission.premiumMerchantRate = premiumMerchantRate;
        }

        if (payoutSchedule) {
            settings.payoutSchedule = payoutSchedule;
        }

        if (minimumPayoutAmount !== undefined) {
            settings.minimumPayoutAmount = minimumPayoutAmount;
        }

        await settings.save();

        res.json({
            success: true,
            message: 'Commission settings updated successfully',
            data: {
                settings: {
                    commission: settings.commission,
                    payoutSchedule: settings.payoutSchedule,
                    minimumPayoutAmount: settings.minimumPayoutAmount
                }
            }
        });
    } catch (error) {
        console.error('Update commission settings error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to update commission settings',
            details: error.message
        });
    }
};

/**
 * @desc    Get GST report (Admin)
 * @route   GET /api/financial/admin/reports/gst
 * @access  Private (Admin)
 */
exports.getGSTReport = async (req, res) => {
    try {
        const { quarter, year } = req.query;
        const y = year ? parseInt(year) : new Date().getFullYear();

        let startMonth, endMonth;

        switch (quarter) {
            case 'Q1': startMonth = 0; endMonth = 2; break;
            case 'Q2': startMonth = 3; endMonth = 5; break;
            case 'Q3': startMonth = 6; endMonth = 8; break;
            case 'Q4': startMonth = 9; endMonth = 11; break;
            default:
                const currentMonth = new Date().getMonth();
                startMonth = Math.floor(currentMonth / 3) * 3;
                endMonth = startMonth + 2;
        }

        const startDate = new Date(y, startMonth, 1);
        const endDate = new Date(y, endMonth + 1, 0, 23, 59, 59, 999);

        const orders = await Order.find({
            status: 'delivered',
            deliveredAt: { $gte: startDate, $lte: endDate }
        });

        const settings = await PlatformSettings.findOne();
        const gstRate = settings?.taxSettings?.gstRate || 18;

        const totalRevenue = orders.reduce((sum, o) => sum + o.totalAmount, 0);
        const commissionRate = settings?.commission?.defaultRate || 5;
        const totalCommission = (totalRevenue * commissionRate) / 100;
        const gstOnCommission = (totalCommission * gstRate) / 100;

        res.json({
            success: true,
            data: {
                period: `${quarter || 'Current Quarter'} ${y}`,
                startDate,
                endDate,
                totalRevenue,
                totalCommission,
                gstRate,
                gstOnCommission,
                totalTaxableAmount: totalCommission,
                totalTaxAmount: gstOnCommission,
                totalOrders: orders.length,
                gstNumber: settings?.taxSettings?.gstNumber
            }
        });
    } catch (error) {
        console.error('Get GST report error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to generate GST report',
            details: error.message
        });
    }
};

/**
 * @desc    Get all payouts (Admin)
 * @route   GET /api/financial/admin/payouts
 * @access  Private (Admin)
 */
exports.getAllPayouts = async (req, res) => {
    try {
        const { status = 'pending', page = 1, limit = 20 } = req.query;

        const query = {};
        if (status) query.status = status;

        const skip = (page - 1) * limit;

        const [payouts, total] = await Promise.all([
            Payout.find(query)
                .populate('merchant', 'businessName email')
                .sort({ createdAt: -1 })
                .skip(skip)
                .limit(parseInt(limit)),
            Payout.countDocuments(query)
        ]);

        const totalAmount = payouts.reduce((sum, p) => sum + p.netAmount, 0);

        res.json({
            success: true,
            data: {
                payouts,
                totalAmount,
                pagination: {
                    page: parseInt(page),
                    limit: parseInt(limit),
                    total,
                    pages: Math.ceil(total / limit)
                }
            }
        });
    } catch (error) {
        console.error('Get all payouts error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch payouts',
            details: error.message
        });
    }
};

/**
 * @desc    Get payout by ID
 * @route   GET /api/financial/payouts/:id
 * @access  Private (Admin/Merchant)
 */
exports.getPayoutById = async (req, res) => {
    try {
        const { id } = req.params;

        const payout = await Payout.findById(id)
            .populate('merchant', 'businessName email');

        if (!payout) {
            return res.status(404).json({
                success: false,
                error: 'Payout not found'
            });
        }

        // Check access
        const isAdmin = req.user.userType === 'admin';
        const isMerchant = payout.merchant._id.toString() === req.user._id.toString();

        if (!isAdmin && !isMerchant) {
            return res.status(403).json({
                success: false,
                error: 'Access denied'
            });
        }

        res.json({
            success: true,
            data: { payout }
        });
    } catch (error) {
        console.error('Get payout by ID error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch payout',
            details: error.message
        });
    }
};

/**
 * @desc    Hold/Release payout (Admin)
 * @route   PATCH /api/financial/admin/payouts/:id/hold
 * @access  Private (Admin)
 */
exports.holdReleasePayout = async (req, res) => {
    try {
        const { id } = req.params;
        const { hold, reason } = req.body;

        if (hold === undefined) {
            return res.status(400).json({
                success: false,
                error: 'hold parameter is required'
            });
        }

        if (hold && !reason) {
            return res.status(400).json({
                success: false,
                error: 'Reason is required when holding a payout'
            });
        }

        const payout = await Payout.findById(id)
            .populate('merchant', 'businessName');

        if (!payout) {
            return res.status(404).json({
                success: false,
                error: 'Payout not found'
            });
        }

        if (payout.status === 'completed') {
            return res.status(400).json({
                success: false,
                error: 'Cannot hold a completed payout'
            });
        }

        payout.status = hold ? 'on_hold' : 'pending';
        if (hold) payout.notes = reason;

        await payout.save();

        // Notify merchant
        try {
            const notificationService = require('../services/notification');
            await notificationService.send(
                payout.merchant._id,
                'Merchant',
                {
                    type: 'payment_received',
                    title: hold ? 'Payout On Hold' : 'Payout Released',
                    message: hold
                        ? `Your payout ${payout.payoutId} has been put on hold. Reason: ${reason}`
                        : `Your payout ${payout.payoutId} has been released and is pending processing`,
                    channels: ['push', 'email']
                }
            );
        } catch (notifError) {
            console.error('Notification error:', notifError);
        }

        res.json({
            success: true,
            message: hold ? 'Payout put on hold' : 'Payout released',
            data: {
                payoutId: payout.payoutId,
                status: payout.status
            }
        });
    } catch (error) {
        console.error('Hold/Release payout error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to update payout status',
            details: error.message
        });
    }
};

module.exports = exports;
