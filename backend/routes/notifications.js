const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const { getMyNotifications, markAsRead, markAllAsRead } = require('../controllers/notificationController');

router.get('/', auth, getMyNotifications);
router.patch('/:id/read', auth, markAsRead);
router.patch('/read-all', auth, markAllAsRead);

module.exports = router;
