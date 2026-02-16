const express = require('express');
const router = express.Router();
const { checkout, getMyOrders, updateOrderStatus, getOrderById } = require('../controllers/orderController');
const auth = require('../middleware/auth');

router.post('/checkout', auth, checkout);
router.get('/', auth, getMyOrders);
router.get('/:id', auth, getOrderById);
router.patch('/:id/status', auth, updateOrderStatus);

module.exports = router;
