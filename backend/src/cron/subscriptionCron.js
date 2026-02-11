const cron = require('node-cron');
const Subscription = require('../models/Subscription');
const Order = require('../models/Order');
const notificationService = require('../services/notification');

const runSubscriptionCron = () => {
    // Run daily at 00:00 (Midnight)
    cron.schedule('0 0 * * *', async () => {
        console.log('Running daily subscription renewal check...');
        try {
            const today = new Date();
            today.setHours(0, 0, 0, 0);

            // Find active subscriptions due for delivery
            // Using $lte to catch any missed runs (e.g. server downtime)
            // Relies on nextDelivery field being properly set
            const dueSubscriptions = await Subscription.find({
                status: 'active',
                nextDelivery: { $lte: new Date() }
            }).populate('user merchant items.product deliveryAddress');

            console.log(`Found ${dueSubscriptions.length} subscriptions due.`);

            for (const sub of dueSubscriptions) {
                try {

                    // Check if paused
                    if (sub.pausedUntil && sub.pausedUntil > new Date()) {
                        // Move nextDelivery forward beyond pause
                        let nextDate = new Date(sub.nextDelivery);
                        while (nextDate <= sub.pausedUntil) {
                            if (sub.frequency === 'daily') nextDate.setDate(nextDate.getDate() + 1);
                            else if (sub.frequency === 'weekly') nextDate.setDate(nextDate.getDate() + 7);
                            else if (sub.frequency === 'bi-weekly') nextDate.setDate(nextDate.getDate() + 14);
                            else if (sub.frequency === 'monthly') nextDate.setMonth(nextDate.getMonth() + 1);
                        }
                        sub.nextDelivery = nextDate;
                        await sub.save();
                        console.log(`Skipped paused subscription ${sub._id}, rescheduled to ${nextDate}`);
                        continue;
                    }

                    // Calculate items for Order
                    const orderItems = [];
                    let itemsTotal = 0;

                    for (const item of sub.items) {
                        if (item.product) {
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

                    // Create Order
                    const order = await Order.create({
                        customer: sub.user._id,
                        merchant: sub.merchant._id,
                        items: orderItems,
                        itemsTotal: itemsTotal,
                        totalAmount: sub.price, // Use subscription price (total)
                        deliveryCharges: 0,
                        paymentMethod: 'online', // Default
                        paymentStatus: 'pending',
                        status: 'pending',
                        deliveryType: 'home-delivery',
                        deliveryAddress: sub.deliveryAddress ? sub.deliveryAddress._id : null,
                        deliveryTimeSlot: {
                            date: new Date(), // Today
                            startTime: sub.deliveryTime || '08:00',
                            endTime: '11:00'
                        },
                        specialRequests: `Subscription: ${sub.name}`,
                        orderedAt: new Date()
                    });

                    // Notify User
                    await notificationService.send(sub.user._id, 'User', {
                        type: 'subscription_reminder',
                        title: 'Subscription Order Created',
                        message: `Order #${order.orderId} created from your subscription. Please complete payment.`,
                        data: { orderId: order._id }
                    });

                    // Update Subscription nextDelivery
                    let nextDate = new Date(sub.nextDelivery);
                    // Ensure we don't set it to past if missed multiple? 
                    // No, just increment ONCE from scheduled date to keep cycle.
                    // But if we missed a week, should we generate multiple orders?
                    // MVP: Generate one, move to next cycle.

                    // If nextDelivery was severeley in past, we should move it to FUTURE relative to TODAY to avoid loop?
                    // Or catch up. Mongoose `find` captures $lte. 
                    // If we only increment once, and it's still in past, the cron will pick it up again IMMEDIATELY next run (or same run if we looped)?
                    // No, cron runs once.
                    // But tomorrow it will pick it up again.
                    // If date is VERY old, we might generate daily orders until caught up.
                    // Better: Set nextDelivery to first valid date >= Tomorrow?
                    // Or just increment logic.

                    if (sub.frequency === 'daily') nextDate.setDate(nextDate.getDate() + 1);
                    else if (sub.frequency === 'weekly') nextDate.setDate(nextDate.getDate() + 7);
                    else if (sub.frequency === 'bi-weekly') nextDate.setDate(nextDate.getDate() + 14);
                    else if (sub.frequency === 'monthly') nextDate.setMonth(nextDate.getMonth() + 1);

                    // If still in past, fast forward?
                    const tomorrow = new Date();
                    tomorrow.setDate(tomorrow.getDate() + 1);
                    tomorrow.setHours(0, 0, 0, 0);

                    while (nextDate < new Date()) { // if still in past
                        if (sub.frequency === 'daily') nextDate.setDate(nextDate.getDate() + 1);
                        else if (sub.frequency === 'weekly') nextDate.setDate(nextDate.getDate() + 7);
                        else if (sub.frequency === 'bi-weekly') nextDate.setDate(nextDate.getDate() + 14);
                        else if (sub.frequency === 'monthly') nextDate.setMonth(nextDate.getMonth() + 1);
                    }

                    sub.nextDelivery = nextDate;
                    await sub.save();

                    console.log(`Generated order ${order.orderId} for subscription ${sub._id}`);

                } catch (subError) {
                    console.error(`Error processing subscription ${sub._id}:`, subError);
                }
            }
        } catch (error) {
            console.error('Subscription cron job error:', error);
        }
    });
};

module.exports = runSubscriptionCron;
