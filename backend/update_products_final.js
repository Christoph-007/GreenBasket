const mongoose = require('mongoose');
const path = require('path');
const backendDir = "/Users/christophleon/Desktop/Projects/GreenBasket/backend";
require('dotenv').config({ path: path.join(backendDir, '.env') });

const connectDB = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('MongoDB Connected...');
    } catch (err) {
        console.error(err.message);
        process.exit(1);
    }
};

const updateProducts = async () => {
    await connectDB();
    const Product = require(path.join(backendDir, 'src/models/Product'));

    const productsData = [
        { name: 'Organic Tomatoes', price: 2.99, unit: 'kg', img: 'https://images.unsplash.com/photo-1546094096-0df4bcaaa337?w=500' },
        { name: 'Organic Baby Spinach', price: 3.49, unit: 'bundle', img: 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=500' },
        { name: 'Organic Bell Peppers', price: 1.99, unit: 'piece', img: 'https://images.unsplash.com/photo-1563565375-f3fdf5e2c3a3?w=500' },
        { name: 'Premium Grapes', price: 5.99, unit: 'kg', img: 'https://images.unsplash.com/photo-1537640538966-79f369b41f8f?w=500' },
        { name: 'Organic Honey', price: 12.50, unit: 'piece', img: 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=500' },
        { name: 'Russet Potatoes', price: 0.99, unit: 'kg', img: 'https://images.unsplash.com/photo-1518977676601-b53f02ac6d31?w=500' }
    ];

    for (const data of productsData) {
        await Product.findOneAndUpdate(
            { name: new RegExp(data.name.split(' ')[1] || data.name, 'i') },
            {
                $set: {
                    name: data.name,
                    price: data.price,
                    unit: data.unit,
                    primaryImage: data.img,
                    status: 'active',
                    isActive: true,
                    totalSales: Math.floor(Math.random() * 200) + 50,
                    averageRating: 4.0 + Math.random()
                }
            }
        );
        console.log(`Updated ${data.name}`);
    }

    process.exit();
};

updateProducts();
