import 'package:dio/dio.dart';
import 'dart:io';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:latlong2/latlong.dart';
import '../../auth/services/auth_service.dart';

class ShopService {
  final Dio _dio = Dio();
  final AuthService _authService = AuthService();

  ShopService() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  Future<Map<String, dynamic>?> getMyShop() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await _dio.get(
        '/shops/me',
        options: Options(headers: {'x-auth-token': token}),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null; // No shop found
      }
      throw Exception('Failed to load shop');
    }
  }

  Future<Map<String, dynamic>> createShop({
    required String name,
    required String description,
    required String shopAddress,
    String? governorate,
    String? phone,
    String? facebook,
    String? instagram,
    String? website,
    LatLng? location,
    File? logo,
    File? banner,
  }) async {
    try {
      final token = await _authService.getToken();
      
      final formData = FormData.fromMap({
        'name': name,
        'description': description,
        'shopAddress': shopAddress,
        if (governorate != null) 'governorate': governorate,
        if (phone != null) 'phone': phone,
        if (facebook != null) 'facebook': facebook,
        if (instagram != null) 'instagram': instagram,
        if (website != null) 'website': website,
        if (location != null) 'locationLat': location.latitude.toString(),
        if (location != null) 'locationLng': location.longitude.toString(),
        if (logo != null)
          'logo': await MultipartFile.fromFile(logo.path, filename: 'logo.jpg'),
        if (banner != null)
          'banner': await MultipartFile.fromFile(banner.path, filename: 'banner.jpg'),
      });

      final response = await _dio.post(
        '/shops',
        data: formData,
        options: Options(headers: {'x-auth-token': token}),
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to create shop');
    }
  }

  Future<Map<String, dynamic>> getShopById(String id) async {
    try {
      final response = await _dio.get('/shops/$id');
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Shop not found');
    } catch (e) {
      throw Exception('Failed to fetch shop: $e');
    }
  }
  Future<List<dynamic>> getAllShops() async {
    try {
      final response = await _dio.get('/shops');
      if (response.statusCode == 200) {
        return response.data;
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch shops: $e');
    }
  }

  Future<Map<String, dynamic>> addReview({
    required String shopId,
    required double rating,
    required String comment,
  }) async {
    try {
      final token = await _authService.getToken();
      final response = await _dio.post(
        '/reviews',
        data: {
          'shopId': shopId,
          'rating': rating,
          'comment': comment,
        },
        options: Options(headers: {'x-auth-token': token}),
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to add review');
    }
  }

  Future<List<dynamic>> getShopReviews(String shopId) async {
    try {
      final response = await _dio.get('/reviews/shop/$shopId');
      if (response.statusCode == 200) {
        return response.data;
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch reviews');
    }
  }

  Future<Map<String, dynamic>> getShopStats(String shopId) async {
    try {
      final response = await _dio.get('/shops/stats/$shopId');
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to fetch stats');
    } catch (e) {
      throw Exception('Failed to fetch shop stats: $e');
    }
  }
}
