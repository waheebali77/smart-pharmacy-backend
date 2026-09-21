import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'customer_home_screen.dart';
import 'owner_home_screen.dart';
import 'pharmacy_location_picker_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _pharmacyNameController = TextEditingController();
  final _pharmacyAddressController = TextEditingController();
  final _pharmacyPhoneController = TextEditingController();
  final _pharmacyLicenseController = TextEditingController();
  bool _isOwner = false;
  bool _roleSelected = false;
  bool _isLoading = false;
  double? _pharmacyLatitude;
  double? _pharmacyLongitude;

  @override
  void dispose() {
    for (final controller in [
      _nameController,
      _emailController,
      _phoneController,
      _passwordController,
      _confirmPasswordController,
      _pharmacyNameController,
      _pharmacyAddressController,
      _pharmacyPhoneController,
      _pharmacyLicenseController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isOwner && (_pharmacyLatitude == null || _pharmacyLongitude == null)) {
      await _showRegistrationMessage(
        'يرجى تحديد موقع الصيدلية قبل إنشاء الحساب.',
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
        phone: _isOwner ? null : _phoneController.text,
        isOwner: _isOwner,
        pharmacyName: _pharmacyNameController.text,
        pharmacyAddress: _pharmacyAddressController.text,
        pharmacyPhone: _pharmacyPhoneController.text,
        pharmacyLicenseNumber: _pharmacyLicenseController.text,
        pharmacyLatitude: _pharmacyLatitude,
        pharmacyLongitude: _pharmacyLongitude,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (_) =>
                  _isOwner
                      ? const OwnerHomeScreen()
                      : const CustomerHomeScreen(),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      await _showRegistrationError(error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickPharmacyLocation() async {
    final selectedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder:
            (_) => PharmacyLocationPickerScreen(
              initialLocation:
                  _pharmacyLatitude != null && _pharmacyLongitude != null
                      ? LatLng(_pharmacyLatitude!, _pharmacyLongitude!)
                      : null,
            ),
      ),
    );
    if (selectedLocation != null && mounted) {
      setState(() {
        _pharmacyLatitude = selectedLocation.latitude;
        _pharmacyLongitude = selectedLocation.longitude;
      });
    }
  }

  Future<void> _showRegistrationMessage(String message) async {
    await showDialog<void>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            content: Text(message, textDirection: TextDirection.rtl),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('موافق'),
              ),
            ],
          ),
    );
  }

  Future<void> _showRegistrationError(Object error) async {
    final serverMessage = _extractRegistrationMessage(error);
    final message =
        serverMessage ??
        'تعذر إنشاء الحساب. يرجى التأكد من صحة البيانات والمحاولة مرة أخرى.';

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => AlertDialog(
            title: const Row(
              textDirection: TextDirection.rtl,
              children: [
                Icon(Icons.error_outline, color: Colors.redAccent),
                SizedBox(width: 8),
                Text('تعذر إنشاء الحساب'),
              ],
            ),
            content: Text(message, textDirection: TextDirection.rtl),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('موافق'),
              ),
            ],
          ),
    );
  }

  String? _extractRegistrationMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final serverMessage = data['message'];
        if (serverMessage is String && serverMessage.trim().isNotEmpty) {
          return serverMessage.trim();
        }

        final errors = data['errors'];
        if (errors is Map) {
          for (final value in errors.values) {
            if (value is List && value.isNotEmpty) {
              return value.first.toString();
            }
            if (value is String && value.trim().isNotEmpty) {
              return value.trim();
            }
          }
        }
      }
    }

    final exceptionMessage =
        error.toString().replaceFirst('Exception: ', '').trim();
    if (exceptionMessage.isNotEmpty &&
        !exceptionMessage.contains(
          'Authentication response did not include a token',
        )) {
      return exceptionMessage;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return _roleSelected ? _buildRegistrationForm() : _buildRoleSelection();
  }

  Widget _buildRoleSelection() {
    const primary = Color(0xFF079C83);
    return Scaffold(
      backgroundColor: const Color(0xFFFCFEFD),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _RegisterWavePainter()),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 86),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Directionality(
                        textDirection: ui.TextDirection.ltr,
                        child: Icon(Icons.arrow_back, size: 25),
                      ),
                      color: const Color(0xFF20354A),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'إنشاء حساب جديد',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: Color(0xFF173B4D),
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'اختر نوع الحساب الذي يناسبك',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(color: Color(0xFF78909C), fontSize: 20),
                  ),
                  const SizedBox(height: 32),
                  _RoleCard(
                    selected: !_isOwner,
                    icon: Icons.person_outline_rounded,
                    title: 'عميل',
                    description: 'تصفح الأدوية، أضفها إلى السلة وتابع طلباتك',
                    onTap:
                        _isLoading
                            ? null
                            : () => setState(() => _isOwner = false),
                  ),
                  const SizedBox(height: 20),
                  _RoleCard(
                    selected: _isOwner,
                    icon: Icons.storefront_outlined,
                    title: 'صاحب صيدلية',
                    description: 'أدر صيدليتك، أضف الأدوية وتابع الطلبات',
                    onTap:
                        _isLoading
                            ? null
                            : () => setState(() => _isOwner = true),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 18,
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () => setState(() => _roleSelected = true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'التالي',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 12),
                      Directionality(
                        textDirection: ui.TextDirection.ltr,
                        child: Icon(Icons.arrow_forward, size: 21),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Directionality(
          textDirection: ui.TextDirection.ltr,
          child: AppBar(
            title: const Text(
              'إنشاء الحساب',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              textDirection: ui.TextDirection.rtl,
            ),
            automaticallyImplyLeading: false,
            leading: IconButton(
              onPressed: () => setState(() => _roleSelected = false),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _field(_nameController, 'الاسم', 'Please enter your name'),
                _field(
                  _emailController,
                  'البريد الإلكتروني',
                  'Please enter your email',
                  keyboardType: TextInputType.emailAddress,
                ),
                if (!_isOwner)
                  _field(
                    _phoneController,
                    'رقم الهاتف',
                    'Please enter your phone number',
                    keyboardType: TextInputType.phone,
                  ),
                _field(
                  _passwordController,
                  'كلمة المرور',
                  'Please enter your password',
                  obscureText: true,
                  password: true,
                ),
                _field(
                  _confirmPasswordController,
                  'تأكيد كلمة المرور',
                  'Passwords do not match',
                  obscureText: true,
                  validator:
                      (value) =>
                          value != _passwordController.text
                              ? 'Passwords do not match'
                              : null,
                ),
                if (_isOwner) ...[
                  _ownerField(_pharmacyNameController, 'اسم الصيدلية'),
                  _ownerField(_pharmacyAddressController, 'عنوان الصيدلية'),
                  _ownerField(_pharmacyPhoneController, 'هاتف الصيدلية'),
                  _ownerField(
                    _pharmacyLicenseController,
                    'رقم ترخيص الصيدلية (اختياري)',
                    required: false,
                  ),
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _pickPharmacyLocation,
                    icon: const Icon(Icons.location_on_outlined),
                    label: Text(
                      _pharmacyLatitude == null
                          ? 'تحديد موقع الصيدلية على الخريطة'
                          : 'تم تحديد موقع الصيدلية',
                    ),
                  ),
                  if (_pharmacyLatitude != null && _pharmacyLongitude != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'خط العرض: ${_pharmacyLatitude!.toStringAsFixed(6)}\n'
                        'خط الطول: ${_pharmacyLongitude!.toStringAsFixed(6)}',
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                ],
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child:
                      _isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                            'إنشاء الحساب',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    String requiredMessage, {
    TextInputType? keyboardType,
    bool obscureText = false,
    bool password = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(labelText: label),
        validator:
            validator ??
            (value) {
              if (value == null || value.trim().isEmpty) return requiredMessage;
              if (password && value.length < 8) {
                return 'Password must be at least 8 characters long';
              }
              return null;
            },
      ),
    );
  }

  Widget _ownerField(
    TextEditingController controller,
    String label, {
    bool required = true,
  }) {
    return _field(
      controller,
      label,
      'Please enter $label',
      validator:
          required
              ? (value) =>
                  value == null || value.trim().isEmpty
                      ? 'Please enter $label'
                      : null
              : null,
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF19B899) : const Color(0xFFDCE7E8),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF079C83), size: 45),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      color: Color(0xFF173B4D),
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    description,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      color: Color(0xFF78909C),
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color:
                  selected ? const Color(0xFF079C83) : const Color(0xFFB8C9D1),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _RegisterWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFE7FAF6);
    final path =
        Path()
          ..moveTo(0, size.height - 80)
          ..quadraticBezierTo(
            size.width * .25,
            size.height - 125,
            size.width * .52,
            size.height - 82,
          )
          ..quadraticBezierTo(
            size.width * .78,
            size.height - 40,
            size.width,
            size.height - 92,
          )
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height)
          ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
