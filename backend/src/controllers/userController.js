const User = require('../models/User');
const Address = require('../models/Address');

exports.getProfile = async (req, res) => {
    try {
        const user = await User.findById(req.user.id);
        res.json({
            success: true,
            data: user
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching profile',
            error: error.message
        });
    }
};

exports.updateProfile = async (req, res) => {
    try {
        const { name, phone, dietaryPreferences, allergies, notificationSettings } = req.body;

        // Only allow updating certain fields
        const updates = {};
        if (name) updates.name = name;
        if (phone) updates.phone = phone;
        if (dietaryPreferences) updates.dietaryPreferences = dietaryPreferences;
        if (allergies) updates.allergies = allergies;
        if (notificationSettings) updates.notificationSettings = notificationSettings;

        const user = await User.findByIdAndUpdate(
            req.user.id,
            updates,
            { new: true, runValidators: true }
        );

        res.json({
            success: true,
            message: 'Profile updated successfully',
            data: user
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error updating profile',
            error: error.message
        });
    }
};

exports.getAddresses = async (req, res) => {
    try {
        const addresses = await Address.find({ user: req.user.id });
        res.json({
            success: true,
            data: addresses
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching addresses',
            error: error.message
        });
    }
};

exports.addAddress = async (req, res) => {
    try {
        // If setting as default, unset other defaults
        if (req.body.isDefault) {
            await Address.updateMany(
                { user: req.user.id },
                { isDefault: false }
            );
        }

        const address = await Address.create({
            ...req.body,
            user: req.user.id
        });

        res.status(201).json({
            success: true,
            message: 'Address added successfully',
            data: address
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error adding address',
            error: error.message
        });
    }
};

exports.updateAddress = async (req, res) => {
    try {
        const { id } = req.params;

        // Check ownership
        const address = await Address.findOne({ _id: id, user: req.user.id });
        if (!address) {
            return res.status(404).json({
                success: false,
                message: 'Address not found'
            });
        }

        if (req.body.isDefault) {
            await Address.updateMany(
                { user: req.user.id },
                { isDefault: false }
            );
        }

        const updatedAddress = await Address.findByIdAndUpdate(
            id,
            req.body,
            { new: true, runValidators: true }
        );

        res.json({
            success: true,
            message: 'Address updated successfully',
            data: updatedAddress
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error updating address',
            error: error.message
        });
    }
};

exports.deleteAddress = async (req, res) => {
    try {
        const { id } = req.params;
        const address = await Address.findOneAndDelete({ _id: id, user: req.user.id });

        if (!address) {
            return res.status(404).json({
                success: false,
                message: 'Address not found'
            });
        }

        res.json({
            success: true,
            message: 'Address deleted successfully'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error deleting address',
            error: error.message
        });
    }
};

// Notification Preferences
exports.updateNotificationPreferences = async (req, res) => {
    try {
        const { email, push, sms } = req.body;

        const user = await User.findById(req.user.id);

        if (!user.notificationPreferences) {
            user.notificationPreferences = {};
        }

        if (email) {
            user.notificationPreferences.email = {
                ...user.notificationPreferences.email,
                ...email
            };
        }

        if (push) {
            user.notificationPreferences.push = {
                ...user.notificationPreferences.push,
                ...push
            };
        }

        if (sms) {
            user.notificationPreferences.sms = {
                ...user.notificationPreferences.sms,
                ...sms
            };
        }

        await user.save();

        res.json({
            success: true,
            message: 'Notification preferences updated successfully',
            data: {
                notificationPreferences: user.notificationPreferences
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error updating notification preferences',
            error: error.message
        });
    }
};

exports.getNotificationPreferences = async (req, res) => {
    try {
        const user = await User.findById(req.user.id);

        res.json({
            success: true,
            data: user.notificationPreferences || {
                email: {
                    orderUpdates: true,
                    offers: true,
                    newsletter: false,
                    productUpdates: true
                },
                push: {
                    orderUpdates: true,
                    offers: true,
                    priceDrops: true,
                    backInStock: true
                },
                sms: {
                    orderUpdates: true,
                    offers: false,
                    otp: true
                }
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching notification preferences',
            error: error.message
        });
    }
};

// FCM Token Management
exports.registerFCMToken = async (req, res) => {
    try {
        const { token, deviceType } = req.body;

        if (!token) {
            return res.status(400).json({
                success: false,
                message: 'Token is required'
            });
        }

        const user = await User.findById(req.user.id);

        if (!user.fcmTokens) {
            user.fcmTokens = [];
        }
        if (!user.deviceTokens) {
            user.deviceTokens = [];
        }

        // Remove token if already exists
        user.fcmTokens = user.fcmTokens.filter(t => t !== token);

        // Add new token
        user.fcmTokens.push(token);

        // Update device tokens
        const existingDevice = user.deviceTokens.find(d => d.token === token);
        if (existingDevice) {
            existingDevice.lastUsed = new Date();
        } else {
            user.deviceTokens.push({
                token,
                deviceType: deviceType || 'web',
                lastUsed: new Date()
            });
        }

        await user.save();

        res.json({
            success: true,
            message: 'FCM token registered successfully'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error registering FCM token',
            error: error.message
        });
    }
};

exports.removeFCMToken = async (req, res) => {
    try {
        const { token } = req.body;

        if (!token) {
            return res.status(400).json({
                success: false,
                message: 'Token is required'
            });
        }

        const user = await User.findById(req.user.id);

        user.fcmTokens = user.fcmTokens.filter(t => t !== token);
        user.deviceTokens = user.deviceTokens.filter(d => d.token !== token);

        await user.save();

        res.json({
            success: true,
            message: 'FCM token removed successfully'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error removing FCM token',
            error: error.message
        });
    }
};
