const Driver = require('../models/Driver');
const Order = require('../models/Order');
const DeliveryAssignment = require('../models/DeliveryAssignment');
const Address = require('../models/Address');

/**
 * Calculate distance between two coordinates using Haversine formula
 * @param {Number} lat1 - Latitude of point 1
 * @param {Number} lon1 - Longitude of point 1
 * @param {Number} lat2 - Latitude of point 2
 * @param {Number} lon2 - Longitude of point 2
 * @returns {Number} - Distance in kilometers
 */
const calculateDistance = (lat1, lon1, lat2, lon2) => {
    const R = 6371; // Earth's radius in km
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLon = (lon2 - lon1) * Math.PI / 180;
    const a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
};

/**
 * Auto-assign order to nearest available driver
 * This is a pure service function that can be called from anywhere
 * @param {String} orderId - MongoDB ObjectId of the order
 * @returns {Object} - Assignment result
 */
exports.assignOrder = async (orderId) => {
    const session = await Order.startSession();
    session.startTransaction();

    try {
        // 1. Fetch the order with delivery address
        const order = await Order.findById(orderId)
            .populate('deliveryAddress')
            .session(session);

        if (!order) {
            throw new Error('Order not found');
        }

        // Skip if already assigned
        if (order.deliveryAssignment) {
            await session.abortTransaction();
            return {
                success: false,
                message: 'Order already has a delivery assignment',
                assignment: null
            };
        }

        // Skip pickup orders
        if (order.deliveryType === 'pickup') {
            await session.abortTransaction();
            return {
                success: true,
                message: 'Pickup orders do not require delivery assignment',
                assignment: null
            };
        }

        // 2. Get delivery coordinates
        const deliveryAddress = order.deliveryAddress;

        // Auto-geocode if missing coordinates
        if (!deliveryAddress.location || !deliveryAddress.location.coordinates || deliveryAddress.location.coordinates.length !== 2) {
            console.log(`🌍 Auto-geocoding delivery address for order ${orderId}...`);
            const geocodingService = require('./geocodingService');
            const addressString = geocodingService.constructAddressString(deliveryAddress);

            try {
                const coords = await geocodingService.getCoordinates(addressString);
                if (coords) {
                    deliveryAddress.location = {
                        type: 'Point',
                        coordinates: [coords.lng, coords.lat]
                    };
                    // Update the address document to avoid re-geocoding later
                    await Address.findByIdAndUpdate(deliveryAddress._id, {
                        location: deliveryAddress.location
                    });
                    console.log(`✅ Geocoding successful: ${coords.lat}, ${coords.lng}`);
                }
            } catch (error) {
                console.warn(`❌ Geocoding failed for order ${orderId}:`, error.message);
            }
        }

        if (!deliveryAddress || !deliveryAddress.location || !deliveryAddress.location.coordinates) {
            // Mark for manual assignment
            order.needsManualAssignment = true;
            await order.save({ session });
            await session.commitTransaction();

            console.warn(`Order ${orderId} marked for manual assignment: No delivery coordinates`);
            return {
                success: false,
                message: 'No delivery coordinates available',
                needsManualAssignment: true
            };
        }

        const [deliveryLng, deliveryLat] = deliveryAddress.location.coordinates;

        // 3. Query available drivers
        const availableDrivers = await Driver.find({
            status: 'available',
            isActive: true,
            isVerified: true
        }).session(session);

        if (availableDrivers.length === 0) {
            // No drivers available - mark for manual assignment
            order.needsManualAssignment = true;
            await order.save({ session });
            await session.commitTransaction();

            console.warn(`Order ${orderId} marked for manual assignment: No available drivers`);
            return {
                success: false,
                message: 'No available drivers at the moment',
                needsManualAssignment: true
            };
        }

        // 4. Calculate distance from each driver to delivery location
        const driversWithDistance = availableDrivers
            .filter(driver => {
                // Only include drivers with valid location
                return driver.currentLocation &&
                    driver.currentLocation.coordinates &&
                    driver.currentLocation.coordinates.length === 2;
            })
            .map(driver => {
                const [driverLng, driverLat] = driver.currentLocation.coordinates;
                const distance = calculateDistance(
                    driverLat, driverLng,
                    deliveryLat, deliveryLng
                );
                return { driver, distance };
            });

        if (driversWithDistance.length === 0) {
            // Drivers available but no location data
            order.needsManualAssignment = true;
            await order.save({ session });
            await session.commitTransaction();

            console.warn(`Order ${orderId} marked for manual assignment: No drivers with location data`);
            return {
                success: false,
                message: 'No drivers with location data available',
                needsManualAssignment: true
            };
        }

        // 5. Pick the closest driver
        driversWithDistance.sort((a, b) => a.distance - b.distance);
        const { driver: closestDriver, distance } = driversWithDistance[0];

        // 6. Create delivery assignment (atomic with driver status update)
        const assignment = await DeliveryAssignment.create([{
            order: orderId,
            driver: closestDriver._id,
            status: 'assigned',
            assignedAt: new Date(),
            deliveryLocation: {
                type: 'Point',
                coordinates: [deliveryLng, deliveryLat],
                address: deliveryAddress.fullAddress || deliveryAddress.street
            },
            estimatedDistance: Math.round(distance * 10) / 10,
            deliveryFee: order.deliveryCharges || 0,
            statusHistory: [{
                status: 'assigned',
                timestamp: new Date(),
                location: closestDriver.currentLocation,
                note: `Auto-assigned to ${closestDriver.name}`
            }]
        }], { session });

        // 7. Update driver status to busy
        closestDriver.status = 'busy';
        await closestDriver.save({ session });

        // 8. Update order with assignment reference
        order.deliveryAssignment = assignment[0]._id;
        order.needsManualAssignment = false;
        order.deliveryPersonnel = {
            name: closestDriver.name,
            phone: closestDriver.phone,
            vehicleNumber: closestDriver.vehicleNumber
        };
        await order.save({ session });

        // Commit transaction
        await session.commitTransaction();

        console.log(`✅ Order ${orderId} assigned to driver ${closestDriver.name} (${distance.toFixed(2)} km away)`);

        return {
            success: true,
            message: 'Order assigned successfully',
            assignment: assignment[0],
            driver: {
                id: closestDriver._id,
                name: closestDriver.name,
                phone: closestDriver.phone,
                vehicleType: closestDriver.vehicleType,
                distance: Math.round(distance * 10) / 10
            }
        };

    } catch (error) {
        // Rollback transaction on error
        await session.abortTransaction();
        console.error('Assignment error:', error);

        // Try to mark order for manual assignment
        try {
            const order = await Order.findById(orderId);
            if (order) {
                order.needsManualAssignment = true;
                await order.save();
            }
        } catch (saveError) {
            console.error('Failed to mark order for manual assignment:', saveError);
        }

        throw error;
    } finally {
        session.endSession();
    }
};

/**
 * Manually assign order to specific driver
 * Used by admin/merchant for manual override
 * @param {String} orderId - Order ID
 * @param {String} driverId - Driver ID
 * @returns {Object} - Assignment result
 */
exports.manualAssignOrder = async (orderId, driverId) => {
    const session = await Order.startSession();
    session.startTransaction();

    try {
        const order = await Order.findById(orderId)
            .populate('deliveryAddress')
            .session(session);

        if (!order) {
            throw new Error('Order not found');
        }

        const driver = await Driver.findById(driverId).session(session);

        if (!driver) {
            throw new Error('Driver not found');
        }

        if (!driver.isActive) {
            throw new Error('Driver is not active');
        }

        // Check if driver is already busy
        if (driver.status === 'busy') {
            console.warn(`Driver ${driver.name} is already busy but being manually assigned`);
        }

        // Get delivery coordinates
        const deliveryAddress = order.deliveryAddress;
        let deliveryCoords = null;
        let distance = 0;

        if (deliveryAddress && deliveryAddress.location && deliveryAddress.location.coordinates) {
            deliveryCoords = deliveryAddress.location.coordinates;

            if (driver.currentLocation && driver.currentLocation.coordinates) {
                const [driverLng, driverLat] = driver.currentLocation.coordinates;
                const [deliveryLng, deliveryLat] = deliveryCoords;
                distance = calculateDistance(driverLat, driverLng, deliveryLat, deliveryLng);
            }
        }

        // Create assignment
        const assignment = await DeliveryAssignment.create([{
            order: orderId,
            driver: driverId,
            status: 'assigned',
            assignedAt: new Date(),
            deliveryLocation: deliveryCoords ? {
                type: 'Point',
                coordinates: deliveryCoords,
                address: deliveryAddress.fullAddress || deliveryAddress.street
            } : undefined,
            estimatedDistance: Math.round(distance * 10) / 10,
            deliveryFee: order.deliveryCharges || 0,
            statusHistory: [{
                status: 'assigned',
                timestamp: new Date(),
                note: 'Manually assigned by admin'
            }]
        }], { session });

        // Update driver status
        driver.status = 'busy';
        await driver.save({ session });

        // Update order
        order.deliveryAssignment = assignment[0]._id;
        order.needsManualAssignment = false;
        order.deliveryPersonnel = {
            name: driver.name,
            phone: driver.phone,
            vehicleNumber: driver.vehicleNumber
        };
        await order.save({ session });

        await session.commitTransaction();

        return {
            success: true,
            message: 'Order manually assigned successfully',
            assignment: assignment[0],
            driver: {
                id: driver._id,
                name: driver.name,
                phone: driver.phone
            }
        };

    } catch (error) {
        await session.abortTransaction();
        throw error;
    } finally {
        session.endSession();
    }
};
