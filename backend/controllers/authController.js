const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { OAuth2Client } = require('google-auth-library');
const { sendVerificationEmail } = require('../services/emailService');

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
// @route   POST /api/auth/register
// @access  Public
exports.registerUser = async (req, res) => {
    const { name, email, password, role, phone } = req.body;

    try {
        let user = await User.findOne({ email });

        if (user) {
            return res.status(400).json({ msg: 'User already exists' });
        }

        user = new User({
            name,
            email,
            password,
            role,
            phone
        });

        // Encrypt password
        const salt = await bcrypt.genSalt(10);
        user.password = await bcrypt.hash(password, salt);

        // Generate verification token (simple JWT or random string)
        const verificationToken = jwt.sign({ email }, process.env.JWT_SECRET, { expiresIn: '1d' });
        user.verificationToken = verificationToken; // Note: Need to add this to model if not there

        await user.save();

        // Send confirmation email
        await sendVerificationEmail(email, name, verificationToken);

        const token = generateToken(user.id);

        const userResponse = user.toObject();
        delete userResponse.password;

        res.json({
            token,
            user: userResponse,
            msg: 'Registration successful. Please check your email to verify your account.'
        });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

// @desc    Auth user & get token
// @route   POST /api/auth/login
// @access  Public
exports.loginUser = async (req, res) => {
    const { email, password } = req.body;

    try {
        let user = await User.findOne({ email });

        if (!user) {
            return res.status(400).json({ msg: 'Invalid Credentials' });
        }

        const isMatch = await bcrypt.compare(password, user.password);

        if (!isMatch) {
            return res.status(400).json({ msg: 'Invalid Credentials' });
        }

        const token = generateToken(user.id);

        const userResponse = user.toObject();
        delete userResponse.password;

        res.json({ token, user: userResponse });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
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

// @desc    Verify email
// @route   GET /api/auth/verify-email
// @access  Public
exports.verifyEmail = async (req, res) => {
    const { token } = req.query;

    try {
        const user = await User.findOne({ verificationToken: token });

        if (!user) {
            return res.status(400).send('<h1>Lien invalide</h1><p>Le jeton de vérification est invalide ou a expiré.</p>');
        }

        user.isVerified = true;
        user.verificationToken = undefined;
        await user.save();

        res.send('<h1>Compte vérifié !</h1><p>Votre compte SoukPro a été activé avec succès. Vous pouvez maintenant fermer cette page et vous connecter sur l\'application.</p>');
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
