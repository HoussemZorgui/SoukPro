import 'dart:async';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../constants/api_constants.dart';
import '../../features/auth/services/auth_service.dart';
import '../models/notification_model.dart';

class NotificationService {
  final Dio _dio = Dio();
  final AuthService _authService = AuthService();
  final FlutterLocalNotificationsPlugin _localNotif = FlutterLocalNotificationsPlugin();

  NotificationService() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
  }
  
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final authToken = await _authService.getToken();
      if (authToken == null) return [];
      
      final response = await _dio.get(
        '/notifications',
        options: Options(headers: {'x-auth-token': authToken}),
      );
      
      return (response.data as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final authToken = await _authService.getToken();
      if (authToken == null) return;
      
      await _dio.patch(
        '/notifications/$id/read',
        options: Options(headers: {'x-auth-token': authToken}),
      );
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

    Future<void> markAllAsRead() async {
    try {
      final authToken = await _authService.getToken();
      if (authToken == null) return;
      
      await _dio.patch(
        '/notifications/read-all',
        options: Options(headers: {'x-auth-token': authToken}),
      );
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  // Stream to broadcast notification payloads
  final _notificationStream = StreamController<String?>.broadcast();
  Stream<String?> get notificationStream => _notificationStream.stream;

  Future<void> initializeNotifications() async {
    try {
      // 1. Initialize Local Notifications for Foreground
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
      
      final InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
      );
      
      await _localNotif.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          print('Local notification clicked. Payload: "${response.payload}"');
          if (response.payload != null && response.payload!.isNotEmpty) {
            _notificationStream.add(response.payload);
          }
        },
      );

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

      // Handle background notification clicks
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        String? orderId = message.data['orderId'];
        print('Background notification clicked. orderId: "$orderId"');
        if (orderId != null && orderId.isNotEmpty) {
          _notificationStream.add(orderId);
        }
      });

      // Handle terminated state notification clicks
      messaging.getInitialMessage().then((RemoteMessage? message) {
        if (message != null) {
          String? orderId = message.data['orderId'];
          print('Initial message (terminated) detected. orderId: "$orderId"');
          if (orderId != null && orderId.isNotEmpty) {
            _notificationStream.add(orderId);
          }
        }
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Foreground message received. Full Data: ${message.data}');
        RemoteNotification? notification = message.notification;
        
        if (notification != null) {
          String? orderId = message.data['orderId']?.toString();
          print('Showing local notification. Title: ${notification.title}, orderId: "$orderId"');
          
          _localNotif.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                importance: Importance.max,
                priority: Priority.high,
                icon: '@mipmap/launcher_icon',
                color: const Color(0xFF000000),
              ),
            ),
            payload: orderId,
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
      print('FCM Token updated on server: ${token.substring(0, 10)}...');
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  Future<void> removeFcmToken() async {
    try {
      final authToken = await _authService.getToken();
      if (authToken == null) return;
      
      await _dio.delete(
        '/users/fcm-token',
        options: Options(headers: {'x-auth-token': authToken}),
      );
      print('FCM Token removed from server');
    } catch (e) {
      print('Error removing FCM token: $e');
    }
  }

  Future<void> checkForMissedNotifications() async {
    try {
      final notifications = await getNotifications();
      final unreadNotifications = notifications.where((n) => !n.read).toList();
      final unreadCount = unreadNotifications.length;

      if (unreadCount > 0) {
        const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
          'high_importance_channel',
          'Commandes & Activité',
          channelDescription: 'Notifications pour les commandes et mises à jour de compte',
          importance: Importance.max,
          priority: Priority.high,
          color: const Color(0xFF000000),
        );
        const NotificationDetails details = NotificationDetails(android: androidDetails);
        
        String title = 'Notifications manquées';
        String body = 'Vous avez $unreadCount nouvelle(s) notification(s).';
        String payload = 'GO_TO_NOTIFICATIONS';

        // If only one unread notification, be more specific
        if (unreadCount == 1) {
          final notif = unreadNotifications.first;
          title = notif.title;
          body = notif.body;
          final orderId = notif.data['orderId']?.toString();
          if (orderId != null && orderId.isNotEmpty && orderId != "null") {
            payload = orderId;
          }
        }

        await _localNotif.show(
          0, // Summary ID
          title,
          body,
          details,
          payload: payload,
        );
      }
    } catch (e) {
      print('Error checking missed notifications: $e');
    }
  }
}
