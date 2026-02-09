import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/models/order.dart'; // Make sure this path is correct
import '../../auth/services/auth_service.dart';

class OrderService {
  final Dio _dio = Dio();
  final AuthService _authService = AuthService();

  OrderService() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  Future<Order> createOrder(String productId, String paymentMethod, String address) async {
    try {
      final token = await _authService.getToken();
      final response = await _dio.post(
        '/orders',
        data: {
          'productId': productId,
          'paymentMethod': paymentMethod,
          'shippingAddress': address,
        },
        options: Options(headers: {'x-auth-token': token}),
      );

      if (response.statusCode == 200) {
        return Order.fromJson(response.data);
      } else {
        throw Exception('Failed to create order');
      }
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }

  Future<List<Order>> getMyOrders() async {
    try {
      final token = await _authService.getToken();
      final response = await _dio.get(
        '/orders',
        options: Options(headers: {'x-auth-token': token}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch orders');
      }
    } catch (e) {
       print(e);
      throw Exception('Error fetching orders: $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      final token = await _authService.getToken();
      await _dio.patch(
        '/orders/$orderId/status',
        data: {'status': status},
        options: Options(headers: {'x-auth-token': token}),
      );
    } catch (e) {
      throw Exception('Error updating status: $e');
    }
  }
}
