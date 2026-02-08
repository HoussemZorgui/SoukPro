class Order {
  final String id;
  final String productId;
  final String productTitle;
  final double totalAmount;
  final String status;
  final String paymentMethod;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.productId,
    required this.productTitle,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'],
      productId: json['product'] is Map ? json['product']['_id'] : json['product'],
      productTitle: json['product'] is Map ? json['product']['title'] : 'Unknown Product',
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'],
      paymentMethod: json['paymentMethod'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
