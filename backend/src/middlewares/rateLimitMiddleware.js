const rateLimit = require('express-rate-limit');

// General API rate limiter
exports.apiLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // 100 requests per window
    message: {
        success: false,
        message: 'Too many requests, please try again later.'
    }
});

// Strict limiter for authentication routes
exports.authLimiter = rateLimit({
    windowMs: 60 * 60 * 1000, // 1 hour
    max: 5, // 5 attempts
    message: {
        success: false,
        message: 'Too many login attempts, please try again after an hour.'
    }
});

// Order creation limiter
exports.orderLimiter = rateLimit({
    windowMs: 60 * 1000, // 1 minute
    max: 3, // 3 orders per minute
    message: {
        success: false,
        message: 'Too many orders, please wait a moment.'
    }
});
