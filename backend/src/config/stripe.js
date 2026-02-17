const Stripe = require('stripe');

if (!process.env.STRIPE_SECRET_KEY) {
    console.error('FATAL: STRIPE_SECRET_KEY is not defined in environment variables.');
    // In production, you might want to exit process, but for dev we might just log
}

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY || 'dummy_key', {
    apiVersion: '2023-10-16', // Use the latest stable API version or match your account
});

const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;

module.exports = { stripe, webhookSecret };
