class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final List<String> images;
  final String category;
  final String condition;
  final String type; // 'fixed' or 'auction'
  final List<String> paymentType; // 'cash', 'installments', 'auction'
  final List<dynamic>? installmentOptions;
  final DateTime? auctionEndDate;
  final double? startingBid;
  final double currentMake;
  final int stock;
  final String status;
  final Map<String, dynamic>? seller;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.images,
    required this.category,
    required this.condition,
    required this.type,
    this.paymentType = const ['cash'],
    this.installmentOptions,
    this.auctionEndDate,
    this.startingBid,
    this.currentMake = 0.0,
    required this.status,
    this.stock = 1,
    this.seller,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      category: json['category'],
      condition: json['condition'],
      type: json['type'] ?? 'fixed',
      paymentType: (json['paymentType'] is List)
          ? List<String>.from(json['paymentType'])
          : [json['paymentType'] ?? 'cash'],
      installmentOptions: json['installmentOptions'],
      auctionEndDate: json['auctionEndDate'] != null ? DateTime.parse(json['auctionEndDate']) : null,
      startingBid: json['startingBid'] != null ? (json['startingBid'] as num).toDouble() : null,
      currentMake: (json['currentMake'] as num?)?.toDouble() ?? 0.0,
      status: json['status'],
      stock: (json['stock'] as num?)?.toInt() ?? 1,
      seller: json['seller'] is Map<String, dynamic> ? json['seller'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'price': price,
      'images': images,
      'category': category,
      'condition': condition,
      'type': type,
      'paymentType': paymentType,
      'installmentOptions': installmentOptions,
      'auctionEndDate': auctionEndDate?.toIso8601String(),
      'startingBid': startingBid,
      'currentMake': currentMake,
      'status': status,
      'stock': stock,
    };
  }
}
