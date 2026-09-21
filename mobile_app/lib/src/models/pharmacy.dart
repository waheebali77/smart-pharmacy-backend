import 'medicine.dart';
import 'offer.dart';

class Pharmacy {
  final int id;
  final String name;
  final String address;
  final String phone;
  final double latitude;
  final double longitude;
  final String status;
  final bool isManuallyClosed;
  final double? distance;
  final double? rating;
  final String? imagePath;
  final String? logoPath;
  final String? image;
  final String? openingTime;
  final String? closingTime;
  final List<Medicine>? medicines;
  final List<Offer>? offers;

  Pharmacy({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.status,
    this.isManuallyClosed = false,
    this.distance,
    this.rating,
    this.imagePath,
    this.logoPath,
    this.image,
    this.openingTime,
    this.closingTime,
    this.medicines,
    this.offers,
  });

  String? get imageUrl => imagePath ?? logoPath ?? image;

  Pharmacy copyWith({
    String? status,
    bool? isManuallyClosed,
  }) {
    return Pharmacy(
      id: id,
      name: name,
      address: address,
      phone: phone,
      latitude: latitude,
      longitude: longitude,
      status: status ?? this.status,
      isManuallyClosed: isManuallyClosed ?? this.isManuallyClosed,
      distance: distance,
      rating: rating,
      imagePath: imagePath,
      logoPath: logoPath,
      image: image,
      openingTime: openingTime,
      closingTime: closingTime,
      medicines: medicines,
      offers: offers,
    );
  }

  static String? _readImageValue(Map<String, dynamic> json) {
    final images = json['images'];
    final firstImage = images is List && images.isNotEmpty ? images.first : null;
    final value = json['image_url'] ??
      json['image_path'] ??
        json['logo_path'] ??
        json['image_url'] ??
        json['image'] ??
        json['logo'] ??
      json['pharmacy_image'] ??
      firstImage;

    if (value == null) return null;

    final path = value.toString().trim();
    return path.isEmpty ? null : path;
  }

  factory Pharmacy.fromJson(Map<String, dynamic> json) {
    final imageValue = _readImageValue(json);

    return Pharmacy(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      status: json['status']?.toString() ?? 'unknown',
      isManuallyClosed: json['is_manually_closed'] == true || json['is_manually_closed'] == 1,
        imagePath: imageValue,
        logoPath: imageValue,
        image: imageValue,
      openingTime: (json['opening_time'] ?? json['openingTime'])?.toString(),
      closingTime: (json['closing_time'] ?? json['closingTime'])?.toString(),
      medicines:
          (json['medicines'] as List<dynamic>?)
              ?.map((item) => Medicine.fromJson(item as Map<String, dynamic>))
              .toList(),
      offers:
          (json['offers'] as List<dynamic>?)
              ?.map((item) => Offer.fromJson(item as Map<String, dynamic>))
              .toList(),
      distance: json['distance'] != null ? double.tryParse(json['distance'].toString()) : null,
      rating: json['rating'] != null ? double.tryParse(json['rating'].toString()) : null,
    );
  }
}
