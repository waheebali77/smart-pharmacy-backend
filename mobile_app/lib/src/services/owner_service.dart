import 'dart:io';

import 'package:dio/dio.dart';
import '../models/pharmacy.dart';
import '../models/medicine.dart';
import '../models/offer.dart';
import '../models/order.dart';

class OwnerService {
  final Dio dio;

  OwnerService(this.dio);

  Future<Map<String, dynamic>> getOwnerDashboard() async {
    final response = await dio.get('/owner/dashboard');
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getPackages() async {
    final response = await dio.get('/packages');
    final items = response.data['data'] as List<dynamic>? ?? [];
    return items.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  Future<Pharmacy> getPharmacyProfile() async {
    final response = await dio.get('/owner/pharmacy');
    return Pharmacy.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Pharmacy> updatePharmacyProfile(Map<String, dynamic> data) async {
    final response = await dio.put('/owner/pharmacy', data: data);
    return Pharmacy.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Pharmacy> updateEmergencyClose(bool isManuallyClosed) async {
    final response = await dio.put(
      '/owner/pharmacy/emergency-close',
      data: {'is_manually_closed': isManuallyClosed},
    );
    return Pharmacy.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Pharmacy> uploadPharmacyImage(File file) async {
    final response = await dio.post(
      '/owner/pharmacy/images',
      data: FormData.fromMap({
        'images[]': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      }),
    );
    return Pharmacy.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<List<Medicine>> getMedicines() async {
    final response = await dio.get('/owner/medicines');
    final items = response.data['data'] as List<dynamic>;
    return items
        .map((json) => Medicine.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<Medicine>> searchCatalogMedicines(String query) async {
    final response = await dio.get(
      '/owner/medicines/catalog',
      queryParameters: {'search': query},
    );
    final items = response.data['data'] as List<dynamic>;
    return items
        .map((json) => Medicine.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Medicine> addCatalogMedicine(int id, Map<String, dynamic> data) async {
    final response = await dio.post(
      '/owner/medicines/$id/inventory',
      data: data,
    );
    final item = _extractData(response.data);
    if (item == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Could not add catalog medicine.',
      );
    }
    return Medicine.fromJson(item);
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await dio.get('/customer/categories');
    final items = response.data['data'] as List<dynamic>;
    return items.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  Future<Map<String, dynamic>> createMedicine(Map<String, dynamic> data) async {
    final hasFile = data.values.any((value) => value is File);
    final payload = hasFile ? await _toFormData(data) : data;
    final response = await dio.post('/owner/medicines', data: payload);

    // Check if medicine already exists
    if (response.data is Map && response.data['exists'] == true) {
      return {
        'exists': true,
        'medicine': response.data['medicine'],
        'message':
            response.data['message'] ?? 'هذا العلاج موجود مسبقاً في الصيدلية',
        'suggested_actions': response.data['suggested_actions'],
      };
    }

    final item = _extractData(response.data);
    if (item == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Could not create medicine. ${_extractMessage(response.data)}',
      );
    }
    return {'exists': false, 'medicine': Medicine.fromJson(item)};
  }

  Future<Medicine> updateMedicine(int id, Map<String, dynamic> data) async {
    final hasFile = data.values.any((value) => value is File);
    final payload = hasFile ? await _toFormData(data) : data;
    final response = await dio.put('/owner/medicines/$id', data: payload);
    final item = _extractData(response.data);
    if (item == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Could not update medicine. ${_extractMessage(response.data)}',
      );
    }
    return Medicine.fromJson(item);
  }

  Future<void> deleteMedicine(int id) async {
    await dio.delete('/owner/medicines/$id');
  }

  Future<List<Offer>> getOffers() async {
    final response = await dio.get('/owner/offers');
    final items = response.data['data'] as List<dynamic>;
    return items
        .map((json) => Offer.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Offer> createOffer(Map<String, dynamic> data) async {
    final hasFile = data.values.any((value) => value is File);
    final payload = hasFile ? await _toFormData(data) : data;
    final response = await dio.post('/owner/offers', data: payload);
    final item = _extractData(response.data);
    if (item == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Could not create offer. ${_extractMessage(response.data)}',
      );
    }
    return Offer.fromJson(item);
  }

  Future<Offer> updateOffer(int id, Map<String, dynamic> data) async {
    final hasFile = data.values.any((value) => value is File);
    final payload = hasFile ? await _toFormData(data) : data;
    final response = await dio.put('/owner/offers/$id', data: payload);
    final item = _extractData(response.data);
    if (item == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Could not update offer. ${_extractMessage(response.data)}',
      );
    }
    return Offer.fromJson(item);
  }

  Future<void> deleteOffer(int id) async {
    await dio.delete('/owner/offers/$id');
  }

  Future<Pharmacy> updateStatus(String status) async {
    final response = await dio.put(
      '/owner/pharmacy/status',
      data: {'status': status},
    );
    return Pharmacy.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Pharmacy> updateWorkingHours(
    String openingTime,
    String closingTime,
  ) async {
    final response = await dio.put(
      '/owner/pharmacy/hours',
      data: {'opening_time': openingTime, 'closing_time': closingTime},
    );
    return Pharmacy.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<List<Order>> getOwnerOrders() async {
    final response = await dio.get('/owner/orders');
    final items = response.data['data'] as List<dynamic>? ?? [];
    return items
        .map((json) => Order.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  Future<Order> updateOrderStatus(int id, String action) async {
    final response = await dio.patch('/owner/orders/$id/$action');
    return Order.fromJson(
      Map<String, dynamic>.from(response.data['data'] as Map),
    );
  }

  Map<String, dynamic>? _extractData(dynamic body) {
    if (body is! Map) return null;

    final map = Map<String, dynamic>.from(body);
    final data = map['data'];
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    if (data != null) {
      return Map<String, dynamic>.from(data);
    }
    return map;
  }

  String _extractMessage(dynamic body) {
    if (body is! Map) return '';
    final map = Map<String, dynamic>.from(body);
    final message = map['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }
    if (map['errors'] is Map) {
      final errors = map['errors'] as Map;
      final firstError = errors.values.first;
      if (firstError is List && firstError.isNotEmpty) {
        return firstError.first.toString();
      }
    }
    return 'Server returned no payload.';
  }

  Future<FormData> _toFormData(Map<String, dynamic> data) async {
    final formData = FormData();

    for (final entry in data.entries) {
      if (entry.value == null) continue;
      if (entry.value is bool) {
        formData.fields.add(
          MapEntry(entry.key, entry.value == true ? '1' : '0'),
        );
      } else if (entry.value is String || entry.value is num) {
        formData.fields.add(MapEntry(entry.key, entry.value.toString()));
      } else if (entry.value is File) {
        final file = entry.value as File;
        formData.files.add(
          MapEntry(
            entry.key,
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        );
      }
    }

    return formData;
  }
}
