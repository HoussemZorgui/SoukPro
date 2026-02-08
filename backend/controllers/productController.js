const Product = require('../models/Product');

// @desc    Create a product
// @route   POST /api/products
// @access  Private
exports.createProduct = async (req, res) => {
    try {
        const { title, description, price, category, condition, type, auctionEndDate, startingBid, isPremium, paymentType, installmentOptions } = req.body;

        // Handle image uploads
        let images = [];
        if (req.files) {
            images = req.files.map(file => file.path);
        }

        let parsedInstallmentOptions = [];
        if (installmentOptions) {
            try {
                parsedInstallmentOptions = typeof installmentOptions === 'string' ? JSON.parse(installmentOptions) : installmentOptions;
            } catch (e) {
                console.error("Error parsing installmentOptions:", e);
            }
        }

        const newProduct = new Product({
            seller: req.user.id,
            title,
            description,
            price,
            images,
            category,
            condition,
            type: type || 'fixed',
            paymentType: paymentType || 'cash',
            installmentOptions: parsedInstallmentOptions,
            auctionEndDate: type === 'auction' ? auctionEndDate : null,
            startingBid: type === 'auction' ? startingBid : null,
            currentMake: type === 'auction' ? startingBid : 0,
            isPremium: isPremium === 'true' || isPremium === true // Handle form-data string or json boolean
        });

        const product = await newProduct.save();
        res.json(product);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

// @desc    Get all products
// @route   GET /api/products
// @access  Public
// @desc    Get all products with filtering and search
// @route   GET /api/products
// @access  Public
exports.getProducts = async (req, res) => {
    try {
        const { search, category, minPrice, maxPrice, condition } = req.query;

        let query = { status: 'available' }; // Default to available products

        // Search text (Title or Description)
        if (search) {
            query.$or = [
                { title: { $regex: search, $options: 'i' } },
                { description: { $regex: search, $options: 'i' } }
            ];
        }

        // Category Filter
        if (category && category !== 'All') {
            query.category = category;
        }

        // Price Filter
        if (minPrice || maxPrice) {
            query.price = {};
            if (minPrice) query.price.$gte = Number(minPrice);
            if (maxPrice) query.price.$lte = Number(maxPrice);
        }

        // Condition Filter
        if (condition) {
            query.condition = condition;
        }

        const products = await Product.find(query)
            .populate('seller', 'name avatar shop role createdAt')
            .sort({ isPremium: -1, createdAt: -1 }); // Premium first
        res.json(products);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

// @desc    Get product by ID
// @route   GET /api/products/:id
// @access  Public
exports.getProductById = async (req, res) => {
    try {
        const product = await Product.findById(req.params.id).populate('seller', 'name email avatar shop role createdAt');
        if (!product) {
            return res.status(404).json({ msg: 'Product not found' });
        }
        res.json(product);
    } catch (err) {
        console.error(err.message);
        if (err.kind === 'ObjectId') {
            return res.status(404).json({ msg: 'Product not found' });
        }
        res.status(500).send('Server error');
    }
};

// @desc    Get products by category
// @route   GET /api/products/category/:category
// @access  Public
exports.getProductsByCategory = async (req, res) => {
    try {
        const products = await Product.find({ category: req.params.category }).sort({ createdAt: -1 });
        res.json(products);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};
// @desc    Update a product
// @route   PATCH /api/products/:id
// @access  Private
exports.updateProduct = async (req, res) => {
    try {
        let product = await Product.findById(req.params.id);

        if (!product) return res.status(404).json({ msg: 'Product not found' });

        // Ensure user owns product
        if (product.seller.toString() !== req.user.id && req.user.role !== 'admin') {
            return res.status(401).json({ msg: 'Not authorized' });
        }

        const fieldsToUpdate = ['title', 'description', 'price', 'category', 'condition', 'status', 'isPremium'];
        fieldsToUpdate.forEach(field => {
            if (req.body[field] !== undefined) {
                product[field] = req.body[field];
            }
        });

        await product.save();
        res.json(product);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// @desc    Delete a product
// @route   DELETE /api/products/:id
// @access  Private
exports.deleteProduct = async (req, res) => {
    try {
        const product = await Product.findById(req.params.id);

        if (!product) return res.status(404).json({ msg: 'Product not found' });

        // Ensure user owns product
        if (product.seller.toString() !== req.user.id && req.user.role !== 'admin') {
            return res.status(401).json({ msg: 'Not authorized' });
        }

        await product.deleteOne();
        res.json({ msg: 'Product removed' });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// @desc    Get products by seller
// @route   GET /api/products/seller/:sellerId
// @access  Public
exports.getProductsBySeller = async (req, res) => {
    try {
        const products = await Product.find({ seller: req.params.sellerId }).sort({ createdAt: -1 });
        res.json(products);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};
