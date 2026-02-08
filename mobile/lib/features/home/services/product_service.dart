import 'package:dio/dio.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/models/product.dart';
import '../../auth/services/auth_service.dart';

class ProductService {
  final Dio _dio = Dio();
  final AuthService _authService = AuthService(); // To get token if needed

  ProductService() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  Future<List<Product>> getProducts({Map<String, dynamic>? filters}) async {
    try {
      final response = await _dio.get('/products', queryParameters: filters);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  Future<Product> getProductById(String id) async {
    try {
      final response = await _dio.get('/products/$id');
      if (response.statusCode == 200) {
        return Product.fromJson(response.data);
      } else {
        throw Exception('Product not found');
      }
    } catch (e) {
      throw Exception('Error fetching product: $e');
    }
  }

  Future<List<Product>> getProductsBySeller(String sellerId) async {
    try {
      final response = await _dio.get('/products/seller/$sellerId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load seller products');
      }
    } catch (e) {
      throw Exception('Error fetching seller products: $e');
    }
  }
  
  // Method to create product (for professionals/sellers)
  Future<Product> createProduct(FormData formData) async {
     try {
      final token = await _authService.getToken();
      final response = await _dio.post(
        '/products',
        data: formData,
        options: Options(headers: {'x-auth-token': token}),
      );
      
      if (response.statusCode == 200) {
        return Product.fromJson(response.data);
      } else {
        throw Exception('Failed to create product');
      }
    } catch (e) {
      throw Exception('Error creating product: $e');
    }
  }
}
