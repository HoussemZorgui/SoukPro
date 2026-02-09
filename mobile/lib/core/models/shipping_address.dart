class ShippingAddress {
  final String? id;
  final String label;
  final String street;
  final String city;
  final String governorate;
  final String zip;
  final String phone;
  final bool isDefault;

  ShippingAddress({
    this.id,
    required this.label,
    required this.street,
    required this.city,
    required this.governorate,
    required this.zip,
    required this.phone,
    this.isDefault = false,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) => ShippingAddress(
    id: json['_id'],
    label: json['label'] ?? '',
    street: json['street'] ?? '',
    city: json['city'] ?? '',
    governorate: json['governorate'] ?? '',
    zip: json['zip'] ?? '',
    phone: json['phone'] ?? '',
    isDefault: json['isDefault'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'label': label,
    'street': street,
    'city': city,
    'governorate': governorate,
    'zip': zip,
    'phone': phone,
    'isDefault': isDefault,
  };
}
