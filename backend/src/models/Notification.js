const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
    recipient: {
        type: mongoose.Schema.Types.ObjectId,
        required: true,
        refPath: 'recipientModel'
    },
    recipientModel: {
        type: String,
        required: true,
        enum: ['User', 'Merchant', 'Admin']
    },
    type: {
        type: String,
        enum: ['order', 'payment', 'promotion', 'system', 'review', 'stock'],
        required: true
    },
    title: {
        type: String,
        required: true
    },
    message: {
        type: String,
        required: true
    },
    data: mongoose.Schema.Types.Mixed,
    isRead: {
        type: Boolean,
        default: false
    },
    readAt: Date
}, { timestamps: true });

module.exports = mongoose.model('Notification', notificationSchema);
