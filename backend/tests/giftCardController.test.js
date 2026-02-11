const crypto = require('crypto');
const Razorpay = require('razorpay');
const mongoose = require('mongoose');

// Mock Razorpay
jest.mock('razorpay', () => {
    return jest.fn().mockImplementation(() => ({
        orders: {
            create: jest.fn().mockResolvedValue({ id: 'order_razor_123', amount: 50000, currency: 'INR' })
        }
    }));
});

// Mock crypto
jest.mock('crypto', () => {
    const originalCrypto = jest.requireActual('crypto');
    return {
        ...originalCrypto,
        createHmac: jest.fn().mockReturnValue({
            update: jest.fn().mockReturnThis(),
            digest: jest.fn().mockReturnValue('valid_signature')
        })
    };
});

// Mock Notification Service to avoid DB calls for User/Notification
jest.mock('../src/services/notification', () => ({
    createNotification: jest.fn().mockResolvedValue(true),
    send: jest.fn().mockResolvedValue(true)
}));

const giftCardController = require('../src/controllers/giftCardController');
const GiftCard = require('../src/models/GiftCard');

jest.mock('../src/models/GiftCard');

describe('Gift Card Controller', () => {
    let req, res;

    beforeEach(() => {
        req = {
            body: {},
            user: { _id: new mongoose.Types.ObjectId().toString(), email: 'test@example.com' }
        };
        res = {
            json: jest.fn(),
            status: jest.fn().mockReturnThis()
        };
        jest.clearAllMocks();
    });

    it('should initiate purchase successfully', async () => {
        req.body = { amount: 500, quantity: 1 };

        await giftCardController.initiatePurchase(req, res);

        expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
            success: true,
            orderId: 'order_razor_123',
            amount: 50000,
            currency: 'INR'
        }));
    });

    it('should verify purchase and generate gift cards', async () => {
        req.body = {
            razorpay_order_id: 'order_razor_123',
            razorpay_payment_id: 'pay_razor_456',
            razorpay_signature: 'valid_signature',
            amount: 500,
            quantity: 1,
            message: 'Happy Birthday'
        };

        // Mock GiftCard.create
        GiftCard.create.mockResolvedValue([{
            code: 'GC-MOCK-CODE',
            amount: 500,
            balance: 500
        }]);

        await giftCardController.verifyPurchase(req, res);

        expect(GiftCard.create).toHaveBeenCalled();
        expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
            success: true
        }));
    });

    it('should fail verification on invalid signature', async () => {
        req.body = {
            razorpay_order_id: 'order_bad',
            razorpay_payment_id: 'pay_bad',
            razorpay_signature: 'invalid_sig'
        };

        await giftCardController.verifyPurchase(req, res);

        expect(res.status).toHaveBeenCalledWith(400);
        expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
            success: false,
            error: 'Invalid payment signature'
        }));
    });

});
