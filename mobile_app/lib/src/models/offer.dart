class Offer {
  final int id;
  final String title;
  final String description;
  final int discountPercentage;
  final String? startDate;
  final String? endDate;
  final String? imagePath;

  Offer({
    required this.id,
    required this.title,
    required this.description,
    this.discountPercentage = 0,
    this.startDate,
    this.endDate,
    this.imagePath,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      discountPercentage:
          int.tryParse(json['discount_percentage'].toString()) ?? 0,
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      imagePath: json['image_path'] as String?,
    );
  }
}
