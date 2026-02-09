const express = require('express');
const router = express.Router();
const { checkout, getMyOrders } = require('../controllers/orderController');
const auth = require('../middleware/auth');

router.post('/checkout', auth, checkout);
router.get('/', auth, getMyOrders);

module.exports = router;
