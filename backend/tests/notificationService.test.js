const notificationService = require('../src/services/notificationService');
const Notification = require('../src/models/Notification');
const NotificationSocket = require('../src/sockets/notificationSocket');

jest.mock('../src/models/Notification');
jest.mock('../src/sockets/notificationSocket');

describe('Unit Tests: Notification Service', () => {

    afterEach(() => {
        jest.clearAllMocks();
    });

    it('should create a notification and send via socket', async () => {
        const data = {
            recipient: 'user_id',
            recipientModel: 'User',
            type: 'test',
            title: 'Test',
            message: 'Hello'
        };

        Notification.create.mockResolvedValue({
            ...data,
            _id: 'notif_id'
        });

        await notificationService.createNotification(data);

        expect(Notification.create).toHaveBeenCalledWith(expect.objectContaining(data));
        expect(NotificationSocket.sendNotification).toHaveBeenCalledWith('user_id', 'user', expect.anything());
    });

    it('should send bulk notifications', async () => {
        const recipients = [
            { id: 'u1', model: 'User' },
            { id: 'u2', model: 'Merchant' }
        ];
        const data = { title: 'Broadcast' };

        // Mock createNotification implementation to avoid actual logic if needed,
        // but here we are integrating within the service. 
        // We can spy on createNotification if we want to isolate 'bulk' logic, but using the real method verifies flow.
        Notification.create.mockResolvedValue({});

        await notificationService.sendBulkNotifications(recipients, data);

        expect(Notification.create).toHaveBeenCalledTimes(2);
        expect(NotificationSocket.sendNotification).toHaveBeenCalledTimes(2);
    });

    it('should get user notifications with pagination', async () => {
        const userId = 'user_1';
        const userType = 'User';

        Notification.find.mockReturnValue({
            sort: jest.fn().mockReturnValue({
                skip: jest.fn().mockReturnValue({
                    limit: jest.fn().mockResolvedValue(['notif1', 'notif2'])
                })
            })
        });

        Notification.countDocuments.mockImplementation((query) => {
            if (query.isRead === false) return Promise.resolve(5); // unread
            return Promise.resolve(20); // total
        });

        const result = await notificationService.getUserNotifications(userId, userType, { page: 1, limit: 10 });

        expect(result.notifications).toHaveLength(2);
        expect(result.unreadCount).toBe(5);
        expect(result.pagination.total).toBe(20);
    });

});
