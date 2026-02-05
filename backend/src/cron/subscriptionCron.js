const cron = require('node-cron');
const Subscription = require('../models/Subscription');
const Order = require('../models/Order');
const Product = require('../models/Product');
const { createNotification } = require('../services/notificationService');

// Run every day at 00:00 (Midnight)
const processSubscriptions = () => {
    cron.schedule('0 0 * * *', async () => {
        console.log('Running Subscription Cron Job...');

        try {
            const today = new Date();
            const dayName = today.toLocaleDateString('en-US', { weekday: 'long' }).toLowerCase();

            // Find active subscriptions due today
            const subscriptions = await Subscription.find({
                status: 'active',
                startDate: { $lte: today },
                $or: [
                    { pausedUntil: { $exists: false } },
                    { pausedUntil: { $lt: today } }
                ],
                deliveryDay: dayName // Simple match for weekly
            }).populate('user merchant items.product deliveryAddress');

            console.log(`Found ${subscriptions.length} subscriptions due today.`);

            for (const sub of subscriptions) {
                // Create Order from Subscription
                // Calculate totals
                let itemsTotal = 0;
                const orderItems = [];

                for (const item of sub.items) {
                    if (item.product) { // Ensure product exists
                        // Basic stock check could be here
                        const subtotal = item.product.price * item.quantity;
                        itemsTotal += subtotal;

                        orderItems.push({
                            product: item.product._id,
                            name: item.product.name,
                            price: item.product.price,
                            quantity: item.quantity,
                            unit: item.product.unit,
                            preparation: item.preparation,
                            subtotal
                        });
                    }
                }

                if (orderItems.length === 0) continue;

                const order = await Order.create({
                    customer: sub.user._id,
                    merchant: sub.merchant._id,
                    items: orderItems,
                    itemsTotal,
                    deliveryCharges: sub.merchant.deliveryCharges || 0,
                    totalAmount: itemsTotal + (sub.merchant.deliveryCharges || 0),
                    deliveryType: 'home-delivery',
                    deliveryAddress: sub.deliveryAddress._id,
                    paymentMethod: 'cod', // Default for subscription usually, or wallet
                    paymentStatus: 'pending',
                    status: 'pending',
                    isRecipeOrder: false,
                    deliveryTimeSlot: {
                        date: today,
                        startTime: sub.deliveryTime || '09:00',
                        endTime: '11:00' // Default window
                    }
                });

                // Notify User
                await createNotification({
                    recipient: sub.user._id,
                    recipientModel: 'User',
                    type: 'order',
                    title: 'Subscription Order Placed',
                    message: `Your subscription order ${order.orderId} has been placed.`,
                    data: { orderId: order._id, subscriptionId: sub._id }
                });

                // Notify Merchant
                await createNotification({
                    recipient: sub.merchant._id,
                    recipientModel: 'Merchant',
                    type: 'order',
                    title: 'Subscription Order Received',
                    message: `New subscription order ${order.orderId}.`,
                    data: { orderId: order._id }
                });
            }

        } catch (error) {
            console.error('Error in subscription cron:', error);
        }
    });
};

module.exports = processSubscriptions;
