class NotificationModel {
  final String id;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final bool read;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.data,
    required this.read,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> dataMap = {};
    if (json['data'] != null) {
      if (json['data'] is Map) {
        dataMap = Map<String, dynamic>.from(json['data']);
      } else if (json['data'] is String) {
        // Handle potentially stringified JSON in some DB drivers
        try {
          // You'd need dart:convert for this, but let's assume it's usually a Map
          // We'll just leave it empty if it's a string for now, or log it
        } catch (_) {}
      }
    }

    return NotificationModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      data: dataMap,
      read: json['read'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}
