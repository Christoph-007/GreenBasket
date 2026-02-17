const jwt = require('jsonwebtoken');
const Driver = require('../models/Driver');

/**
 * Middleware to authenticate delivery agents
 * Validates JWT token with role: 'agent'
 * This is SEPARATE from customer/merchant/admin auth
 */
exports.requireAgent = async (req, res, next) => {
    try {
        let token;

        // Get token from header
        if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
            token = req.headers.authorization.split(' ')[1];
        }

        if (!token) {
            return res.status(401).json({
                success: false,
                message: 'Not authorized. Please login as a delivery agent.'
            });
        }

        // Verify token
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        // Check if token is for an agent
        if (decoded.role !== 'agent') {
            return res.status(403).json({
                success: false,
                message: 'Access denied. Delivery agents only.'
            });
        }

        // Get driver from database
        const driver = await Driver.findById(decoded.id);

        if (!driver) {
            return res.status(401).json({
                success: false,
                message: 'Driver not found'
            });
        }

        if (!driver.isActive) {
            return res.status(403).json({
                success: false,
                message: 'Account has been deactivated. Please contact support.'
            });
        }

        // Attach driver to request
        req.agent = driver;
        req.agentId = driver._id;

        next();
    } catch (error) {
        console.error('Agent auth error:', error);

        if (error.name === 'JsonWebTokenError') {
            return res.status(401).json({
                success: false,
                message: 'Invalid token'
            });
        }

        if (error.name === 'TokenExpiredError') {
            return res.status(401).json({
                success: false,
                message: 'Token expired. Please login again.'
            });
        }

        return res.status(401).json({
            success: false,
            message: 'Authentication failed',
            error: error.message
        });
    }
};

/**
 * Optional middleware to check if agent is verified
 */
exports.requireVerifiedAgent = async (req, res, next) => {
    if (!req.agent) {
        return res.status(401).json({
            success: false,
            message: 'Agent authentication required'
        });
    }

    if (!req.agent.isVerified) {
        return res.status(403).json({
            success: false,
            message: 'Your account is pending verification. Please wait for admin approval.'
        });
    }

    next();
};

/**
 * Generate JWT token for agent
 */
exports.generateAgentToken = (driverId) => {
    return jwt.sign(
        {
            id: driverId,
            role: 'agent' // CRITICAL: This distinguishes agent tokens from user/merchant tokens
        },
        process.env.JWT_SECRET,
        { expiresIn: process.env.JWT_EXPIRE || '30d' }
    );
};
