const mongoose = require('mongoose');

// Mock paymentService (Stripe-based) instead of Razorpay
jest.mock('../src/services/paymentService', () => ({
    createPaymentIntent: jest.fn().mockResolvedValue({
        id: 'pi_gift_123',
        client_secret: 'secret_gift_123',
        amount: 50000,
        currency: 'INR',
        status: 'requires_payment_method'
    }),
    getPaymentIntent: jest.fn().mockResolvedValue({
        id: 'pi_gift_success',
        status: 'succeeded',
        amount_received: 50000
    })
}));

// Mock Notification Service to avoid DB calls for User/Notification
jest.mock('../src/services/notification', () => ({
    createNotification: jest.fn().mockResolvedValue(true),
    send: jest.fn().mockResolvedValue(true)
}));

const giftCardController = require('../src/controllers/giftCardController');
const GiftCard = require('../src/models/GiftCard');
const paymentService = require('../src/services/paymentService');

jest.mock('../src/models/GiftCard');

describe('Gift Card Controller', () => {
    let req, res;

    beforeEach(() => {
        req = {
            body: {},
            params: {},
            user: { _id: new mongoose.Types.ObjectId().toString(), email: 'test@example.com' }
        };
        res = {
            json: jest.fn(),
            status: jest.fn().mockReturnThis()
        };
        jest.clearAllMocks();
    });

    describe('initiatePurchase', () => {
        it('should initiate purchase successfully using Stripe', async () => {
            req.body = { amount: 500, currency: 'INR' };

            await giftCardController.initiatePurchase(req, res);

            expect(paymentService.createPaymentIntent).toHaveBeenCalledWith(
                500,
                expect.stringContaining('gift_rcpt_'),
                req.user._id.toString(),
                { type: 'gift_card' }
            );
            expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
                success: true,
                paymentIntentId: 'pi_gift_123',
                clientSecret: 'secret_gift_123',
                amount: 500
            }));
        });

        it('should return 400 if amount is below minimum', async () => {
            req.body = { amount: 50 }; // Below ₹100 minimum

            await giftCardController.initiatePurchase(req, res);

            expect(res.status).toHaveBeenCalledWith(400);
            expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
                success: false,
                error: 'Minimum amount is ₹100'
            }));
        });
    });

    describe('verifyPurchase', () => {
        it('should verify purchase and generate gift card on successful payment', async () => {
            req.body = {
                paymentIntentId: 'pi_gift_success',
                amount: 500,
                recipientEmail: 'recipient@example.com',
                message: 'Happy Birthday'
            };

            // Mock GiftCard.create
            GiftCard.create.mockResolvedValue({
                _id: new mongoose.Types.ObjectId(),
                code: 'GC-MOCK-CODE',
                amount: 500,
                balance: 500,
                expiryDate: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000)
            });

            await giftCardController.verifyPurchase(req, res);

            expect(paymentService.getPaymentIntent).toHaveBeenCalledWith('pi_gift_success');
            expect(GiftCard.create).toHaveBeenCalled();
            expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
                success: true,
                message: 'Payment verified and Gift Card created'
            }));
        });

        it('should return 400 if paymentIntentId is missing', async () => {
            req.body = { amount: 500 }; // Missing paymentIntentId

            await giftCardController.verifyPurchase(req, res);

            expect(res.status).toHaveBeenCalledWith(400);
            expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
                success: false,
                error: 'paymentIntentId and amount are required'
            }));
        });

        it('should return 400 if payment status is not succeeded', async () => {
            req.body = {
                paymentIntentId: 'pi_pending',
                amount: 500
            };

            // Override mock to return pending status
            paymentService.getPaymentIntent.mockResolvedValueOnce({
                id: 'pi_pending',
                status: 'requires_payment_method'
            });

            await giftCardController.verifyPurchase(req, res);

            expect(res.status).toHaveBeenCalledWith(400);
            expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
                success: false,
                error: 'Payment verification failed or pending'
            }));
        });
    });

    describe('validateGiftCard', () => {
        it('should return 400 if code is missing', async () => {
            req.body = {};

            await giftCardController.validateGiftCard(req, res);

            expect(res.status).toHaveBeenCalledWith(400);
            expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
                success: false,
                error: 'Gift card code is required'
            }));
        });

        it('should return 404 if gift card not found', async () => {
            req.body = { code: 'INVALID-CODE' };
            GiftCard.findOne.mockResolvedValue(null);

            await giftCardController.validateGiftCard(req, res);

            expect(res.status).toHaveBeenCalledWith(404);
            expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
                success: false,
                error: 'Invalid gift card code'
            }));
        });

        it('should return valid gift card details', async () => {
            req.body = { code: 'GC-VALID-001' };
            GiftCard.findOne.mockResolvedValue({
                code: 'GC-VALID-001',
                amount: 500,
                originalAmount: 500,
                status: 'active',
                expiryDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days from now
                minOrderValue: 0,
                type: 'gift_card',
                save: jest.fn()
            });

            await giftCardController.validateGiftCard(req, res);

            expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
                success: true,
                message: 'Gift card is valid',
                data: expect.objectContaining({
                    code: 'GC-VALID-001',
                    balance: 500
                })
            }));
        });
    });
});
