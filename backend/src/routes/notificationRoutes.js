const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notificationController');
const { authenticate: protect, isAdmin } = require('../middlewares/authMiddleware');

router.use(protect);

router.get('/', notificationController.getNotifications);
router.get('/unread-count', notificationController.getUnreadCount);
router.patch('/read-all', notificationController.markAllAsRead);
router.delete('/clear-all', notificationController.clearAllNotifications);
router.patch('/:id/read', notificationController.markAsRead);
router.delete('/:id', notificationController.deleteNotification);

// Admin routes
router.post('/admin/test', isAdmin, notificationController.sendTestNotification);
router.post('/admin/bulk-send', isAdmin, notificationController.bulkSendNotifications);

module.exports = router;
