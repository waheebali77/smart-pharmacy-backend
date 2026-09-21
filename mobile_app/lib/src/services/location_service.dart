import 'package:dio/dio.dart';

import '../models/location.dart';
import 'api_service.dart';

class LocationService {
  final Dio _dio;

  LocationService(this._dio);

  Future<List<Country>> getCountries() async {
    final response = await ApiService.requestWithFallback<dynamic>(
      _dio,
      '/locations',
      method: 'GET',
    );
    final body = response.data;
    final countries = body is Map<String, dynamic> ? body['data'] : body;
    if (countries is! List) {
      throw const FormatException('Invalid locations response.');
    }
    return countries
        .whereType<Map<String, dynamic>>()
        .map(Country.fromJson)
        .toList();
  }
}
