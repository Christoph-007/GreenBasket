const Upload = require('../models/Upload');
const Product = require('../models/Product');
const cloudinary = require('../config/cloudinary');

exports.uploadImage = async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({
                success: false,
                error: 'No file uploaded'
            });
        }

        const { category } = req.body;

        if (!category) {
            await cloudinary.uploader.destroy(req.file.public_id);
            return res.status(400).json({
                success: false,
                error: 'Category is required'
            });
        }

        const upload = await Upload.create({
            userId: req.user._id,
            userModel: req.user.userType === 'user' ? 'User' :
                req.user.userType === 'merchant' ? 'Merchant' : 'Admin',
            fileType: 'image',
            category,
            originalName: req.file.originalname,
            cloudinaryPublicId: req.file.public_id,
            cloudinaryUrl: req.file.url,
            secureUrl: req.file.secure_url,
            format: req.file.format,
            size: req.file.bytes,
            width: req.file.width,
            height: req.file.height
        });

        res.status(201).json({
            success: true,
            message: 'Image uploaded successfully',
            data: {
                uploadId: upload._id,
                url: upload.cloudinaryUrl,
                secureUrl: upload.secureUrl,
                publicId: upload.cloudinaryPublicId,
                format: upload.format,
                width: upload.width,
                height: upload.height,
                size: upload.size
            }
        });
    } catch (error) {
        if (req.file && req.file.public_id) {
            await cloudinary.uploader.destroy(req.file.public_id);
        }

        res.status(500).json({
            success: false,
            error: 'Failed to upload image',
            details: error.message
        });
    }
};

exports.uploadMultipleImages = async (req, res) => {
    try {
        if (!req.files || req.files.length === 0) {
            return res.status(400).json({
                success: false,
                error: 'No files uploaded'
            });
        }

        if (req.files.length > 5) {
            for (const file of req.files) {
                await cloudinary.uploader.destroy(file.public_id);
            }
            return res.status(400).json({
                success: false,
                error: 'Maximum 5 images allowed',
                received: req.files.length
            });
        }

        const { category } = req.body;

        if (!category) {
            for (const file of req.files) {
                await cloudinary.uploader.destroy(file.public_id);
            }
            return res.status(400).json({
                success: false,
                error: 'Category is required'
            });
        }

        const uploadPromises = req.files.map(file =>
            Upload.create({
                userId: req.user._id,
                userModel: req.user.userType === 'user' ? 'User' :
                    req.user.userType === 'merchant' ? 'Merchant' : 'Admin',
                fileType: 'image',
                category,
                originalName: file.originalname,
                cloudinaryPublicId: file.public_id,
                cloudinaryUrl: file.url,
                secureUrl: file.secure_url,
                format: file.format,
                size: file.bytes,
                width: file.width,
                height: file.height
            })
        );

        const uploads = await Promise.all(uploadPromises);

        const responseData = uploads.map(upload => ({
            uploadId: upload._id,
            url: upload.cloudinaryUrl,
            secureUrl: upload.secureUrl,
            publicId: upload.cloudinaryPublicId
        }));

        res.status(201).json({
            success: true,
            message: `${uploads.length} images uploaded successfully`,
            data: {
                uploads: responseData,
                count: uploads.length
            }
        });
    } catch (error) {
        if (req.files) {
            for (const file of req.files) {
                await cloudinary.uploader.destroy(file.public_id);
            }
        }

        res.status(500).json({
            success: false,
            error: 'Failed to upload images',
            details: error.message
        });
    }
};

exports.uploadDocument = async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({
                success: false,
                error: 'No file uploaded'
            });
        }

        const { documentType } = req.body;

        if (!documentType) {
            await cloudinary.uploader.destroy(req.file.public_id, { resource_type: 'raw' });
            return res.status(400).json({
                success: false,
                error: 'Document type is required'
            });
        }

        const upload = await Upload.create({
            userId: req.user._id,
            userModel: req.user.userType === 'merchant' ? 'Merchant' : 'Admin',
            fileType: 'document',
            category: 'document',
            originalName: req.file.originalname,
            cloudinaryPublicId: req.file.public_id,
            cloudinaryUrl: req.file.url,
            secureUrl: req.file.secure_url,
            format: req.file.format,
            size: req.file.bytes,
            metadata: {
                documentType
            }
        });

        res.status(201).json({
            success: true,
            message: 'Document uploaded successfully',
            data: {
                uploadId: upload._id,
                url: upload.cloudinaryUrl,
                secureUrl: upload.secureUrl,
                publicId: upload.cloudinaryPublicId,
                format: upload.format,
                size: upload.size
            }
        });
    } catch (error) {
        if (req.file && req.file.public_id) {
            await cloudinary.uploader.destroy(req.file.public_id, { resource_type: 'raw' });
        }

        res.status(500).json({
            success: false,
            error: 'Failed to upload document',
            details: error.message
        });
    }
};

exports.deleteUpload = async (req, res) => {
    try {
        const { uploadId } = req.params;

        const upload = await Upload.findById(uploadId);

        if (!upload) {
            return res.status(404).json({
                success: false,
                error: 'Upload not found'
            });
        }

        if (upload.userId.toString() !== req.user._id.toString() &&
            req.user.userType !== 'admin') {
            return res.status(403).json({
                success: false,
                error: 'You can only delete your own uploads'
            });
        }

        try {
            if (upload.fileType === 'document') {
                await cloudinary.uploader.destroy(upload.cloudinaryPublicId, {
                    resource_type: 'raw'
                });
            } else {
                await cloudinary.uploader.destroy(upload.cloudinaryPublicId);
            }
        } catch (cloudinaryError) {
            console.error('Cloudinary deletion error:', cloudinaryError);
        }

        await upload.deleteOne();

        res.json({
            success: true,
            message: 'Upload deleted successfully'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to delete upload',
            details: error.message
        });
    }
};

exports.getMyUploads = async (req, res) => {
    try {
        const { category, fileType, page = 1, limit = 20 } = req.query;

        const query = { userId: req.user._id };

        if (category) query.category = category;
        if (fileType) query.fileType = fileType;

        const skip = (page - 1) * limit;

        const [uploads, total] = await Promise.all([
            Upload.find(query)
                .select('-cloudinaryPublicId -cloudinaryUrl')
                .sort({ createdAt: -1 })
                .skip(skip)
                .limit(parseInt(limit)),
            Upload.countDocuments(query)
        ]);

        res.json({
            success: true,
            data: {
                uploads,
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
            error: 'Failed to fetch uploads',
            details: error.message
        });
    }
};

exports.updateProductImages = async (req, res) => {
    try {
        const { productId } = req.params;
        const { images, primaryImage } = req.body;

        if (!images || !Array.isArray(images) || images.length === 0) {
            return res.status(400).json({
                success: false,
                error: 'Images array is required and must not be empty'
            });
        }

        if (!primaryImage || !images.includes(primaryImage)) {
            return res.status(400).json({
                success: false,
                error: 'Primary image must be one of the provided images'
            });
        }

        const product = await Product.findById(productId);

        if (!product) {
            return res.status(404).json({
                success: false,
                error: 'Product not found'
            });
        }

        if (product.merchant.toString() !== req.user._id.toString()) {
            return res.status(403).json({
                success: false,
                error: 'You can only update your own products'
            });
        }

        product.primaryImage = primaryImage;
        product.images = images;
        await product.save();

        res.json({
            success: true,
            message: 'Product images updated successfully',
            data: {
                product: {
                    _id: product._id,
                    name: product.name,
                    primaryImage: product.primaryImage,
                    images: product.images
                }
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to update product images',
            details: error.message
        });
    }
};

exports.getUploadById = async (req, res) => {
    try {
        const { uploadId } = req.params;

        const upload = await Upload.findById(uploadId)
            .select('-cloudinaryPublicId -cloudinaryUrl');

        if (!upload) {
            return res.status(404).json({
                success: false,
                error: 'Upload not found'
            });
        }

        res.json({
            success: true,
            data: upload
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to fetch upload',
            details: error.message
        });
    }
};

exports.bulkDeleteUploads = async (req, res) => {
    try {
        const { uploadIds } = req.body;

        if (!uploadIds || !Array.isArray(uploadIds) || uploadIds.length === 0) {
            return res.status(400).json({
                success: false,
                error: 'Upload IDs array is required'
            });
        }

        const uploads = await Upload.find({
            _id: { $in: uploadIds },
            userId: req.user.userType === 'admin' ? { $exists: true } : req.user._id
        });

        if (uploads.length === 0) {
            return res.status(404).json({
                success: false,
                error: 'No uploads found'
            });
        }

        const deleteResults = { deleted: [], failed: [] };

        for (const upload of uploads) {
            try {
                if (upload.fileType === 'document') {
                    await cloudinary.uploader.destroy(upload.cloudinaryPublicId, {
                        resource_type: 'raw'
                    });
                } else {
                    await cloudinary.uploader.destroy(upload.cloudinaryPublicId);
                }

                await upload.deleteOne();
                deleteResults.deleted.push(upload._id);
            } catch (error) {
                deleteResults.failed.push({
                    uploadId: upload._id,
                    error: error.message
                });
            }
        }

        res.json({
            success: true,
            message: `${deleteResults.deleted.length} uploads deleted successfully`,
            data: {
                deletedCount: deleteResults.deleted.length,
                failed: deleteResults.failed
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to delete uploads',
            details: error.message
        });
    }
};
