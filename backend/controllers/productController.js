const Product = require('../models/Product');

// @desc    Create a product
// @route   POST /api/products
// @access  Private
exports.createProduct = async (req, res) => {
    try {
        const { title, description, price, category, condition, type, auctionEndDate, startingBid, isPremium, paymentType, installmentOptions, stock } = req.body;

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
            stock: stock || 1,
            type: type || 'fixed',
            paymentType: Array.isArray(paymentType) ? paymentType : (paymentType ? [paymentType] : ['cash']),
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
        const { search, category, minPrice, maxPrice, condition, status } = req.query;

        let query = {};

        // Default to 'available' if no status is provided
        if (!status) {
            query.status = 'available';
        } else if (status !== 'all') {
            query.status = status;
        }

        // Search text (Title or Description)
        if (search) {
            query.$or = [
                { title: { $regex: search, $options: 'i' } },
                { description: { $regex: search, $options: 'i' } }
            ];
            // When searching by text, maybe we want to see sold items too? 
            // Let's keep the status filter as requested but prioritize available ones in sort
        }

        // Category Filter
        if (category && category !== 'All' && category !== 'Tout') {
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
            .populate({
                path: 'seller',
                select: 'name avatar shop role createdAt',
                populate: {
                    path: 'shop',
                    select: 'name logo governorate isVerified'
                }
            })
            .sort({
                status: 1, // 'available' before 'sold'
                isPremium: -1,
                createdAt: -1
            });
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
        const product = await Product.findById(req.params.id).populate({
            path: 'seller',
            select: 'name email avatar shop role createdAt',
            populate: {
                path: 'shop',
                select: 'name logo governorate isVerified'
            }
        });
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
        const products = await Product.find({ category: req.params.category })
            .populate({
                path: 'seller',
                select: 'name avatar shop role createdAt',
                populate: {
                    path: 'shop',
                    select: 'name logo governorate isVerified'
                }
            })
            .sort({ createdAt: -1 });
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

        const { title, description, price, category, condition, status, isPremium, paymentType, installmentOptions } = req.body;

        // Handle image updates
        let finalImages = [];
        // If existingImages is passed as a JSON string or array, keep them
        if (req.body.existingImages) {
            const existing = typeof req.body.existingImages === 'string' ? JSON.parse(req.body.existingImages) : req.body.existingImages;
            finalImages = Array.isArray(existing) ? existing : [existing];
        }

        // Add new uploaded files
        if (req.files && req.files.length > 0) {
            const newImagePaths = req.files.map(file => file.path);
            finalImages = [...finalImages, ...newImagePaths];
        }

        if (finalImages.length > 0) {
            product.images = finalImages;
        }

        if (title) product.title = title;
        if (description) product.description = description;
        if (price) product.price = Number(price);
        if (category) product.category = category;
        if (condition) product.condition = condition;
        if (status) product.status = status;
        if (paymentType) product.paymentType = paymentType;

        if (isPremium !== undefined) {
            product.isPremium = isPremium === 'true' || isPremium === true;
        }

        if (installmentOptions) {
            try {
                product.installmentOptions = typeof installmentOptions === 'string' ? JSON.parse(installmentOptions) : installmentOptions;
            } catch (e) {
                console.error("Error parsing installmentOptions:", e);
            }
        }

        await product.save();

        // Populate seller to return full product object
        const updatedProduct = await Product.findById(product._id).populate({
            path: 'seller',
            select: 'name email avatar shop role createdAt',
            populate: {
                path: 'shop',
                select: 'name logo governorate isVerified'
            }
        });

        res.json(updatedProduct);
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
        const products = await Product.find({ seller: req.params.sellerId })
            .populate({
                path: 'seller',
                select: 'name avatar shop role createdAt',
                populate: {
                    path: 'shop',
                    select: 'name logo governorate isVerified'
                }
            })
            .sort({ createdAt: -1 });
        res.json(products);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};
