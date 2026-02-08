const Product = require('../models/Product');
const Auction = require('../models/Auction');

// @desc    Place a bid
// @route   POST /api/auctions/bid/:productId
// @access  Private
exports.placeBid = async (req, res) => {
    try {
        const { amount } = req.body;
        const productId = req.params.productId;
        const userId = req.user.id;

        const product = await Product.findById(productId);
        if (!product || product.type !== 'auction' || product.status !== 'active') {
            return res.status(400).json({ msg: 'Auction not active or product not found' });
        }

        if (new Date() > product.auctionEndDate) {
            product.status = 'expired';
            await product.save();
            return res.status(400).json({ msg: 'Auction has ended' });
        }

        if (amount <= product.currentMake) {
            return res.status(400).json({ msg: 'Bid must be higher than current price' });
        }

        // Update product current make
        product.currentMake = amount;
        await product.save();

        // Find or create auction record for detailed bid history
        let auction = await Auction.findOne({ product: productId });
        if (!auction) {
            auction = new Auction({
                product: productId,
                bids: []
            });
        }

        auction.bids.push({
            user: userId,
            amount: amount
        });

        await auction.save();

        // Emit socket event
        const io = req.app.get('socketio');
        io.to(productId).emit('bidUpdate', {
            productId,
            amount,
            user: { _id: userId }, // Simplified user obj
            currentMake: product.currentMake
        });

        // Return updated product and auction info
        res.json({ product, auction });

    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

// @desc    Get auction details
// @route   GET /api/auctions/:productId
// @access  Public
exports.getAuctionDetails = async (req, res) => {
    try {
        const auction = await Auction.findOne({ product: req.params.productId })
            .populate('bids.user', 'name avatar')
            .populate('product');

        if (!auction) {
            return res.status(404).json({ msg: 'Auction history not found' });
        }
        res.json(auction);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};
