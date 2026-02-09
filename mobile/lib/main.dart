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

void main() {
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
