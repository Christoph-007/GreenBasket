const express = require('express');
const http = require('http');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

// Import config
const connectDB = require('./src/config/database');
const { initializeSocket } = require('./src/config/socket');

// Import routes
const authRoutes = require('./src/routes/authRoutes');
const productRoutes = require('./src/routes/productRoutes');
const categoryRoutes = require('./src/routes/categoryRoutes');
const orderRoutes = require('./src/routes/orderRoutes');
const cartRoutes = require('./src/routes/cartRoutes');
const recipeRoutes = require('./src/routes/recipeRoutes');
const userRoutes = require('./src/routes/userRoutes');
const merchantRoutes = require('./src/routes/merchantRoutes');
const adminRoutes = require('./src/routes/adminRoutes');
const reviewRoutes = require('./src/routes/reviewRoutes');
const subscriptionRoutes = require('./src/routes/subscriptionRoutes');
const uploadRoutes = require('./src/routes/uploadRoutes');
const paymentRoutes = require('./src/routes/paymentRoutes');
const notificationRoutes = require('./src/routes/notificationRoutes');
const wishlistRoutes = require('./src/routes/wishlistRoutes');
const walletRoutes = require('./src/routes/walletRoutes');
const loyaltyRoutes = require('./src/routes/loyaltyRoutes');

// Import middlewares
const { notFound, errorHandler } = require('./src/middlewares/errorMiddleware');
const { apiLimiter } = require('./src/middlewares/rateLimitMiddleware');

// Initialize express app
const app = express();
const server = http.createServer(app);

// Initialize Socket.IO
initializeSocket(server);

// Middleware
app.use(helmet());
app.use(cors({
    origin: process.env.FRONTEND_URL || '*',
    credentials: true
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(morgan('dev'));

// Rate limiting
app.use('/api/', apiLimiter);

// Health check route
app.get('/', (req, res) => {
    res.json({
        success: true,
        message: 'Green Basket API is running',
        version: '1.0.0',
        timestamp: new Date().toISOString()
    });
});

app.get('/api/health', (req, res) => {
    res.json({
        success: true,
        status: 'healthy',
        uptime: process.uptime(),
        timestamp: new Date().toISOString()
    });
});

// API Documentation endpoint
app.get('/api', (req, res) => {
    res.json({
        success: true,
        message: 'Green Basket API',
        version: '1.0.0',
        totalAPIs: 103,
        endpoints: {
            authentication: {
                userSignup: 'POST /api/auth/user/signup',
                userLogin: 'POST /api/auth/user/login',
                verifyEmail: 'POST /api/auth/user/verify-email',
                forgotPassword: 'POST /api/auth/user/forgot-password',
                resetPassword: 'POST /api/auth/user/reset-password',
                merchantSignup: 'POST /api/auth/merchant/signup',
                merchantLogin: 'POST /api/auth/merchant/login',
                adminLogin: 'POST /api/auth/admin/login',
                refreshToken: 'POST /api/auth/refresh-token',
                logout: 'POST /api/auth/logout'
            },
            products: {
                getAll: 'GET /api/products',
                search: 'GET /api/products/search',
                getById: 'GET /api/products/:id',
                create: 'POST /api/products (Merchant)',
                update: 'PUT /api/products/:id (Merchant)',
                delete: 'DELETE /api/products/:id (Merchant)',
                updateStock: 'PATCH /api/products/:id/stock (Merchant)',
                getMyProducts: 'GET /api/products/merchant/my-products (Merchant)'
            },
            categories: {
                getAll: 'GET /api/categories',
                getById: 'GET /api/categories/:id',
                create: 'POST /api/categories (Admin)',
                update: 'PUT /api/categories/:id (Admin)',
                delete: 'DELETE /api/categories/:id (Admin)'
            },
            cart: {
                getCart: 'GET /api/cart',
                addToCart: 'POST /api/cart/add',
                updateItem: 'PUT /api/cart/update/:productId',
                removeItem: 'DELETE /api/cart/remove/:productId',
                clearCart: 'DELETE /api/cart/clear',
                addRecipe: 'POST /api/cart/recipe-to-cart'
            },
            orders: {
                create: 'POST /api/orders',
                getMyOrders: 'GET /api/orders/my-orders',
                getById: 'GET /api/orders/:id',
                cancel: 'PATCH /api/orders/:id/cancel',
                getMerchantOrders: 'GET /api/orders/merchant/orders (Merchant)',
                updateStatus: 'PATCH /api/orders/merchant/:id/status (Merchant)'
            },
            recipes: {
                getAll: 'GET /api/recipes',
                search: 'GET /api/recipes/search',
                getById: 'GET /api/recipes/:id',
                calculateIngredients: 'POST /api/recipes/:id/calculate-ingredients',
                create: 'POST /api/recipes (Admin)',
                update: 'PUT /api/recipes/:id (Admin)',
                delete: 'DELETE /api/recipes/:id (Admin)'
            },
            reviews: {
                getProductReviews: 'GET /api/reviews/product/:productId',
                getMerchantReviews: 'GET /api/reviews/merchant/:merchantId',
                deleteReview: 'DELETE /api/reviews/:id'
            },
            subscriptions: {
                create: 'POST /api/subscriptions',
                getMySubscriptions: 'GET /api/subscriptions',
                updateStatus: 'PATCH /api/subscriptions/:id/status'
            },
            users: {
                getProfile: 'GET /api/users/profile',
                updateProfile: 'PUT /api/users/profile',
                getAddresses: 'GET /api/users/addresses',
                addAddress: 'POST /api/users/addresses',
                updateAddress: 'PUT /api/users/addresses/:id',
                deleteAddress: 'DELETE /api/users/addresses/:id',
                getNotificationPreferences: 'GET /api/users/notification-preferences',
                updateNotificationPreferences: 'PUT /api/users/notification-preferences',
                registerFCMToken: 'POST /api/users/fcm-token',
                removeFCMToken: 'DELETE /api/users/fcm-token'
            },
            merchants: {
                getProfile: 'GET /api/merchants/profile',
                updateProfile: 'PUT /api/merchants/profile',
                toggleStore: 'PATCH /api/merchants/toggle-store',
                getDashboard: 'GET /api/merchants/dashboard-stats'
            },
            admin: {
                getPendingMerchants: 'GET /api/admin/merchants/pending',
                verifyMerchant: 'PATCH /api/admin/merchants/:id/verify',
                getUsers: 'GET /api/admin/users',
                toggleUserBlock: 'PATCH /api/admin/users/:id/block',
                getPlatformStats: 'GET /api/admin/stats'
            },
            upload: {
                uploadImage: 'POST /api/upload/image',
                uploadMultipleImages: 'POST /api/upload/images',
                uploadDocument: 'POST /api/upload/document',
                getMyUploads: 'GET /api/upload/my-uploads',
                getUploadById: 'GET /api/upload/:uploadId',
                deleteUpload: 'DELETE /api/upload/:uploadId',
                bulkDelete: 'POST /api/upload/bulk-delete',
                updateProductImages: 'PUT /api/upload/products/:productId/images'
            },
            payment: {
                createOrder: 'POST /api/payment/create-order',
                verifyPayment: 'POST /api/payment/verify',
                processRefund: 'POST /api/payment/refund'
            },
            notifications: {
                getNotifications: 'GET /api/notifications',
                getUnreadCount: 'GET /api/notifications/unread-count',
                markAsRead: 'PATCH /api/notifications/:id/read',
                markAllAsRead: 'PATCH /api/notifications/read-all',
                deleteNotification: 'DELETE /api/notifications/:id',
                clearAll: 'DELETE /api/notifications/clear-all',
                sendTest: 'POST /api/notifications/admin/test (Admin)',
                bulkSend: 'POST /api/notifications/admin/bulk-send (Admin)'
            },
            wishlist: {
                getWishlist: 'GET /api/wishlist',
                addToWishlist: 'POST /api/wishlist/add',
                removeFromWishlist: 'DELETE /api/wishlist/remove/:productId',
                moveToCart: 'POST /api/wishlist/move-to-cart/:productId',
                checkWishlisted: 'GET /api/wishlist/check/:productId'
            },
            wallet: {
                getWallet: 'GET /api/wallet',
                getTransactions: 'GET /api/wallet/transactions',
                addMoney: 'POST /api/wallet/add-money',
                verifyTopup: 'POST /api/wallet/verify-topup',
                useForPayment: 'POST /api/wallet/use-for-payment',
                adminCredit: 'POST /api/wallet/admin/credit (Admin)',
                lockUnlock: 'PATCH /api/wallet/admin/:userId/lock (Admin)',
                creditRefund: 'POST /api/wallet/credit-refund (Admin)'
            },
            loyalty: {
                redeemPoints: 'POST /api/loyalty/redeem',
                getHistory: 'GET /api/loyalty/history',
                getBenefits: 'GET /api/loyalty/benefits',
                awardPoints: 'POST /api/loyalty/award (Admin)'
            }
        },
        features: {
            implemented: [
                'File Upload System (8 APIs)',
                'Payment Gateway Integration (3 APIs)',
                'Comprehensive Notification System (12 APIs)',
                'Wishlist System (5 APIs)',
                'Wallet & Credits System (8 APIs)',
                'Loyalty Points Redemption (4 APIs)'
            ],
            total: '6 features, 103 APIs'
        },
        documentation: 'See /backend/docs/ for detailed API documentation',
        health: 'GET /api/health'
    });
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/products', productRoutes);
app.use('/api/categories', categoryRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/recipes', recipeRoutes);
app.use('/api/users', userRoutes);
app.use('/api/merchants', merchantRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/reviews', reviewRoutes);
app.use('/api/subscriptions', subscriptionRoutes);
app.use('/api/upload', uploadRoutes);
app.use('/api/payment', paymentRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/wishlist', wishlistRoutes);
app.use('/api/wallet', walletRoutes);
app.use('/api/loyalty', loyaltyRoutes);

// Error handling
app.use(notFound);
app.use(errorHandler);

// Start server
const PORT = process.env.PORT || 6000;

if (require.main === module) {
    // Database connection
    connectDB();

    // Initialize Cron Jobs
    require('./src/cron/subscriptionCron')();
    require('./src/cron/reminderCron')();

    server.listen(PORT, () => {
        console.log('='.repeat(50));
        console.log(`🚀 Server running on port ${PORT}`);
        console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
        console.log(`📡 API: http://localhost:${PORT}/api`);
        console.log('='.repeat(50));
    });
}

// Handle unhandled rejections
process.on('unhandledRejection', (err) => {
    console.error('❌ Unhandled Rejection:', err);
    server.close(() => process.exit(1));
});

// Handle SIGTERM
process.on('SIGTERM', () => {
    console.log('👋 SIGTERM received, shutting down gracefully');
    server.close(() => {
        console.log('💤 Process terminated');
    });
});

module.exports = app;
