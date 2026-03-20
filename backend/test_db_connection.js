const mongoose = require('mongoose');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });

const uri = process.env.MONGODB_URI;

console.log('---------------------------------------------------');
console.log('Testing MongoDB Connection');
console.log('URI:', uri.replace(/:([^:@]+)@/, ':****@')); // Hide password in logs
console.log('Mongoose Version:', mongoose.version);
console.log('---------------------------------------------------');

const connectDB = async () => {
    try {
        console.log('Attempting to connect...');
        // Set a 5-second timeout to fail fast if it's a network issue
        const conn = await mongoose.connect(uri, {
            serverSelectionTimeoutMS: 5000,
            socketTimeoutMS: 45000,
            family: 4,
        });

        console.log(`✅ MongoDB Connected Successfully!`);
        console.log(`Host: ${conn.connection.host}`);
        console.log(`Name: ${conn.connection.name}`);

        await mongoose.connection.close();
        console.log('Connection closed.');
        process.exit(0);
    } catch (error) {
        console.error('❌ Connection Failed!');
        console.error('Error Name:', error.name);
        console.error('Error Message:', error.message);
        if (error.reason) console.error('Reason:', error.reason);
        process.exit(1);
    }
};

connectDB();
