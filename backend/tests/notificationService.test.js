require('dotenv').config();
const mongoose = require('mongoose');
const notificationService = require('../src/services/notificationService'); // Aliases to notification.js
const Notification = require('../src/models/Notification');
const User = require('../src/models/User');

jest.mock('../src/models/Notification');
jest.mock('../src/models/User');
// We don't verify socket emissions here as they depend on server.io singleton

describe('Unit Tests: Notification Service', () => {

    afterEach(() => {
        jest.clearAllMocks();
    });

    it('should create a notification record', async () => {
        const userId = new mongoose.Types.ObjectId().toString();
        const data = {
            recipient: userId,
            recipientModel: 'User',
            type: 'order_placed',
            title: 'Test Order',
            message: 'Your order has been placed'
        };

        // Mock User found
        User.findById.mockResolvedValue({
            _id: userId,
            notificationPreferences: {}
        });

        // Mock Notification creation
        Notification.create.mockResolvedValue({
            ...data,
            _id: 'notif_123',
            user: userId,
            channels: { push: {}, email: {}, sms: {}, inApp: {} },
            save: jest.fn().mockResolvedValue(true)
        });

        // Suppress console warnings from missing keys in test env
        const consoleSpy = jest.spyOn(console, 'warn').mockImplementation(() => { });

        await notificationService.createNotification(data);

        expect(User.findById).toHaveBeenCalledWith(userId);
        expect(Notification.create).toHaveBeenCalledWith(expect.objectContaining({
            user: userId,
            title: 'Test Order'
        }));

        consoleSpy.mockRestore();
    });

    it('should get user notifications with pagination', async () => {
        const userId = new mongoose.Types.ObjectId().toString();

        // Mongoose query chain mock
        const mockChain = {
            sort: jest.fn().mockReturnThis(),
            skip: jest.fn().mockReturnThis(),
            limit: jest.fn().mockResolvedValue(['notif1', 'notif2'])
        };
        Notification.find.mockReturnValue(mockChain);

        Notification.countDocuments.mockImplementation((query) => {
            if (query['channels.inApp.read'] === false) return Promise.resolve(5); // unread
            return Promise.resolve(20); // total
        });

        const result = await notificationService.getUserNotifications(userId, { page: 1, limit: 10 });

        expect(result.notifications).toHaveLength(2);
        expect(result.unreadCount).toBe(5);
        expect(result.pagination.total).toBe(20);
        expect(Notification.find).toHaveBeenCalledWith({ user: userId });
    });

});
