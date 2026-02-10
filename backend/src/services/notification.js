const Notification = require('../models/Notification');
const sendEmail = require('./email');
const sendSMS = require('./sms');
const sendPushNotification = require('./pushNotification');

class NotificationService {
    async send(userId, userModel, notificationData) {
        const {
            type,
            title,
            message,
            data = {},
            channels = ['push', 'email', 'inApp'],
            priority = 'medium',
            actionUrl,
            imageUrl
        } = notificationData;

        // Get user preferences
        const User = require('../models/User');
        const Merchant = require('../models/Merchant');
        const Admin = require('../models/Admin');

        const Model = userModel === 'User' ? User :
            userModel === 'Merchant' ? Merchant : Admin;

        const user = await Model.findById(userId);

        if (!user) {
            throw new Error('User not found');
        }

        const prefs = user.notificationPreferences || {};

        // Create notification record
        const notification = await Notification.create({
            user: userId,
            userModel,
            type,
            title,
            message,
            data,
            priority,
            actionUrl,
            imageUrl,
            channels: {
                push: { sent: false },
                email: { sent: false },
                sms: { sent: false },
                inApp: { sent: true }
            }
        });

        // Send via enabled channels
        const promises = [];

        // Push notification
        if (channels.includes('push') && this.shouldSendPush(type, prefs)) {
            promises.push(
                sendPushNotification(userId, notification)
                    .then(() => {
                        notification.channels.push.sent = true;
                        notification.channels.push.sentAt = new Date();
                    })
                    .catch(err => {
                        notification.channels.push.error = err.message;
                    })
            );
        }

        // Email
        if (channels.includes('email') && this.shouldSendEmail(type, prefs)) {
            promises.push(
                sendEmail({
                    to: user.email,
                    subject: title,
                    template: this.getEmailTemplate(type),
                    data: { ...data, message, title }
                })
                    .then(() => {
                        notification.channels.email.sent = true;
                        notification.channels.email.sentAt = new Date();
                    })
                    .catch(err => {
                        notification.channels.email.error = err.message;
                    })
            );
        }

        // SMS
        if (channels.includes('sms') && this.shouldSendSMS(type, prefs) && user.phone) {
            promises.push(
                sendSMS({
                    to: user.phone,
                    message: `${title}: ${message}`
                })
                    .then(() => {
                        notification.channels.sms.sent = true;
                        notification.channels.sms.sentAt = new Date();
                    })
                    .catch(err => {
                        notification.channels.sms.error = err.message;
                    })
            );
        }

        await Promise.allSettled(promises);
        await notification.save();

        // Emit via Socket.IO for real-time (if available)
        try {
            const io = require('../../server').io;
            if (io) {
                io.to(`user_${userId}`).emit('notification', notification);
            }
        } catch (error) {
            // Socket.IO not available, skip
        }

        return notification;
    }

    shouldSendPush(type, prefs) {
        const typeCategory = this.getTypeCategory(type);
        return prefs.push?.[typeCategory] !== false;
    }

    shouldSendEmail(type, prefs) {
        const typeCategory = this.getTypeCategory(type);
        return prefs.email?.[typeCategory] !== false;
    }

    shouldSendSMS(type, prefs) {
        const typeCategory = this.getTypeCategory(type);
        return prefs.sms?.[typeCategory] !== false;
    }

    getTypeCategory(type) {
        const orderTypes = ['order_placed', 'order_confirmed', 'order_preparing',
            'order_out_for_delivery', 'order_delivered', 'order_cancelled'];
        const offerTypes = ['offer_available', 'flash_sale'];
        const productTypes = ['price_drop', 'back_in_stock'];

        if (orderTypes.includes(type)) return 'orderUpdates';
        if (offerTypes.includes(type)) return 'offers';
        if (productTypes.includes(type)) return 'productUpdates';

        return 'orderUpdates';
    }

    getEmailTemplate(type) {
        const templates = {
            'order_placed': 'orderConfirmation',
            'order_confirmed': 'orderConfirmed',
            'order_delivered': 'orderDelivered',
            'order_cancelled': 'orderCancelled',
            'merchant_approved': 'merchantApproved',
            'offer_available': 'offerNotification',
            'price_drop': 'priceDrop',
            'back_in_stock': 'backInStock',
            'refund_processed': 'refundProcessed',
            'wallet_credit': 'walletCredit'
        };

        return templates[type] || 'generic';
    }
}

module.exports = new NotificationService();
