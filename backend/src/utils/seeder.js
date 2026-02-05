const mongoose = require('mongoose');
const dotenv = require('dotenv');

// Load env vars
dotenv.config();

// Load Models
const User = require('../models/User');
const Merchant = require('../models/Merchant');
const Category = require('../models/Category');
const Product = require('../models/Product');
const Recipe = require('../models/Recipe');
const Admin = require('../models/Admin');

// Sample Data
const users = [
    {
        name: 'John Doe',
        email: 'user@example.com',
        password: 'password123',
        phone: '1234567890',
        isEmailVerified: true
    },
    {
        name: 'Jane Smith',
        email: 'jane@example.com',
        password: 'password123',
        phone: '0987654321',
        isEmailVerified: true
    }
];

const merchants = [
    {
        name: 'Farmer Joe',
        email: 'merchant@example.com',
        password: 'password123',
        phone: '1122334455',
        businessName: 'Green Valley Farms',
        merchantType: 'organic-farmer',
        description: 'Fresh organic produce directly from the valley.',
        address: {
            street: '123 Farm Lane',
            city: 'Green City',
            state: 'Kerala',
            pincode: '682001'
        },
        location: {
            type: 'Point',
            coordinates: [76.2711, 9.9312] // Cochin coordinates
        },
        verificationStatus: 'approved',
        isStoreOpen: true
    }
];

const categories = [
    {
        name: 'Vegetables',
        description: 'Fresh organic vegetables',
        image: 'https://res.cloudinary.com/demo/image/upload/v1/vegetables.jpg',
        icon: 'carrot'
    },
    {
        name: 'Fruits',
        description: 'Seasonal fresh fruits',
        image: 'https://res.cloudinary.com/demo/image/upload/v1/fruits.jpg',
        icon: 'apple'
    },
    {
        name: 'Spices',
        description: 'Aromatic spices',
        image: 'https://res.cloudinary.com/demo/image/upload/v1/spices.jpg',
        icon: 'pepper'
    }
];

const connectDB = async () => {
    try {
        const conn = await mongoose.connect(process.env.MONGODB_URI);
        console.log(`MongoDB Connected: ${conn.connection.host}`);
    } catch (error) {
        console.error(`Error: ${error.message}`);
        process.exit(1);
    }
};

const importData = async () => {
    try {
        await connectDB();

        // Clear existing data
        await User.deleteMany();
        await Merchant.deleteMany();
        await Category.deleteMany();
        await Product.deleteMany();
        await Recipe.deleteMany();
        await Admin.deleteMany();

        console.log('Data Destroyed...');

        // Create Users
        const createdUsers = await User.create(users);
        console.log(`Created ${createdUsers.length} Users`);

        // Create Merchant
        const createdMerchants = await Merchant.create(merchants);
        const merchantId = createdMerchants[0]._id;
        console.log(`Created ${createdMerchants.length} Merchants`);

        // Create Categories
        const createdCategories = await Category.create(categories);
        console.log(`Created ${createdCategories.length} Categories`);

        const vegCat = createdCategories.find(c => c.name === 'Vegetables');
        const fruitCat = createdCategories.find(c => c.name === 'Fruits');

        // Create Products
        const products = [
            {
                name: 'Organic Ooty Carrot',
                description: 'Sweet and crunchy organic carrots from Ooty.',
                merchant: merchantId,
                category: vegCat._id,
                price: 60,
                unit: 'kg',
                stock: 100,
                primaryImage: 'https://res.cloudinary.com/demo/image/upload/v1/carrot.jpg',
                tags: ['organic', 'farm-fresh'],
                nutritionalInfo: { calories: 41, protein: 0.9, carbohydrates: 9.6, fat: 0.2, fiber: 2.8 },
                availableMonths: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
            },
            {
                name: 'Red Delicious Apple',
                description: 'Fresh apples from Kashmir.',
                merchant: merchantId,
                category: fruitCat._id,
                price: 180,
                unit: 'kg',
                stock: 50,
                primaryImage: 'https://res.cloudinary.com/demo/image/upload/v1/apple.jpg',
                tags: ['seasonal', 'best-seller'],
                availableMonths: [9, 10, 11, 12]
            },
            {
                name: 'Potato',
                description: 'Organic potatoes suitable for all dishes.',
                merchant: merchantId,
                category: vegCat._id,
                price: 40,
                unit: 'kg',
                stock: 200,
                primaryImage: 'https://res.cloudinary.com/demo/image/upload/v1/potato.jpg',
                tags: ['organic', 'farm-fresh'],
                availableMonths: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
            }
        ];

        const createdProducts = await Product.create(products);
        console.log(`Created ${createdProducts.length} Products`);

        // Create Recipe
        const carrot = createdProducts.find(p => p.name === 'Organic Ooty Carrot');
        const potato = createdProducts.find(p => p.name === 'Potato');

        const recipes = [
            {
                name: 'Carrot & Potato Stew',
                description: 'A hearty stew perfect for dinner.',
                image: 'https://res.cloudinary.com/demo/image/upload/v1/stew.jpg',
                cuisine: 'continental',
                category: 'dinner',
                servings: 4,
                prepTime: 20,
                cookTime: 40,
                difficulty: 'easy',
                ingredients: [
                    {
                        name: 'Carrots',
                        quantity: 0.5,
                        unit: 'kg',
                        product: carrot._id
                    },
                    {
                        name: 'Potatoes',
                        quantity: 0.5,
                        unit: 'kg',
                        product: potato._id
                    }
                ],
                instructions: [
                    { stepNumber: 1, instruction: 'Chop carrots and potatoes.' },
                    { stepNumber: 2, instruction: 'Boil in water with spices.' },
                    { stepNumber: 3, instruction: 'Serve hot.' }
                ],
                dietaryTags: ['vegetarian', 'vegan', 'gluten-free']
            }
        ];

        await Recipe.create(recipes);
        console.log(`Created ${recipes.length} Recipes`);

        console.log('Data Imported Successfully!');
        process.exit();

    } catch (error) {
        console.error(`${error}`);
        process.exit(1);
    }
};

const destroyData = async () => {
    try {
        await connectDB();

        await User.deleteMany();
        await Merchant.deleteMany();
        await Category.deleteMany();
        await Product.deleteMany();
        await Recipe.deleteMany();
        await Admin.deleteMany();

        console.log('Data Destroyed!');
        process.exit();
    } catch (error) {
        console.error(`${error}`);
        process.exit(1);
    }
};

if (process.argv[2] === '-d') {
    destroyData();
} else {
    importData();
}
