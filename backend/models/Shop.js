const mongoose = require('mongoose');

const ShopSchema = new mongoose.Schema({
    owner: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
        unique: true
    },
    name: {
        type: String,
        required: true
    },
    description: {
        type: String
    },
    logo: {
        type: String
    },
    banner: {
        type: String
    },
    shopAddress: {
        type: String
    },
    governorate: {
        type: String,
        enum: [
            'Ariana', 'Beja', 'Ben Arous', 'Bizerte', 'Gabes', 'Gafsa', 'Jendouba',
            'Kairouan', 'Kasserine', 'Kebili', 'Kef', 'Mahdia', 'Manouba',
            'Medenine', 'Monastir', 'Nabeul', 'Sfax', 'Sidi Bouzid', 'Siliana',
            'Sousse', 'Tataouine', 'Tozeur', 'Tunis', 'Zaghouan'
        ]
    },
    location: {
        lat: { type: Number },
        lng: { type: Number }
    },
    phone: {
        type: String
    },
    socialLinks: {
        facebook: { type: String },
        instagram: { type: String },
        website: { type: String }
    },
    openingHours: {
        monday: { type: String, default: '9:00 - 18:00' },
        tuesday: { type: String, default: '9:00 - 18:00' },
        wednesday: { type: String, default: '9:00 - 18:00' },
        thursday: { type: String, default: '9:00 - 18:00' },
        friday: { type: String, default: '9:00 - 18:00' },
        saturday: { type: String, default: '9:00 - 13:00' },
        sunday: { type: String, default: 'Closed' }
    },
    rating: {
        type: Number,
        default: 4.5
    },
    reviewCount: {
        type: Number,
        default: 10
    },
    isVerified: {
        type: Boolean,
        default: false
    },
    subscriptionStatus: {
        type: String,
        enum: ['active', 'inactive', 'trial'],
        default: 'inactive'
    },
    subscriptionEndDate: {
        type: Date
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('Shop', ShopSchema);
