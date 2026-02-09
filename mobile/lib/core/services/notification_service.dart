import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../constants/api_constants.dart';
import '../../features/auth/services/auth_service.dart';

class NotificationService {
  final Dio _dio = Dio();
  final AuthService _authService = AuthService();
  final FlutterLocalNotificationsPlugin _localNotif = FlutterLocalNotificationsPlugin();

  NotificationService() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
  }

  Future<void> initializeNotifications() async {
    try {
      // 1. Initialize Local Notifications for Foreground
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initSettings = InitializationSettings(android: androidSettings);
      await _localNotif.initialize(initSettings);

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'Commandes & Activité',
        description: 'Notifications pour les commandes et mises à jour de compte',
        importance: Importance.max,
      );

      await _localNotif.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // 2. Firebase Setup
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      
      // Get the token
      String? token = await messaging.getToken();
      if (token != null) {
        await updateFcmToken(token);
      }

      // Listen for token refreshes
      messaging.onTokenRefresh.listen((newToken) {
        updateFcmToken(newToken);
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        if (notification != null && android != null) {
          _localNotif.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                'high_importance_channel',
                'Commandes & Activité',
                channelDescription: 'Notifications pour les commandes et mises à jour de compte',
                icon: android.smallIcon,
                importance: Importance.max,
                priority: Priority.high,
              ),
            ),
          );
        }
      });
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  Future<void> updateFcmToken(String token) async {
    try {
      final authToken = await _authService.getToken();
      if (authToken == null) return;
      
      await _dio.patch(
        '/users/fcm-token',
        data: {'fcmToken': token},
        options: Options(headers: {'x-auth-token': authToken}),
      );
      print('FCM Token updated on server');
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }
}
