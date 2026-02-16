const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { OAuth2Client } = require('google-auth-library');
const { sendVerificationEmail, sendWelcomeEmail } = require('../services/emailService');

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

// Generate JWT
const generateToken = (userId) => {
    return jwt.sign(
        { user: { id: userId } },
        process.env.JWT_SECRET,
        { expiresIn: '30d' }
    );
};

// @desc    Register a new user
exports.registerUser = async (req, res) => {
    const { name, email, password, role, phone } = req.body;

    try {
        let user = await User.findOne({ email });

        if (user) {
            return res.status(400).json({ msg: 'L\'utilisateur existe déjà' });
        }

        user = new User({
            name,
            email,
            password,
            role,
            phone,
            isVerified: false
        });

        // Encrypt password
        const salt = await bcrypt.genSalt(10);
        user.password = await bcrypt.hash(password, salt);

        // Generate 6-digit verification code
        const verificationCode = Math.floor(100000 + Math.random() * 900000).toString();
        user.verificationCode = verificationCode;
        user.verificationCodeExpires = Date.now() + 10 * 60 * 1000; // 10 minutes

        await user.save();

        // Send confirmation email
        await sendVerificationEmail(email, name, verificationCode);

        res.json({
            email: user.email,
            msg: 'Inscription réussie. Veuillez entrer le code envoyé à votre e-mail.'
        });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Erreur serveur');
    }
};

// @desc    Auth user & get token
exports.loginUser = async (req, res) => {
    const { email, password } = req.body;

    try {
        let user = await User.findOne({ email });

        if (!user) {
            return res.status(400).json({ msg: 'Identifiants invalides' });
        }

        const isMatch = await bcrypt.compare(password, user.password);

        if (!isMatch) {
            return res.status(400).json({ msg: 'Identifiants invalides' });
        }

        // Check verification status
        if (!user.isVerified) {
            return res.status(401).json({
                msg: 'Votre compte n\'est pas encore vérifié.',
                notVerified: true,
                email: user.email
            });
        }

        const token = generateToken(user.id);

        const userResponse = user.toObject();
        delete userResponse.password;
        delete userResponse.verificationCode;

        res.json({ token, user: userResponse });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Erreur serveur');
    }
};

// @desc    Google Login
// @route   POST /api/auth/google
// @access  Public
exports.googleLogin = async (req, res) => {
    const { idToken, role } = req.body;

    try {
        const ticket = await client.verifyIdToken({
            idToken,
            audience: process.env.GOOGLE_CLIENT_ID,
        });

        const { name, email, sub: googleId, picture } = ticket.getPayload();

        let user = await User.findOne({ email });

        if (!user) {
            // Register new user via Google
            user = new User({
                name,
                email,
                googleId,
                avatar: picture,
                isVerified: true, // Google accounts are usually verified
                role: role || 'user' // Use provided role or default to user
            });
            await user.save();
        } else if (!user.googleId) {
            // Link google account to existing email
            user.googleId = googleId;
            if (!user.avatar) user.avatar = picture;
            // Note: We don't change role for existing users for security reasons
            await user.save();
        }

        const token = generateToken(user.id);
        const userResponse = user.toObject();
        delete userResponse.password;

        res.json({ token, user: userResponse });
    } catch (err) {
        console.error('Google Login Error:', err.message);
        res.status(400).json({ msg: 'Google login failed' });
    }
};

// @desc    Verify email with code
// @route   POST /api/auth/verify-code
exports.verifyCode = async (req, res) => {
    const { email, code } = req.body;

    try {
        const user = await User.findOne({ email });

        if (!user) {
            return res.status(404).json({ msg: 'Utilisateur non trouvé' });
        }

        if (user.isVerified) {
            return res.status(400).json({ msg: 'Le compte est déjà vérifié' });
        }

        if (user.verificationCode !== code) {
            return res.status(400).json({ msg: 'Code incorrect' });
        }

        if (user.verificationCodeExpires < Date.now()) {
            return res.status(400).json({ msg: 'Le code a expiré. Veuillez en demander un nouveau.' });
        }

        user.isVerified = true;
        user.verificationCode = undefined;
        user.verificationCodeExpires = undefined;
        await user.save();

        const token = generateToken(user.id);
        const userResponse = user.toObject();
        delete userResponse.password;

        // Send Welcome Email
        await sendWelcomeEmail(user.email, user.name);

        res.json({
            token,
            user: userResponse,
            msg: 'Compte vérifié avec succès !'
        });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Erreur serveur');
    }
};

// @desc    Resend verification code
// @route   POST /api/auth/resend-code
exports.resendCode = async (req, res) => {
    const { email } = req.body;

    try {
        const user = await User.findOne({ email });

        if (!user) {
            return res.status(404).json({ msg: 'Utilisateur non trouvé' });
        }

        if (user.isVerified) {
            return res.status(400).json({ msg: 'Le compte est déjà vérifié' });
        }

        // Generate new 6-digit verification code
        const verificationCode = Math.floor(100000 + Math.random() * 900000).toString();
        user.verificationCode = verificationCode;
        user.verificationCodeExpires = Date.now() + 10 * 60 * 1000; // 10 minutes

        await user.save();

        // Send confirmation email
        await sendVerificationEmail(user.email, user.name, verificationCode);

        res.json({ msg: 'Un nouveau code a été envoyé à votre e-mail.' });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Erreur serveur');
    }
};

// @desc    Get current user
// @route   GET /api/auth/me
// @access  Private
exports.getMe = async (req, res) => {
    try {
        const user = await User.findById(req.user.id).select('-password');
        res.json(user);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};
