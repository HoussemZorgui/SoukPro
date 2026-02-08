const Shop = require('../models/Shop');
const User = require('../models/User');

// @desc    Create or Update Shop
// @route   POST /api/shops
// @access  Private (Professional only)
exports.createUpdateShop = async (req, res) => {
    try {
        const { name, description, shopAddress, governorate, locationLat, locationLng, phone, facebook, instagram, website } = req.body;

        // Handle file uploads
        let logoPath = null;
        let bannerPath = null;

        if (req.files) {
            if (req.files.logo) {
                logoPath = req.files.logo[0].path;
            }
            if (req.files.banner) {
                bannerPath = req.files.banner[0].path;
            }
        }

        // Build shop object
        const shopFields = {};
        shopFields.owner = req.user.id;
        if (name) shopFields.name = name;
        if (description) shopFields.description = description;
        if (shopAddress) shopFields.shopAddress = shopAddress;
        if (governorate) shopFields.governorate = governorate;
        if (phone) shopFields.phone = phone;

        shopFields.socialLinks = {};
        if (facebook) shopFields.socialLinks.facebook = facebook;
        if (instagram) shopFields.socialLinks.instagram = instagram;
        if (website) shopFields.socialLinks.website = website;

        if (locationLat && locationLng) {
            shopFields.location = { lat: locationLat, lng: locationLng };
        }
        if (logoPath) shopFields.logo = logoPath;
        if (bannerPath) shopFields.banner = bannerPath;

        // See if shop exists
        let shop = await Shop.findOne({ owner: req.user.id });

        if (shop) {
            // Update
            shop = await Shop.findOneAndUpdate(
                { owner: req.user.id },
                { $set: shopFields },
                { new: true }
            );
            return res.json(shop);
        }

        // Create
        shop = new Shop(shopFields);
        await shop.save();

        // Update user shop
        await User.findByIdAndUpdate(req.user.id, { shop: shop.id });

        res.json(shop);

    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

// @desc    Get current user shop
// @route   GET /api/shops/me
// @access  Private
exports.getMyShop = async (req, res) => {
    try {
        const shop = await Shop.findOne({ owner: req.user.id });
        if (!shop) {
            return res.status(404).json({ msg: 'There is no shop for this user' });
        }
        res.json(shop);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

exports.getAllShops = async (req, res) => {
    try {
        const shops = await Shop.find().populate('owner', ['name', 'avatar']);
        res.json(shops);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

// @desc    Get shop by ID
// @route   GET /api/shops/:id
// @access  Public
exports.getShopById = async (req, res) => {
    try {
        const shop = await Shop.findById(req.params.id).populate('owner', ['name', 'avatar', 'createdAt']);
        if (!shop) {
            return res.status(404).json({ msg: 'Shop not found' });
        }
        res.json(shop);
    } catch (err) {
        console.error(err.message);
        if (err.kind === 'ObjectId') {
            return res.status(404).json({ msg: 'Shop not found' });
        }
        res.status(500).send('Server error');
    }
};
