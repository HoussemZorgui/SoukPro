const mongoose = require('mongoose');

const ProductSchema = new mongoose.Schema({
    seller: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    title: {
        type: String,
        required: true
    },
    description: {
        type: String,
        required: true
    },
    price: {
        type: Number,
        required: true
    },
    images: [{
        type: String // URLs or paths
    }],
    category: {
        type: String,
        required: true
    },
    condition: {
        type: String,
        enum: ['New', 'Used - Like New', 'Used - Good', 'Used - Fair', 'new', 'used', 'Neuf', 'Utilisé - Comme Neuf', 'Utilisé - Bon État', 'Utilisé - État Correct'], // Supporting both formats
        default: 'New'
    },
    type: {
        type: String,
        enum: ['fixed', 'auction'],
        default: 'fixed'
    },
    paymentType: [{
        type: String,
        enum: ['cash', 'installments', 'auction'],
        default: 'cash'
    }],
    installmentOptions: [{
        months: { type: Number },
        interestRate: { type: Number },
        totalPrice: { type: Number }
    }],
    // Auction specific fields
    auctionEndDate: {
        type: Date
    },
    startingBid: {
        type: Number
    },
    currentMake: { // Highest bid
        type: Number,
        default: 0
    },
    status: {
        type: String,
        enum: ['available', 'sold', 'pending'],
        default: 'available'
    },
    stock: {
        type: Number,
        default: 1, // Default quantity
        min: 0
    },
    isPremium: {
        type: Boolean,
        default: false
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('Product', ProductSchema);
