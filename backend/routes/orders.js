const express = require('express');
const router = express.Router();
const { checkout, getMyOrders, updateOrderStatus } = require('../controllers/orderController');
const auth = require('../middleware/auth');

router.post('/checkout', auth, checkout);
router.get('/', auth, getMyOrders);
router.patch('/:id/status', auth, updateOrderStatus);

module.exports = router;
