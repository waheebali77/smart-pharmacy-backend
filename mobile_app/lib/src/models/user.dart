import 'pharmacy.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? avatarUrl;
  final String? location;
  final DateTime? trialEndsAt;
  final bool isActive;
  final Pharmacy? pharmacy;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.avatarUrl,
    this.location,
    this.trialEndsAt,
    this.isActive = true,
    this.pharmacy,
  });

  String? get imageUrl => avatarUrl;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone']?.toString(),
      role: json['role'] as String? ?? 'customer',
      avatarUrl: json['avatar_url']?.toString(),
      location: (json['location'] ?? json['address'])?.toString(),
        trialEndsAt: json['trial_ends_at'] != null
          ? DateTime.tryParse(json['trial_ends_at'].toString())
          : null,
        isActive: json['is_active'] != false,
      pharmacy: json['pharmacy'] != null
          ? Pharmacy.fromJson(json['pharmacy'] as Map<String, dynamic>)
          : null,
    );
  }
}
