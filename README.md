<div align="center">

# 🛍️ SoukPro

### Modern E-Commerce Platform & Multi-Vendor Marketplace

[![Flutter](https://img.shields.io/badge/Flutter-3.7.2-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-18.x-339933?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org)
[![MongoDB](https://img.shields.io/badge/MongoDB-Atlas-47A248?style=for-the-badge&logo=mongodb&logoColor=white)](https://www.mongodb.com)
[![Express](https://img.shields.io/badge/Express-5.2.1-000000?style=for-the-badge&logo=express&logoColor=white)](https://expressjs.com)
[![Firebase](https://img.shields.io/badge/Firebase-3.10.1-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)

*A complete e-commerce solution with Flutter mobile app and Node.js REST API*

[Features](#-key-features) • [Architecture](#-architecture) • [Installation](#-installation) • [Documentation](#-technical-documentation)

---

</div>

## 📋 Table of Contents

- [Overview](#-overview)
- [Key Features](#-key-features)
- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Technical Documentation](#-technical-documentation)
- [API Endpoints](#-api-endpoints)
- [Data Models](#-data-models)
- [Security](#-security)
- [Deployment](#-deployment)

---

## 🎯 Overview

**SoukPro** is a comprehensive e-commerce platform that enables users to buy and sell products, featuring advanced capabilities such as:

- 🏪 **Multi-Vendor Marketplace**: Both regular users and professionals can sell
- 🎯 **Real-Time Auctions**: Live bidding system with WebSocket technology
- 💳 **Flexible Payments**: Cash, installment plans, or cash on delivery
- 🔐 **Advanced Authentication**: Email/password, Google OAuth, KYC verification
- 📱 **Native Mobile App**: Modern and responsive Flutter interface
- 🔔 **Push Notifications**: Firebase Cloud Messaging for real-time updates
- 🛒 **Complete Order Management**: End-to-end tracking with multiple statuses
- ⭐ **Review System**: Product ratings and comments
- 🏢 **Shop Management**: Professional profiles with analytics

---

## ✨ Key Features

### 👥 User Management

- **Multi-Channel Registration/Login**
  - Email and password with validation
  - Google OAuth 2.0
  - Email verification code (Brevo)
  
- **Roles & Permissions**
  - `user`: Standard user (can buy and sell)
  - `professional`: Professional seller with shop
  - `admin`: Administrator with full access
  
- **User Profile**
  - Customizable avatar
  - Multiple shipping addresses
  - Order history
  - KYC (Know Your Customer) management

### 🛍️ Product Catalog

- **Product Types**
  - Fixed price sales
  - Real-time auctions
  
- **Product Features**
  - Multiple images
  - Categorization
  - Product condition (New, Used)
  - Stock management
  - Payment options (cash, installments)
  - Premium products (featured)

### 🎯 Auction System

- **Real-Time Bidding**
  - WebSocket (Socket.IO) for instant updates
  - Automatic bidding
  - Push notifications for outbids
  - Automatic end date
  - Bid history

### 🛒 Cart & Orders

- **Smart Cart**
  - Multi-vendor management
  - Automatic total calculation
  - Local persistence
  
- **Order Management**
  - Statuses: Pending, Confirmed, Shipped, Delivered, Cancelled
  - Payment: Click to Pay, Flouci, Cash on Delivery
  - Delivery tracking
  - Notifications at each stage

### 🏪 Professional Shops

- **Shop Profile**
  - Name, description, logo
  - Contact info and location (Mapbox)
  - Opening hours
  - Product categories
  
- **Analytics**
  - Product count
  - Average ratings
  - Total sales

### ⭐ Reviews & Ratings

- **Review System**
  - 1 to 5 star ratings
  - Text comments
  - Purchase verification (only buyers can rate)
  - Average rating per product

### 🔔 Notifications

- **Push Notifications (Firebase)**
  - New orders
  - Status changes
  - Outbids
  - System messages
  
- **In-App Notifications**
  - Notification center
  - Read/unread marking
  - Complete history

---

## 🏗️ Architecture

### Global Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     CLIENT LAYER                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         Flutter Mobile App (iOS/Android)              │   │
│  │  • Provider State Management                          │   │
│  │  • Dio HTTP Client                                    │   │
│  │  • Firebase Messaging                                 │   │
│  │  • Socket.IO Client                                   │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            ↕ HTTPS/WSS
┌─────────────────────────────────────────────────────────────┐
│                     API LAYER                                │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         Node.js + Express REST API                    │   │
│  │  • JWT Authentication                                 │   │
│  │  • Role-Based Access Control                          │   │
│  │  • Multer File Upload                                 │   │
│  │  • Socket.IO Server                                   │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            ↕
┌─────────────────────────────────────────────────────────────┐
│                   DATABASE LAYER                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         MongoDB Atlas (Cloud Database)                │   │
│  │  • Users, Products, Orders, Shops                     │   │
│  │  • Reviews, Auctions, Notifications                   │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            ↕
┌─────────────────────────────────────────────────────────────┐
│                   EXTERNAL SERVICES                          │
│  • Firebase (Auth, Messaging, Admin SDK)                    │
│  • Google OAuth 2.0                                          │
│  • Brevo (Email Service)                                     │
│  • Mapbox (Maps & Geolocation)                               │
└─────────────────────────────────────────────────────────────┘
```

### Backend Architecture (MVC Pattern)

```
backend/
├── models/          → MongoDB Schemas (Mongoose)
├── controllers/     → Business Logic
├── routes/          → Endpoint Definitions
├── middleware/      → Auth, Validation, Error Handling
├── services/        → External Services (Firebase, Email)
├── utils/           → Utility Functions
├── config/          → Database Configuration
└── server.js        → Entry Point
```

### Mobile Architecture (Feature-First)

```
mobile/lib/
├── core/
│   ├── constants/   → Global Constants
│   ├── models/      → Data Models
│   ├── services/    → API Services
│   ├── theme/       → Theme & Styles
│   ├── utils/       → Utilities
│   └── widgets/     → Reusable Widgets
└── features/
    ├── auth/        → Authentication
    ├── home/        → Home Page
    ├── shop/        → Shop & Products
    ├── cart/        → Shopping Cart
    ├── orders/      → Orders
    └── profile/     → User Profile
```

---

## 🚀 Tech Stack

### 📱 Mobile (Flutter)

| Technology | Version | Usage |
|------------|---------|-------|
| **Flutter SDK** | 3.7.2 | Cross-platform mobile framework |
| **Dart** | ^3.7.2 | Programming language |
| **Provider** | 6.1.5 | State management |
| **Dio** | 5.9.1 | HTTP client |
| **Firebase Core** | 3.10.1 | Firebase services |
| **Firebase Messaging** | 15.2.2 | Push notifications |
| **Google Sign In** | 6.2.1 | Google authentication |
| **Shared Preferences** | 2.5.3 | Local storage |
| **Flutter Secure Storage** | 10.0.0 | Secure storage (tokens) |
| **Google Fonts** | 6.3.2 | Custom typography |
| **Animate Do** | 4.2.0 | Animations |
| **Image Picker** | 1.2.1 | Image selection |
| **FL Chart** | 1.1.0 | Charts and analytics |
| **Intl** | 0.20.2 | Internationalization |
| **Carousel Slider Plus** | 7.1.1 | Image carousels |
| **Mapbox Maps Flutter** | 2.18.0 | Interactive maps |
| **Flutter Map** | 8.2.2 | Alternative maps |
| **Shimmer** | 3.0.0 | Loading effects |

### 🔧 Backend (Node.js)

| Technology | Version | Usage |
|------------|---------|-------|
| **Node.js** | 18.x+ | JavaScript runtime |
| **Express** | 5.2.1 | Web framework |
| **MongoDB** | Atlas | NoSQL database |
| **Mongoose** | 9.1.5 | MongoDB ODM |
| **JWT** | 9.0.3 | Token authentication |
| **bcryptjs** | 3.0.3 | Password hashing |
| **Socket.IO** | 4.8.3 | Real-time WebSocket |
| **Multer** | 2.0.2 | File uploads |
| **CORS** | 2.8.6 | Cross-Origin Resource Sharing |
| **dotenv** | 17.2.3 | Environment variables |
| **Firebase Admin** | 13.6.1 | Firebase server-side |
| **Google Auth Library** | 10.5.0 | Google OAuth |
| **Brevo** | 3.0.1 | Email service |
| **Nodemon** | 3.1.11 | Auto-reload in development |

### ☁️ Cloud & External Services

- **MongoDB Atlas**: Cloud database
- **Firebase**: Authentication, Cloud Messaging, Admin SDK
- **Google Cloud**: OAuth 2.0
- **Brevo (Sendinblue)**: Transactional email service
- **Mapbox**: Maps and geolocation

---

## 📁 Project Structure

### Backend Structure

```
backend/
├── config/
│   └── db.js                    # MongoDB configuration
├── controllers/
│   ├── authController.js        # Authentication
│   ├── productController.js     # Product management
│   ├── orderController.js       # Order management
│   ├── shopController.js        # Shop management
│   ├── userController.js        # User management
│   ├── reviewController.js      # Product reviews
│   ├── auctionController.js     # Auctions
│   └── notificationController.js # Notifications
├── middleware/
│   ├── auth.js                  # JWT middleware
│   └── roleCheck.js             # Role verification
├── models/
│   ├── User.js                  # User schema
│   ├── Product.js               # Product schema
│   ├── Order.js                 # Order schema
│   ├── Shop.js                  # Shop schema
│   ├── Review.js                # Review schema
│   ├── Auction.js               # Auction schema
│   └── Notification.js          # Notification schema
├── routes/
│   ├── auth.js                  # Auth routes
│   ├── products.js              # Product routes
│   ├── orders.js                # Order routes
│   ├── shops.js                 # Shop routes
│   ├── users.js                 # User routes
│   ├── reviews.js               # Review routes
│   ├── auctions.js              # Auction routes
│   └── notifications.js         # Notification routes
├── services/
│   └── firebaseService.js       # Firebase service
├── utils/
│   └── emailService.js          # Email service
├── uploads/                     # Uploaded files
├── .env                         # Environment variables
├── firebase-service-account.json # Firebase keys
├── package.json                 # npm dependencies
└── server.js                    # Entry point
```

### Mobile Structure

```
mobile/
├── android/                     # Android configuration
├── ios/                         # iOS configuration
├── assets/
│   └── images/                  # Images and logos
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   └── api_constants.dart
│   │   ├── models/
│   │   │   ├── user.dart
│   │   │   ├── product.dart
│   │   │   ├── order.dart
│   │   │   ├── shop.dart
│   │   │   └── review.dart
│   │   ├── services/
│   │   │   ├── api_service.dart
│   │   │   ├── auth_service.dart
│   │   │   └── storage_service.dart
│   │   ├── theme/
│   │   │   └── app_theme.dart
│   │   ├── utils/
│   │   │   └── validators.dart
│   │   └── widgets/
│   │       ├── custom_button.dart
│   │       ├── google_button.dart
│   │       └── product_card.dart
│   └── features/
│       ├── auth/
│       │   ├── providers/
│       │   │   └── auth_provider.dart
│       │   ├── screens/
│       │   │   ├── login_screen.dart
│       │   │   ├── register_screen.dart
│       │   │   └── verification_screen.dart
│       │   └── services/
│       │       └── auth_api_service.dart
│       ├── home/
│       │   ├── providers/
│       │   │   └── product_provider.dart
│       │   ├── screens/
│       │   │   ├── main_layout_screen.dart
│       │   │   ├── home_screen.dart
│       │   │   └── product_details_screen.dart
│       │   ├── services/
│       │   │   └── product_service.dart
│       │   └── widgets/
│       │       ├── global_drawer.dart
│       │       └── product_grid.dart
│       ├── shop/
│       │   ├── providers/
│       │   │   └── shop_provider.dart
│       │   ├── screens/
│       │   │   ├── shop_screen.dart
│       │   │   ├── add_product_screen.dart
│       │   │   └── shop_details_screen.dart
│       │   └── services/
│       │       └── shop_service.dart
│       ├── cart/
│       │   ├── providers/
│       │   │   └── cart_provider.dart
│       │   └── screens/
│       │       ├── cart_screen.dart
│       │       └── checkout_screen.dart
│       ├── orders/
│       │   ├── providers/
│       │   │   └── order_provider.dart
│       │   ├── screens/
│       │   │   ├── orders_screen.dart
│       │   │   └── order_details_screen.dart
│       │   └── services/
│       │       └── order_service.dart
│       └── profile/
│           └── screens/
│               ├── profile_screen.dart
│               └── edit_profile_screen.dart
│   └── main.dart                # Entry point
├── pubspec.yaml                 # Flutter dependencies
└── README.md
```

---

## 🔧 Installation

### Prerequisites

- **Node.js** 18.x or higher
- **npm** or **yarn**
- **Flutter SDK** 3.7.2 or higher
- **MongoDB Atlas** account (or local MongoDB)
- **Firebase** project configured
- **Android Studio** / **Xcode** (for emulators)

### 1️⃣ Backend Installation

```bash
# Clone the repository
git clone <repository-url>
cd SoukPro/backend

# Install dependencies
npm install

# Create .env file (see Configuration)
cp .env.example .env

# Add firebase-service-account.json
# (Download from Firebase Console)

# Start server in development mode
npm run dev

# Or in production mode
npm start
```

Server starts on `http://localhost:5001`

### 2️⃣ Mobile Installation

```bash
cd SoukPro/mobile

# Install Flutter dependencies
flutter pub get

# Generate app icons
flutter pub run flutter_launcher_icons

# Generate splash screen
flutter pub run flutter_native_splash:create

# Run on emulator/device
flutter run

# Or build for production
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

---

## ⚙️ Configuration

### Backend (.env)

Create a `.env` file in `/backend/`:

```env
# Server
PORT=5001
NODE_ENV=development

# Database
MONGO_URI=mongodb+srv://<username>:<password>@cluster0.xxxxx.mongodb.net/SoukPro?appName=Cluster0

# JWT
JWT_SECRET=your_super_secret_jwt_key_change_this_in_production

# Google OAuth
GOOGLE_CLIENT_ID=your-google-client-id.apps.googleusercontent.com

# Frontend URL (for redirects)
FRONTEND_URL=http://localhost:5001/api/auth

# Brevo Email Service
BREVO_API_KEY=your-brevo-api-key
EMAIL_FROM=your-email@example.com
```

### Firebase Configuration

1. **Create a Firebase project** on [Firebase Console](https://console.firebase.google.com)

2. **Enable services**:
   - Authentication (Email/Password, Google)
   - Cloud Messaging

3. **Download configuration files**:
   - **Backend**: `firebase-service-account.json` → place in `/backend/`
   - **Mobile Android**: `google-services.json` → place in `/mobile/android/app/`
   - **Mobile iOS**: `GoogleService-Info.plist` → place in `/mobile/ios/Runner/`

4. **Configure in mobile code**:

```dart
// mobile/lib/main.dart
await Firebase.initializeApp();
```

### API Base URL (Mobile)

Update the API URL in:

```dart
// mobile/lib/core/constants/api_constants.dart
class ApiConstants {
  static const String baseUrl = 'http://YOUR_IP:5001/api';
  // For Android emulator: http://10.0.2.2:5001/api
  // For physical device: http://192.168.x.x:5001/api
}
```

### MongoDB Atlas

1. Create a cluster on [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. Create a database user
3. Whitelist your IP (or 0.0.0.0/0 for development)
4. Copy the connection string to `MONGO_URI`

---

## 📚 Technical Documentation

### Authentication & Security

#### JWT Token Flow

```
1. Login/Register → Server generates JWT
2. Client stores token (Flutter Secure Storage)
3. Each request → Header: Authorization: Bearer <token>
4. Middleware verifies token → Extracts user ID
5. Controller accesses req.user
```

#### Authentication Middleware

```javascript
// backend/middleware/auth.js
const jwt = require('jsonwebtoken');

module.exports = function(req, res, next) {
  const token = req.header('Authorization')?.replace('Bearer ', '');
  
  if (!token) {
    return res.status(401).json({ msg: 'No token, authorization denied' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded.user;
    next();
  } catch (err) {
    res.status(401).json({ msg: 'Token is not valid' });
  }
};
```

#### Role Verification

```javascript
// backend/middleware/roleCheck.js
module.exports = function(...allowedRoles) {
  return async (req, res, next) => {
    const user = await User.findById(req.user.id);
    
    if (!allowedRoles.includes(user.role)) {
      return res.status(403).json({ msg: 'Access denied' });
    }
    
    next();
  };
};
```

### WebSocket (Real-Time Auctions)

#### Server Configuration

```javascript
// backend/server.js
const io = new Server(server, {
  cors: { origin: "*", methods: ["GET", "POST"] }
});

io.on('connection', (socket) => {
  socket.on('joinAuction', (productId) => {
    socket.join(productId);
  });
});

// In controller
io.to(productId).emit('newBid', { currentBid, bidder });
```

#### Flutter Client

```dart
// Socket.IO connection
import 'package:socket_io_client/socket_io_client.dart' as IO;

IO.Socket socket = IO.io('http://YOUR_IP:5001', <String, dynamic>{
  'transports': ['websocket'],
  'autoConnect': false,
});

socket.connect();
socket.emit('joinAuction', productId);
socket.on('newBid', (data) {
  // Update UI
});
```

### File Upload

#### Multer Configuration

```javascript
// backend/controllers/productController.js
const multer = require('multer');
const path = require('path');

const storage = multer.diskStorage({
  destination: './uploads/',
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`);
  }
});

const upload = multer({ storage });
```

#### Flutter Client

```dart
// Upload with Dio
FormData formData = FormData.fromMap({
  'title': 'Product Title',
  'price': 100,
  'images': await MultipartFile.fromFile(imagePath),
});

await dio.post('/products', data: formData);
```

### State Management (Provider)

```dart
// Example: AuthProvider
class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await AuthService.login(email, password);
      _token = response['token'];
      _user = User.fromJson(response['user']);
      await _saveToken(_token!);
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

---

## 🌐 API Endpoints

### Authentication (`/api/auth`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/register` | User registration | ❌ |
| POST | `/login` | Login | ❌ |
| POST | `/google` | Google OAuth login | ❌ |
| POST | `/verify` | Verify email code | ❌ |
| POST | `/resend-code` | Resend verification code | ❌ |
| GET | `/me` | Get current user | ✅ |

### Products (`/api/products`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/` | List all products | ❌ |
| GET | `/:id` | Product details | ❌ |
| POST | `/` | Create product | ✅ |
| PUT | `/:id` | Update product | ✅ |
| DELETE | `/:id` | Delete product | ✅ |
| GET | `/category/:category` | Products by category | ❌ |
| GET | `/seller/:sellerId` | Products by seller | ❌ |

### Orders (`/api/orders`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/` | My orders | ✅ |
| GET | `/:id` | Order details | ✅ |
| POST | `/` | Create order | ✅ |
| PUT | `/:id/status` | Update status | ✅ |
| GET | `/seller` | Received orders (seller) | ✅ |

### Shops (`/api/shops`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/` | List shops | ❌ |
| GET | `/:id` | Shop details | ❌ |
| POST | `/` | Create shop | ✅ |
| PUT | `/:id` | Update shop | ✅ |
| GET | `/my-shop` | My shop | ✅ |

### Reviews (`/api/reviews`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/product/:productId` | Product reviews | ❌ |
| POST | `/` | Create review | ✅ |
| DELETE | `/:id` | Delete review | ✅ |

### Auctions (`/api/auctions`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/product/:productId` | Product auctions | ❌ |
| POST | `/bid` | Place bid | ✅ |

### Notifications (`/api/notifications`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/` | My notifications | ✅ |
| PUT | `/:id/read` | Mark as read | ✅ |
| POST | `/register-token` | Register FCM token | ✅ |

### Users (`/api/users`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/` | List users | ✅ Admin |
| GET | `/:id` | User details | ✅ |
| PUT | `/:id` | Update user | ✅ |
| DELETE | `/:id` | Delete user | ✅ Admin |
| POST | `/shipping-address` | Add address | ✅ |

---

## 📊 Data Models

### User

```javascript
{
  name: String,
  email: String (unique),
  password: String (hashed),
  googleId: String (optional),
  role: Enum ['user', 'professional', 'admin'],
  phone: String,
  avatar: String (URL),
  address: String,
  kycStatus: Enum ['none', 'pending', 'verified', 'rejected'],
  kycDocuments: [String],
  shop: ObjectId (ref: Shop),
  isVerified: Boolean,
  verificationCode: String,
  verificationCodeExpires: Date,
  shippingAddresses: [{
    label: String,
    street: String,
    city: String,
    governorate: String,
    zip: String,
    phone: String,
    isDefault: Boolean
  }],
  fcmToken: String,
  createdAt: Date
}
```

### Product

```javascript
{
  seller: ObjectId (ref: User),
  title: String,
  description: String,
  price: Number,
  images: [String],
  category: String,
  condition: Enum ['New', 'Used - Like New', 'Used - Good', 'Used - Fair'],
  type: Enum ['fixed', 'auction'],
  paymentType: [Enum ['cash', 'installments', 'auction']],
  installmentOptions: [{
    months: Number,
    interestRate: Number,
    totalPrice: Number
  }],
  auctionEndDate: Date,
  startingBid: Number,
  currentBid: Number,
  status: Enum ['available', 'sold', 'pending'],
  stock: Number,
  isPremium: Boolean,
  createdAt: Date
}
```

### Order

```javascript
{
  buyer: ObjectId (ref: User),
  items: [{
    product: ObjectId (ref: Product),
    quantity: Number,
    price: Number,
    seller: ObjectId (ref: User)
  }],
  totalAmount: Number,
  paymentMethod: Enum ['click_to_pay', 'flouci', 'cash_on_delivery'],
  paymentStatus: Enum ['pending', 'paid', 'failed', 'refunded'],
  status: Enum ['pending', 'confirmed', 'shipped', 'delivered', 'cancelled'],
  shippingAddress: {
    label: String,
    street: String,
    city: String,
    governorate: String,
    zip: String,
    phone: String
  },
  createdAt: Date
}
```

### Shop

```javascript
{
  owner: ObjectId (ref: User),
  name: String,
  description: String,
  logo: String,
  banner: String,
  phone: String,
  email: String,
  address: String,
  location: {
    type: 'Point',
    coordinates: [Number, Number] // [longitude, latitude]
  },
  openingHours: String,
  categories: [String],
  isVerified: Boolean,
  rating: Number,
  totalSales: Number,
  createdAt: Date
}
```

### Review

```javascript
{
  product: ObjectId (ref: Product),
  user: ObjectId (ref: User),
  rating: Number (1-5),
  comment: String,
  createdAt: Date
}
```

### Auction

```javascript
{
  product: ObjectId (ref: Product),
  bidder: ObjectId (ref: User),
  amount: Number,
  createdAt: Date
}
```

### Notification

```javascript
{
  user: ObjectId (ref: User),
  title: String,
  message: String,
  type: Enum ['order', 'auction', 'system'],
  isRead: Boolean,
  data: Object,
  createdAt: Date
}
```

---

## 🔒 Security

### Implemented Measures

✅ **JWT Authentication** with expiration
✅ **bcrypt Hashing** for passwords (10 rounds)
✅ **Input Validation** server-side
✅ **CORS** configured
✅ **Secure Token Storage** (Flutter Secure Storage)
✅ **HTTPS** recommended in production
✅ **Rate Limiting** (to be implemented)
✅ **MongoDB Data Sanitization**
✅ **Role-Based Access Control** (RBAC)
✅ **Email Verification** required
✅ **KYC** for professionals

### Production Recommendations

- [ ] Enable HTTPS (Let's Encrypt)
- [ ] Implement rate limiting (express-rate-limit)
- [ ] Add helmet.js for secure headers
- [ ] Configure MongoDB IP Whitelist
- [ ] Enable MongoDB encryption at rest
- [ ] Implement refresh tokens
- [ ] Add monitoring (Sentry, LogRocket)
- [ ] Configure automatic backups
- [ ] Implement CSRF protection
- [ ] Add Joi/Yup validation

---

## 🚀 Deployment

### Backend (Node.js)

#### Option 1: Heroku

```bash
# Install Heroku CLI
heroku login

# Create app
heroku create soukpro-api

# Set environment variables
heroku config:set MONGO_URI=your_mongo_uri
heroku config:set JWT_SECRET=your_secret
# ... other variables

# Deploy
git push heroku main
```

#### Option 2: DigitalOcean / AWS / GCP

```bash
# On server
git clone <repo>
cd backend
npm install --production
pm2 start server.js --name soukpro-api
pm2 startup
pm2 save
```

#### Option 3: Docker

```dockerfile
# Dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
EXPOSE 5001
CMD ["node", "server.js"]
```

```bash
docker build -t soukpro-api .
docker run -p 5001:5001 --env-file .env soukpro-api
```

### Mobile (Flutter)

#### Android (Google Play)

```bash
# Build release APK
flutter build apk --release

# Or App Bundle (recommended)
flutter build appbundle --release

# Generated file:
# build/app/outputs/bundle/release/app-release.aab
```

#### iOS (App Store)

```bash
# Build release
flutter build ios --release

# Open Xcode
open ios/Runner.xcworkspace

# Archive → Distribute → App Store Connect
```

#### Signing Configuration

**Android**: Create `android/key.properties`
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-keystore>
```

**iOS**: Configure in Xcode
- Team
- Bundle Identifier
- Provisioning Profile

---

## 📈 Performance & Optimizations

### Backend

- **MongoDB Indexing** on frequent fields (email, seller, category)
- **Pagination** for lists (limit/skip)
- **Caching** (to implement with Redis)
- **Response Compression** (gzip)
- **CDN** for static images

### Mobile

- **Image Lazy Loading**
- **List Pagination**
- **Local Caching** (Shared Preferences)
- **Image Optimization** (compression)
- **Code Splitting** by feature
- **Search Debouncing**

---

## 🧪 Testing

### Backend

```bash
# To be implemented
npm test

# Unit tests (Jest)
# Integration tests (Supertest)
# E2E tests
```

### Mobile

```bash
# Unit tests
flutter test

# Integration tests
flutter drive --target=test_driver/app.dart

# Widget tests
flutter test test/widget_test.dart
```

---

## 📝 Logs & Monitoring

### Backend Logs

```javascript
// Use Winston or Morgan
const morgan = require('morgan');
app.use(morgan('combined'));
```

### Mobile Logs

```dart
// Firebase Crashlytics
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
```

---

## 🤝 Contributing

1. Fork the project
2. Create a branch (`git checkout -b feature/AmazingFeature`)
3. Commit (`git commit -m 'Add AmazingFeature'`)
4. Push (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License.

---

## 👨‍💻 Author

**Houssem Zorgui**
- Email: houssemzorgui10@gmail.com
- GitHub: [@HoussemZorgui](https://github.com/HoussemZorgui)

---

## 🙏 Acknowledgments

- Flutter Team
- Node.js Community
- MongoDB
- Firebase
- All open-source contributors

---

<div align="center">

### ⭐ If this project helped you, don't hesitate to give it a star!

**Made with ❤️ by Houssem Zorgui**

</div>
