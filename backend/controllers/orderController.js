const Order = require('../models/Order');
const Product = require('../models/Product');
const User = require('../models/User');

// @desc    Create a new order
// @route   POST /api/orders
// @access  Private
exports.createOrder = async (req, res) => {
    try {
        const { productId, paymentMethod, shippingAddress } = req.body;

        const product = await Product.findById(productId);
        if (!product) {
            return res.status(404).json({ msg: 'Product not found' });
        }

        if (product.status !== 'available') {
            return res.status(400).json({ msg: 'Product is not available for sale' });
        }

        const buyerId = req.user.id;
        const sellerId = product.seller; // Assuming product has seller field populated or just ID

        // Calculate amounts
        const totalAmount = product.price; // or high bid if auction
        const commissionRate = 0.05;
        const commissionAmount = totalAmount * commissionRate;
        const netSellerAmount = totalAmount - commissionAmount;

        const order = new Order({
            buyer: buyerId,
            seller: sellerId,
            product: productId,
            totalAmount,
            commissionAmount,
            netSellerAmount,
            paymentMethod,
            shippingAddress,
            status: 'paid' // For mock puprose, we assume instant payment
        });

        await order.save();

        // Update product status
        product.status = 'sold';
        await product.save();

        res.json(order);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// @desc    Get current user's orders (as buyer or seller)
// @route   GET /api/orders
// @access  Private
exports.getMyOrders = async (req, res) => {
    try {
        // Fetch orders where user is buyer OR seller
        const orders = await Order.find({
            $or: [{ buyer: req.user.id }, { seller: req.user.id }]
        })
            .populate('product', 'title images price')
            .populate('buyer', 'name email')
            .populate('seller', 'name email')
            .sort({ createdAt: -1 });

        res.json(orders);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};
