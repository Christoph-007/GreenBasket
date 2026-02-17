const Product = require('../models/Product');
const uploadService = require('../services/uploadService');

// Get All Products
exports.getAllProducts = async (req, res) => {
    try {
        const { page = 1, limit = 12, category, merchant, search, sort = '-createdAt' } = req.query;

        const query = { status: 'active' };
        if (category) query.category = category;
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
        const merchantId = req.user.id;
        const productData = req.body;

        // Handle image uploads
        let images = [];
        if (req.files && req.files.length > 0) {
            images = await uploadService.uploadMultipleImages(req.files, 'products');
        }

        const product = await Product.create({
            ...productData,
            merchant: merchantId,
            images: images,
            primaryImage: images[0]?.url || ''
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
        const merchantId = req.user.id;
        const updates = req.body;

        const product = await Product.findOne({ _id: id, merchant: merchantId });

        if (!product) {
            return res.status(404).json({
                success: false,
                message: 'Product not found'
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
        const merchantId = req.user.id;

        const product = await Product.findOneAndDelete({ _id: id, merchant: merchantId });

        if (!product) {
            return res.status(404).json({
                success: false,
                message: 'Product not found'
            });
        }

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
        const merchantId = req.user.id;

        const product = await Product.findOne({ _id: id, merchant: merchantId });

        if (!product) {
            return res.status(404).json({
                success: false,
                message: 'Product not found'
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
        const merchantId = req.user.id;
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
