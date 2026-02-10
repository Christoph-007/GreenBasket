const Notification = require('../models/Notification');
const notificationService = require('../services/notification');

exports.getNotifications = async (req, res) => {
    try {
        const { page = 1, limit = 20, unread, type } = req.query;

        const query = { user: req.user._id };

        if (unread === 'true') {
            query['channels.inApp.read'] = false;
        }

        if (type) {
            query.type = type;
        }

        const skip = (page - 1) * limit;

        const [notifications, total, unreadCount] = await Promise.all([
            Notification.find(query)
                .sort({ createdAt: -1 })
                .skip(skip)
                .limit(parseInt(limit)),
            Notification.countDocuments(query),
            Notification.countDocuments({
                user: req.user._id,
                'channels.inApp.read': false
            })
        ]);

        res.json({
            success: true,
            data: {
                notifications,
                unreadCount,
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
            error: 'Failed to fetch notifications',
            details: error.message
        });
    }
};

exports.markAsRead = async (req, res) => {
    try {
        const { id } = req.params;

        const notification = await Notification.findOne({
            _id: id,
            user: req.user._id
        });

        if (!notification) {
            return res.status(404).json({
                success: false,
                error: 'Notification not found'
            });
        }

        notification.channels.inApp.read = true;
        notification.channels.inApp.readAt = new Date();
        await notification.save();

        res.json({
            success: true,
            message: 'Notification marked as read'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to mark notification as read',
            details: error.message
        });
    }
};

exports.markAllAsRead = async (req, res) => {
    try {
        const result = await Notification.updateMany(
            {
                user: req.user._id,
                'channels.inApp.read': false
            },
            {
                $set: {
                    'channels.inApp.read': true,
                    'channels.inApp.readAt': new Date()
                }
            }
        );

        res.json({
            success: true,
            message: 'All notifications marked as read',
            data: {
                modifiedCount: result.modifiedCount
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to mark all notifications as read',
            details: error.message
        });
    }
};

exports.deleteNotification = async (req, res) => {
    try {
        const { id } = req.params;

        const notification = await Notification.findOneAndDelete({
            _id: id,
            user: req.user._id
        });

        if (!notification) {
            return res.status(404).json({
                success: false,
                error: 'Notification not found'
            });
        }

        res.json({
            success: true,
            message: 'Notification deleted successfully'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to delete notification',
            details: error.message
        });
    }
};

exports.getUnreadCount = async (req, res) => {
    try {
        const count = await Notification.countDocuments({
            user: req.user._id,
            'channels.inApp.read': false
        });

        res.json({
            success: true,
            data: {
                count
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to get unread count',
            details: error.message
        });
    }
};

exports.clearAllNotifications = async (req, res) => {
    try {
        const result = await Notification.deleteMany({
            user: req.user._id
        });

        res.json({
            success: true,
            message: 'All notifications cleared',
            data: {
                deletedCount: result.deletedCount
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to clear notifications',
            details: error.message
        });
    }
};

exports.updateNotificationPreferences = async (req, res) => {
    try {
        const { email, push, sms } = req.body;

        const user = await req.user.constructor.findById(req.user._id);

        if (!user.notificationPreferences) {
            user.notificationPreferences = {};
        }

        if (email) {
            user.notificationPreferences.email = {
                ...user.notificationPreferences.email,
                ...email
            };
        }

        if (push) {
            user.notificationPreferences.push = {
                ...user.notificationPreferences.push,
                ...push
            };
        }

        if (sms) {
            user.notificationPreferences.sms = {
                ...user.notificationPreferences.sms,
                ...sms
            };
        }

        await user.save();

        res.json({
            success: true,
            message: 'Notification preferences updated successfully',
            data: {
                notificationPreferences: user.notificationPreferences
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to update notification preferences',
            details: error.message
        });
    }
};

exports.getNotificationPreferences = async (req, res) => {
    try {
        const user = await req.user.constructor.findById(req.user._id);

        res.json({
            success: true,
            data: user.notificationPreferences || {
                email: {
                    orderUpdates: true,
                    offers: true,
                    newsletter: false,
                    productUpdates: true
                },
                push: {
                    orderUpdates: true,
                    offers: true,
                    priceDrops: true,
                    backInStock: true
                },
                sms: {
                    orderUpdates: true,
                    offers: false,
                    otp: true
                }
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to get notification preferences',
            details: error.message
        });
    }
};

exports.registerFCMToken = async (req, res) => {
    try {
        const { token, deviceType } = req.body;

        if (!token) {
            return res.status(400).json({
                success: false,
                error: 'Token is required'
            });
        }

        const user = await req.user.constructor.findById(req.user._id);

        if (!user.fcmTokens) {
            user.fcmTokens = [];
        }
        if (!user.deviceTokens) {
            user.deviceTokens = [];
        }

        // Remove token if already exists
        user.fcmTokens = user.fcmTokens.filter(t => t !== token);

        // Add new token
        user.fcmTokens.push(token);

        // Update device tokens
        const existingDevice = user.deviceTokens.find(d => d.token === token);
        if (existingDevice) {
            existingDevice.lastUsed = new Date();
        } else {
            user.deviceTokens.push({
                token,
                deviceType: deviceType || 'web',
                lastUsed: new Date()
            });
        }

        await user.save();

        res.json({
            success: true,
            message: 'FCM token registered successfully'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to register FCM token',
            details: error.message
        });
    }
};

exports.removeFCMToken = async (req, res) => {
    try {
        const { token } = req.body;

        if (!token) {
            return res.status(400).json({
                success: false,
                error: 'Token is required'
            });
        }

        const user = await req.user.constructor.findById(req.user._id);

        user.fcmTokens = user.fcmTokens.filter(t => t !== token);
        user.deviceTokens = user.deviceTokens.filter(d => d.token !== token);

        await user.save();

        res.json({
            success: true,
            message: 'FCM token removed successfully'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to remove FCM token',
            details: error.message
        });
    }
};

exports.sendTestNotification = async (req, res) => {
    try {
        const { userId, title, message, channels } = req.body;

        if (!userId || !title || !message) {
            return res.status(400).json({
                success: false,
                error: 'userId, title, and message are required'
            });
        }

        const notification = await notificationService.send(
            userId,
            'User',
            {
                type: 'flash_sale',
                title,
                message,
                channels: channels || ['push', 'email', 'inApp'],
                priority: 'medium'
            }
        );

        res.json({
            success: true,
            message: 'Test notification sent successfully',
            data: {
                notificationId: notification._id
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to send test notification',
            details: error.message
        });
    }
};

exports.bulkSendNotifications = async (req, res) => {
    try {
        const { userIds, title, message, type, channels, actionUrl } = req.body;

        if (!userIds || !Array.isArray(userIds) || userIds.length === 0) {
            return res.status(400).json({
                success: false,
                error: 'userIds array is required'
            });
        }

        if (!title || !message || !type) {
            return res.status(400).json({
                success: false,
                error: 'title, message, and type are required'
            });
        }

        const results = {
            sent: 0,
            failed: 0
        };

        for (const userId of userIds) {
            try {
                await notificationService.send(userId, 'User', {
                    type,
                    title,
                    message,
                    channels: channels || ['push', 'email', 'inApp'],
                    actionUrl,
                    priority: 'medium'
                });
                results.sent++;
            } catch (error) {
                console.error(`Failed to send notification to ${userId}:`, error);
                results.failed++;
            }
        }

        res.json({
            success: true,
            message: 'Bulk notifications sent successfully',
            data: results
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to send bulk notifications',
            details: error.message
        });
    }
};
