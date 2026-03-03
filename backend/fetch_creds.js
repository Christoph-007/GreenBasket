const mongoose = require('mongoose');
require('dotenv').config();

const User = require('./src/models/User');
const Merchant = require('./src/models/Merchant');
const Admin = require('./src/models/Admin');
const Driver = require('./src/models/Driver');

async function getAllTestAccounts() {
    try {
        await mongoose.connect(process.env.MONGODB_URI);

        const admins = await Admin.find({}).limit(1);
        const merchants = await Merchant.find({}).limit(1);
        const users = await User.find({}).limit(1);
        const drivers = await Driver.find({}).limit(1);

        if (admins.length > 0) {
            console.log('--- ADMIN ---');
            console.log(`ID: ${admins[0]._id}`);
            console.log(`Email: ${admins[0].email}`);
            console.log(`Password: (See manual for default or use login API)\n`);
        }

        if (merchants.length > 0) {
            console.log('--- MERCHANT ---');
            console.log(`ID: ${merchants[0]._id}`);
            console.log(`Email: ${merchants[0].email}`);
            console.log(`Password: (See manual for default or use login API)\n`);
        }

        if (users.length > 0) {
            console.log('--- USER ---');
            console.log(`ID: ${users[0]._id}`);
            console.log(`Email: ${users[0].email}`);
            console.log(`Password: (See manual for default or use login API)\n`);
        }

        if (drivers.length > 0) {
            console.log('--- DRIVER ---');
            console.log(`ID: ${drivers[0]._id}`);
            console.log(`Email: ${drivers[0].email}`);
            console.log(`Password: (See manual for default or use login API)\n`);
        }

    } catch (error) {
        console.error('Error:', error.message);
    } finally {
        await mongoose.connection.close();
    }
}

getAllTestAccounts();
