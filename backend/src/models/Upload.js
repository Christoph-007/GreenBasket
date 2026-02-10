const mongoose = require('mongoose');

const uploadSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        refPath: 'userModel',
        required: true
    },
    userModel: {
        type: String,
        enum: ['User', 'Merchant', 'Admin'],
        required: true
    },
    fileType: {
        type: String,
        enum: ['image', 'document', 'video'],
        required: true
    },
    category: {
        type: String,
        enum: ['product', 'profile', 'review', 'document', 'recipe', 'category', 'other'],
        required: true
    },
    originalName: {
        type: String,
        required: true
    },
    cloudinaryPublicId: {
        type: String,
        required: true,
        unique: true
    },
    cloudinaryUrl: {
        type: String,
        required: true
    },
    secureUrl: {
        type: String,
        required: true
    },
    format: String,
    size: Number, // in bytes
    width: Number,
    height: Number,
    metadata: {
        type: Map,
        of: String
    }
}, { timestamps: true });

// Indexes
uploadSchema.index({ userId: 1, category: 1 });
uploadSchema.index({ createdAt: 1 });

module.exports = mongoose.model('Upload', uploadSchema);
