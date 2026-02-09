const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true
    },
    email: {
        type: String,
        required: true,
        unique: true
    },
    password: {
        type: String,
        required: function () { return !this.googleId && !this.facebookId; } // Password not required if social login
    },
    googleId: {
        type: String,
        unique: true,
        sparse: true
    },
    facebookId: {
        type: String,
        unique: true,
        sparse: true
    },
    role: {
        type: String,
        enum: ['user', 'professional', 'admin'],
        default: 'user'
    },
    phone: {
        type: String,
        required: false,
        default: ''
    },
    avatar: {
        type: String,
        default: ''
    },
    address: {
        type: String,
        default: ''
    },
    kycStatus: {
        type: String,
        enum: ['none', 'pending', 'verified', 'rejected'],
        default: 'none'
    },
    kycDocuments: [{
        type: String // URL/Path to document
    }],
    // For professionals
    shop: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Shop'
    },
    isVerified: {
        type: Boolean,
        default: false
    },
    verificationToken: {
        type: String,
        required: false
    },
    shippingAddresses: [{
        label: String, // Home, Office, etc.
        street: String,
        city: String,
        governorate: String,
        zip: String,
        phone: String,
        isDefault: { type: Boolean, default: false }
    }],
    createdAt: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('User', UserSchema);
