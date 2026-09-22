import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService authService;
  final FlutterSecureStorage secureStorage;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  User? _user;
  User? get user => _user;
  bool get isOwner => _user?.role == 'pharmacy_owner';

  AuthProvider({required this.authService, required this.secureStorage});

  Future<void> initialize() async {
    final token = await authService.getToken();
    _isAuthenticated = token != null;

    if (_isAuthenticated) {
      try {
        _user = await authService.getProfile();
      } catch (_) {
        await authService.logout();
        _isAuthenticated = false;
        _user = null;
      }
    }

    notifyListeners();
  }

  Future<void> login(String identifier, String password) async {
    try {
      await authService.login(identifier, password);
      final user = await authService.getProfile();
      _user = user;
      _isAuthenticated = true;
      notifyListeners();
    } catch (error) {
      await authService.logout();
      _isAuthenticated = false;
      _user = null;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> register(
    String name,
    String email,
    String password, {
    required bool isOwner,
    String? phone,
    String? pharmacyName,
    String? pharmacyAddress,
    String? pharmacyPhone,
    String? pharmacyLicenseNumber,
    double? pharmacyLatitude,
    double? pharmacyLongitude,
  }) async {
    await authService.register(
      name,
      email,
      password,
      isOwner: isOwner,
      phone: phone,
      pharmacyName: pharmacyName,
      pharmacyAddress: pharmacyAddress,
      pharmacyPhone: pharmacyPhone,
      pharmacyLicenseNumber: pharmacyLicenseNumber,
      pharmacyLatitude: pharmacyLatitude,
      pharmacyLongitude: pharmacyLongitude,
    );
    _isAuthenticated = true;
    _user = await authService.getProfile();
    notifyListeners();
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    _user = await authService.updateProfile(updates);
    notifyListeners();
  }

  Future<void> uploadProfileAvatar(File file) async {
    _user = await authService.uploadProfileAvatar(file);
    notifyListeners();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String confirmation,
  }) async {
    await authService.changePassword(
      currentPassword: currentPassword,
      password: password,
      confirmation: confirmation,
    );
  }

  Future<void> logout() async {
    await authService.logout();
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }

  Future<void> handleUnauthorized() async {
    await authService.logout();
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    await authService.deleteAccount();
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }
}
