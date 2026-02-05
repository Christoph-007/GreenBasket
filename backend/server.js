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
const orderRoutes = require('./src/routes/orderRoutes');
const cartRoutes = require('./src/routes/cartRoutes');
const recipeRoutes = require('./src/routes/recipeRoutes');
const userRoutes = require('./src/routes/userRoutes');
const merchantRoutes = require('./src/routes/merchantRoutes');
const adminRoutes = require('./src/routes/adminRoutes');
const reviewRoutes = require('./src/routes/reviewRoutes');
const subscriptionRoutes = require('./src/routes/subscriptionRoutes');

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

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/products', productRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/recipes', recipeRoutes);
app.use('/api/users', userRoutes);
app.use('/api/merchants', merchantRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/reviews', reviewRoutes);
app.use('/api/subscriptions', subscriptionRoutes);

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
