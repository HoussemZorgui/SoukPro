const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const { addReview, getShopReviews } = require('../controllers/reviewController');

// @route   POST /api/reviews
// @desc    Add or update a review
// @access  Private
router.post('/', auth, addReview);

// @route   GET /api/reviews/shop/:shopId
// @desc    Get all reviews for a shop
// @access  Public
router.get('/shop/:shopId', getShopReviews);

module.exports = router;
