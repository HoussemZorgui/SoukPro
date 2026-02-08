import 'package:dio/dio.dart';
import 'dart:io';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthService() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'jwt_token');
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(ApiConstants.loginEndpoint, data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['token'];
        await saveToken(token);
        return response.data;
      } else {
        throw Exception('Login failed');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['msg'] ?? 'Login failed');
    }
  }

   Future<Map<String, dynamic>> googleLogin(String idToken, String? role) async {
    try {
      print("DÉBUT API: Envoi POST vers ${ApiConstants.googleLoginEndpoint}");
      final response = await _dio.post(ApiConstants.googleLoginEndpoint, data: {
        'idToken': idToken,
        if (role != null) 'role': role,
      });

      print("RÉPONSE API: StatusCode = ${response.statusCode}");
      if (response.statusCode == 200) {
        final token = response.data['token'];
        await saveToken(token);
        print("TOKEN SAUVEGARDÉ: Succès");
        return response.data;
      } else {
        print("ERREUR API: Status non-200");
        throw Exception('Google Login failed');
      }
    } on DioException catch (e) {
      print("ERREUR DIO: ${e.response?.statusCode} - ${e.response?.data}");
      throw Exception(e.response?.data['msg'] ?? 'Google Login failed');
    } catch (e) {
      print("ERREUR INCONNUE API: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password, String role) async {
    try {
      final response = await _dio.post(ApiConstants.registerEndpoint, data: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      });

      if (response.statusCode == 200) {
        final token = response.data['token'];
        await saveToken(token);
        return response.data;
      } else {
        throw Exception('Registration failed');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['msg'] ?? 'Registration failed');
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await _dio.get(
        ApiConstants.meEndpoint,
        options: Options(
          headers: {'x-auth-token': token},
        ),
      );

      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<User> updateProfile({
    required String id,
    required String name,
    String? phone,
    String? address,
    File? avatar,
    File? kycDoc
  }) async {
    try {
      final token = await getToken();

      final formData = FormData.fromMap({
        'name': name,
        'phone': phone,
        'address': address,
        if (avatar != null) 'avatar': await MultipartFile.fromFile(avatar.path),
      });

      final response = await _dio.patch(
        '${ApiConstants.baseUrl}/users/$id',
        data: formData,
        options: Options(headers: {'x-auth-token': token}),
      );

      if (kycDoc != null) {
          final kycData = FormData.fromMap({
            'documents': [await MultipartFile.fromFile(kycDoc.path)]
          });
          await _dio.post('${ApiConstants.baseUrl}/users/kyc',
            data: kycData,
             options: Options(headers: {'x-auth-token': token})
          );
      }

      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      } else {
        throw Exception('Failed to update profile');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['msg'] ?? 'Update failed');
    }
  }
}
