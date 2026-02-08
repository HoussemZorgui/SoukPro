const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const { placeBid, getAuctionDetails } = require('../controllers/auctionController');

// @route   POST /api/auctions/bid/:productId
// @desc    Place a bid
// @access  Private
router.post('/bid/:productId', auth, placeBid);

// @route   GET /api/auctions/:productId
// @desc    Get auction details
// @access  Public
router.get('/:productId', getAuctionDetails);

module.exports = router;
