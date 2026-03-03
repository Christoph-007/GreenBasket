const mongoose = require('mongoose');
require('dotenv').config();
const Merchant = require('./src/models/Merchant');

async function checkMerchants() {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('Connected to MongoDB');

        const retailCount = await Merchant.countDocuments({ sellingModel: 'retail' });
        const wholesaleCount = await Merchant.countDocuments({ sellingModel: 'wholesale' });
        const bothCount = await Merchant.countDocuments({ sellingModel: 'both' });
        const totalCount = await Merchant.countDocuments({});

        console.log(`Retail: ${retailCount}`);
        console.log(`Wholesale: ${wholesaleCount}`);
        console.log(`Both: ${bothCount}`);
        console.log(`Total: ${totalCount}`);

        const sampleRetail = await Merchant.findOne({ sellingModel: 'retail' }).select('businessName sellingModel');
        const sampleWholesale = await Merchant.findOne({ sellingModel: 'wholesale' }).select('businessName sellingModel');
        const sampleBoth = await Merchant.findOne({ sellingModel: 'both' }).select('businessName sellingModel');

        console.log('Sample Retail:', sampleRetail);
        console.log('Sample Wholesale:', sampleWholesale);
        console.log('Sample Both:', sampleBoth);

    } catch (error) {
        console.error('Error:', error);
    } finally {
        await mongoose.disconnect();
    }
}

checkMerchants();
