const orderController = require('../src/controllers/orderController');
const Order = require('../src/models/Order');
const Product = require('../src/models/Product');
const Cart = require('../src/models/Cart');
const OrderSocket = require('../src/sockets/orderSocket');
const notificationService = require('../src/services/notificationService');

// Mock dependencies
jest.mock('../src/models/Order');
jest.mock('../src/models/Product');
jest.mock('../src/models/Cart');
jest.mock('../src/sockets/orderSocket');
jest.mock('../src/services/notificationService');

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

describe('Unit Tests: Order Controller', () => {

    afterEach(() => {
        jest.clearAllMocks();
    });

    describe('createOrder', () => {
        it('should calculate totals and create order successfully', async () => {
            const req = mockRequest(
                { id: 'user_id', name: 'Test User' },
                {
                    items: [
                        { product: 'prod_1', quantity: 2 },
                        { product: 'prod_2', quantity: 1 }
                    ],
                    deliveryAddress: 'addr_id',
                    deliveryType: 'home-delivery',
                    paymentMethod: 'cod'
                }
            );
            const res = mockResponse();

            // Mock Products
            Product.findById.mockImplementation((id) => {
                if (id === 'prod_1') return Promise.resolve({
                    _id: 'prod_1', name: 'Apple', price: 100, stock: 10, unit: 'kg', merchant: 'merchant_id', save: jest.fn()
                });
                if (id === 'prod_2') return Promise.resolve({
                    _id: 'prod_2', name: 'Banana', price: 50, stock: 10, unit: 'kg', merchant: 'merchant_id', save: jest.fn()
                });
                return Promise.resolve(null);
            });

            // Mock Order Create
            Order.create.mockResolvedValue({
                _id: 'order_id',
                orderId: 'GB123',
                totalAmount: 290, // (100*2 + 50*1) + 40 delivery
                items: [{}, {}]
            });

            await orderController.createOrder(req, res);

            // Assertions
            expect(Product.findById).toHaveBeenCalledTimes(3); // 2 items + 1 for merchant lookup (optimized in code, actually it calls findById inside loop then again for merchant? Code says: get merchant from first product)
            // Code re-fetches or uses found? 
            // Loop: `const product = await Product.findById(item.product);`
            // Then: `const firstProduct = await Product.findById(items[0].product);` (Line 62)
            // So it calls findById again.

            expect(Order.create).toHaveBeenCalledWith(expect.objectContaining({
                itemsTotal: 250, // 200 + 50
                deliveryCharges: 40,
                totalAmount: 290,
                merchant: 'merchant_id'
            }));

            expect(Cart.findOneAndUpdate).toHaveBeenCalledWith(
                { user: 'user_id' },
                { items: [], total: 0 }
            );

            expect(res.status).toHaveBeenCalledWith(201);
            expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
                success: true
            }));
        });

        it('should return error if insufficient stock', async () => {
            const req = mockRequest(
                { id: 'user_id' },
                { items: [{ product: 'prod_1', quantity: 20 }] }
            );
            const res = mockResponse();

            Product.findById.mockResolvedValue({
                _id: 'prod_1', name: 'Apple', price: 100, stock: 5 // Less than 20
            });

            await orderController.createOrder(req, res);

            expect(res.status).toHaveBeenCalledWith(400);
            expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
                success: false,
                message: expect.stringContaining('Insufficient stock')
            }));
        });

        it('should return error if product not found', async () => {
            const req = mockRequest(
                { id: 'user_id' },
                { items: [{ product: 'invalid_id', quantity: 1 }] }
            );
            const res = mockResponse();

            Product.findById.mockResolvedValue(null);

            await orderController.createOrder(req, res);

            expect(res.status).toHaveBeenCalledWith(404);
        });
    });

});
