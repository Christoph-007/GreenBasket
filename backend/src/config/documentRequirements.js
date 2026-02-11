const REQUIRED_DOCUMENTS = ['fssai', 'gst', 'pan'];

const DOCUMENT_CONFIG = {
    fssai: {
        name: 'FSSAI License',
        description: 'Food Safety and Standards Authority of India license',
        required: true,
        hasExpiry: true,
        acceptedFormats: ['pdf', 'jpg', 'jpeg', 'png'],
        maxSizeMB: 5
    },
    gst: {
        name: 'GST Registration',
        description: 'Goods and Services Tax registration certificate',
        required: true,
        hasExpiry: false,
        acceptedFormats: ['pdf', 'jpg', 'jpeg', 'png'],
        maxSizeMB: 5
    },
    pan: {
        name: 'PAN Card',
        description: 'Permanent Account Number card',
        required: true,
        hasExpiry: false,
        acceptedFormats: ['pdf', 'jpg', 'jpeg', 'png'],
        maxSizeMB: 5
    },
    aadhaar: {
        name: 'Aadhaar Card',
        description: 'National identity document',
        required: false,
        hasExpiry: false,
        acceptedFormats: ['pdf', 'jpg', 'jpeg', 'png'],
        maxSizeMB: 5
    },
    bank_details: {
        name: 'Bank Account Details',
        description: 'Cancelled cheque or bank statement',
        required: false,
        hasExpiry: false,
        acceptedFormats: ['pdf', 'jpg', 'jpeg', 'png'],
        maxSizeMB: 5
    },
    organic_certificate: {
        name: 'Organic Certification',
        description: 'Certificate proving organic farming practices',
        required: false,
        hasExpiry: true,
        acceptedFormats: ['pdf', 'jpg', 'jpeg', 'png'],
        maxSizeMB: 10
    },
    farm_ownership: {
        name: 'Farm Ownership Proof',
        description: 'Land ownership or lease documents',
        required: false,
        hasExpiry: false,
        acceptedFormats: ['pdf', 'jpg', 'jpeg', 'png'],
        maxSizeMB: 10
    },
    trade_license: {
        name: 'Trade License',
        description: 'Local body trade license',
        required: false,
        hasExpiry: true,
        acceptedFormats: ['pdf', 'jpg', 'jpeg', 'png'],
        maxSizeMB: 5
    },
    other: {
        name: 'Other Document',
        description: 'Any other relevant document',
        required: false,
        hasExpiry: false,
        acceptedFormats: ['pdf', 'jpg', 'jpeg', 'png'],
        maxSizeMB: 10
    }
};

module.exports = {
    REQUIRED_DOCUMENTS,
    DOCUMENT_CONFIG
};
