<div align="center">

# 🛍️ SoukPro

### Plateforme E-Commerce Moderne & Marketplace Multi-Vendeurs

[![Flutter](https://img.shields.io/badge/Flutter-3.7.2-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-18.x-339933?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org)
[![MongoDB](https://img.shields.io/badge/MongoDB-Atlas-47A248?style=for-the-badge&logo=mongodb&logoColor=white)](https://www.mongodb.com)
[![Express](https://img.shields.io/badge/Express-5.2.1-000000?style=for-the-badge&logo=express&logoColor=white)](https://expressjs.com)
[![Firebase](https://img.shields.io/badge/Firebase-3.10.1-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)

*Une solution complète de commerce électronique avec application mobile Flutter et API REST Node.js*

[Fonctionnalités](#-fonctionnalités-principales) • [Architecture](#-architecture) • [Installation](#-installation) • [Documentation](#-documentation-technique)

---

</div>

## 📋 Table des Matières

- [Vue d'Ensemble](#-vue-densemble)
- [Fonctionnalités Principales](#-fonctionnalités-principales)
- [Architecture](#-architecture)
- [Stack Technologique](#-stack-technologique)
- [Structure du Projet](#-structure-du-projet)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Documentation Technique](#-documentation-technique)
- [API Endpoints](#-api-endpoints)
- [Modèles de Données](#-modèles-de-données)
- [Sécurité](#-sécurité)
- [Déploiement](#-déploiement)

---

## 🎯 Vue d'Ensemble

**SoukPro** est une plateforme e-commerce complète qui permet aux utilisateurs d'acheter et de vendre des produits, avec des fonctionnalités avancées telles que :

- 🏪 **Marketplace Multi-Vendeurs** : Utilisateurs et professionnels peuvent vendre
- 🎯 **Ventes aux Enchères** : Système d'enchères en temps réel avec WebSocket
- 💳 **Paiements Flexibles** : Paiement comptant, à tempérament, ou à la livraison
- 🔐 **Authentification Avancée** : Email/mot de passe, Google OAuth, vérification KYC
- 📱 **Application Mobile Native** : Interface Flutter moderne et réactive
- 🔔 **Notifications Push** : Firebase Cloud Messaging pour les mises à jour en temps réel
- 🛒 **Gestion Complète des Commandes** : Suivi de bout en bout avec statuts multiples
- ⭐ **Système d'Avis** : Évaluations et commentaires sur les produits
- 🏢 **Gestion de Boutiques** : Profils professionnels avec statistiques

---

## ✨ Fonctionnalités Principales

### 👥 Gestion des Utilisateurs

- **Inscription/Connexion Multi-Canal**
  - Email et mot de passe avec validation
  - Google OAuth 2.0
  - Vérification par code email (Brevo)
  
- **Rôles et Permissions**
  - `user` : Utilisateur standard (peut vendre et acheter)
  - `professional` : Vendeur professionnel avec boutique
  - `admin` : Administrateur avec accès complet
  
- **Profil Utilisateur**
  - Avatar personnalisable
  - Adresses de livraison multiples
  - Historique des commandes
  - Gestion KYC (Know Your Customer)

### 🛍️ Catalogue Produits

- **Types de Produits**
  - Vente à prix fixe
  - Vente aux enchères en temps réel
  
- **Caractéristiques Produits**
  - Images multiples
  - Catégorisation
  - État du produit (Neuf, Occasion)
  - Gestion de stock
  - Options de paiement (comptant, tempérament)
  - Produits premium (mise en avant)

### 🎯 Système d'Enchères

- **Enchères en Temps Réel**
  - WebSocket (Socket.IO) pour les mises à jour instantanées
  - Enchères automatiques
  - Notifications push pour les surenchères
  - Date de fin automatique
  - Historique des enchères

### 🛒 Panier & Commandes

- **Panier Intelligent**
  - Gestion multi-vendeurs
  - Calcul automatique des totaux
  - Persistance locale
  
- **Gestion des Commandes**
  - Statuts : Pending, Confirmed, Shipped, Delivered, Cancelled
  - Paiement : Click to Pay, Flouci, Cash on Delivery
  - Suivi de livraison
  - Notifications à chaque étape

### 🏪 Boutiques Professionnelles

- **Profil Boutique**
  - Nom, description, logo
  - Coordonnées et localisation (Mapbox)
  - Horaires d'ouverture
  - Catégories de produits
  
- **Statistiques**
  - Nombre de produits
  - Évaluations moyennes
  - Ventes totales

### ⭐ Avis & Évaluations

- **Système de Reviews**
  - Notes de 1 à 5 étoiles
  - Commentaires textuels
  - Vérification achat (seuls les acheteurs peuvent noter)
  - Moyenne des notes par produit

### 🔔 Notifications

- **Push Notifications (Firebase)**
  - Nouvelles commandes
  - Changements de statut
  - Surenchères
  - Messages système
  
- **Notifications In-App**
  - Centre de notifications
  - Marquage lu/non lu
  - Historique complet

---

## 🏗️ Architecture

### Architecture Globale

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

### Architecture Backend (MVC Pattern)

```
backend/
├── models/          → Schémas MongoDB (Mongoose)
├── controllers/     → Logique métier
├── routes/          → Définition des endpoints
├── middleware/      → Auth, validation, error handling
├── services/        → Services externes (Firebase, Email)
├── utils/           → Fonctions utilitaires
├── config/          → Configuration DB
└── server.js        → Point d'entrée
```

### Architecture Mobile (Feature-First)

```
mobile/lib/
├── core/
│   ├── constants/   → Constantes globales
│   ├── models/      → Modèles de données
│   ├── services/    → Services API
│   ├── theme/       → Thème et styles
│   ├── utils/       → Utilitaires
│   └── widgets/     → Widgets réutilisables
└── features/
    ├── auth/        → Authentification
    ├── home/        → Page d'accueil
    ├── shop/        → Boutique et produits
    ├── cart/        → Panier
    ├── orders/      → Commandes
    └── profile/     → Profil utilisateur
```

---

## 🚀 Stack Technologique

### 📱 Mobile (Flutter)

| Technologie | Version | Usage |
|------------|---------|-------|
| **Flutter SDK** | 3.7.2 | Framework mobile cross-platform |
| **Dart** | ^3.7.2 | Langage de programmation |
| **Provider** | 6.1.5 | State management |
| **Dio** | 5.9.1 | Client HTTP |
| **Firebase Core** | 3.10.1 | Services Firebase |
| **Firebase Messaging** | 15.2.2 | Push notifications |
| **Google Sign In** | 6.2.1 | Authentification Google |
| **Shared Preferences** | 2.5.3 | Stockage local |
| **Flutter Secure Storage** | 10.0.0 | Stockage sécurisé (tokens) |
| **Google Fonts** | 6.3.2 | Typographies personnalisées |
| **Animate Do** | 4.2.0 | Animations |
| **Image Picker** | 1.2.1 | Sélection d'images |
| **FL Chart** | 1.1.0 | Graphiques et statistiques |
| **Intl** | 0.20.2 | Internationalisation |
| **Carousel Slider Plus** | 7.1.1 | Carrousels d'images |
| **Mapbox Maps Flutter** | 2.18.0 | Cartes interactives |
| **Flutter Map** | 8.2.2 | Cartes alternatives |
| **Shimmer** | 3.0.0 | Effets de chargement |
| **Socket.IO Client** | (via Dio) | WebSocket pour enchères |

### 🔧 Backend (Node.js)

| Technologie | Version | Usage |
|------------|---------|-------|
| **Node.js** | 18.x+ | Runtime JavaScript |
| **Express** | 5.2.1 | Framework web |
| **MongoDB** | Atlas | Base de données NoSQL |
| **Mongoose** | 9.1.5 | ODM MongoDB |
| **JWT** | 9.0.3 | Authentification par tokens |
| **bcryptjs** | 3.0.3 | Hachage de mots de passe |
| **Socket.IO** | 4.8.3 | WebSocket temps réel |
| **Multer** | 2.0.2 | Upload de fichiers |
| **CORS** | 2.8.6 | Cross-Origin Resource Sharing |
| **dotenv** | 17.2.3 | Variables d'environnement |
| **Firebase Admin** | 13.6.1 | Firebase côté serveur |
| **Google Auth Library** | 10.5.0 | OAuth Google |
| **Brevo** | 3.0.1 | Service d'emailing |
| **Nodemon** | 3.1.11 | Auto-reload en développement |

### ☁️ Services Cloud & Externes

- **MongoDB Atlas** : Base de données cloud
- **Firebase** : Authentication, Cloud Messaging, Admin SDK
- **Google Cloud** : OAuth 2.0
- **Brevo (Sendinblue)** : Service d'emailing transactionnel
- **Mapbox** : Cartes et géolocalisation

---

## 📁 Structure du Projet

### Backend Structure

```
backend/
├── config/
│   └── db.js                    # Configuration MongoDB
├── controllers/
│   ├── authController.js        # Authentification
│   ├── productController.js     # Gestion produits
│   ├── orderController.js       # Gestion commandes
│   ├── shopController.js        # Gestion boutiques
│   ├── userController.js        # Gestion utilisateurs
│   ├── reviewController.js      # Avis produits
│   ├── auctionController.js     # Enchères
│   └── notificationController.js # Notifications
├── middleware/
│   ├── auth.js                  # Middleware JWT
│   └── roleCheck.js             # Vérification des rôles
├── models/
│   ├── User.js                  # Schéma utilisateur
│   ├── Product.js               # Schéma produit
│   ├── Order.js                 # Schéma commande
│   ├── Shop.js                  # Schéma boutique
│   ├── Review.js                # Schéma avis
│   ├── Auction.js               # Schéma enchère
│   └── Notification.js          # Schéma notification
├── routes/
│   ├── auth.js                  # Routes authentification
│   ├── products.js              # Routes produits
│   ├── orders.js                # Routes commandes
│   ├── shops.js                 # Routes boutiques
│   ├── users.js                 # Routes utilisateurs
│   ├── reviews.js               # Routes avis
│   ├── auctions.js              # Routes enchères
│   └── notifications.js         # Routes notifications
├── services/
│   └── firebaseService.js       # Service Firebase
├── utils/
│   └── emailService.js          # Service email
├── uploads/                     # Fichiers uploadés
├── .env                         # Variables d'environnement
├── firebase-service-account.json # Clés Firebase
├── package.json                 # Dépendances npm
└── server.js                    # Point d'entrée
```

### Mobile Structure

```
mobile/
├── android/                     # Configuration Android
├── ios/                         # Configuration iOS
├── assets/
│   └── images/                  # Images et logos
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
│   └── main.dart                # Point d'entrée
├── pubspec.yaml                 # Dépendances Flutter
└── README.md
```

---

## 🔧 Installation

### Prérequis

- **Node.js** 18.x ou supérieur
- **npm** ou **yarn**
- **Flutter SDK** 3.7.2 ou supérieur
- **MongoDB Atlas** compte (ou MongoDB local)
- **Firebase** projet configuré
- **Android Studio** / **Xcode** (pour émulateurs)

### 1️⃣ Installation Backend

```bash
# Cloner le repository
git clone <repository-url>
cd SoukPro/backend

# Installer les dépendances
npm install

# Créer le fichier .env (voir Configuration)
cp .env.example .env

# Ajouter firebase-service-account.json
# (Télécharger depuis Firebase Console)

# Démarrer le serveur en mode développement
npm run dev

# Ou en mode production
npm start
```

Le serveur démarre sur `http://localhost:5001`

### 2️⃣ Installation Mobile

```bash
cd SoukPro/mobile

# Installer les dépendances Flutter
flutter pub get

# Générer les icônes d'application
flutter pub run flutter_launcher_icons

# Générer le splash screen
flutter pub run flutter_native_splash:create

# Lancer sur émulateur/appareil
flutter run

# Ou build pour production
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

---

## ⚙️ Configuration

### Backend (.env)

Créer un fichier `.env` dans `/backend/` :

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

1. **Créer un projet Firebase** sur [Firebase Console](https://console.firebase.google.com)

2. **Activer les services** :
   - Authentication (Email/Password, Google)
   - Cloud Messaging

3. **Télécharger les fichiers de configuration** :
   - **Backend** : `firebase-service-account.json` → placer dans `/backend/`
   - **Mobile Android** : `google-services.json` → placer dans `/mobile/android/app/`
   - **Mobile iOS** : `GoogleService-Info.plist` → placer dans `/mobile/ios/Runner/`

4. **Configurer dans le code mobile** :

```dart
// mobile/lib/main.dart
await Firebase.initializeApp();
```

### API Base URL (Mobile)

Modifier l'URL de l'API dans :

```dart
// mobile/lib/core/constants/api_constants.dart
class ApiConstants {
  static const String baseUrl = 'http://YOUR_IP:5001/api';
  // Pour émulateur Android : http://10.0.2.2:5001/api
  // Pour appareil physique : http://192.168.x.x:5001/api
}
```

### MongoDB Atlas

1. Créer un cluster sur [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. Créer un utilisateur de base de données
3. Whitelist votre IP (ou 0.0.0.0/0 pour développement)
4. Copier la connection string dans `MONGO_URI`

---

## 📚 Documentation Technique

### Authentification & Sécurité

#### JWT Token Flow

```
1. Login/Register → Server génère JWT
2. Client stocke token (Flutter Secure Storage)
3. Chaque requête → Header: Authorization: Bearer <token>
4. Middleware vérifie token → Extrait user ID
5. Controller accède à req.user
```

#### Middleware d'Authentification

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

#### Vérification des Rôles

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

### WebSocket (Enchères en Temps Réel)

#### Configuration Serveur

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

// Dans le controller
io.to(productId).emit('newBid', { currentBid, bidder });
```

#### Client Flutter

```dart
// Connexion Socket.IO
import 'package:socket_io_client/socket_io_client.dart' as IO;

IO.Socket socket = IO.io('http://YOUR_IP:5001', <String, dynamic>{
  'transports': ['websocket'],
  'autoConnect': false,
});

socket.connect();
socket.emit('joinAuction', productId);
socket.on('newBid', (data) {
  // Mettre à jour l'UI
});
```

### Upload de Fichiers

#### Configuration Multer

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

#### Client Flutter

```dart
// Upload avec Dio
FormData formData = FormData.fromMap({
  'title': 'Product Title',
  'price': 100,
  'images': await MultipartFile.fromFile(imagePath),
});

await dio.post('/products', data: formData);
```

### State Management (Provider)

```dart
// Exemple: AuthProvider
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
| POST | `/register` | Inscription utilisateur | ❌ |
| POST | `/login` | Connexion | ❌ |
| POST | `/google` | Connexion Google OAuth | ❌ |
| POST | `/verify` | Vérifier code email | ❌ |
| POST | `/resend-code` | Renvoyer code | ❌ |
| GET | `/me` | Obtenir utilisateur actuel | ✅ |

### Products (`/api/products`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/` | Liste tous les produits | ❌ |
| GET | `/:id` | Détails d'un produit | ❌ |
| POST | `/` | Créer un produit | ✅ |
| PUT | `/:id` | Modifier un produit | ✅ |
| DELETE | `/:id` | Supprimer un produit | ✅ |
| GET | `/category/:category` | Produits par catégorie | ❌ |
| GET | `/seller/:sellerId` | Produits d'un vendeur | ❌ |

### Orders (`/api/orders`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/` | Mes commandes | ✅ |
| GET | `/:id` | Détails commande | ✅ |
| POST | `/` | Créer une commande | ✅ |
| PUT | `/:id/status` | Changer statut | ✅ |
| GET | `/seller` | Commandes reçues (vendeur) | ✅ |

### Shops (`/api/shops`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/` | Liste boutiques | ❌ |
| GET | `/:id` | Détails boutique | ❌ |
| POST | `/` | Créer boutique | ✅ |
| PUT | `/:id` | Modifier boutique | ✅ |
| GET | `/my-shop` | Ma boutique | ✅ |

### Reviews (`/api/reviews`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/product/:productId` | Avis d'un produit | ❌ |
| POST | `/` | Créer un avis | ✅ |
| DELETE | `/:id` | Supprimer avis | ✅ |

### Auctions (`/api/auctions`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/product/:productId` | Enchères d'un produit | ❌ |
| POST | `/bid` | Placer une enchère | ✅ |

### Notifications (`/api/notifications`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/` | Mes notifications | ✅ |
| PUT | `/:id/read` | Marquer comme lu | ✅ |
| POST | `/register-token` | Enregistrer FCM token | ✅ |

### Users (`/api/users`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/` | Liste utilisateurs | ✅ Admin |
| GET | `/:id` | Détails utilisateur | ✅ |
| PUT | `/:id` | Modifier utilisateur | ✅ |
| DELETE | `/:id` | Supprimer utilisateur | ✅ Admin |
| POST | `/shipping-address` | Ajouter adresse | ✅ |

---

## 📊 Modèles de Données

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

## 🔒 Sécurité

### Mesures Implémentées

✅ **Authentification JWT** avec expiration
✅ **Hachage bcrypt** pour les mots de passe (10 rounds)
✅ **Validation des entrées** côté serveur
✅ **CORS** configuré
✅ **Tokens stockés de manière sécurisée** (Flutter Secure Storage)
✅ **HTTPS** recommandé en production
✅ **Rate limiting** (à implémenter)
✅ **Sanitization** des données MongoDB
✅ **Role-Based Access Control** (RBAC)
✅ **Vérification email** obligatoire
✅ **KYC** pour les professionnels

### Recommandations Production

- [ ] Activer HTTPS (Let's Encrypt)
- [ ] Implémenter rate limiting (express-rate-limit)
- [ ] Ajouter helmet.js pour headers sécurisés
- [ ] Configurer MongoDB IP Whitelist
- [ ] Activer MongoDB encryption at rest
- [ ] Implémenter refresh tokens
- [ ] Ajouter monitoring (Sentry, LogRocket)
- [ ] Configurer backups automatiques
- [ ] Implémenter CSRF protection
- [ ] Ajouter validation Joi/Yup

---

## 🚀 Déploiement

### Backend (Node.js)

#### Option 1: Heroku

```bash
# Installer Heroku CLI
heroku login

# Créer app
heroku create soukpro-api

# Configurer variables d'environnement
heroku config:set MONGO_URI=your_mongo_uri
heroku config:set JWT_SECRET=your_secret
# ... autres variables

# Déployer
git push heroku main
```

#### Option 2: DigitalOcean / AWS / GCP

```bash
# Sur le serveur
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

# Ou App Bundle (recommandé)
flutter build appbundle --release

# Fichier généré:
# build/app/outputs/bundle/release/app-release.aab
```

#### iOS (App Store)

```bash
# Build release
flutter build ios --release

# Ouvrir Xcode
open ios/Runner.xcworkspace

# Archive → Distribute → App Store Connect
```

#### Configuration Signing

**Android** : Créer `android/key.properties`
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-keystore>
```

**iOS** : Configurer dans Xcode
- Team
- Bundle Identifier
- Provisioning Profile

---

## 📈 Performances & Optimisations

### Backend

- **Indexation MongoDB** sur champs fréquents (email, seller, category)
- **Pagination** pour les listes (limit/skip)
- **Caching** (à implémenter avec Redis)
- **Compression** des réponses (gzip)
- **CDN** pour les images statiques

### Mobile

- **Lazy Loading** des images
- **Pagination** des listes
- **Caching** local (Shared Preferences)
- **Optimisation images** (compression)
- **Code splitting** par feature
- **Debouncing** pour la recherche

---

## 🧪 Tests

### Backend

```bash
# À implémenter
npm test

# Tests unitaires (Jest)
# Tests d'intégration (Supertest)
# Tests E2E
```

### Mobile

```bash
# Tests unitaires
flutter test

# Tests d'intégration
flutter drive --target=test_driver/app.dart

# Tests widgets
flutter test test/widget_test.dart
```

---

## 📝 Logs & Monitoring

### Backend Logs

```javascript
// Utiliser Winston ou Morgan
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

## 🤝 Contribution

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit (`git commit -m 'Add AmazingFeature'`)
4. Push (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

---

## 📄 License

Ce projet est sous licence MIT.

---

## 👨‍💻 Auteur

**Houssem Zorgui**
- Email: houssemzorgui10@gmail.com
- GitHub: [@houssemzorgui](https://github.com/houssemzorgui)

---

## 🙏 Remerciements

- Flutter Team
- Node.js Community
- MongoDB
- Firebase
- Tous les contributeurs open-source

---

<div align="center">

### ⭐ Si ce projet vous a aidé, n'hésitez pas à lui donner une étoile !

**Made with ❤️ by Houssem Zorgui**

</div>
