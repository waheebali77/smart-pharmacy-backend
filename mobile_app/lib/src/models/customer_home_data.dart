import 'category.dart';
import 'medicine.dart';
import 'offer.dart';
import 'pharmacy.dart';

class CustomerHomeData {
  final List<Offer> featuredOffers;
  final List<Category> categories;
  final List<Medicine> popularMedicines;
  final List<Pharmacy> nearbyPharmacies;

  CustomerHomeData({
    required this.featuredOffers,
    required this.categories,
    required this.popularMedicines,
    required this.nearbyPharmacies,
  });

  factory CustomerHomeData.fromJson(Map<String, dynamic> json) {
    return CustomerHomeData(
      featuredOffers: (json['featured_offers'] as List<dynamic>?)
              ?.map((item) => Offer.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      categories: (json['categories'] as List<dynamic>?)
              ?.map((item) => Category.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      popularMedicines: (json['popular_medicines'] as List<dynamic>?)
              ?.map((item) => Medicine.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      nearbyPharmacies: (json['nearby_pharmacies'] as List<dynamic>?)
              ?.map((item) => Pharmacy.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
