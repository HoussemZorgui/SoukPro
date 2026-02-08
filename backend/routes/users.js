const express = require('express');
const router = express.Router();
const { getUserById, updateUser, uploadKYC } = require('../controllers/userController');
const auth = require('../middleware/auth');
const upload = require('../middleware/upload');

router.get('/:id', auth, getUserById);
router.patch('/:id', [auth, upload.single('avatar')], updateUser);
router.post('/kyc', [auth, upload.array('documents', 3)], uploadKYC);

module.exports = router;
