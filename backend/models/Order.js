const mongoose = require('mongoose');

const OrderSchema = new mongoose.Schema({
    buyer: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    seller: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User', // Can be a professional user
        required: true
    },
    product: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Product',
        required: true
    },
    totalAmount: {
        type: Number,
        required: true
    },
    commissionAmount: {
        type: Number,
        required: true
    },
    netSellerAmount: {
        type: Number,
        required: true
    },
    paymentMethod: {
        type: String,
        enum: ['click_to_pay', 'flouci', 'cash_on_delivery'], // Added COD for flexibility
        default: 'click_to_pay'
    },
    status: {
        type: String,
        enum: ['pending', 'paid', 'verifying_item', 'shipped', 'delivered', 'cancelled', 'completed'],
        default: 'pending'
    },
    shippingAddress: {
        type: String,
        required: true
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('Order', OrderSchema);
