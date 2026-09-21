class Governorate {
  final int id;
  final int countryId;
  final String nameAr;
  final String nameEn;

  const Governorate({
    required this.id,
    required this.countryId,
    required this.nameAr,
    required this.nameEn,
  });

  factory Governorate.fromJson(Map<String, dynamic> json) {
    return Governorate(
      id: int.parse(json['id'].toString()),
      countryId: int.parse(json['country_id'].toString()),
      nameAr: json['name_ar']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
    );
  }
}

class Country {
  final int id;
  final String nameAr;
  final String nameEn;
  final String code;
  final List<Governorate> governorates;

  const Country({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.code,
    required this.governorates,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    final rawGovernorates = json['governorates'];
    return Country(
      id: int.parse(json['id'].toString()),
      nameAr: json['name_ar']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      governorates: rawGovernorates is List
          ? rawGovernorates
              .whereType<Map<String, dynamic>>()
              .map(Governorate.fromJson)
              .toList()
          : const [],
    );
  }
}
