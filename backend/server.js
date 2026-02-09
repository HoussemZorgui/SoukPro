const express = require('express');
const connectDB = require('./config/db');
const dotenv = require('dotenv');
const cors = require('cors');
const http = require('http');
const { Server } = require("socket.io");

// Load env vars
dotenv.config();

// Connect Database
connectDB();

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
    cors: {
        origin: "*",
        methods: ["GET", "POST"]
    }
});

// Init Middleware
app.use(express.json());
app.use(cors());

// Define Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/products', require('./routes/products'));
app.use('/api/auctions', require('./routes/auctions'));
app.use('/api/shops', require('./routes/shops'));
app.use('/api/orders', require('./routes/orders'));
app.use('/api/users', require('./routes/users'));
app.use('/api/reviews', require('./routes/reviews'));

// Make uploads folder static
app.use('/uploads', express.static('uploads'));

// Test Route
app.get('/', (req, res) => res.send('SoukPro API is running'));

// Socket.IO Logic
app.set('socketio', io); // Make io accessible in controllers

io.on('connection', (socket) => {
    console.log('New client connected: ' + socket.id);

    socket.on('joinAuction', (productId) => {
        socket.join(productId);
        console.log(`Socket ${socket.id} joined auction ${productId}`);
    });

    socket.on('disconnect', () => {
        console.log('Client disconnected: ' + socket.id);
    });
});

const PORT = process.env.PORT || 5000;

server.listen(PORT, () => console.log(`Server started on port ${PORT}`));
