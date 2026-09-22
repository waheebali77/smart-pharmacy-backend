import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  static const _tokenKey = 'jwt_token';
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  AuthService({required this.dio, required this.secureStorage});

  Future<String> login(String identifier, String password) async {
    await secureStorage.delete(key: _tokenKey);
    _setAuthorizationHeader(null);
    final value = identifier.trim();
    if (value.isEmpty || password.isEmpty) {
      throw Exception('يرجى إدخال البريد الإلكتروني وكلمة المرور');
    }
    final isPhone = !value.contains('@');
    final response = await ApiService.requestWithFallback(
      dio,
      '/auth/login',
      method: 'POST',
      data: {
        if (isPhone) 'phone': value else 'email': value,
        'password': password,
      },
    );
    return _storeToken(response);
  }

  Future<String> register(
    String name,
    String email,
    String password, {
    required bool isOwner,
    String? phone,
    String? pharmacyName,
    String? pharmacyAddress,
    String? pharmacyPhone,
    String? pharmacyLicenseNumber,
    double? pharmacyLatitude,
    double? pharmacyLongitude,
  }) async {
    final response = await ApiService.requestWithFallback(
      dio,
      isOwner ? '/auth/register/pharmacy-owner' : '/auth/register/customer',
      method: 'POST',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        if (!isOwner && phone != null) 'phone': phone,
        if (isOwner) ...{
          'pharmacy_name': pharmacyName,
          'pharmacy_address': pharmacyAddress,
          'pharmacy_phone': pharmacyPhone,
          'pharmacy_license_number': pharmacyLicenseNumber,
          'latitude': pharmacyLatitude,
          'longitude': pharmacyLongitude,
        },
      },
    );
    return _storeToken(response);
  }

  Future<String> _storeToken(Response<dynamic> response) async {
    final token = _extractToken(response);
    await secureStorage.write(key: _tokenKey, value: token);
    _setAuthorizationHeader(token);
    dio.options.headers['Authorization'] = ['Bearer', token].join(' ');
    return token;
  }

  Future<User> getProfile() async {
    final response = await dio.get('/auth/profile');
    final payload = _extractPayload(response);
    final data = payload['data'];
    final user =
        data is Map && data['user'] is Map ? data['user'] : payload['user'];
    if (user is! Map) {
      throw Exception('Profile response did not include user data');
    }
    return User.fromJson(Map<String, dynamic>.from(user));
  }

  Future<User> updateProfile(Map<String, dynamic> data) async {
    final response = await dio.put('/auth/profile', data: data);
    final payload = _extractPayload(response);
    final responseData = payload['data'];
    final user =
        responseData is Map && responseData['user'] is Map
            ? responseData['user']
            : payload['user'];
    if (user is! Map) {
      throw Exception('Profile update response did not include user data');
    }
    return User.fromJson(Map<String, dynamic>.from(user));
  }

  Future<User> uploadProfileAvatar(File file) async {
    final response = await dio.post(
      '/auth/profile/avatar',
      data: FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      }),
    );
    final payload = _extractPayload(response);
    final data = payload['data'];
    final user =
        data is Map && data['user'] is Map ? data['user'] : payload['user'];
    if (user is! Map) {
      throw Exception('Avatar response did not include user data');
    }
    return User.fromJson(Map<String, dynamic>.from(user));
  }

  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String confirmation,
  }) async {
    await dio.put(
      '/auth/change-password',
      data: {
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': confirmation,
      },
    );
  }

  Future<Map<String, dynamic>> requestOtpReset(String phone) async {
    final response = await ApiService.requestWithFallback(
      dio,
      '/auth/request-otp-reset',
      method: 'POST',
      data: {'phone': phone},
    );
    return _authActionPayload(response);
  }

  Future<Map<String, dynamic>> verifyOtpReset({
    required String phone,
    required String otp,
  }) async {
    final response = await ApiService.requestWithFallback(
      dio,
      '/auth/verify-otp-reset',
      method: 'POST',
      data: {'phone': phone, 'otp': otp},
    );
    return _authActionPayload(response);
  }

  Future<Map<String, dynamic>> resetPasswordPhone({
    required String phone,
    required String token,
    required String password,
    required String confirmation,
  }) async {
    final response = await ApiService.requestWithFallback(
      dio,
      '/auth/reset-password-phone',
      method: 'POST',
      data: {
        'phone': phone,
        'token': token,
        'password': password,
        'password_confirmation': confirmation,
      },
    );
    return _authActionPayload(response);
  }

  Future<void> logout() async {
    await secureStorage.delete(key: _tokenKey);
    _setAuthorizationHeader(null);
  }

  Future<void> deleteAccount() async {
    await ApiService.requestWithFallback(
      dio,
      '/auth/profile',
      method: 'DELETE',
    );
    await secureStorage.delete(key: _tokenKey);
    _setAuthorizationHeader(null);
  }

  Future<String?> getToken() async {
    final token = await secureStorage.read(key: _tokenKey);
    _setAuthorizationHeader(token);
    if (token != null && token.isNotEmpty) {
      dio.options.headers['Authorization'] = ['Bearer', token].join(' ');
    }
    return token;
  }

  void _setAuthorizationHeader(String? token) {
    if (token == null || token.isEmpty) {
      dio.options.headers.remove('Authorization');
    } else {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Map<String, dynamic> _extractPayload(Response<dynamic> response) {
    final raw = response.data;
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is String) {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    }
    throw Exception('Unexpected auth response format: $raw');
  }

  Map<String, dynamic> _authActionPayload(Response<dynamic> response) {
    final payload = _extractPayload(response);
    if ((response.statusCode != null && response.statusCode! >= 400) ||
        payload['success'] == false) {
      final message = payload['message']?.toString();
      throw Exception(
        message?.trim().isNotEmpty == true
            ? message
            : 'تعذر تنفيذ العملية، يرجى المحاولة مرة أخرى',
      );
    }
    return payload;
  }

  String _extractToken(Response<dynamic> response) {
    final payload = _extractPayload(response);
    if (payload['success'] == false) {
      final errors = payload['errors'];
      if (errors is Map) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty) {
            throw Exception(value.first.toString());
          }
        }
      }
      throw Exception(
        payload['message']?.toString() ?? 'Authentication failed',
      );
    }

    final data = payload['data'];
    if (data is Map) {
      final token = data['token'];
      if (token is String && token.isNotEmpty) return token;
    }
    final token = payload['token'];
    if (token is String && token.isNotEmpty) return token;

    final message = payload['message'];
    if (message is String && message.trim().isNotEmpty) {
      throw Exception(message.trim());
    }
    throw Exception('Authentication response did not include a token');
  }
}
