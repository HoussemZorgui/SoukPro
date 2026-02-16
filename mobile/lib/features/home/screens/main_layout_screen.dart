import 'package:flutter/material.dart';
import '../../home/screens/home_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../widgets/global_drawer.dart';
import '../widgets/global_app_bar.dart';
import 'search_screen.dart';
import 'notifications_screen.dart';
import '../../shop/screens/shop_orders_screen.dart';
import '../../orders/screens/order_loader_screen.dart';
import '../../../core/services/notification_service.dart';
import 'dart:async';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;
  final NotificationService _notificationService = NotificationService();
  StreamSubscription? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    
    // 1. Attach listener FIRST to ensure we don't miss anything from the stream
    _notificationSubscription = _notificationService.notificationStream.listen((orderId) {
      print('MainLayout: Notification stream emitted orderId: "$orderId"');
      if (orderId == null || orderId.isEmpty || orderId == "null") return;

      if (mounted) {
        if (orderId == 'GO_TO_NOTIFICATIONS') {
          setState(() => _currentIndex = 3); // 3 is Notifications tab
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderLoaderScreen(orderId: orderId),
            ),
          );
        }
      }
    });

    // 2. Then initialize services
    _notificationService.initializeNotifications().then((_) {
      _notificationService.checkForMissedNotifications();
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const ShopOrdersScreen(),
    const NotificationsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GlobalAppBar(showMenu: true),
      drawer: const GlobalDrawer(),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Recherche',
          ),
          NavigationDestination(
            icon: Icon(Icons.sell_outlined),
            selectedIcon: Icon(Icons.sell),
            label: 'Mes Ventes',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

