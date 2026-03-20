const mongoose = require('mongoose');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });

const fixDates = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        const Product = require('./src/models/Product');
        const res = await Product.updateMany({}, { 
            $set: { 
                premiumAccessStartDate: new Date("2024-01-01"),
                status: 'active'
            } 
        });
        console.log(`✅ Updated ${res.modifiedCount} products to be available immediately.`);
        process.exit();
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
};

fixDates();
