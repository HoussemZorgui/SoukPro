class Order {
  final String id;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final String paymentMethod;
  final String? paymentStatus;
  final DateTime createdAt;
  final Map<String, dynamic>? shippingAddress;

  final String? buyerId;
  final String? buyerName;
  final String? buyerAvatar;

  Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    this.paymentStatus,
    required this.createdAt,
    this.shippingAddress,
    this.buyerId,
    this.buyerName,
    this.buyerAvatar,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // Handle cases where items might be missing or null
    final List<OrderItem> itemsList = [];
    if (json['items'] != null && json['items'] is List) {
      for (var item in json['items']) {
        if (item != null && item is Map<String, dynamic>) {
          itemsList.add(OrderItem.fromJson(item));
        }
      }
    }
    
    // Defensive handling for shippingAddress which might be a String in old orders
    Map<String, dynamic>? address;
    if (json['shippingAddress'] is Map) {
      address = Map<String, dynamic>.from(json['shippingAddress']);
    } else if (json['shippingAddress'] is String) {
      // If it's a string, we could optionally wrap it or just leave it null
      address = {'address': json['shippingAddress']};
    }

    // Handle buyer info
    final buyer = json['buyer'];
    String? bId, bName, bAvatar;
    if (buyer is Map) {
      bId = buyer['_id']?.toString();
      bName = buyer['name']?.toString();
      bAvatar = buyer['avatar']?.toString();
    } else {
      bId = buyer?.toString();
    }

    return Order(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      items: itemsList,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: (json['status'] ?? 'pending').toString(),
      paymentMethod: (json['paymentMethod'] ?? 'cash_on_delivery').toString(),
      paymentStatus: json['paymentStatus']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : DateTime.now(),
      shippingAddress: address,
      buyerId: bId,
      buyerName: bName,
      buyerAvatar: bAvatar,
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
