const mongoose = require('mongoose');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });

const connectDB = async () => {
    try {
        if (!process.env.MONGODB_URI) {
            console.error('MONGODB_URI is not defined in .env');
            process.exit(1);
        }
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('MongoDB Connected...');
    } catch (err) {
        console.error(err.message);
        process.exit(1);
    }
};

const checkProducts = async () => {
    await connectDB();
    const Product = require('./src/models/Product');
    const Category = require('./src/models/Category');

    const products = await Product.find({});
    console.log(`Total Products: ${products.length}`);

    const activeProducts = await Product.find({ status: 'active' });
    console.log(`Active Products: ${activeProducts.length}`);

    products.forEach((p, i) => {
        if (i === 0) console.log(JSON.stringify(p, null, 2));
        console.log(`- ${p.name}: status=${p.status}, stock=${p.stock}, isPremiumExclusive=${p.isPremiumExclusive}, premiumStartDate=${p.premiumAccessStartDate}`);
    });

    const categories = await Category.find({});
    console.log(`Total Categories: ${categories.length}`);
    categories.forEach(c => console.log(`- ${c.name} (${c._id})`));

    process.exit();
};

checkProducts();
