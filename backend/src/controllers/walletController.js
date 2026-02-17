const Wallet = require('../models/Wallet');
const Order = require('../models/Order');
const paymentService = require('../services/paymentService');

exports.getWallet = async (req, res) => {
    try {
        let wallet = await Wallet.findOne({ user: req.user._id });

        if (!wallet) {
            wallet = await Wallet.create({
                user: req.user._id,
                balance: 0,
                transactions: []
            });
        }

        // Get recent transactions (last 10)
        const recentTransactions = wallet.transactions
            .sort((a, b) => b.createdAt - a.createdAt)
            .slice(0, 10);

        res.json({
            success: true,
            data: {
                balance: wallet.balance,
                isLocked: wallet.isLocked,
                lockedReason: wallet.lockedReason,
                recentTransactions
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to fetch wallet',
            details: error.message
        });
    }
};

exports.getTransactionHistory = async (req, res) => {
    try {
        const {
            page = 1,
            limit = 20,
            type,
            source,
            startDate,
            endDate
        } = req.query;

        const wallet = await Wallet.findOne({ user: req.user._id });

        if (!wallet) {
            return res.json({
                success: true,
                data: {
                    transactions: [],
                    summary: {
                        totalCredits: 0,
                        totalDebits: 0,
                        netBalance: 0
                    },
                    pagination: {
                        page: 1,
                        limit: 20,
                        total: 0,
                        pages: 0
                    }
                }
            });
        }

        // Filter transactions
        let transactions = [...wallet.transactions];

        if (type) {
            transactions = transactions.filter(t => t.type === type);
        }

        if (source) {
            transactions = transactions.filter(t => t.source === source);
        }

        if (startDate) {
            const start = new Date(startDate);
            transactions = transactions.filter(t => t.createdAt >= start);
        }

        if (endDate) {
            const end = new Date(endDate);
            transactions = transactions.filter(t => t.createdAt <= end);
        }

        // Sort by date (newest first)
        transactions.sort((a, b) => b.createdAt - a.createdAt);

        // Calculate summary
        const summary = {
            totalCredits: wallet.transactions
                .filter(t => t.type === 'credit' && t.status === 'completed')
                .reduce((sum, t) => sum + t.amount, 0),
            totalDebits: wallet.transactions
                .filter(t => t.type === 'debit' && t.status === 'completed')
                .reduce((sum, t) => sum + t.amount, 0),
            netBalance: wallet.balance
        };

        // Pagination
        const total = transactions.length;
        const pages = Math.ceil(total / limit);
        const skip = (page - 1) * limit;
        const paginatedTransactions = transactions.slice(skip, skip + parseInt(limit));

        res.json({
            success: true,
            data: {
                transactions: paginatedTransactions,
                summary,
                pagination: {
                    page: parseInt(page),
                    limit: parseInt(limit),
                    total,
                    pages
                }
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to fetch transaction history',
            details: error.message
        });
    }
};

exports.addMoney = async (req, res) => {
    try {
        const { amount } = req.body;

        if (!amount || amount <= 0) {
            return res.status(400).json({
                success: false,
                error: 'Valid amount is required'
            });
        }

        if (amount < 10) {
            return res.status(400).json({
                success: false,
                error: 'Minimum topup amount is ₹10'
            });
        }

        if (amount > 10000) {
            return res.status(400).json({
                success: false,
                error: 'Maximum topup amount is ₹10,000'
            });
        }

        // Create Stripe Payment Intent
        const paymentIntent = await paymentService.createPaymentIntent(
            amount,
            `wallet_topup_${req.user._id}_${Date.now()}`,
            req.user._id.toString(),
            {
                type: 'wallet_topup',
                description: 'Wallet Topup'
            }
        );

        res.json({
            success: true,
            message: 'Wallet topup initiated',
            data: {
                paymentIntentId: paymentIntent.id,
                clientSecret: paymentIntent.client_secret,
                amount: amount,
                currency: 'INR'
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to initiate wallet topup',
            details: error.message
        });
    }
};

exports.verifyTopup = async (req, res) => {
    try {
        const {
            paymentIntentId,
            amount
        } = req.body;

        if (!paymentIntentId || !amount) {
            return res.status(400).json({
                success: false,
                error: 'paymentIntentId and amount are required'
            });
        }

        // Verify status with Stripe
        const paymentIntent = await paymentService.getPaymentIntent(paymentIntentId);

        if (paymentIntent.status !== 'succeeded') {
            return res.status(400).json({
                success: false,
                error: 'Payment not successful'
            });
        }

        // Check if transaction already processed (idempotency)
        let wallet = await Wallet.findOne({ user: req.user._id });

        if (!wallet) {
            wallet = await Wallet.create({
                user: req.user._id,
                balance: 0,
                transactions: []
            });
        }

        const alreadyProcessed = wallet.transactions.some(t => t.paymentId === paymentIntentId || t.referenceId === paymentIntentId);
        if (alreadyProcessed) {
            return res.json({
                success: true,
                message: 'Transaction already processed',
                data: { newBalance: wallet.balance }
            });
        }

        // Check if wallet is locked
        if (wallet.isLocked) {
            return res.status(403).json({
                success: false,
                error: 'Wallet is locked',
                reason: wallet.lockedReason
            });
        }

        // Add transaction
        const balanceBefore = wallet.balance;
        wallet.balance += amount;

        wallet.transactions.push({
            type: 'credit',
            amount,
            source: 'topup',
            description: `Wallet topup via Stripe`,
            paymentId: paymentIntentId,
            referenceId: paymentIntentId,
            balanceBefore,
            balanceAfter: wallet.balance,
            status: 'completed'
        });

        await wallet.save();

        const transactionId = wallet.transactions[wallet.transactions.length - 1]._id;

        // Send notification
        try {
            const notificationService = require('../services/notification');
            await notificationService.send(
                req.user._id,
                'User',
                {
                    type: 'wallet_credit',
                    title: 'Money Added to Wallet',
                    message: `₹${amount} has been added to your wallet`,
                    data: {
                        amount,
                        newBalance: wallet.balance
                    },
                    channels: ['push', 'email']
                }
            );
        } catch (notifError) {
            console.error('Notification error:', notifError);
        }

        res.json({
            success: true,
            message: 'Money added to wallet successfully',
            data: {
                newBalance: wallet.balance,
                transactionId
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to verify wallet topup',
            details: error.message
        });
    }
};

exports.useForPayment = async (req, res) => {
    try {
        const { orderId, amount } = req.body;

        if (!orderId || !amount) {
            return res.status(400).json({
                success: false,
                error: 'Order ID and amount are required'
            });
        }

        if (amount <= 0) {
            return res.status(400).json({
                success: false,
                error: 'Invalid amount'
            });
        }

        const wallet = await Wallet.findOne({ user: req.user._id });

        if (!wallet) {
            return res.status(404).json({
                success: false,
                error: 'Wallet not found'
            });
        }

        if (wallet.isLocked) {
            return res.status(403).json({
                success: false,
                error: 'Wallet is locked',
                reason: wallet.lockedReason
            });
        }

        if (wallet.balance < amount) {
            return res.status(400).json({
                success: false,
                error: 'Insufficient wallet balance',
                available: wallet.balance,
                required: amount
            });
        }

        const order = await Order.findOne({ orderId });

        if (!order) {
            return res.status(404).json({
                success: false,
                error: 'Order not found'
            });
        }

        // Deduct from wallet
        const balanceBefore = wallet.balance;
        wallet.balance -= amount;

        wallet.transactions.push({
            type: 'debit',
            amount,
            source: 'payment',
            description: `Payment for order ${orderId}`,
            orderId: order._id,
            balanceBefore,
            balanceAfter: wallet.balance,
            status: 'completed'
        });

        await wallet.save();

        const transactionId = wallet.transactions[wallet.transactions.length - 1]._id;

        res.json({
            success: true,
            message: 'Payment deducted from wallet',
            data: {
                deductedAmount: amount,
                newBalance: wallet.balance,
                transactionId
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to process wallet payment',
            details: error.message
        });
    }
};

exports.creditRefund = async (req, res) => {
    try {
        const { userId, amount, orderId, description } = req.body;

        if (!userId || !amount || !orderId) {
            return res.status(400).json({
                success: false,
                error: 'userId, amount, and orderId are required'
            });
        }

        let wallet = await Wallet.findOne({ user: userId });

        if (!wallet) {
            wallet = await Wallet.create({
                user: userId,
                balance: 0,
                transactions: []
            });
        }

        const order = await Order.findOne({ orderId });

        const balanceBefore = wallet.balance;
        wallet.balance += amount;

        wallet.transactions.push({
            type: 'credit',
            amount,
            source: 'refund',
            description: description || `Refund for order ${orderId}`,
            orderId: order?._id,
            balanceBefore,
            balanceAfter: wallet.balance,
            status: 'completed'
        });

        await wallet.save();

        const transactionId = wallet.transactions[wallet.transactions.length - 1]._id;

        // Send notification
        try {
            const notificationService = require('../services/notification');
            await notificationService.send(
                userId,
                'User',
                {
                    type: 'wallet_credit',
                    title: 'Refund Credited',
                    message: `₹${amount} refund has been credited to your wallet`,
                    data: {
                        amount,
                        orderId,
                        newBalance: wallet.balance
                    },
                    channels: ['push', 'email']
                }
            );
        } catch (notifError) {
            console.error('Notification error:', notifError);
        }

        res.json({
            success: true,
            message: 'Refund credited to wallet',
            data: {
                newBalance: wallet.balance,
                transactionId
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to credit refund',
            details: error.message
        });
    }
};

exports.adminCredit = async (req, res) => {
    try {
        const { userId, amount, description } = req.body;

        if (!userId || !amount) {
            return res.status(400).json({
                success: false,
                error: 'userId and amount are required'
            });
        }

        if (amount <= 0) {
            return res.status(400).json({
                success: false,
                error: 'Amount must be greater than 0'
            });
        }

        let wallet = await Wallet.findOne({ user: userId });

        if (!wallet) {
            wallet = await Wallet.create({
                user: userId,
                balance: 0,
                transactions: []
            });
        }

        const balanceBefore = wallet.balance;
        wallet.balance += amount;

        wallet.transactions.push({
            type: 'credit',
            amount,
            source: 'admin_credit',
            description: description || 'Credit by admin',
            balanceBefore,
            balanceAfter: wallet.balance,
            status: 'completed'
        });

        await wallet.save();

        const transactionId = wallet.transactions[wallet.transactions.length - 1]._id;

        // Send notification
        try {
            const notificationService = require('../services/notification');
            await notificationService.send(
                userId,
                'User',
                {
                    type: 'wallet_credit',
                    title: 'Wallet Credited',
                    message: `₹${amount} has been added to your wallet by admin`,
                    data: {
                        amount,
                        description,
                        newBalance: wallet.balance
                    },
                    channels: ['push', 'email']
                }
            );
        } catch (notifError) {
            console.error('Notification error:', notifError);
        }

        res.json({
            success: true,
            message: 'Amount credited to wallet',
            data: {
                newBalance: wallet.balance,
                transactionId
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to credit wallet',
            details: error.message
        });
    }
};

exports.lockUnlockWallet = async (req, res) => {
    try {
        const { userId } = req.params;
        const { lock, reason } = req.body;

        if (lock === undefined) {
            return res.status(400).json({
                success: false,
                error: 'lock parameter is required'
            });
        }

        if (lock && !reason) {
            return res.status(400).json({
                success: false,
                error: 'Reason is required when locking wallet'
            });
        }

        const wallet = await Wallet.findOne({ user: userId });

        if (!wallet) {
            return res.status(404).json({
                success: false,
                error: 'Wallet not found'
            });
        }

        wallet.isLocked = lock;
        wallet.lockedReason = lock ? reason : null;

        await wallet.save();

        // Send notification
        try {
            const notificationService = require('../services/notification');
            await notificationService.send(
                userId,
                'User',
                {
                    type: 'wallet_credit',
                    title: lock ? 'Wallet Locked' : 'Wallet Unlocked',
                    message: lock
                        ? `Your wallet has been locked. Reason: ${reason}`
                        : 'Your wallet has been unlocked',
                    channels: ['push', 'email']
                }
            );
        } catch (notifError) {
            console.error('Notification error:', notifError);
        }

        res.json({
            success: true,
            message: lock ? 'Wallet locked successfully' : 'Wallet unlocked successfully'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to update wallet status',
            details: error.message
        });
    }
};
