const Merchant = require('../models/Merchant');

/**
 * @desc    Upload/Update merchant document
 * @route   POST /api/documents/upload
 * @access  Private (Merchant)
 */
exports.uploadDocument = async (req, res) => {
    try {
        const { documentType, documentNumber, expiryDate, documentUrl, notes } = req.body;

        // Validation
        if (!documentType || !documentUrl) {
            return res.status(400).json({
                success: false,
                error: 'documentType and documentUrl are required'
            });
        }

        const validTypes = ['fssai', 'gst', 'pan', 'aadhaar', 'bank_details', 'organic_certificate', 'farm_ownership', 'other'];
        if (!validTypes.includes(documentType)) {
            return res.status(400).json({
                success: false,
                error: `Invalid document type. Must be one of: ${validTypes.join(', ')}`
            });
        }

        const merchant = await Merchant.findById(req.user._id);
        if (!merchant) {
            return res.status(404).json({
                success: false,
                error: 'Merchant not found'
            });
        }

        // Initialize documents array if doesn't exist
        if (!merchant.documents) {
            merchant.documents = [];
        }

        // Check if document type already exists
        const existingDocIndex = merchant.documents.findIndex(d => d.type === documentType);

        if (existingDocIndex !== -1) {
            // Update existing document
            const existingDoc = merchant.documents[existingDocIndex];

            // Archive old doc to history
            if (!merchant.documentHistory) merchant.documentHistory = [];
            merchant.documentHistory.push({
                originalId: existingDoc._id,
                type: existingDoc.type,
                documentNumber: existingDoc.documentNumber,
                documentUrl: existingDoc.documentUrl,
                expiryDate: existingDoc.expiryDate,
                status: existingDoc.status,
                verifiedBy: existingDoc.verifiedBy,
                verifiedAt: existingDoc.verifiedAt,
                rejectionReason: existingDoc.rejectionReason,
                uploadedAt: existingDoc.uploadedAt,
                notes: existingDoc.notes,
                archivedAt: new Date()
            });

            existingDoc.documentUrl = documentUrl;
            existingDoc.documentNumber = documentNumber;
            existingDoc.expiryDate = expiryDate ? new Date(expiryDate) : undefined;
            existingDoc.status = 'pending';
            existingDoc.uploadedAt = new Date();
            existingDoc.rejectionReason = undefined;
            existingDoc.notes = notes;
        } else {
            // Add new document
            merchant.documents.push({
                type: documentType,
                documentNumber,
                documentUrl,
                expiryDate: expiryDate ? new Date(expiryDate) : undefined,
                status: 'pending',
                notes
            });
        }

        await merchant.save();

        res.status(201).json({
            success: true,
            message: 'Document submitted for verification',
            data: {
                documents: merchant.documents
            }
        });
    } catch (error) {
        console.error('Upload document error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to upload document',
            details: error.message
        });
    }
};

/**
 * @desc    Get merchant's documents
 * @route   GET /api/documents
 * @access  Private (Merchant)
 */
exports.getMerchantDocuments = async (req, res) => {
    try {
        const merchant = await Merchant.findById(req.user._id)
            .select('documents businessName email');

        if (!merchant) {
            return res.status(404).json({
                success: false,
                error: 'Merchant not found'
            });
        }

        // Check for expired documents
        let hasChanges = false;
        if (merchant.documents) {
            merchant.documents.forEach(doc => {
                if (doc.status === 'verified' && doc.expiryDate && new Date() > doc.expiryDate) {
                    doc.status = 'expired';
                    hasChanges = true;
                }
            });

            if (hasChanges) {
                await merchant.save();
            }
        }

        res.json({
            success: true,
            data: {
                documents: merchant.documents || [],
                merchantInfo: {
                    businessName: merchant.businessName,
                    email: merchant.email
                }
            }
        });
    } catch (error) {
        console.error('Get merchant documents error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch documents',
            details: error.message
        });
    }
};

/**
 * @desc    Get pending documents for verification (Admin)
 * @route   GET /api/documents/admin/pending
 * @access  Private (Admin)
 */
exports.getPendingDocuments = async (req, res) => {
    try {
        const merchants = await Merchant.find({
            'documents.status': 'pending'
        }).select('businessName email phone documents');

        const pendingDocs = [];

        merchants.forEach(merchant => {
            merchant.documents
                .filter(doc => doc.status === 'pending')
                .forEach(doc => {
                    pendingDocs.push({
                        merchantId: merchant._id,
                        businessName: merchant.businessName,
                        email: merchant.email,
                        phone: merchant.phone,
                        document: doc
                    });
                });
        });

        // Sort by upload date (newest first)
        pendingDocs.sort((a, b) => b.document.uploadedAt - a.document.uploadedAt);

        res.json({
            success: true,
            data: {
                pendingDocuments: pendingDocs,
                count: pendingDocs.length
            }
        });
    } catch (error) {
        console.error('Get pending documents error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch pending documents',
            details: error.message
        });
    }
};

/**
 * @desc    Verify or reject a document (Admin)
 * @route   PUT /api/documents/admin/:merchantId/:documentId/verify
 * @access  Private (Admin)
 */
exports.verifyDocument = async (req, res) => {
    try {
        const { merchantId, documentId } = req.params;
        const { status, rejectionReason } = req.body;

        // Validation
        if (!['verified', 'rejected'].includes(status)) {
            return res.status(400).json({
                success: false,
                error: 'status must be either "verified" or "rejected"'
            });
        }

        if (status === 'rejected' && !rejectionReason) {
            return res.status(400).json({
                success: false,
                error: 'rejectionReason is required when rejecting a document'
            });
        }

        const merchant = await Merchant.findById(merchantId);
        if (!merchant) {
            return res.status(404).json({
                success: false,
                error: 'Merchant not found'
            });
        }

        const doc = merchant.documents.id(documentId);
        if (!doc) {
            return res.status(404).json({
                success: false,
                error: 'Document not found'
            });
        }

        // Update document status
        doc.status = status;
        doc.verifiedBy = req.user._id;
        doc.verifiedAt = new Date();

        if (status === 'rejected') {
            doc.rejectionReason = rejectionReason;
        } else {
            doc.rejectionReason = undefined;
        }

        await merchant.save();

        // Send notification to merchant
        try {
            const notificationService = require('../services/notification');
            await notificationService.send(merchant._id, 'Merchant', {
                type: status === 'verified' ? 'document_verified' : 'document_rejected',
                title: status === 'verified' ? 'Document Verified' : 'Document Rejected',
                message: status === 'verified'
                    ? `Your ${doc.type} document has been verified successfully.`
                    : `Your ${doc.type} document was rejected: ${rejectionReason}`,
                data: {
                    documentType: doc.type,
                    documentId: doc._id
                },
                channels: ['push', 'email']
            });
        } catch (notifError) {
            console.error('Notification error:', notifError);
        }

        res.json({
            success: true,
            message: `Document ${status} successfully`,
            data: {
                document: doc,
                merchantInfo: {
                    businessName: merchant.businessName,
                    email: merchant.email
                }
            }
        });
    } catch (error) {
        console.error('Verify document error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to verify document',
            details: error.message
        });
    }
};

/**
 * @desc    Get documents expiring soon (Admin)
 * @route   GET /api/documents/admin/expiring-soon
 * @access  Private (Admin)
 */
exports.getExpiringDocuments = async (req, res) => {
    try {
        const { days = 30 } = req.query;
        const daysFromNow = new Date(Date.now() + parseInt(days) * 24 * 60 * 60 * 1000);
        const now = new Date();

        const merchants = await Merchant.find({
            'documents.status': 'verified',
            'documents.expiryDate': {
                $lte: daysFromNow,
                $gte: now
            }
        }).select('businessName email phone documents');

        const expiringDocs = [];

        merchants.forEach(merchant => {
            merchant.documents
                .filter(doc =>
                    doc.status === 'verified' &&
                    doc.expiryDate &&
                    doc.expiryDate <= daysFromNow &&
                    doc.expiryDate >= now
                )
                .forEach(doc => {
                    const daysUntilExpiry = Math.ceil(
                        (doc.expiryDate - now) / (24 * 60 * 60 * 1000)
                    );

                    expiringDocs.push({
                        merchantId: merchant._id,
                        businessName: merchant.businessName,
                        email: merchant.email,
                        phone: merchant.phone,
                        document: doc,
                        daysUntilExpiry,
                        urgency: daysUntilExpiry <= 7 ? 'high' : daysUntilExpiry <= 15 ? 'medium' : 'low'
                    });
                });
        });

        // Sort by days until expiry (most urgent first)
        expiringDocs.sort((a, b) => a.daysUntilExpiry - b.daysUntilExpiry);

        res.json({
            success: true,
            data: {
                expiringDocuments: expiringDocs,
                count: expiringDocs.length,
                breakdown: {
                    high: expiringDocs.filter(d => d.urgency === 'high').length,
                    medium: expiringDocs.filter(d => d.urgency === 'medium').length,
                    low: expiringDocs.filter(d => d.urgency === 'low').length
                }
            }
        });
    } catch (error) {
        console.error('Get expiring documents error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch expiring documents',
            details: error.message
        });
    }
};

/**
 * @desc    Delete a document (Merchant)
 * @route   DELETE /api/documents/:documentId
 * @access  Private (Merchant)
 */
exports.deleteDocument = async (req, res) => {
    try {
        const { documentId } = req.params;

        const merchant = await Merchant.findById(req.user._id);
        if (!merchant) {
            return res.status(404).json({
                success: false,
                error: 'Merchant not found'
            });
        }

        const doc = merchant.documents.id(documentId);
        if (!doc) {
            return res.status(404).json({
                success: false,
                error: 'Document not found'
            });
        }

        // Only allow deletion of pending or rejected documents
        if (doc.status === 'verified') {
            return res.status(400).json({
                success: false,
                error: 'Cannot delete verified documents. Please contact support.'
            });
        }

        doc.deleteOne();
        await merchant.save();

        res.json({
            success: true,
            message: 'Document deleted successfully'
        });
    } catch (error) {
        console.error('Delete document error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to delete document',
            details: error.message
        });
    }
};

/**
 * @desc    Get document history (Merchant)
 * @route   GET /api/documents/history
 * @access  Private (Merchant)
 */
exports.getDocumentHistory = async (req, res) => {
    try {
        const merchant = await Merchant.findById(req.user._id).select('documentHistory');

        if (!merchant) {
            return res.status(404).json({ success: false, error: 'Merchant not found' });
        }

        res.json({
            success: true,
            data: merchant.documentHistory || []
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

module.exports = exports;
