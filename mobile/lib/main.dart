import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/home/providers/product_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/home/screens/main_layout_screen.dart';
import 'core/theme/app_theme.dart';

import 'features/orders/providers/order_provider.dart';
import 'features/shop/providers/shop_provider.dart';
import 'features/cart/providers/cart_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/date_symbol_data_local.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Request permission for iOS/Android 13+
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  } catch (e) {
    print("Firebase initialization error: $e");
  }

  runApp(const SoukProApp());
}

class SoukProApp extends StatelessWidget {
  const SoukProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'SoukPro',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        themeMode: ThemeMode.light,
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.isLoading) {
              return Scaffold(
                backgroundColor: Colors.white,
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/SoukPro.png',
                        height: 200,
                        width: 200,
                      ),
                      const SizedBox(height: 30),
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC9A24D)),
                      ),
                    ],
                  ),
                ),
              );
            }
            return auth.isAuthenticated ? const MainLayoutScreen() : const LoginScreen();
          },
        ),
      ),
    );
  }
}
