const Order = require('../models/Order');
const Product = require('../models/Product');
const User = require('../models/User');

// @desc    Checkout (Cart to Order)
// @route   POST /api/orders/checkout
// @access  Private
exports.checkout = async (req, res) => {
    try {
        const { items, paymentMethod, shippingAddress } = req.body;

        if (!items || items.length === 0) {
            return res.status(400).json({ msg: 'Cart is empty' });
        }

        let totalAmount = 0;
        const processedItems = [];

        for (const item of items) {
            const product = await Product.findById(item.productId);
            if (!product || product.status !== 'available') {
                return res.status(400).json({ msg: `Product ${product ? product.title : item.productId} is not available` });
            }

            const itemPrice = product.price * (item.quantity || 1);
            totalAmount += itemPrice;

            processedItems.push({
                product: product._id,
                quantity: item.quantity || 1,
                price: product.price,
                seller: product.seller
            });

            // Mark product as sold (Simple logic for now)
            product.status = 'sold';
            await product.save();
        }

        const order = new Order({
            buyer: req.user.id,
            items: processedItems,
            totalAmount,
            paymentMethod: paymentMethod || 'cash_on_delivery',
            paymentStatus: paymentMethod === 'cash_on_delivery' ? 'pending' : 'paid',
            shippingAddress,
            status: 'pending'
        });

        await order.save();
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
        // Fetch orders where user is buyer OR seller in one of the items
        const orders = await Order.find({
            $or: [
                { buyer: req.user.id },
                { 'items.seller': req.user.id }
            ]
        })
            .populate('items.product', 'title images price')
            .populate('buyer', 'name email avatar')
            .populate('items.seller', 'name email shop role')
            .sort({ createdAt: -1 });

        res.json(orders);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};
