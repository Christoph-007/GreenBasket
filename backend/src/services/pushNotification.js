const { messaging } = require('../config/firebase');
const User = require('../models/User');

const sendPushNotification = async (userId, notification) => {
    try {
        // Get user's FCM tokens
        const user = await User.findById(userId);

        if (!user || !user.fcmTokens || user.fcmTokens.length === 0) {
            return { success: false, reason: 'No FCM tokens' };
        }

        const message = {
            notification: {
                title: notification.title,
                body: notification.message
            },
            data: notification.data ? JSON.parse(JSON.stringify(notification.data)) : {},
            tokens: user.fcmTokens
        };

        // Add image if provided
        if (notification.imageUrl) {
            message.notification.imageUrl = notification.imageUrl;
        }

        const response = await messaging.sendMulticast(message);

        // Remove invalid tokens
        if (response.failureCount > 0) {
            const tokensToRemove = [];
            response.responses.forEach((resp, idx) => {
                if (!resp.success) {
                    tokensToRemove.push(user.fcmTokens[idx]);
                }
            });

            if (tokensToRemove.length > 0) {
                await User.findByIdAndUpdate(userId, {
                    $pull: { fcmTokens: { $in: tokensToRemove } }
                });
            }
        }

        return {
            success: true,
            successCount: response.successCount,
            failureCount: response.failureCount
        };
    } catch (error) {
        console.error('Push notification error:', error);
        throw error;
    }
};

module.exports = sendPushNotification;
