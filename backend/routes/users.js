const express = require('express');
const router = express.Router();
const { getUserById, updateUser, uploadKYC, addAddress, removeAddress } = require('../controllers/userController');
const auth = require('../middleware/auth');
const upload = require('../middleware/upload');

// FCM Token
const { updateFcmToken, removeFcmToken } = require('../controllers/userController');
router.patch('/fcm-token', auth, updateFcmToken);
router.delete('/fcm-token', auth, removeFcmToken);

router.get('/:id', auth, getUserById);
router.patch('/:id', [auth, upload.single('avatar')], updateUser);
router.post('/kyc', [auth, upload.array('documents', 3)], uploadKYC);

// Shipping Addresses
router.post('/addresses', auth, addAddress);
router.delete('/addresses/:addressId', auth, removeAddress);

module.exports = router;
