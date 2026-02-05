const Notification = require('../models/Notification');
const NotificationSocket = require('../sockets/notificationSocket');

class NotificationService {
    /**
     * Create and send notification
     */
    async createNotification({ recipient, recipientModel, type, title, message, data }) {
        try {
            const notification = await Notification.create({
                recipient,
                recipientModel,
                type,
                title,
                message,
                data
            });

            // Send real-time notification via Socket.IO
            const userType = recipientModel.toLowerCase();
            NotificationSocket.sendNotification(recipient, userType, notification);

            return notification;
        } catch (error) {
            console.error('Notification error:', error);
            throw error;
        }
    }

    /**
     * Send bulk notifications
     */
    async sendBulkNotifications(recipients, notificationData) {
        const promises = recipients.map(recipient =>
            this.createNotification({
                ...notificationData,
                recipient: recipient.id,
                recipientModel: recipient.model
            })
        );
        return await Promise.all(promises);
    }

    /**
     * Mark notification as read
     */
    async markAsRead(notificationId, userId) {
        const notification = await Notification.findOneAndUpdate(
            { _id: notificationId, recipient: userId },
            { isRead: true, readAt: new Date() },
            { new: true }
        );
        return notification;
    }

    /**
     * Mark all as read
     */
    async markAllAsRead(userId, userType) {
        await Notification.updateMany(
            { recipient: userId, recipientModel: userType, isRead: false },
            { isRead: true, readAt: new Date() }
        );
    }

    /**
     * Get user notifications
     */
    async getUserNotifications(userId, userType, { page = 1, limit = 20 }) {
        const skip = (page - 1) * limit;

        const notifications = await Notification.find({
            recipient: userId,
            recipientModel: userType
        })
            .sort({ createdAt: -1 })
            .skip(skip)
            .limit(limit);

        const total = await Notification.countDocuments({
            recipient: userId,
            recipientModel: userType
        });

        const unreadCount = await Notification.countDocuments({
            recipient: userId,
            recipientModel: userType,
            isRead: false
        });

        return {
            notifications,
            pagination: {
                page,
                limit,
                total,
                pages: Math.ceil(total / limit)
            },
            unreadCount
        };
    }
}

module.exports = new NotificationService();
