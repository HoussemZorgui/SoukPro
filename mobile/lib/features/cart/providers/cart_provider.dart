import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/models/cart_item.dart';
import '../../../core/models/product.dart';
import '../../../core/models/shipping_address.dart';
import '../../../core/constants/api_constants.dart';
import '../../auth/services/auth_service.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  final Dio _dio = Dio();
  final AuthService _authService = AuthService();

  List<CartItem> get items => [..._items];
  
  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + (double.parse(item.product.price.toString()) * item.quantity));
  }

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  void addToCart(Product product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity += 1;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void decrementQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity -= 1;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Address Management
  List<ShippingAddress> _addresses = [];
  List<ShippingAddress> get addresses => [..._addresses];
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchAddresses() async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await _authService.getToken();
      final user = await _authService.getCurrentUser(); // We might need a separate endpoint or just get user profile
      
      final response = await _dio.get(
        '${ApiConstants.baseUrl}/users/${user!.id}',
        options: Options(headers: {'x-auth-token': token}),
      );
      
      if (response.data['shippingAddresses'] != null) {
        _addresses = (response.data['shippingAddresses'] as List)
            .map((a) => ShippingAddress.fromJson(a))
            .toList();
      }
    } catch (e) {
      print('Error fetching addresses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addAddress(ShippingAddress address) async {
    try {
      final token = await _authService.getToken();
      final response = await _dio.post(
        '${ApiConstants.baseUrl}/users/addresses',
        data: address.toJson(),
        options: Options(headers: {'x-auth-token': token}),
      );
      _addresses = (response.data as List).map((a) => ShippingAddress.fromJson(a)).toList();
      notifyListeners();
      return true;
    } catch (e) {
      print('Error adding address: $e');
      return false;
    }
  }

  Future<bool> checkout({
    required ShippingAddress shippingAddress,
    required String paymentMethod,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await _authService.getToken();
      final response = await _dio.post(
        '${ApiConstants.baseUrl}/orders/checkout',
        data: {
          'items': _items.map((i) => i.toJson()).toList(),
          'paymentMethod': paymentMethod,
          'shippingAddress': shippingAddress.toJson(),
        },
        options: Options(headers: {'x-auth-token': token}),
      );
      
      if (response.statusCode == 200) {
        clearCart();
        return true;
      }
      return false;
    } catch (e) {
      print('Checkout error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
