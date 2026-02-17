const { stripe } = require('../config/stripe');

class PaymentService {
    /**
     * Create Payment Intent
     * @param {number} amount - Amount in INR
     * @param {string} orderId - Internal Order ID
     * @param {string} customerId - Customer ID
     * @param {Object} metadata - Additional metadata
     */
    async createPaymentIntent(amount, orderId, customerId, metadata = {}) {
        try {
            const paymentIntent = await stripe.paymentIntents.create({
                amount: Math.round(amount * 100), // Convert to paise/cents
                currency: 'inr',
                description: `Order ${orderId}`,
                metadata: {
                    orderId,
                    customerId,
                    ...metadata
                },
                automatic_payment_methods: {
                    enabled: true,
                },
            });
            return paymentIntent;
        } catch (error) {
            console.error('Stripe payment intent creation error:', error);
            throw error;
        }
    }

    /**
     * Retrieve Payment Intent
     */
    async getPaymentIntent(paymentIntentId) {
        try {
            const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);
            return paymentIntent;
        } catch (error) {
            console.error('Stripe retrieve payment intent error:', error);
            throw error;
        }
    }

    /**
     * Process Refund
     */
    async processRefund(paymentIntentId, amount, reason = 'requested_by_customer') {
        try {
            const refund = await stripe.refunds.create({
                payment_intent: paymentIntentId,
                amount: Math.round(amount * 100),
                reason: null, // Stripe reasons are limited (duplicate, fraudulent, requested_by_customer), providing explicit one might fail if not in enum. safest is to put logic or leave null/default
                metadata: {
                    reason_description: reason
                }
            });
            return refund;
        } catch (error) {
            console.error('Stripe refund error:', error);
            throw error;
        }
    }

    /**
     * Verify Webhook Signature
     */
    verifyWebhookSignature(payload, signature) {
        try {
            const event = stripe.webhooks.constructEvent(
                payload,
                signature,
                process.env.STRIPE_WEBHOOK_SECRET
            );
            return event;
        } catch (err) {
            console.error(`Webhook signature verification failed: ${err.message}`);
            throw err;
        }
    }
}

module.exports = new PaymentService();
