class Order {
  final String id;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final String paymentMethod;
  final String? paymentStatus;
  final DateTime createdAt;
  final Map<String, dynamic>? shippingAddress;

  Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    this.paymentStatus,
    required this.createdAt,
    this.shippingAddress,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // Handle cases where items might be missing or null
    final itemsList = (json['items'] as List?)?.map((item) => OrderItem.fromJson(item)).toList() ?? [];
    
    // Defensive handling for shippingAddress which might be a String in old orders
    Map<String, dynamic>? address;
    if (json['shippingAddress'] is Map) {
      address = Map<String, dynamic>.from(json['shippingAddress']);
    }

    return Order(
      id: json['_id'] ?? '',
      items: itemsList.cast<OrderItem>(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      paymentMethod: json['paymentMethod'] ?? 'cash_on_delivery',
      paymentStatus: json['paymentStatus'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      shippingAddress: address,
    );
  }
}

class OrderItem {
  final String productId;
  final String title;
  final String image;
  final double price;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.title,
    required this.image,
    required this.price,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'];
    String imageUrl = '';
    
    if (product is Map && product['images'] != null && product['images'] is List && (product['images'] as List).isNotEmpty) {
      imageUrl = (product['images'] as List).first.toString();
    }

    return OrderItem(
      productId: product is Map ? (product['_id'] ?? '').toString() : (product?.toString() ?? ''),
      title: product is Map ? (product['title'] ?? 'Article inconnu').toString() : 'Article inconnu',
      image: imageUrl,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }
}
