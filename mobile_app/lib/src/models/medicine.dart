import 'pharmacy.dart';

class PharmacyPrice {
  final int pharmacyId;
  final String name;
  final double price;
  final int quantity;
  final bool isAvailable;

  const PharmacyPrice({
    required this.pharmacyId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.isAvailable,
  });

  factory PharmacyPrice.fromJson(Map<String, dynamic> json) {
    return PharmacyPrice(
      pharmacyId: int.tryParse(json['pharmacy_id']?.toString() ?? json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      quantity: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      isAvailable: json['is_available'] == true || json['is_available'] == 1,
    );
  }
}

class Medicine {
  final int id;
  final int? categoryId;
  final String name;
  final String description;
  final String? genericName;
  final String? manufacturer;
  final String? dosageForm;
  final String? strength;
  final bool requiresPrescription;
  final double price;
  final double finalPrice;
  final int discountPercentage;
  final int quantity;
  final bool isAvailable;
  final bool isDonation;
  final bool isNearExpiry;
  final bool isAdded;
  final String? expirationDate;
  final String? barcode;
  final String? imagePath;
  final String? categoryName;
  final List<PharmacyPrice> pharmacies;
  final Pharmacy? pharmacy;

  Medicine({
    required this.id,
    this.categoryId,
    required this.name,
    required this.description,
    this.genericName,
    this.manufacturer,
    this.dosageForm,
    this.strength,
    this.requiresPrescription = false,
    required this.price,
    this.finalPrice = 0,
    required this.discountPercentage,
    required this.quantity,
    this.isAvailable = true,
    this.isDonation = false,
    this.isNearExpiry = false,
    this.isAdded = true,
    this.imagePath,
    this.categoryName,
    this.expirationDate,
    this.barcode,
    this.pharmacies = const [],
    this.pharmacy,
  });

  double get displayPrice {
    if (pharmacies.isNotEmpty) {
      final availablePrices = pharmacies
          .where((pharmacy) => pharmacy.quantity > 0 && pharmacy.price > 0)
          .map((pharmacy) => pharmacy.price)
          .toList();

      if (availablePrices.isNotEmpty) {
        return availablePrices.reduce((a, b) => a < b ? a : b);
      }
    }

    return price;
  }

  factory Medicine.fromJson(Map<String, dynamic> json) {
    final nestedMedicine = json['medicine'] is Map
        ? Map<String, dynamic>.from(json['medicine'] as Map)
        : <String, dynamic>{};
    final source = <String, dynamic>{...nestedMedicine, ...json};
    final parsedPharmacies = (source['pharmacies'] as List? ?? [])
        .map((item) => PharmacyPrice.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
    final nestedPharmacy = json['pharmacy'] is Map
        ? Map<String, dynamic>.from(json['pharmacy'] as Map)
        : null;
    if (parsedPharmacies.isEmpty && nestedPharmacy != null) {
      parsedPharmacies.add(PharmacyPrice.fromJson({
        ...nestedPharmacy,
        'price': json['final_price'] ?? json['price'],
        'quantity': json['quantity'],
        'is_available': json['is_available'],
      }));
    }

    final lowestPharmacyPrice = parsedPharmacies.isNotEmpty
        ? parsedPharmacies
            .where((pharmacy) => pharmacy.quantity > 0 && pharmacy.price > 0)
            .map((pharmacy) => pharmacy.price)
            .fold<double>(double.infinity, (minValue, value) => value < minValue ? value : minValue)
        : double.infinity;

    final basePrice = lowestPharmacyPrice != double.infinity
        ? lowestPharmacyPrice
      : double.tryParse(source['price']?.toString() ?? '0') ?? 0.0;

    final discount = int.tryParse(source['discount_percentage']?.toString() ?? '0') ?? 0;
    final finalPriceValue = basePrice * (1 - (discount / 100));

    return Medicine(
      id: int.tryParse(source['id'].toString()) ?? 0,
      categoryId: int.tryParse(source['category_id']?.toString() ?? ''),
      name: source['name']?.toString() ?? '',
      description: source['description']?.toString() ?? '',
      genericName: source['generic_name']?.toString(),
      manufacturer: source['manufacturer']?.toString(),
      dosageForm: source['dosage_form']?.toString(),
      strength: source['strength']?.toString(),
      requiresPrescription:
          source['requires_prescription'] == true ||
          source['requires_prescription'] == 1 ||
          source['requires_prescription']?.toString() == '1',
      price: basePrice,
      finalPrice: finalPriceValue,
      discountPercentage: discount,
        quantity: int.tryParse(source['quantity']?.toString() ?? '0') ?? 0,
      isAvailable:
          source['is_available'] == null ||
          source['is_available'] == true ||
          source['is_available'] == 1,
          isDonation: source['is_donation'] == true || source['is_donation'] == 1 || source['is_donation']?.toString() == '1',
          isNearExpiry: source['is_near_expiry'] == true || source['is_near_expiry'] == 1 || source['is_near_expiry']?.toString() == '1',
      isAdded:
          json['is_added'] == null ||
          json['is_added'] == true ||
          json['is_added'] == 1 ||
          json['is_added']?.toString() == '1',
      imagePath: _imagePath(source),
      categoryName:
          json['category'] is Map ? json['category']['name']?.toString() : null,
      expirationDate: source['expiration_date']?.toString(),
      barcode: source['barcode']?.toString(),
      pharmacies: parsedPharmacies,
      pharmacy: nestedPharmacy == null ? null : Pharmacy.fromJson(nestedPharmacy),
    );
  }

  static String? _imagePath(Map<String, dynamic> json) {
    final value = json['image_path'] ?? json['image_url'] ?? json['image'];
    if (value == null) return null;
    final path = value.toString().trim();
    return path.isEmpty ? null : path;
  }
}
