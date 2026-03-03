const Product = require('../models/Product');
const Category = require('../models/Category');
const mongoose = require('mongoose');
const uploadService = require('../services/uploadService');

// Get All Products
exports.getAllProducts = async (req, res) => {
    try {
        const { page = 1, limit = 12, category, merchant, search, sort = '-createdAt' } = req.query;

        const query = { status: 'active' };

        // Premium Logic: Filter restricted products for non-premium users
        const isPremium = req.user && req.userType === 'user' && req.user.isPremium;
        const now = new Date();

        if (isPremium) {
            // Premium users: see products available to premium members
            query.premiumAccessStartDate = { $lte: now };
        } else {
            // Regular users: see public products
            query.isPremiumExclusive = { $ne: true };
            query.$and = [
                { premiumAccessStartDate: { $lte: now } },
                {
                    $or: [
                        { premiumAccessEndDate: { $exists: false } },
                        { premiumAccessEndDate: null },
                        { premiumAccessEndDate: { $lte: now } }
                    ]
                }
            ];
        }

        if (category) {
            if (mongoose.Types.ObjectId.isValid(category)) {
                query.category = category;
            } else {
                const cat = await Category.findOne({ name: new RegExp(`^${category}$`, 'i') });
                if (cat) {
                    query.category = cat._id;
                } else {
                    return res.json({ success: true, data: { products: [], pagination: { page: 1, limit, total: 0, pages: 0 } } });
                }
            }
        }

        if (merchant) query.merchant = merchant;
        if (search) {
            query.$text = { $search: search };
        }

        const products = await Product.find(query)
            .populate('merchant', 'businessName profileImage averageRating')
            .populate('category', 'name')
            .sort(sort)
            .limit(limit * 1)
            .skip((page - 1) * limit);

        const total = await Product.countDocuments(query);

        res.json({
            success: true,
            data: {
                products,
                pagination: {
                    page: parseInt(page),
                    limit: parseInt(limit),
                    total,
                    pages: Math.ceil(total / limit)
                }
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching products',
            error: error.message
        });
    }
};

// Get Product By ID
exports.getProductById = async (req, res) => {
    try {
        const { id } = req.params;

        const product = await Product.findById(id)
            .populate('merchant', 'businessName profileImage averageRating address')
            .populate('category', 'name');

        if (!product) {
            return res.status(404).json({
                success: false,
                message: 'Product not found'
            });
        }

        // Premium Logic: Check if user is restricted
        const isPremium = req.user && req.userType === 'user' && req.user.isPremium;
        const isOwner = req.user && req.userType === 'merchant' && product.merchant._id.toString() === req.user._id.toString();

        if (!isOwner) {
            const now = new Date();

            // Check if product is even released for premium
            if (now < product.premiumAccessStartDate) {
                return res.status(403).json({
                    success: false,
                    message: 'This product is not yet available.'
                });
            }

            // Check if product is still premium-only
            if (!isPremium) {
                const isEarlyAccess = product.premiumAccessEndDate && now < product.premiumAccessEndDate;
                if (product.isPremiumExclusive || isEarlyAccess) {
                    return res.status(403).json({
                        success: false,
                        message: product.isPremiumExclusive ? 'This product is exclusive to premium members.' : 'This product is currently in early access for premium members.'
                    });
                }
            }
        }

        // Increment views
        product.views += 1;
        await product.save();

        res.json({
            success: true,
            data: { product }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching product',
            error: error.message
        });
    }
};

// Create Product (Merchant)
exports.createProduct = async (req, res) => {
    try {
        const merchantId = req.user._id;
        const productData = { ...req.body };

        // Check if product with same name already exists for this merchant (Upsert logic)
        const existingProduct = await Product.findOne({
            name: productData.name,
            merchant: merchantId
        });

        if (existingProduct) {
            existingProduct.stock += (parseInt(productData.stock) || 0);

            // Re-activate if it was out of stock
            if (existingProduct.stock > 0 && existingProduct.status === 'out-of-stock') {
                existingProduct.status = 'active';
            }

            await existingProduct.save();

            return res.status(200).json({
                success: true,
                message: 'Product already exists. Stock updated successfully.',
                data: { product: existingProduct }
            });
        }

        // Handle image uploads
        let images = [];
        if (req.files && req.files.length > 0) {
            images = await uploadService.uploadMultipleImages(req.files, 'products');
        }

        if (req.body.premiumAccessStartDate && req.body.premiumAccessEndDate) {
            if (new Date(req.body.premiumAccessStartDate) >= new Date(req.body.premiumAccessEndDate)) {
                return res.status(400).json({
                    success: false,
                    message: 'Premium access start date must be before the end date'
                });
            }
        }

        const product = await Product.create({
            ...productData,
            merchant: merchantId,
            images: images,
            primaryImage: images[0]?.url || req.body.primaryImage || 'https://res.cloudinary.com/demo/image/upload/sample.jpg'
        });

        res.status(201).json({
            success: true,
            message: 'Product created successfully',
            data: { product }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error creating product',
            error: error.message
        });
    }
};

// Update Product (Merchant)
exports.updateProduct = async (req, res) => {
    try {
        const { id } = req.params;
        const merchantId = req.user._id;
        const updates = { ...req.body };

        // 1. Check if product exists at all
        const product = await Product.findById(id);

        if (!product) {
            return res.status(404).json({
                success: false,
                message: `Product with ID ${id} not found in database.`
            });
        }

        // 2. Check ownership
        if (product.merchant.toString() !== merchantId.toString()) {
            return res.status(403).json({
                success: false,
                message: `Access denied. You do not own this product. (Your ID: ${merchantId}, Product Owner: ${product.merchant})`
            });
        }

        // Handle new image uploads
        if (req.files && req.files.length > 0) {
            const newImages = await uploadService.uploadMultipleImages(req.files, 'products');
            updates.images = [...product.images, ...newImages];
            if (!updates.primaryImage) {
                updates.primaryImage = newImages[0]?.url;
            }
        }

        Object.assign(product, updates);
        await product.save();

        res.json({
            success: true,
            message: 'Product updated successfully',
            data: { product }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error updating product',
            error: error.message
        });
    }
};

// Delete Product (Merchant)
exports.deleteProduct = async (req, res) => {
    try {
        const { id } = req.params;
        const merchantId = req.user._id;

        // 1. Check if product exists at all
        const productCheck = await Product.findById(id);

        if (!productCheck) {
            return res.status(404).json({
                success: false,
                message: `Product with ID ${id} not found in database.`
            });
        }

        // 2. Check ownership
        if (productCheck.merchant.toString() !== merchantId.toString()) {
            return res.status(403).json({
                success: false,
                message: `Access denied. You do not own this product. (Your ID: ${merchantId}, Product Owner: ${productCheck.merchant})`
            });
        }

        const product = await Product.findByIdAndDelete(id);

        // Delete images from Cloudinary
        if (product.images && product.images.length > 0) {
            const publicIds = product.images.map(img => img.publicId).filter(Boolean);
            await uploadService.deleteMultipleImages(publicIds);
        }

        res.json({
            success: true,
            message: 'Product deleted successfully'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error deleting product',
            error: error.message
        });
    }
};

// Update Stock (Merchant)
exports.updateStock = async (req, res) => {
    try {
        const { id } = req.params;
        const { stock } = req.body;
        const merchantId = req.user._id;

        // 1. Check if product exists at all
        const product = await Product.findById(id);

        if (!product) {
            return res.status(404).json({
                success: false,
                message: `Product with ID ${id} not found in database.`
            });
        }

        // 2. Check ownership
        if (product.merchant.toString() !== merchantId.toString()) {
            return res.status(403).json({
                success: false,
                message: `Access denied. You do not own this product. (Your ID: ${merchantId}, Product Owner: ${product.merchant})`
            });
        }

        product.stock = stock;

        // Update status based on stock
        if (stock === 0) {
            product.status = 'out-of-stock';
        } else if (product.status === 'out-of-stock') {
            product.status = 'active';
        }

        await product.save();

        res.json({
            success: true,
            message: 'Stock updated successfully',
            data: { product }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error updating stock',
            error: error.message
        });
    }
};

// Get My Products (Merchant)
exports.getMyProducts = async (req, res) => {
    try {
        const merchantId = req.user._id;
        const { page = 1, limit = 12, status } = req.query;

        const query = { merchant: merchantId };
        if (status) query.status = status;

        const products = await Product.find(query)
            .populate('category', 'name')
            .sort({ createdAt: -1 })
            .limit(limit * 1)
            .skip((page - 1) * limit);

        const total = await Product.countDocuments(query);

        res.json({
            success: true,
            data: {
                products,
                pagination: {
                    page: parseInt(page),
                    limit: parseInt(limit),
                    total,
                    pages: Math.ceil(total / limit)
                }
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching products',
            error: error.message
        });
    }
};

// Search Products
exports.searchProducts = async (req, res) => {
    try {
        const { q } = req.query;

        if (!q) {
            return res.json({
                success: true,
                data: { products: [] }
            });
        }

        const products = await Product.find({
            $text: { $search: q },
            status: 'active'
        })
            .populate('merchant', 'businessName')
            .limit(20);

        res.json({
            success: true,
            data: { products }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error searching products',
            error: error.message
        });
    }
};
