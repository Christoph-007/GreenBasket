const request = require('supertest');
const mongoose = require('mongoose');
const app = require('../server');
const User = require('../src/models/User');
const Product = require('../src/models/Product');
const Cart = require('../src/models/Cart');
const Order = require('../src/models/Order');
const Merchant = require('../src/models/Merchant');
const Category = require('../src/models/Category');
const Recipe = require('../src/models/Recipe');
const Review = require('../src/models/Review');
const Subscription = require('../src/models/Subscription');
const Address = require('../src/models/Address');

// Timeout is set to 30s as some operations might take time
jest.setTimeout(30000);

let userToken;
let merchantToken;
let productId;
let recipeId;

beforeAll(async () => {
    // Wait for DB connection if not already connected (server.js connects it)
    if (mongoose.connection.readyState === 0) {
        await mongoose.connect(process.env.MONGODB_URI);
    }
});

afterAll(async () => {
    await mongoose.connection.close();
});

describe('Green Basket Backend Complete Feature Test', () => {

    describe('1. Authentication', () => {
        it('should login as a User', async () => {
            const res = await request(app)
                .post('/api/auth/user/login')
                .send({
                    email: 'user@example.com',
                    password: 'password123'
                });

            if (res.statusCode !== 200) console.log('User Login Error:', res.body);
            expect(res.statusCode).toEqual(200);
            expect(res.body.data).toHaveProperty('token');
            userToken = res.body.data.token;
        });

        it('should login as a Merchant', async () => {
            const res = await request(app)
                .post('/api/auth/merchant/login')
                .send({
                    email: 'merchant@example.com',
                    password: 'password123'
                });

            if (res.statusCode !== 200) console.log('Merchant Login Error:', res.body);
            expect(res.statusCode).toEqual(200);
            expect(res.body.data).toHaveProperty('token');
            merchantToken = res.body.data.token;
        });
    });

    describe('2. Product Management', () => {
        it('should get all products', async () => {
            const res = await request(app)
                .get('/api/products');

            if (res.statusCode !== 200) console.log('Get Products Error:', res.body);
            expect(res.statusCode).toEqual(200);
            expect(res.body.data.products).toBeDefined();
            expect(res.body.data.products.length).toBeGreaterThan(0);

            // Save a product ID for later tests
            productId = res.body.data.products[0]._id;
        });

        it('should get a single product by ID', async () => {
            const res = await request(app)
                .get(`/api/products/${productId}`);

            if (res.statusCode !== 200) console.log('Get One Product Error:', res.body);
            expect(res.statusCode).toEqual(200);
            expect(res.body.data.product).toBeDefined();
            expect(res.body.data.product._id).toEqual(productId);
        });

        it('should protect merchant routes', async () => {
            // Try to create product as user (should fail)
            const res = await request(app)
                .post('/api/products')
                .set('Authorization', `Bearer ${userToken}`)
                .send({ name: 'Fail' });

            // Should be 401 or 403
            expect([401, 403]).toContain(res.statusCode);
        });
    });

    describe('3. Shopping Cart', () => {
        it('should add item to cart', async () => {
            // First clear cart to be safe
            await Cart.deleteMany({ user: (await User.findOne({ email: 'user@example.com' }))._id });

            const res = await request(app)
                .post('/api/cart/add')
                .set('Authorization', `Bearer ${userToken}`)
                .send({
                    productId: productId,
                    quantity: 1
                });

            if (res.statusCode !== 200) console.log('Add Cart Error:', res.body);
            expect(res.statusCode).toEqual(200);
            expect(res.body.data.cart.items).toHaveLength(1);
            expect(res.body.data.cart.items[0].product._id).toEqual(productId);
        });

        it('should get user cart', async () => {
            const res = await request(app)
                .get('/api/cart')
                .set('Authorization', `Bearer ${userToken}`);

            if (res.statusCode !== 200) console.log('Get Cart Error:', res.body);
            expect(res.statusCode).toEqual(200);
            expect(res.body.data.cart).toBeDefined();
            expect(res.body.data.cart.items.length).toBeGreaterThan(0);
        });
    });

    describe('4. Recipes', () => {
        it('should get all recipes', async () => {
            const res = await request(app)
                .get('/api/recipes');

            if (res.statusCode !== 200) console.log('Get Recipes Error:', res.body);
            expect(res.statusCode).toEqual(200);
            expect(res.body.data.recipes).toBeDefined();
            expect(res.body.data.recipes.length).toBeGreaterThan(0);
            recipeId = res.body.data.recipes[0]._id;
        });

        it('should get ingredient calculation for a recipe', async () => {
            const res = await request(app)
                .post(`/api/recipes/${recipeId}/calculate-ingredients`)
                .send({ servings: 8 }); // Double the default 4

            if (res.statusCode !== 200) console.log('Calc Ingredients Error:', res.body);
            expect(res.statusCode).toEqual(200);
            // Check if quantity is scaled (e.g. carrots 0.5kg for 4 -> 1kg for 8)
            // Just checking structure for now
            expect(res.body.data.ingredients).toBeDefined();
        });
    });

    describe('5. Order Processing', () => {
        let addressId;

        it('should create an address', async () => {
            const res = await request(app)
                .post('/api/users/addresses')
                .set('Authorization', `Bearer ${userToken}`)
                .send({
                    addressLine1: '123 Test St',
                    city: 'Test City',
                    state: 'Test State',
                    pincode: '123456',
                    label: 'home'
                });

            if (res.statusCode !== 200 && res.statusCode !== 201) console.log('Create Address Error:', res.body);
            expect([200, 201]).toContain(res.statusCode);
            addressId = res.body.data._id;
        });

        it('should create an order', async () => { // Renamed from 'create an order from cart' since we pass items manually
            const res = await request(app)
                .post('/api/orders')
                .set('Authorization', `Bearer ${userToken}`)
                .send({
                    items: [{ product: productId, quantity: 1 }],
                    deliveryAddress: addressId,
                    paymentMethod: 'cod'
                });

            // Depending on payment implementation, this might return 201 or 200 with payment intent
            // Since we don't have a real razorpay token, we expect the order initiation to pass
            // In many implementations, 'razorpay' creates an order_id from razorpay.
            // Let's assume 201 or 200.
            if (res.statusCode !== 200 && res.statusCode !== 201) console.log('Create Order Error:', res.body);
            expect([200, 201]).toContain(res.statusCode);
        });

        it('should get user orders', async () => {
            const res = await request(app)
                .get('/api/orders/my-orders')
                .set('Authorization', `Bearer ${userToken}`);

            if (res.statusCode !== 200) console.log('Get My Orders Error:', res.body);
            expect(res.statusCode).toEqual(200);
            expect(res.body.data.orders).toBeDefined();
        });

        it('should get merchant orders', async () => {
            const res = await request(app)
                .get('/api/orders/merchant/orders')
                .set('Authorization', `Bearer ${merchantToken}`);

            if (res.statusCode !== 200) console.log('Get Merchant Orders Error:', res.body);
            expect(res.statusCode).toEqual(200);
            // Merchant should see the order we just placed (if it contained his product)
            // Our products are all from this merchant.
            expect(res.body.data.orders).toBeDefined();
        });
    });

});
