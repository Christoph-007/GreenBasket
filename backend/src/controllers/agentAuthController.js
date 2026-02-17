const Driver = require('../models/Driver');
const { generateAgentToken } = require('../middlewares/agentAuthMiddleware');

/**
 * @desc    Register new delivery agent
 * @route   POST /api/agents/register
 * @access  Public
 */
exports.register = async (req, res) => {
    try {
        const {
            name,
            email,
            password,
            phone,
            vehicleType,
            vehicleNumber,
            licenseNumber
        } = req.body;

        // Validation
        if (!name || !email || !password || !phone || !vehicleType) {
            return res.status(400).json({
                success: false,
                message: 'Please provide all required fields: name, email, password, phone, vehicleType'
            });
        }

        // Check if driver already exists
        const existingDriver = await Driver.findOne({
            $or: [{ email }, { phone }]
        });

        if (existingDriver) {
            return res.status(400).json({
                success: false,
                message: 'A driver with this email or phone already exists'
            });
        }

        // Create driver
        const driver = await Driver.create({
            name,
            email,
            password, // Will be hashed by pre-save hook
            phone,
            vehicleType,
            vehicleNumber,
            licenseNumber,
            status: 'offline',
            isActive: true,
            isVerified: false // Requires admin verification
        });

        // Generate token
        const token = generateAgentToken(driver._id);

        res.status(201).json({
            success: true,
            message: 'Registration successful. Your account is pending verification.',
            data: {
                driver: {
                    id: driver._id,
                    name: driver.name,
                    email: driver.email,
                    phone: driver.phone,
                    vehicleType: driver.vehicleType,
                    status: driver.status,
                    isVerified: driver.isVerified
                },
                token
            }
        });
    } catch (error) {
        console.error('Driver registration error:', error);
        res.status(500).json({
            success: false,
            message: 'Registration failed',
            error: error.message
        });
    }
};

/**
 * @desc    Login delivery agent
 * @route   POST /api/agents/login
 * @access  Public
 */
exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;

        // Validation
        if (!email || !password) {
            return res.status(400).json({
                success: false,
                message: 'Please provide email and password'
            });
        }

        // Find driver with password field
        const driver = await Driver.findOne({ email }).select('+password');

        if (!driver) {
            return res.status(401).json({
                success: false,
                message: 'Invalid credentials'
            });
        }

        // Check password
        const isPasswordValid = await driver.comparePassword(password);

        if (!isPasswordValid) {
            return res.status(401).json({
                success: false,
                message: 'Invalid credentials'
            });
        }

        // Check if account is active
        if (!driver.isActive) {
            return res.status(403).json({
                success: false,
                message: 'Your account has been deactivated. Please contact support.'
            });
        }

        // Generate token
        const token = generateAgentToken(driver._id);

        // Remove password from response
        driver.password = undefined;

        res.json({
            success: true,
            message: 'Login successful',
            data: {
                driver: {
                    id: driver._id,
                    name: driver.name,
                    email: driver.email,
                    phone: driver.phone,
                    vehicleType: driver.vehicleType,
                    vehicleNumber: driver.vehicleNumber,
                    status: driver.status,
                    isVerified: driver.isVerified,
                    rating: driver.rating,
                    totalDeliveries: driver.totalDeliveries,
                    totalEarnings: driver.totalEarnings,
                    profilePhotoUrl: driver.profilePhotoUrl
                },
                token
            }
        });
    } catch (error) {
        console.error('Driver login error:', error);
        res.status(500).json({
            success: false,
            message: 'Login failed',
            error: error.message
        });
    }
};

/**
 * @desc    Get current agent profile
 * @route   GET /api/agents/me
 * @access  Private (Agent)
 */
exports.getProfile = async (req, res) => {
    try {
        const driver = await Driver.findById(req.agent._id)
            .select('-password');

        res.json({
            success: true,
            data: { driver }
        });
    } catch (error) {
        console.error('Get profile error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch profile',
            error: error.message
        });
    }
};

/**
 * @desc    Update agent profile
 * @route   PUT /api/agents/me
 * @access  Private (Agent)
 */
exports.updateProfile = async (req, res) => {
    try {
        const allowedUpdates = [
            'name',
            'phone',
            'vehicleType',
            'vehicleNumber',
            'licenseNumber',
            'profilePhotoUrl'
        ];

        const updates = {};
        allowedUpdates.forEach(field => {
            if (req.body[field] !== undefined) {
                updates[field] = req.body[field];
            }
        });

        const driver = await Driver.findByIdAndUpdate(
            req.agent._id,
            updates,
            { new: true, runValidators: true }
        ).select('-password');

        res.json({
            success: true,
            message: 'Profile updated successfully',
            data: { driver }
        });
    } catch (error) {
        console.error('Update profile error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to update profile',
            error: error.message
        });
    }
};

/**
 * @desc    Update agent status (available/offline)
 * @route   PUT /api/agents/me/status
 * @access  Private (Agent)
 */
exports.updateStatus = async (req, res) => {
    try {
        const { status } = req.body;

        if (!status || !['available', 'offline'].includes(status)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid status. Must be "available" or "offline"'
            });
        }

        const driver = await Driver.findById(req.agent._id);

        // Can't go available if not verified
        if (status === 'available' && !driver.isVerified) {
            return res.status(403).json({
                success: false,
                message: 'Your account must be verified before you can go available'
            });
        }

        driver.status = status;
        await driver.save();

        res.json({
            success: true,
            message: `Status updated to ${status}`,
            data: {
                status: driver.status
            }
        });
    } catch (error) {
        console.error('Update status error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to update status',
            error: error.message
        });
    }
};

/**
 * @desc    Update agent location
 * @route   POST /api/agents/me/location
 * @access  Private (Agent)
 */
exports.updateLocation = async (req, res) => {
    try {
        const { latitude, longitude } = req.body;

        if (latitude === undefined || longitude === undefined) {
            return res.status(400).json({
                success: false,
                message: 'Please provide latitude and longitude'
            });
        }

        // Validate coordinates
        if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
            return res.status(400).json({
                success: false,
                message: 'Invalid coordinates'
            });
        }

        const driver = await Driver.findById(req.agent._id);
        await driver.updateLocation(longitude, latitude);

        res.json({
            success: true,
            message: 'Location updated successfully',
            data: {
                location: driver.currentLocation
            }
        });
    } catch (error) {
        console.error('Update location error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to update location',
            error: error.message
        });
    }
};
