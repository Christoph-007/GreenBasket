const mongoose = require('mongoose');
const path = require('path');
const backendDir = "/Users/christophleon/Desktop/Projects/GreenBasket/backend";
require('dotenv').config({ path: path.join(backendDir, '.env') });
const Product = require(path.join(backendDir, 'src/models/Product'));

async function seedData() {
    await mongoose.connect(process.env.MONGODB_URI);

    const todayStr = new Date().toISOString().split('T')[0];

    // Assign varying daily stats
    const products = await Product.find({ status: 'active' });

    for (let i = 0; i < products.length; i++) {
        const p = products[i];

        let views = 0;
        let sales = 0;

        // Randomly assign so it sorts properly. 
        // e.g., product at i=0 (Tomatoes) gets high metrics
        if (i === 0) {
            views = 150;
            sales = 30;
        } else if (i === 1) {
            views = 120;
            sales = 50;
        } else if (i === 2) {
            views = 80;
            sales = 10;
        } else {
            views = Math.floor(Math.random() * 50);
            sales = Math.floor(Math.random() * 5);
        }

        p.dailyViews = views;
        p.dailySales = sales;
        p.lastDailyActivity = todayStr;
        await p.save();
    }

    console.log("Seeded daily activity for 24h popular now testing!");
    process.exit();
}

seedData();
