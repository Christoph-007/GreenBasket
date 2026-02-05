const Review = require('../models/Review');

exports.getProductReviews = async (req, res) => {
    try {
        const { productId } = req.params;
        const { page = 1, limit = 10 } = req.query;

        const reviews = await Review.find({ product: productId, isVerified: true })
            .populate('customer', 'name profileImage')
            .sort({ createdAt: -1 })
            .limit(limit * 1)
            .skip((page - 1) * limit);

        const total = await Review.countDocuments({ product: productId, isVerified: true });

        res.json({
            success: true,
            data: {
                reviews,
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
            message: 'Error fetching reviews',
            error: error.message
        });
    }
};

exports.getMerchantReviews = async (req, res) => {
    try {
        const { merchantId } = req.params;
        const { page = 1, limit = 10 } = req.query;

        // Assuming reviews are linked to merchant via `merchant` field
        const reviews = await Review.find({ merchant: merchantId, isVerified: true })
            .populate('customer', 'name profileImage')
            .populate('product', 'name images')
            .sort({ createdAt: -1 })
            .limit(limit * 1)
            .skip((page - 1) * limit);

        const total = await Review.countDocuments({ merchant: merchantId, isVerified: true });

        res.json({
            success: true,
            data: {
                reviews,
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
            message: 'Error fetching reviews',
            error: error.message
        });
    }
};

exports.deleteReview = async (req, res) => {
    try {
        const { id } = req.params;
        const review = await Review.findById(id);

        if (!review) {
            return res.status(404).json({
                success: false,
                message: 'Review not found'
            });
        }

        // Check permissions (Admin or the customer who wrote it)
        if (req.userType !== 'admin' && review.customer.toString() !== req.user.id.toString()) {
            return res.status(403).json({
                success: false,
                message: 'Not authorized to delete this review'
            });
        }

        await review.deleteOne();

        res.json({
            success: true,
            message: 'Review deleted successfully'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error deleting review',
            error: error.message
        });
    }
};
