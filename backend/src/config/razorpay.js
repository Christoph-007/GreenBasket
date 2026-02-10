const Razorpay = require('razorpay');

const razorpay = new Razorpay({
    key_id: process.env.RAZORPAY_KEY_ID,
    key_secret: process.env.RAZORPAY_KEY_SECRET
});

const webhookSecret = process.env.RAZORPAY_WEBHOOK_SECRET;

module.exports = { razorpay, webhookSecret };
