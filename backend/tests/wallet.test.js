const walletController = require('../src/controllers/walletController');
const Wallet = require('../src/models/Wallet');
const paymentService = require('../src/services/paymentService');
const notificationService = require('../src/services/notification');

// Mock dependencies
jest.mock('../src/models/Wallet');
jest.mock('../src/services/paymentService');
jest.mock('../src/services/notification');

const mockResponse = () => {
    const res = {};
    res.status = jest.fn().mockReturnValue(res);
    res.json = jest.fn().mockReturnValue(res);
    return res;
};

describe('Unit Tests: Wallet Controller', () => {

    afterEach(() => {
        jest.clearAllMocks();
    });

    describe('getWallet', () => {
        it('should return wallet balance and transactions', async () => {
            const req = { user: { _id: 'user_123' } };
            const res = mockResponse();

            Wallet.findOne.mockResolvedValue({
                balance: 100,
                transactions: [],
                isLocked: false,
                lockedReason: null
            });

            await walletController.getWallet(req, res);

            expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
                success: true,
                data: expect.objectContaining({
                    balance: 100
                })
            }));
        });
    });

    describe('addMoney', () => {
        it('should create payment intent for adding money', async () => {
            const req = { user: { _id: 'user_123' }, body: { amount: 500 } };
            const res = mockResponse();

            paymentService.createPaymentIntent.mockResolvedValue({
                id: 'pi_wallet',
                client_secret: 'sec_wallet',
                amount: 500,
                currency: 'INR'
            });

            await walletController.addMoney(req, res);

            expect(paymentService.createPaymentIntent).toHaveBeenCalled();
            expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
                success: true,
                data: expect.objectContaining({
                    paymentIntentId: 'pi_wallet'
                })
            }));
        });
    });

    describe('verifyTopup', () => {
        it('should add money to wallet on successful payment', async () => {
            const req = {
                user: { _id: 'user_123' },
                body: { paymentIntentId: 'pi_success', amount: 500 }
            };
            const res = mockResponse();

            paymentService.getPaymentIntent.mockResolvedValue({
                status: 'succeeded'
            });

            const mockWallet = {
                user: 'user_123',
                balance: 0,
                transactions: [],
                save: jest.fn()
            };

            Wallet.findOne.mockResolvedValue(mockWallet);

            await walletController.verifyTopup(req, res);

            expect(mockWallet.balance).toBe(500);
            expect(mockWallet.transactions).toHaveLength(1);
            expect(mockWallet.save).toHaveBeenCalled();
            expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
                success: true,
                message: 'Money added to wallet successfully'
            }));
        });
    });
});
