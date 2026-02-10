const twilio = require('twilio');

const accountSid = process.env.TWILIO_ACCOUNT_SID || '';
const authToken = process.env.TWILIO_AUTH_TOKEN || '';

let client;
if (accountSid && accountSid.startsWith('AC') && authToken) {
    client = twilio(accountSid, authToken);
} else {
    console.warn('Twilio credentials not configured or invalid. SMS sending will be disabled.');
    // Create dummy client
    client = {
        messages: {
            create: async () => {
                throw new Error('Twilio not configured');
            }
        }
    };
}

const sendSMS = async ({ to, message }) => {
    try {
        await client.messages.create({
            body: message,
            from: process.env.TWILIO_PHONE_NUMBER || '+1234567890',
            to: `+91${to}`
        });

        return { success: true };
    } catch (error) {
        console.error('SMS sending error:', error);
        throw error;
    }
};

module.exports = sendSMS;
