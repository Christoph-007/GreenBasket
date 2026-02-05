const Razorpay = require('razorpay');
const crypto = require('crypto');

const razorpay = new Razorpay({
    key_id: process.env.RAZORPAY_KEY_ID,
    key_secret: process.env.RAZORPAY_KEY_SECRET
});

class PaymentService {
    /**
     * Create Razorpay order
     */
    async createOrder(amount, orderId, customerId) {
        try {
            const options = {
                amount: amount * 100, // Convert to paise
                currency: 'INR',
                receipt: orderId,
                notes: {
                    customerId,
                    orderId
                }
            };

            const razorpayOrder = await razorpay.orders.create(options);
            return razorpayOrder;
        } catch (error) {
            console.error('Razorpay order creation error:', error);
            throw error;
        }
    }

    /**
     * Verify payment signature
     */
    verifyPaymentSignature(razorpayOrderId, razorpayPaymentId, razorpaySignature) {
        const generatedSignature = crypto
            .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
            .update(`${razorpayOrderId}|${razorpayPaymentId}`)
            .digest('hex');

        return generatedSignature === razorpaySignature;
    }

    /**
     * Process refund
     */
    async processRefund(paymentId, amount, orderId) {
        try {
            const refund = await razorpay.payments.refund(paymentId, {
                amount: amount * 100, // Convert to paise
                notes: {
                    orderId,
                    reason: 'Order cancelled'
                }
            });
            return refund;
        } catch (error) {
            console.error('Refund error:', error);
            throw error;
        }
    }

    /**
     * Fetch payment details
     */
    async getPaymentDetails(paymentId) {
        try {
            const payment = await razorpay.payments.fetch(paymentId);
            return payment;
        } catch (error) {
            console.error('Fetch payment error:', error);
            throw error;
        }
    }
}

module.exports = new PaymentService();
