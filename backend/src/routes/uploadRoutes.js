const express = require('express');
const router = express.Router();
const uploadController = require('../controllers/uploadController');
const { authenticate: protect, isMerchant, isAdmin } = require('../middlewares/authMiddleware');
const { uploadImage, uploadMultipleImages, uploadDocument } = require('../middlewares/upload');

// Using authenticate middleware directly as protect
// Combining isMerchant and isAdmin checks where needed

router.use(protect);

router.post('/image', uploadImage, uploadController.uploadImage);
router.post('/images', uploadMultipleImages, uploadController.uploadMultipleImages);

// Initializing a custom middleware for restricting to merchant/admin
const restrictToMerchantOrAdmin = (req, res, next) => {
    if (req.userType === 'merchant' || req.userType === 'admin') {
        return next();
    }
    return res.status(403).json({
        success: false,
        error: 'Access denied. Only merchants and admins can perform this action.'
    });
};

router.post('/document', restrictToMerchantOrAdmin, uploadDocument, uploadController.uploadDocument);

router.get('/my-uploads', uploadController.getMyUploads);
router.get('/:uploadId', uploadController.getUploadById);

router.delete('/:uploadId', uploadController.deleteUpload);
router.post('/bulk-delete', restrictToMerchantOrAdmin, uploadController.bulkDeleteUploads);

// Product images update
router.put('/products/:productId/images', restrictToMerchantOrAdmin, uploadController.updateProductImages);

module.exports = router;
