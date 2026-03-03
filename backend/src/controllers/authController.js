const User = require('../models/User');
const Merchant = require('../models/Merchant');
const Admin = require('../models/Admin');
const Driver = require('../models/Driver');
const generateToken = require('../utils/generateToken');
const { generateAgentToken } = require('../middlewares/agentAuthMiddleware');
const { sendEmail } = require('../services/emailService');
const { addContactToSendGrid } = require('../services/sendgridContactService');
const jwt = require('jsonwebtoken');

// ─────────────────────────────────────────────────────────────
// UNIFIED LOGIN  –  POST /api/auth/login
// Accepts email + password, auto-detects role from DB,
// returns { token, role, user }
// ─────────────────────────────────────────────────────────────
exports.unifiedLogin = async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({
                success: false,
                message: 'Email and password are required'
            });
        }

        // ── 1. Try Customer (User) ──────────────────────────────
        const userRecord = await User.findOne({ email: email.toLowerCase() }).select('+password');
        if (userRecord) {
            const isMatch = await userRecord.comparePassword(password);
            if (!isMatch) {
                return res.status(401).json({ success: false, message: 'Invalid email or password' });
            }
            if (userRecord.isBlocked) {
                return res.status(403).json({ success: false, message: 'Your account has been blocked. Please contact support.' });
            }
            userRecord.lastLoginAt = new Date();
            await userRecord.save({ validateBeforeSave: false });
            const token = generateToken(userRecord._id, 'user');
            return res.json({
                success: true,
                message: 'Login successful',
                token,
                role: 'customer',
                user: {
                    id: userRecord._id,
                    name: userRecord.name,
                    email: userRecord.email,
                    phone: userRecord.phone,
                    profileImage: userRecord.profileImage,
                    isPremium: userRecord.isPremium,
                    loyaltyPoints: userRecord.loyaltyPoints
                }
            });
        }

        // ── 2. Try Merchant ─────────────────────────────────────
        const merchantRecord = await Merchant.findOne({ email: email.toLowerCase() }).select('+password');
        if (merchantRecord) {
            const isMatch = await merchantRecord.comparePassword(password);
            if (!isMatch) {
                return res.status(401).json({ success: false, message: 'Invalid email or password' });
            }
            if (merchantRecord.isBlocked) {
                return res.status(403).json({ success: false, message: 'Your account has been blocked.' });
            }
            merchantRecord.lastLoginAt = new Date();
            await merchantRecord.save({ validateBeforeSave: false });
            const token = generateToken(merchantRecord._id, 'merchant');
            return res.json({
                success: true,
                message: 'Login successful',
                token,
                role: 'merchant',
                user: {
                    id: merchantRecord._id,
                    name: merchantRecord.name,
                    email: merchantRecord.email,
                    businessName: merchantRecord.businessName,
                    verificationStatus: merchantRecord.verificationStatus,
                    isStoreOpen: merchantRecord.isStoreOpen
                }
            });
        }

        // ── 3. Try Admin ────────────────────────────────────────
        const adminRecord = await Admin.findOne({ email: email.toLowerCase() }).select('+password');
        if (adminRecord) {
            const isMatch = await adminRecord.comparePassword(password);
            if (!isMatch) {
                return res.status(401).json({ success: false, message: 'Invalid email or password' });
            }
            adminRecord.lastLoginAt = new Date();
            await adminRecord.save({ validateBeforeSave: false });
            const token = generateToken(adminRecord._id, 'admin');
            return res.json({
                success: true,
                message: 'Login successful',
                token,
                role: 'admin',
                user: {
                    id: adminRecord._id,
                    name: adminRecord.name,
                    email: adminRecord.email,
                    role: adminRecord.role,
                    permissions: adminRecord.permissions
                }
            });
        }

        // ── 4. Try Delivery Agent (Driver) ──────────────────────
        const driverRecord = await Driver.findOne({ email: email.toLowerCase() }).select('+password');
        if (driverRecord) {
            const isMatch = await driverRecord.comparePassword(password);
            if (!isMatch) {
                return res.status(401).json({ success: false, message: 'Invalid email or password' });
            }
            if (!driverRecord.isActive) {
                return res.status(403).json({ success: false, message: 'Your account has been deactivated. Please contact support.' });
            }
            const token = generateAgentToken(driverRecord._id);
            return res.json({
                success: true,
                message: 'Login successful',
                token,
                role: 'delivery_agent',
                user: {
                    id: driverRecord._id,
                    name: driverRecord.name,
                    email: driverRecord.email,
                    phone: driverRecord.phone,
                    vehicleType: driverRecord.vehicleType,
                    status: driverRecord.status,
                    isVerified: driverRecord.isVerified,
                    rating: driverRecord.rating,
                    totalDeliveries: driverRecord.totalDeliveries,
                    totalEarnings: driverRecord.totalEarnings
                }
            });
        }

        // ── 5. Email not found in any collection ────────────────
        return res.status(404).json({
            success: false,
            message: 'No account found with this email address'
        });

    } catch (error) {
        console.error('Unified login error:', error);
        res.status(500).json({
            success: false,
            message: 'Login failed. Please try again.',
            error: error.message
        });
    }
};

// User Signup
exports.userSignup = async (req, res) => {
    try {
        const { name, email, phone, password } = req.body;

        // Check if user exists
        const existingUser = await User.findOne({ $or: [{ email }, { phone }] });
        if (existingUser) {
            return res.status(400).json({
                success: false,
                message: 'User already exists with this email or phone'
            });
        }

        // Create user
        const user = await User.create({
            name,
            email,
            phone,
            password
        });

        // Generate verification token
        const verificationToken = jwt.sign(
            { id: user._id, email: user.email },
            process.env.JWT_SECRET,
            { expiresIn: '24h' }
        );

        // Send verification email
        try {
            await sendEmail({
                to: email,
                subject: 'Verify your Green Basket account',
                template: 'emailVerification',
                data: {
                    name: user.name,
                    verificationLink: `${process.env.FRONTEND_URL}/verify-email?token=${verificationToken}`
                }
            });

            // Add to SendGrid Contacts (Non-blocking / specific list)
            // We run this asynchronously so it doesn't delay the response too much.
            addContactToSendGrid({
                name: user.name,
                email: user.email,
                firstName: user.firstName, // If available in future models
                lastName: user.lastName
            }).catch(console.error);

        } catch (emailError) {
            console.error('Email sending failed:', emailError);
        }

        // Generate auth token
        const token = generateToken(user._id, 'user');

        res.status(201).json({
            success: true,
            message: 'User registered successfully. Please verify your email.',
            data: {
                user: {
                    id: user._id,
                    name: user.name,
                    email: user.email,
                    phone: user.phone
                },
                token
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error in user signup',
            error: error.message
        });
    }
};

// User Login
exports.userLogin = async (req, res) => {
    try {
        const { email, password } = req.body;

        // Find user with password field
        const user = await User.findOne({ email }).select('+password');

        if (!user || !(await user.comparePassword(password))) {
            return res.status(401).json({
                success: false,
                message: 'Invalid email or password'
            });
        }

        if (user.isBlocked) {
            return res.status(403).json({
                success: false,
                message: 'Your account has been blocked. Please contact support.'
            });
        }

        // Update last login
        user.lastLoginAt = new Date();
        await user.save({ validateBeforeSave: false });

        // Generate token
        const token = generateToken(user._id, 'user');

        res.json({
            success: true,
            message: 'Login successful',
            data: {
                user: {
                    id: user._id,
                    name: user.name,
                    email: user.email,
                    phone: user.phone,
                    profileImage: user.profileImage,
                    isPremium: user.isPremium,
                    loyaltyPoints: user.loyaltyPoints
                },
                token
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error in user login',
            error: error.message
        });
    }
};

// Merchant Signup
exports.merchantSignup = async (req, res) => {
    try {
        const { name, email, phone, password, businessName, merchantType } = req.body;

        // Check existing merchant
        const existingMerchant = await Merchant.findOne({ $or: [{ email }, { phone }] });
        if (existingMerchant) {
            return res.status(400).json({
                success: false,
                message: 'Merchant already exists'
            });
        }

        // Create merchant
        const merchant = await Merchant.create({
            name,
            email,
            phone,
            password,
            businessName,
            merchantType,
            verificationStatus: 'pending'
        });

        const token = generateToken(merchant._id, 'merchant');

        res.status(201).json({
            success: true,
            message: 'Merchant registered. Waiting for admin approval.',
            data: {
                merchant: {
                    id: merchant._id,
                    name: merchant.name,
                    businessName: merchant.businessName,
                    verificationStatus: merchant.verificationStatus
                },
                token
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error in merchant signup',
            error: error.message
        });
    }
};

// Merchant Login
exports.merchantLogin = async (req, res) => {
    try {
        const { email, password } = req.body;

        const merchant = await Merchant.findOne({ email }).select('+password');

        if (!merchant || !(await merchant.comparePassword(password))) {
            return res.status(401).json({
                success: false,
                message: 'Invalid email or password'
            });
        }

        if (merchant.isBlocked) {
            return res.status(403).json({
                success: false,
                message: 'Your account has been blocked.'
            });
        }

        merchant.lastLoginAt = new Date();
        await merchant.save({ validateBeforeSave: false });

        const token = generateToken(merchant._id, 'merchant');

        res.json({
            success: true,
            message: 'Login successful',
            data: {
                merchant: {
                    id: merchant._id,
                    name: merchant.name,
                    businessName: merchant.businessName,
                    verificationStatus: merchant.verificationStatus,
                    isStoreOpen: merchant.isStoreOpen
                },
                token
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error in merchant login',
            error: error.message
        });
    }
};

// Admin Login
exports.adminLogin = async (req, res) => {
    try {
        const { email, password } = req.body;

        const admin = await Admin.findOne({ email }).select('+password');

        if (!admin || !(await admin.comparePassword(password))) {
            return res.status(401).json({
                success: false,
                message: 'Invalid credentials'
            });
        }

        admin.lastLoginAt = new Date();
        await admin.save({ validateBeforeSave: false });

        const token = generateToken(admin._id, 'admin');

        res.json({
            success: true,
            message: 'Admin login successful',
            data: {
                admin: {
                    id: admin._id,
                    name: admin.name,
                    role: admin.role,
                    permissions: admin.permissions
                },
                token
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error in admin login',
            error: error.message
        });
    }
};

// Verify Email
exports.verifyEmail = async (req, res) => {
    try {
        const { token } = req.body;

        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        const user = await User.findById(decoded.id);
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        user.isEmailVerified = true;
        await user.save();

        res.json({
            success: true,
            message: 'Email verified successfully'
        });
    } catch (error) {
        res.status(400).json({
            success: false,
            message: 'Invalid or expired verification token'
        });
    }
};

// Forgot Password
exports.forgotPassword = async (req, res) => {
    try {
        const { email } = req.body;

        const user = await User.findOne({ email });
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        // Generate reset token
        const resetToken = jwt.sign(
            { id: user._id },
            process.env.JWT_SECRET,
            { expiresIn: '1h' }
        );

        // Send reset email
        await sendEmail({
            to: email,
            subject: 'Password Reset Request',
            template: 'passwordReset',
            data: {
                name: user.name,
                resetLink: `${process.env.FRONTEND_URL}/reset-password?token=${resetToken}`
            }
        });

        res.json({
            success: true,
            message: 'Password reset link sent to your email'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error sending reset email',
            error: error.message
        });
    }
};

// Reset Password
exports.resetPassword = async (req, res) => {
    try {
        const { token, newPassword } = req.body;

        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        const user = await User.findById(decoded.id);
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        user.password = newPassword;
        user.passwordChangedAt = new Date();
        await user.save();

        res.json({
            success: true,
            message: 'Password reset successful'
        });
    } catch (error) {
        res.status(400).json({
            success: false,
            message: 'Invalid or expired reset token'
        });
    }
};

// Refresh Token
exports.refreshToken = async (req, res) => {
    try {
        const { token } = req.body;

        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        const newToken = generateToken(decoded.id, decoded.userType);

        res.json({
            success: true,
            data: { token: newToken }
        });
    } catch (error) {
        res.status(401).json({
            success: false,
            message: 'Invalid token'
        });
    }
};

// Logout
exports.logout = async (req, res) => {
    res.json({
        success: true,
        message: 'Logged out successfully'
    });
};
