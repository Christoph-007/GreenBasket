const multer = require('multer');
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const cloudinary = require('../config/cloudinary');

// Image upload configuration
const imageStorage = new CloudinaryStorage({
    cloudinary: cloudinary,
    params: async (req, file) => {
        return {
            folder: `greenbasket/images/${req.user._id}`,
            allowed_formats: ['jpg', 'jpeg', 'png', 'webp'],
            transformation: [
                { width: 2000, height: 2000, crop: 'limit' },
                { quality: 'auto:good' },
                { fetch_format: 'auto' }
            ],
            public_id: `${Date.now()}-${file.originalname.split('.')[0]}`
        };
    }
});

const uploadImage = multer({
    storage: imageStorage,
    limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
    fileFilter: (req, file, cb) => {
        if (file.mimetype.startsWith('image/')) {
            cb(null, true);
        } else {
            cb(new Error('Only image files are allowed'), false);
        }
    }
});

// Document upload configuration
const documentStorage = new CloudinaryStorage({
    cloudinary: cloudinary,
    params: async (req, file) => {
        return {
            folder: `greenbasket/documents/${req.user._id}`,
            allowed_formats: ['pdf'],
            resource_type: 'raw',
            public_id: `${Date.now()}-${file.originalname.split('.')[0]}`
        };
    }
});

const uploadDocument = multer({
    storage: documentStorage,
    limits: { fileSize: 10 * 1024 * 1024 }, // 10MB
    fileFilter: (req, file, cb) => {
        if (file.mimetype === 'application/pdf') {
            cb(null, true);
        } else {
            cb(new Error('Only PDF files are allowed'), false);
        }
    }
});

module.exports = {
    uploadImage: uploadImage.single('image'),
    uploadMultipleImages: uploadImage.array('images', 5),
    uploadDocument: uploadDocument.single('document')
};
