const User = require('../models/User');

// @desc    Get user profile (public or private view)
// @route   GET /api/users/:id
// @access  Private
exports.getUserById = async (req, res) => {
    try {
        const user = await User.findById(req.params.id).select('-password');
        if (!user) {
            return res.status(404).json({ msg: 'User not found' });
        }
        res.json(user);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// @desc    Update user profile
// @route   PATCH /api/users/:id
// @access  Private
exports.updateUser = async (req, res) => {
    try {
        console.log('Update User Request:', req.params.id);
        console.log('Body:', req.body);
        console.log('File:', req.file);

        if (req.params.id !== req.user.id && req.user.role !== 'admin') {
            return res.status(401).json({ msg: 'Not authorized' });
        }

        let user = await User.findById(req.params.id);
        if (!user) {
            return res.status(404).json({ msg: 'User not found' });
        }

        const { name, phone, address } = req.body;

        if (req.file) {
            // Store relative path
            user.avatar = req.file.path.replace(/\\/g, '/'); // Ensure forward slashes
            console.log('New Avatar Path:', user.avatar);
        }

        if (name) user.name = name;
        if (phone) user.phone = phone;
        if (address) user.address = address;

        await user.save();
        console.log('User saved successfully');

        const userResponse = user.toObject();
        delete userResponse.password;
        res.json(userResponse);

    } catch (err) {
        console.error('Update Error:', err.message);
        res.status(500).send('Server Error');
    }
};

// @desc    Upload KYC Documents
// @route   POST /api/users/kyc
// @access  Private
exports.uploadKYC = async (req, res) => {
    try {
        const user = await User.findById(req.user.id);

        if (req.files) {
            const paths = req.files.map(file => file.path);
            user.kycDocuments.push(...paths);
            user.kycStatus = 'pending';
            await user.save();
            return res.json({ msg: 'KYC Documents uploaded', kycStatus: user.kycStatus });
        }

        res.status(400).json({ msg: 'No files uploaded' });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};
