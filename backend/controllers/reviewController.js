const Review = require('../models/Review');
const Shop = require('../models/Shop');

// @desc    Add a review to a shop
// @route   POST /api/reviews
// @access  Private
exports.addReview = async (req, res) => {
    try {
        const { shopId, rating, comment } = req.body;

        // Check if shop exists
        const shop = await Shop.findById(shopId);
        if (!shop) {
            return res.status(404).json({ msg: 'Shop not found' });
        }

        // Check if user already reviewed this shop
        let review = await Review.findOne({ user: req.user.id, shop: shopId });
        if (review) {
            // Update existing review
            review.rating = rating;
            review.comment = comment;
        } else {
            // Create new review
            review = new Review({
                user: req.user.id,
                shop: shopId,
                rating,
                comment
            });
        }

        await review.save();

        // Recalculate shop rating
        const reviews = await Review.find({ shop: shopId });
        const reviewCount = reviews.length;
        const avgRating = reviews.reduce((acc, item) => item.rating + acc, 0) / reviewCount;

        const updatedShop = await Shop.findByIdAndUpdate(shopId, {
            rating: avgRating.toFixed(1),
            reviewCount: reviewCount
        }, { new: true });

        res.json({ review, shop: updatedShop });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

// @desc    Get reviews for a shop
// @route   GET /api/reviews/shop/:shopId
// @access  Public
exports.getShopReviews = async (req, res) => {
    try {
        const reviews = await Review.find({ shop: req.params.shopId })
            .populate('user', ['name', 'avatar'])
            .sort({ createdAt: -1 });
        res.json(reviews);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};
