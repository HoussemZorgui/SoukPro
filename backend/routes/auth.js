const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const { registerUser, loginUser, getMe, googleLogin, verifyCode, resendCode } = require('../controllers/authController');

// @route   POST /api/auth/register
// @desc    Register user
// @access  Public
router.post('/register', registerUser);

// @route   POST /api/auth/login
// @desc    Login user
// @access  Public
router.post('/login', loginUser);

// @route   POST /api/auth/google
// @desc    Google login
// @access  Public
router.post('/google', googleLogin);

// @route   POST /api/auth/verify-code
// @desc    Verify email address with code
// @access  Public
router.post('/verify-code', verifyCode);

// @route   POST /api/auth/resend-code
// @desc    Resend verification code
// @access  Public
router.post('/resend-code', resendCode);

// @route   GET /api/auth/me
// @desc    Get current user
// @access  Private
router.get('/me', auth, getMe);

module.exports = router;
