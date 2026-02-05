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
