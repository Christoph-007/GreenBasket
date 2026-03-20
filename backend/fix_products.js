const mongoose = require('mongoose');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });

const connectDB = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('MongoDB Connected...');
    } catch (err) {
        console.error(err.message);
        process.exit(1);
    }
};

const fixProducts = async () => {
    await connectDB();
    const Product = require('./src/models/Product');

    const now = new Date();
    const pastDate = new Date(now.getTime() - 24 * 60 * 60 * 1000); // 1 day ago

    const result = await Product.updateMany(
        {},
        {
            $set: {
                premiumAccessStartDate: pastDate,
                isActive: true,
                status: 'active'
            }
        }
    );

    console.log(`Updated ${result.nModified || result.modifiedCount} products to be available.`);

    // Give them some mock data for popular/featured
    const products = await Product.find({});
    for (let i = 0; i < products.length; i++) {
        const p = products[i];
        p.totalSales = Math.floor(Math.random() * 100) + 10;
        p.averageRating = (Math.random() * 2) + 3; // 3.0 to 5.0
        await p.save();
        console.log(`Updated mock data for ${p.name}: sales=${p.totalSales}, rating=${p.averageRating.toFixed(1)}`);
    }

    process.exit();
};

fixProducts();
