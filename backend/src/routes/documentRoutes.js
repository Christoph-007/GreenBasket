const express = require('express');
const router = express.Router();
const documentController = require('../controllers/documentVerificationController');
const { protect, restrictTo, isAdmin } = require('../middlewares/authMiddleware');

// Merchant routes
router.use(protect);

router.post('/upload',
    restrictTo('merchant'),
    documentController.uploadDocument
);

router.get('/history',
    restrictTo('merchant'),
    documentController.getDocumentHistory
);

router.get('/',
    restrictTo('merchant'),
    documentController.getMerchantDocuments
);
router.delete('/:documentId',
    restrictTo('merchant'),
    documentController.deleteDocument
);

// Admin routes
router.get('/admin/pending',
    isAdmin,
    documentController.getPendingDocuments
);
router.put('/admin/:merchantId/:documentId/verify',
    isAdmin,
    documentController.verifyDocument
);
router.get('/admin/expiring-soon',
    isAdmin,
    documentController.getExpiringDocuments
);

module.exports = router;
