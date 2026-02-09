const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const { createUpdateShop, getMyShop, getAllShops, getShopById } = require('../controllers/shopController');

// @route   POST /api/shops
// @desc    Create or update shop
// @access  Private
const upload = require('../middleware/upload');

// @route   POST /api/shops
// @desc    Create or update shop
// @access  Private
// Use upload.fields to handle multiple files (logo and banner)
router.post('/', auth, upload.fields([{ name: 'logo', maxCount: 1 }, { name: 'banner', maxCount: 1 }]), createUpdateShop);

// @route   GET /api/shops/me
// @desc    Get current user's shop
// @access  Private
router.get('/me', auth, getMyShop);

// @route   GET /api/shops
// @desc    Get all shops
// @access  Public
router.get('/', getAllShops);

// @route   GET /api/shops/:id
// @desc    Get shop by ID
// @access  Public
// @route   GET /api/shops/stats/:id
// @desc    Get shop statistics
// @access  Public
const { getShopStats } = require('../controllers/shopController');
router.get('/stats/:id', getShopStats);

module.exports = router;
