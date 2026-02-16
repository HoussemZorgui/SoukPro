import 'package:flutter/material.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/models/notification_model.dart';
import 'package:intl/intl.dart';
import '../../orders/screens/order_loader_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  late Future<List<NotificationModel>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _refreshNotifications();
  }

  void _refreshNotifications() {
    setState(() {
      _notificationsFuture = _notificationService.getNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light grey background
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.blue),
            tooltip: 'Tout marquer comme lu',
            onPressed: () async {
              await _notificationService.markAllAsRead();
              _refreshNotifications();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
             return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Erreur de chargement des notifications'),
                  TextButton(
                    onPressed: _refreshNotifications,
                    child: const Text('Réessayer'),
                  )
                ],
              ),
            );
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  Text(
                    "Aucune notification pour le moment",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _refreshNotifications();
            },
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: notifications.length,
              separatorBuilder: (ctx, i) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Dismissible(
                   key: Key(notification.id),
                   background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                   // For now, we don't impl delete in backend, so disable dismiss or handle it
                   direction: DismissDirection.none, 
                   child: Container(
                     color: notification.read ? Colors.white : Colors.blue.withOpacity(0.05),
                     child: ListTile(
                       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                       leading: CircleAvatar(
                         backgroundColor: notification.read ? Colors.grey[200] : Colors.blue[100],
                         child: Icon(
                           Icons.notifications,
                           color: notification.read ? Colors.grey : Colors.blue,
                         ),
                       ),
                       title: Text(
                         notification.title,
                         style: TextStyle(
                           fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
                           color: Colors.black87,
                         ),
                       ),
                       subtitle: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           const SizedBox(height: 4),
                           Text(
                             notification.body,
                             style: TextStyle(color: Colors.grey[700]),
                             maxLines: 2,
                             overflow: TextOverflow.ellipsis,
                           ),
                           const SizedBox(height: 6),
                           Text(
                             DateFormat('dd MMM yyyy, HH:mm', 'fr_FR').format(notification.createdAt),
                             style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                           ),
                         ],
                       ),
                       onTap: () async {
                         if (!notification.read) {
                            await _notificationService.markAsRead(notification.id);
                            _refreshNotifications();
                         }
                          
                         // Navigate to Order details if it's an order notification
                         if (notification.data != null && notification.data!['orderId'] != null) {
                           String orderId = notification.data!['orderId'].toString();
                           print('Notification tapped in NotificationsScreen. OrderId: "$orderId"');
                           
                           if (orderId.trim().isNotEmpty && orderId != "null" && mounted) {
                             Navigator.push(
                               context,
                               MaterialPageRoute(
                                 builder: (context) => OrderLoaderScreen(orderId: orderId),
                               ),
                             );
                           }
                         }
                       },
                     ),
                   ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
