import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../models/medicine.dart';
import '../models/pharmacy.dart';
import '../models/offer.dart';
import '../models/order.dart';
import '../models/customer_home_data.dart';

class CustomerService {
  final Dio dio;

  CustomerService(this.dio);

  static List<Pharmacy> sortPharmaciesByDistance(
    List<Pharmacy> pharmacies,
    Position userPosition,
  ) {
    final sorted = List<Pharmacy>.of(pharmacies);
    sorted.sort((first, second) {
      final firstDistance = _distanceToPharmacy(first, userPosition);
      final secondDistance = _distanceToPharmacy(second, userPosition);

      if (firstDistance == null && secondDistance == null) return 0;
      if (firstDistance == null) return 1;
      if (secondDistance == null) return -1;
      final distanceComparison = firstDistance.compareTo(secondDistance);
      return distanceComparison != 0
          ? distanceComparison
          : first.id.compareTo(second.id);
    });
    return sorted;
  }

  static double? _distanceToPharmacy(Pharmacy pharmacy, Position userPosition) {
    if (pharmacy.latitude < -90 ||
        pharmacy.latitude > 90 ||
        pharmacy.longitude < -180 ||
        pharmacy.longitude > 180 ||
        (pharmacy.latitude == 0 && pharmacy.longitude == 0)) {
      return null;
    }

    return Geolocator.distanceBetween(
      userPosition.latitude,
      userPosition.longitude,
      pharmacy.latitude,
      pharmacy.longitude,
    );
  }

  static List<Medicine> sortMedicinesByPharmacyDistance(
    List<Medicine> medicines,
    Position userPosition,
  ) {
    final sorted = List<Medicine>.of(medicines);
    sorted.sort((first, second) {
      final firstDistance =
          first.pharmacy == null
              ? null
              : _distanceToPharmacy(first.pharmacy!, userPosition);
      final secondDistance =
          second.pharmacy == null
              ? null
              : _distanceToPharmacy(second.pharmacy!, userPosition);

      if (firstDistance == null && secondDistance == null) return 0;
      if (firstDistance == null) return 1;
      if (secondDistance == null) return -1;
      return firstDistance.compareTo(secondDistance);
    });
    return sorted;
  }

  static List<Medicine> sortMedicinesByPrice(List<Medicine> medicines) {
    final sorted = List<Medicine>.of(medicines);
    sorted.sort((first, second) {
      final priceComparison = first.displayPrice.compareTo(second.displayPrice);
      return priceComparison != 0
          ? priceComparison
          : first.id.compareTo(second.id);
    });
    return sorted;
  }

  Future<List<Pharmacy>> getPharmaciesSortedByDistance() async {
    final pharmacies = await getAllPharmacies();
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return pharmacies;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return pharmacies;
      }

      final position = await Geolocator.getCurrentPosition();
      return sortPharmaciesByDistance(pharmacies, position);
    } catch (_) {
      return pharmacies;
    }
  }

  Future<List<Medicine>> searchMedicines(
    String query, {
    bool availableOnly = false,
    bool openOnly = false,
    bool lowestPrice = false,
    bool donationsOnly = false,
    bool clearanceOnly = false,
  }) async {
    final response = await dio.get(
      '/customer/medicines/search',
      queryParameters: {
        'search': query,
        if (availableOnly) 'available_only': 1,
        if (openOnly) 'open_only': 1,
        if (lowestPrice) 'lowest_price': 1,
        if (donationsOnly) 'donations_only': 1,
        if (clearanceOnly) 'clearance_only': 1,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final items = data['data'] as List<dynamic>;
    return items
        .map((json) => Medicine.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<Pharmacy>> getNearbyPharmacies(
    double latitude,
    double longitude,
  ) async {
    final response = await dio.get(
      '/customer/pharmacies/nearby',
      queryParameters: {'latitude': latitude, 'longitude': longitude},
    );

    final data = response.data as Map<String, dynamic>;
    final items = data['data'];
    if (items is! List) throw Exception('Invalid pharmacies response');
    return items
        .map(
          (json) => Pharmacy.fromJson(Map<String, dynamic>.from(json as Map)),
        )
        .toList();
  }

  Future<Pharmacy> getPharmacyDetails(int id) async {
    final response = await dio.get('/customer/pharmacies/$id');
    final data = response.data as Map<String, dynamic>;
    return Pharmacy.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<List<Medicine>> getPharmacyMedicines(int pharmacyId) async {
    final response = await dio.get(
      '/customer/pharmacies/$pharmacyId/medicines',
    );
    final data = response.data as Map<String, dynamic>;
    final items = data['data'];
    if (items is! List) throw Exception('Invalid pharmacies response');
    return items
        .map(
          (item) => Medicine.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<List<Medicine>> getMedicineAvailability(int medicineId) async {
    final response = await dio.get(
      '/customer/medicines/$medicineId/availability',
    );
    final data = response.data as Map<String, dynamic>;
    final items = data['data'];
    if (items is! List) {
      throw Exception('Invalid medicine availability response');
    }
    return items
        .map(
          (item) => Medicine.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<List<Pharmacy>> getAllPharmacies() async {
    final response = await dio.get('/customer/pharmacies');
    final data = response.data as Map<String, dynamic>;
    final items = data['data'] as List<dynamic>? ?? [];
    return items
        .map(
          (item) => Pharmacy.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<List<Offer>> getFeaturedOffers() async {
    final response = await dio.get('/customer/offers/featured');
    final data = response.data as Map<String, dynamic>;
    final items = data['data'] as List<dynamic>;
    return items
        .map((json) => Offer.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<Medicine>> getPopularMedicines() async {
    final response = await dio.get('/customer/medicines/popular');
    final data = response.data as Map<String, dynamic>;
    final items = data['data'];
    if (items is! List) throw Exception('Invalid popular medicines response');
    return items
        .map(
          (item) => Medicine.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<List<Medicine>> getDonationMedicines() =>
      searchMedicines('', availableOnly: true, donationsOnly: true);

  Future<List<Medicine>> getClearanceMedicines() =>
      searchMedicines('', availableOnly: true, clearanceOnly: true);

  Future<List<Pharmacy>> searchNearbyPharmacies(
    double latitude,
    double longitude,
    String query,
  ) async {
    final pharmacies = await getNearbyPharmacies(latitude, longitude);
    return pharmacies
        .where(
          (pharmacy) =>
              pharmacy.name.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  Future<List<Offer>> searchOffers(String query) async {
    final offers = await getFeaturedOffers();
    return offers.where((offer) {
      final searchText = query.toLowerCase();
      return offer.title.toLowerCase().contains(searchText) ||
          offer.description.toLowerCase().contains(searchText);
    }).toList();
  }

  Future<CustomerHomeData> getHomeData({
    double? latitude,
    double? longitude,
  }) async {
    final response = await dio.get(
      '/customer/home',
      queryParameters: {
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      },
    );

    final data = response.data as Map<String, dynamic>;
    return CustomerHomeData.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<List<Order>> getCustomerOrders() async {
    final response = await dio.get('/customer/orders');
    final data = response.data as Map<String, dynamic>;
    final items = data['data'] as List<dynamic>? ?? [];
    return items
        .map((json) => Order.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  Future<Order> createOrder(
    int pharmacyId,
    List<Map<String, dynamic>> items,
  ) async {
    final response = await dio.post(
      '/customer/orders',
      data: {'pharmacy_id': pharmacyId, 'items': items},
    );
    final data = response.data as Map<String, dynamic>;
    return Order.fromJson(Map<String, dynamic>.from(data['data'] as Map));
  }

  Future<Order> requestMedicine(int medicineId, {int quantity = 1}) async {
    final response = await dio.post(
      '/customer/medicines/$medicineId/request',
      data: {'quantity': quantity},
    );
    final data = response.data as Map<String, dynamic>;
    return Order.fromJson(Map<String, dynamic>.from(data['data'] as Map));
  }

  Future<Order> requestOffer(int offerId) async {
    final response = await dio.post('/customer/offers/$offerId/request');
    final data = response.data as Map<String, dynamic>;
    return Order.fromJson(Map<String, dynamic>.from(data['data'] as Map));
  }

  Future<void> cancelOrder(int id) async {
    await dio.patch('/customer/orders/$id/cancel');
  }

  Future<void> deleteOrder(int id) async {
    await dio.delete('/customer/orders/$id');
  }
}
