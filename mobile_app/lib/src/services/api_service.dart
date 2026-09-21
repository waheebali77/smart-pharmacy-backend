import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final Dio dio;

  ApiService._internal(this.dio);

  static List<String> _normalizeBaseUrls(String baseUrl) {
    return baseUrl
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
  }

  static bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.receiveTimeout ||
        error.response?.statusCode == 302;
  }

  static Future<Response<T>> requestWithFallback<T>(
    Dio dio,
    String path, {
    required String method,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final baseUrls = _normalizeBaseUrls(dio.options.baseUrl);
    if (baseUrls.isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        error: 'No API base URL configured',
      );
    }

    final originalBaseUrl = dio.options.baseUrl;
    try {
      for (var index = 0; index < baseUrls.length; index++) {
        try {
          dio.options.baseUrl = baseUrls[index];
          return await dio.request<T>(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options ?? Options(method: method),
          );
        } on DioException catch (error) {
          if (!_shouldRetry(error) || index == baseUrls.length - 1) {
            rethrow;
          }
        }
      }
    } finally {
      dio.options.baseUrl = originalBaseUrl;
    }

    throw DioException(
      requestOptions: RequestOptions(path: path),
      error: 'Unable to reach API',
    );
  }

  static ApiService create({
    required String baseUrl,
    FlutterSecureStorage? secureStorage,
  }) {
    final baseUrls = _normalizeBaseUrls(baseUrl);
    final effectiveBaseUrl =
        baseUrls.isNotEmpty
            ? baseUrls.first
            : 'https://smart-pharmacy-backend-1.onrender.com/api';

    final dio = Dio(
      BaseOptions(
        baseUrl: effectiveBaseUrl,
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 30),
        responseType: ResponseType.json,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        followRedirects: false,
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await (secureStorage ?? FlutterSecureStorage()).read(
            key: 'jwt_token',
          );
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
      ),
    );

    return ApiService._internal(dio);
  }
}
