const mongoose = require('mongoose');
const path = require('path');
const backendDir = "/Users/christophleon/Desktop/Projects/GreenBasket/backend";
require('dotenv').config({ path: path.join(backendDir, '.env') });

const updateProductTags = async () => {
    await mongoose.connect(process.env.MONGODB_URI);
    const Product = require(path.join(backendDir, 'src/models/Product'));

    // Update Organic products
    await Product.updateMany(
        { name: /Organic/i },
        { $addToSet: { tags: 'organic' } }
    );

    // Update Farm Fresh/Local products
    await Product.updateMany(
        { name: /Tomatoes|Spinach|Peppers|Potatoes/i },
        { $addToSet: { tags: 'farm-fresh' } }
    );

    console.log("Product tags updated according to names.");
    process.exit();
};

updateProductTags();
