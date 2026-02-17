const paymentController = require('../src/controllers/paymentController');
const Order = require('../src/models/Order');
const paymentService = require('../src/services/paymentService');

// Mock dependencies
jest.mock('../src/models/Order');
jest.mock('../src/services/paymentService');

const mockResponse = () => {
    const res = {};
    res.status = jest.fn().mockReturnValue(res);
    res.json = jest.fn().mockReturnValue(res);
    return res;
};

const mockRequest = (user, body) => ({
    user,
    body
});

describe('Unit Tests: Payment Controller', () => {

    afterEach(() => {
        jest.clearAllMocks();
    });

    describe('createPaymentOrder', () => {
        it('should create a payment intent successfully', async () => {
            const req = mockRequest(
                { _id: 'user_id' },
                { orderId: 'GB123', amount: 500 }
            );
            const res = mockResponse();

            Order.findOne.mockReturnValue({
                populate: jest.fn().mockResolvedValue({
                    _id: 'order_id',
                    orderId: 'GB123',
                    totalAmount: 500,
                    paymentStatus: 'pending',
                    customer: { name: 'Test User', email: 'test@example.com' },
                    paymentGateway: {},
                    paymentEvents: [],
                    save: jest.fn()
                })
            });

            paymentService.createPaymentIntent.mockResolvedValue({
                id: 'pi_fake123',
                client_secret: 'secret_fake123',
                amount: 50000,
                currency: 'INR',
                status: 'requires_payment_method'
            });

            await paymentController.createPaymentOrder(req, res);

            // Assertions
            expect(Order.findOne).toHaveBeenCalled();
            expect(paymentService.createPaymentIntent).toHaveBeenCalledWith(
                500,
                'GB123',
                'user_id',
                expect.any(Object)
            );
            expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
                success: true,
                data: expect.objectContaining({
                    clientSecret: 'secret_fake123',
                    paymentIntentId: 'pi_fake123'
                })
            }));
        });

        it('should return 400 if amount mismatch', async () => {
            const req = mockRequest(
                { _id: 'user_id' },
                { orderId: 'GB123', amount: 100 } // Send 100, but order is 500
            );
            const res = mockResponse();

            Order.findOne.mockReturnValue({
                populate: jest.fn().mockResolvedValue({
                    orderId: 'GB123',
                    totalAmount: 500, // Matches DB
                    paymentStatus: 'pending',
                    customer: {}
                })
            });

            await paymentController.createPaymentOrder(req, res);

            expect(res.status).toHaveBeenCalledWith(400);
            expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
                error: 'Amount mismatch'
            }));
        });
    });

    describe('verifyPayment', () => {
        it('should verify payment and update order status', async () => {
            const req = mockRequest(
                { _id: 'user_id' },
                { orderId: 'GB123', paymentIntentId: 'pi_success' }
            );
            const res = mockResponse();

            const mockOrder = {
                orderId: 'GB123',
                paymentStatus: 'pending',
                status: 'pending',
                paymentGateway: {},
                paymentEvents: [],
                save: jest.fn(),
                merchant: 'merchant_id',
                totalAmount: 500
            };

            Order.findOne.mockResolvedValue(mockOrder);

            paymentService.getPaymentIntent.mockResolvedValue({
                id: 'pi_success',
                status: 'succeeded',
                amount_received: 50000,
                charges: { data: [{ payment_method_details: { type: 'card' } }] }
            });

            // Mock socket
            req.app = { get: jest.fn().mockReturnValue({ to: jest.fn().mockReturnValue({ emit: jest.fn() }) }) };

            await paymentController.verifyPayment(req, res);

            expect(mockOrder.paymentStatus).toBe('completed');
            expect(mockOrder.status).toBe('confirmed');
            expect(mockOrder.save).toHaveBeenCalled();
            expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
                success: true,
                message: 'Payment verified successfully'
            }));
        });
    });
});
