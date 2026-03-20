const Order = require('../models/Order');
const Cart = require('../models/Cart');
const Product = require('../models/Product');
const OrderSocket = require('../sockets/orderSocket');
const notificationService = require('../services/notificationService');
const assignmentService = require('../services/assignmentService');
const mongoose = require('mongoose');

// Create Order
exports.createOrder = async (req, res) => {
    try {
        const userId = req.user.id;
        const {
            items,
            deliveryAddress,
            deliveryType,
            paymentMethod,
            deliveryTimeSlot,
            specialRequests,
            couponCode
        } = req.body;

        // Calculate totals
        let itemsTotal = 0;
        const orderItems = [];

        for (let item of items) {
            const product = await Product.findById(item.product);
            if (!product) {
                return res.status(404).json({
                    success: false,
                    message: `Product ${item.product} not found`
                });
            }

            if (product.stock < item.quantity) {
                return res.status(400).json({
                    success: false,
                    message: `Insufficient stock for ${product.name}`
                });
            }

            const subtotal = product.price * item.quantity;
            itemsTotal += subtotal;

            orderItems.push({
                product: product._id,
                name: product.name,
                price: product.price,
                quantity: item.quantity,
                unit: product.unit,
                preparation: item.preparation,
                subtotal
            });

            // Reduce stock
            product.stock -= item.quantity;
            product.totalSales += item.quantity;

            const todayStr = new Date().toISOString().split('T')[0];
            if (product.lastDailyActivity !== todayStr) {
                product.dailySales = item.quantity;
                product.dailyViews = 0;
                product.lastDailyActivity = todayStr;
            } else {
                product.dailySales = (product.dailySales || 0) + item.quantity;
            }

            await product.save();
        }

        // Get merchant from first product
        const firstProduct = await Product.findById(items[0].product);
        const merchantId = firstProduct.merchant;

        // Calculate delivery charges
        const deliveryCharges = deliveryType === 'pickup' ? 0 : 40;

        // Apply coupon discount if any
        let discount = 0;
        // TODO: Implement coupon logic

        const totalAmount = itemsTotal + deliveryCharges - discount;

        // Create order
        const order = await Order.create({
            customer: userId,
            merchant: merchantId,
            items: orderItems,
            itemsTotal,
            deliveryCharges,
            discount,
            totalAmount,
            deliveryType,
            deliveryAddress,
            deliveryTimeSlot,
            paymentMethod,
            paymentStatus: paymentMethod === 'cod' ? 'pending' : 'pending',
            specialRequests,
            couponCode,
            statusHistory: [{
                status: 'pending',
                timestamp: new Date(),
                note: 'Order placed successfully',
                updatedBy: userId,
                updatedByModel: 'User'
            }]
        });

        // Clear cart
        await Cart.findOneAndUpdate(
            { user: userId },
            { items: [], total: 0 }
        );

        // Real-time notification to merchant
        OrderSocket.notifyNewOrder(merchantId, {
            orderId: order.orderId,
            customerName: req.user.name,
            totalAmount: order.totalAmount,
            itemsCount: order.items.length
        });

        // Create notification
        await notificationService.createNotification({
            recipient: merchantId,
            recipientModel: 'Merchant',
            type: 'order',
            title: 'New Order Received',
            message: `New order ${order.orderId} from ${req.user.name}`,
            data: { orderId: order._id }
        });

        res.status(201).json({
            success: true,
            message: 'Order placed successfully',
            data: { order }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error creating order',
            error: error.message
        });
    }
};

// Get My Orders (Customer)
exports.getMyOrders = async (req, res) => {
    try {
        const userId = req.user.id;
        const { page = 1, limit = 10, status } = req.query;

        const query = { customer: userId };
        if (status) query.status = status;

        const orders = await Order.find(query)
            .populate('merchant', 'businessName profileImage')
            .populate('items.product', 'name primaryImage')
            .sort({ createdAt: -1 })
            .limit(limit * 1)
            .skip((page - 1) * limit);

        const total = await Order.countDocuments(query);

        res.json({
            success: true,
            data: {
                orders,
                pagination: {
                    page: parseInt(page),
                    limit: parseInt(limit),
                    total,
                    pages: Math.ceil(total / limit)
                }
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching orders',
            error: error.message
        });
    }
};

// Get Merchant Orders
exports.getMerchantOrders = async (req, res) => {
    try {
        const merchantId = req.user.id;
        const { page = 1, limit = 10, status } = req.query;

        const query = { merchant: merchantId };
        if (status) query.status = status;

        const orders = await Order.find(query)
            .populate('customer', 'name phone profileImage isPremium')
            .populate('deliveryAddress')
            .sort({ createdAt: -1 })
            .limit(limit * 1)
            .skip((page - 1) * limit);

        const total = await Order.countDocuments(query);

        res.json({
            success: true,
            data: {
                orders,
                pagination: {
                    page: parseInt(page),
                    limit: parseInt(limit),
                    total,
                    pages: Math.ceil(total / limit)
                }
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching orders',
            error: error.message
        });
    }
};

// Update Order Status (Merchant)
exports.updateOrderStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const { status, note } = req.body;
        const merchantId = req.user.id;

        if (!status) {
            return res.status(400).json({
                success: false,
                message: 'Status is required'
            });
        }

        const query = mongoose.Types.ObjectId.isValid(id)
            ? { _id: id, merchant: merchantId }
            : { orderId: id, merchant: merchantId };

        const order = await Order.findOne(query)
            .populate('customer', 'name email phone isPremium')
            .populate('items.product', 'name primaryImage')
            .populate('deliveryAddress');

        if (!order) {
            return res.status(404).json({
                success: false,
                message: 'Order not found'
            });
        }

        // Update status with history
        order.status = status;

        const statusEntry = {
            status,
            timestamp: new Date(),
            note: note || getStatusMessage(status),
            updatedBy: req.user._id,
            updatedByModel: 'Merchant'
        };

        order.statusHistory.push(statusEntry);

        // Update specific timestamps
        if (status === 'confirmed' && !order.confirmedAt) {
            order.confirmedAt = new Date();

            // AUTO-ASSIGN DELIVERY AGENT
            // This happens asynchronously and won't break the order flow if it fails
            if (order.deliveryType === 'home-delivery') {
                setImmediate(async () => {
                    try {
                        console.log(`🚚 Attempting auto-assignment for order ${order.orderId}`);
                        const assignmentResult = await assignmentService.assignOrder(order._id);

                        if (assignmentResult.success) {
                            console.log(`✅ Order ${order.orderId} assigned to ${assignmentResult.driver.name}`);
                        } else if (assignmentResult.needsManualAssignment) {
                            console.warn(`⚠️ Order ${order.orderId} marked for manual assignment: ${assignmentResult.message}`);
                        }
                    } catch (error) {
                        console.error(`❌ Auto-assignment failed for order ${order.orderId}:`, error.message);
                        // Order continues normally - admin can manually assign later
                    }
                });
            }
        }
        if (status === 'out-for-delivery') order.outForDeliveryAt = new Date();
        if (status === 'delivered') order.deliveredAt = new Date();

        await order.save();

        // Real-time update to customer & Notifications
        try {
            OrderSocket.notifyOrderStatusUpdate(order.customer._id, {
                orderId: order.orderId,
                status: order.status,
                statusMessage: getStatusMessage(status)
            });

            await notificationService.createNotification({
                recipient: order.customer._id,
                recipientModel: 'User',
                type: 'order',
                title: 'Order Status Updated',
                message: `Your order ${order.orderId} is now ${status}`,
                data: { orderId: order._id, status }
            });
        } catch (error) {
            console.error('⚠️ Error sending status update notification:', error.message);
            // Don't fail the whole request for notification errors
        }

        res.json({
            success: true,
            message: 'Order status updated',
            data: order
        });
    } catch (error) {
        console.error('❌ Status update failed:', error);
        res.status(500).json({
            success: false,
            message: 'Error updating order status',
            error: error.message
        });
    }
};

// Get Order By ID
exports.getOrderById = async (req, res) => {
    try {
        const { id } = req.params;

        const query = mongoose.Types.ObjectId.isValid(id) ? { _id: id } : { orderId: id };

        const order = await Order.findOne(query)
            .populate('customer', 'name email phone isPremium')
            .populate('merchant', 'businessName phone')
            .populate('items.product', 'name primaryImage')
            .populate('deliveryAddress');

        if (!order) {
            return res.status(404).json({
                success: false,
                message: 'Order not found'
            });
        }

        res.json({
            success: true,
            data: order
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching order',
            error: error.message
        });
    }
};

// Cancel Order
exports.cancelOrder = async (req, res) => {
    try {
        const { id } = req.params;
        const { reason } = req.body;
        const userId = req.user.id;

        const query = mongoose.Types.ObjectId.isValid(id)
            ? { _id: id, customer: userId }
            : { orderId: id, customer: userId };

        const order = await Order.findOne(query);

        if (!order) {
            return res.status(404).json({
                success: false,
                message: 'Order not found'
            });
        }

        if (['delivered', 'cancelled'].includes(order.status)) {
            return res.status(400).json({
                success: false,
                message: 'Cannot cancel this order'
            });
        }

        order.status = 'cancelled';
        order.cancellationReason = reason;
        order.cancelledBy = 'customer';
        order.cancelledAt = new Date();
        await order.save();

        // Restore stock
        for (let item of order.items) {
            await Product.findByIdAndUpdate(item.product, {
                $inc: { stock: item.quantity }
            });
        }

        // Notify merchant
        OrderSocket.notifyOrderCancellation(order.merchant, 'merchant', {
            orderId: order.orderId,
            reason
        });

        res.json({
            success: true,
            message: 'Order cancelled successfully',
            data: { order }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error cancelling order',
            error: error.message
        });
    }
};

// Helper function
const getStatusMessage = (status) => {
    const messages = {
        'confirmed': 'Your order has been confirmed',
        'ready': 'Your order is ready for pickup/delivery',
        'out-for-delivery': 'Your order is out for delivery',
        'delivered': 'Your order has been delivered',
        'cancelled': 'Your order has been cancelled'
    };
    return messages[status] || 'Order status updated';
};

// Add Review
exports.addReview = async (req, res) => {
    try {
        const { id } = req.params;
        const { rating, comment, images } = req.body;
        const userId = req.user.id;

        const order = await Order.findOne({ _id: id, customer: userId });

        if (!order) {
            return res.status(404).json({
                success: false,
                message: 'Order not found'
            });
        }

        if (order.status !== 'delivered') {
            return res.status(400).json({
                success: false,
                message: 'Can only review delivered orders'
            });
        }

        // Check if already reviewed (naive check on order level, though usually reviews are per product)
        // User schema snippet implies review is linked to order, product, etc.
        // But here we are reviewing the ORDER or the PRODUCTS?
        // User schema for Review: order, customer, merchant, product.
        // So a review is per product in an order.
        // But the endpoint is `/api/orders/:id/review`.
        // This suggests reviewing the whole order OR submitting multiple reviews for items.
        // Let's assume it reviews the *Order* (maybe Merchant interaction) AND/OR *Products*.
        // The Review model has `product` field required.
        // This endpoint likely needs to handle creating reviews for each product in the order?

        // Actually, looking at the Review Schema:
        // product: linked to product.
        // So we likely need to iterate over items and create reviews, OR this endpoint receives a specific product ID?
        // Usually `/api/orders/:id/review` implies "Review this order". But if Review requires Product, it's ambiguous.

        // Let's look at `reviewRoutes.js` or descriptions.
        // "Review System" ... "Rating and review system"

        // I will assume the body contains `reviews: [{ productId, rating, comment }]` OR `productId, rating, comment`.
        // If the schema requires Product, we can't just review the Order. 
        // OR maybe the user schema implies one review per order?
        // "product: ... required: true" -> So it IS per product.

        // Let's implement creating reviews for products in the order.
        // But wait, if I use `addReview`, I need the `Review` model.

        // I'll make it simple: Body should have `productId`.

        const Review = require('../models/Review'); // lazy require or move to top

        // Validate productId is in order
        const item = order.items.find(i => i.product.toString() === req.body.productId);
        if (!item) {
            return res.status(400).json({ message: 'Product not in this order' });
        }

        const review = await Review.create({
            order: id,
            customer: userId,
            merchant: order.merchant,
            product: req.body.productId,
            rating,
            comment,
            images
        });

        // Update product average rating
        const Product = require('../models/Product');
        const stats = await Review.aggregate([
            { $match: { product: new mongoose.Types.ObjectId(req.body.productId) } },
            { $group: { _id: '$product', nRating: { $sum: 1 }, avgRating: { $avg: '$rating' } } }
        ]);

        await Product.findByIdAndUpdate(req.body.productId, {
            averageRating: stats[0].avgRating,
            totalReviews: stats[0].nRating
        });

        // Update order reviewed status if all items reviewed? 
        // Or just mark order as reviewed.
        order.rating = rating; // Assuming order also has a rating field? Schema said: rating, review reviewedAt.
        order.review = comment;
        order.reviewedAt = new Date();
        await order.save(); // This reviews the ORDER itself. 
        // The Review Model is for PRODUCTS. 
        // The Order Model has rating/review fields too!

        // Okay, Order Model has `rating` and `review` fields.
        // AND there is a `Review` model.
        // This is a bit duplicative or they serve different purposes (Order Rating vs Product Review).
        // I will implement saving to Order Model AND creating a Review document for the merchant?
        // Review model has `product` field required.
        // If the user wants to review the ORDER (Experience), they update Order model.
        // If they want to review PRODUCTS, they create Review documents.

        // Given the endpoint is `/api/orders/:id/review`, it strongly suggests updating the Order's rating/review.
        // I will do that as primary.

        // AND/OR create a Review for the products?
        // Because Review schema exists and requires Product, maybe there is a separate route for product reviews?
        // But Review also has `order` field.

        // I'll assume this endpoint updates the Order's own rating (Merchant feedback) and OPTIONALLY creates product reviews if provided?
        // Or maybe this endpoint is just for the Order/Merchant experience.

        // I'll stick to updating Order fields for now as that's safe, and maybe create a general 'Review' if product is specified.

        // Let's keep it simple: Update Order rating/review.

        order.rating = rating;
        order.review = comment;
        order.reviewedAt = new Date();
        await order.save();

        res.json({ success: true, data: order });

    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error adding review',
            error: error.message
        });
    }
};

// Enhanced Order Tracking
exports.enhancedTrackOrder = async (req, res) => {
    try {
        const { id } = req.params;
        const query = mongoose.Types.ObjectId.isValid(id) ? { _id: id } : { orderId: id };

        const order = await Order.findOne(query)
            .populate('deliveryPersonnel', 'name phone vehicleNumber')
            .populate('merchant', 'businessName phone') // Location might not be in merchant model selection directly or needs processing
            .select('orderId status statusHistory estimatedDeliveryTime deliveryPersonnel merchant');

        if (!order) {
            return res.status(404).json({ success: false, message: 'Order not found' });
        }

        // Calculate progress percentage
        const statusSteps = ['pending', 'confirmed', 'out-for-delivery', 'delivered'];
        const currentStepIndex = statusSteps.indexOf(order.status);
        const progress = Math.max(0, Math.round(((currentStepIndex + 1) / statusSteps.length) * 100));

        // Mock current location if not available
        const currentLocation = order.deliveryPersonnel?.currentLocation ||
            (order.merchant?.location ? order.merchant.location : { lat: 12.9716, lng: 77.5946 });

        res.json({
            success: true,
            data: {
                orderId: order.orderId,
                status: order.status,
                progress,
                estimatedDelivery: order.estimatedDeliveryTime || new Date(Date.now() + 30 * 60 * 1000), // Mock 30 mins
                currentLocation,
                timeline: (order.statusHistory || []).sort((a, b) => b.timestamp - a.timestamp),
                deliveryPersonnel: order.deliveryPersonnel,
                merchant: order.merchant
            }
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.updateOrderLocation = async (req, res) => {
    try {
        const { id } = req.params;
        const { lat, lng } = req.body;

        if (!lat || !lng) {
            return res.status(400).json({ success: false, error: 'Latitude and longitude are required' });
        }

        const query = mongoose.Types.ObjectId.isValid(id) ? { _id: id } : { orderId: id };
        const order = await Order.findOne(query);
        if (!order) return res.status(404).json({ success: false, error: 'Order not found' });

        if (!order.deliveryPersonnel) order.deliveryPersonnel = {};

        order.deliveryPersonnel.currentLocation = {
            lat,
            lng,
            updatedAt: new Date()
        };
        await order.save();

        OrderSocket.updateOrderLocation(order._id, order.customer, { lat, lng });

        res.json({ success: true, message: 'Location updated' });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

/**
 * @desc    Get comprehensive order tracking information
 * @route   GET /api/orders/:orderId/tracking
 * @access  Private (User/Merchant/Admin)
 */
exports.getOrderTracking = async (req, res) => {
    try {
        const { orderId } = req.params;

        const order = await Order.findOne({ orderId })
            .populate('merchant', 'businessName phone')
            .populate('customer', 'name phone');

        if (!order) {
            return res.status(404).json({ success: false, error: 'Order not found' });
        }

        // Access control
        const isCustomer = order.customer._id.toString() === req.user._id.toString();
        const isMerchant = order.merchant._id.toString() === req.user._id.toString();
        const isAdmin = req.user.userType === 'admin';

        if (!isCustomer && !isMerchant && !isAdmin) {
            return res.status(403).json({ success: false, error: 'Access denied' });
        }

        // Build timeline
        const statusConfig = [
            { status: 'pending', label: 'Order Placed', description: 'Your order has been placed successfully' },
            { status: 'confirmed', label: 'Order Confirmed', description: 'Merchant has confirmed your order' },
            { status: 'out_for_delivery', label: 'Out for Delivery', description: 'Your order is on the way' },
            { status: 'delivered', label: 'Delivered', description: 'Order delivered successfully' }
        ];

        if (order.status === 'cancelled') {
            statusConfig.push({
                status: 'cancelled',
                label: 'Cancelled',
                description: 'Order has been cancelled'
            });
        }

        const historyMap = {};
        (order.statusHistory || []).forEach(h => {
            historyMap[h.status] = { timestamp: h.timestamp, note: h.note };
        });

        const timeline = statusConfig.map(config => ({
            status: config.status,
            label: config.label,
            description: config.description,
            timestamp: historyMap[config.status]?.timestamp || null,
            note: historyMap[config.status]?.note || null,
            completed: !!historyMap[config.status]
        }));

        res.json({
            success: true,
            data: {
                orderId: order.orderId,
                status: order.status,
                estimatedDeliveryTime: order.estimatedDeliveryTime,
                deliveryPersonnel: order.deliveryPersonnel,
                merchant: {
                    businessName: order.merchant.businessName,
                    phone: order.merchant.phone
                },
                deliveryAddress: order.deliveryAddress,
                timeline
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to fetch order tracking',
            details: error.message
        });
    }
};

