import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'customer_home_screen.dart';
import 'forgot_password_screen.dart';
import 'owner_home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.initialIdentifier});

  final String? initialIdentifier;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController? _identifierController;
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  TextEditingController get _loginIdentifierController =>
      _identifierController ??= TextEditingController(
        text: widget.initialIdentifier ?? '',
      );

  @override
  void initState() {
    super.initState();
    _identifierController = TextEditingController(
      text: widget.initialIdentifier ?? '',
    );
  }

  @override
  void dispose() {
    _identifierController?.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final authProvider = context.read<AuthProvider>();
      final identifier = _loginIdentifierController.text.trim();
      debugPrint(
        'Login request identifier type: '
        '${identifier.contains('@') ? 'email' : 'phone'}',
      );
      await authProvider.login(identifier, _passwordController.text);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (_) =>
                  authProvider.isOwner
                      ? const OwnerHomeScreen()
                      : const CustomerHomeScreen(),
        ),
      );
    } catch (error) {
      debugPrint('Login failed: ${error.runtimeType}');
      if (!mounted) return;
      setState(() => _errorMessage = _loginErrorMessage(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _loginErrorMessage(Object error) {
    if (error is DioException && error.response?.statusCode == 401) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    }

    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] is String) {
        final message = data['message'].toString().trim();
        if (message.isNotEmpty) return message;
      }
    }

    final message = error.toString().replaceFirst('Exception: ', '').trim();
    final normalized = message.toLowerCase();
    if (normalized.contains('credential') ||
        normalized.contains('unauthorized') ||
        normalized.contains('authentication failed')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    }

    return 'تعذر تسجيل الدخول. يرجى التحقق من بياناتك والمحاولة مرة أخرى';
  }

  void _clearLoginError(String _) {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  void _open(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF08A889);

    return Scaffold(
      backgroundColor: const Color(0xFFFCFEFD),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 58, 16, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/7.png',
                        width: 110,
                        height: 110,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'دوائي',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF087A68),
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      'Dawaei',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF76CDBB),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'مرحبًا بك مجددًا',
                      textAlign: TextAlign.center,
                      textDirection: ui.TextDirection.rtl,
                      style: TextStyle(
                        color: Color(0xFF173B4D),
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'سعيد بعودتك، قم بتسجيل الدخول للمتابعة',
                      textAlign: TextAlign.center,
                      textDirection: ui.TextDirection.rtl,
                      style: TextStyle(color: Color(0xFF6B8790), fontSize: 18),
                    ),
                    const SizedBox(height: 25),
                    _StyledTextField(
                      controller: _loginIdentifierController,
                      hintText: 'البريد الإلكتروني أو رقم الهاتف',
                      keyboardType: TextInputType.text,
                      icon: Icons.person_outline_rounded,
                      validator:
                          (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Please enter your email'
                                  : null,
                      onChanged: _clearLoginError,
                    ),
                    const SizedBox(height: 10),
                    _StyledTextField(
                      controller: _passwordController,
                      hintText: 'كلمة المرور',
                      obscureText: true,
                      icon: Icons.lock_outline_rounded,
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Please enter your password'
                                  : null,
                      onChanged: _clearLoginError,
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 8),
                      _LoginErrorMessage(message: _errorMessage!),
                    ],
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton(
                        onPressed: () => _open(const ForgotPasswordScreen()),
                        style: TextButton.styleFrom(
                          foregroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: Text(
                          'forgot_password'.tr(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'login'.tr(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Directionality(
                                      textDirection: ui.TextDirection.ltr,
                                      child: Icon(
                                        Icons.arrow_forward,
                                        size: 21,
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: Color(0xFFE3ECEB)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'أو',
                            style: TextStyle(
                              color: Colors.blueGrey.shade400,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(color: Color(0xFFE3ECEB)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: null,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: primaryColor),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const _GoogleMark(),
                          const SizedBox(width: 10),
                          const Text(
                            'تسجيل الدخول عبر Google',
                            style: TextStyle(
                              color: Color(0xFF087A68),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => _open(const RegisterScreen()),
                      child: Text.rich(
                        TextSpan(
                          text: 'ليس لديك حساب؟ ',
                          style: TextStyle(
                            color: Colors.blueGrey.shade500,
                            fontSize: 15,
                          ),
                          children: [
                            TextSpan(
                              text: 'إنشاء حساب جديد',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 4,
              left: 4,
              child: Directionality(
                textDirection: ui.TextDirection.ltr,
                child: IconButton(
                  tooltip: 'رجوع',
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF455A64),
                    size: 28,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  const _StyledTextField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      textDirection: ui.TextDirection.rtl,
      style: const TextStyle(color: Color(0xFF1F2937), fontSize: 16),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF8AA0A6), fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF47636D), size: 21),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDCE7E8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF08A889), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
        ),
      ),
    );
  }
}

class _LoginErrorMessage extends StatelessWidget {
  const _LoginErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.right,
        textDirection: ui.TextDirection.rtl,
        style: const TextStyle(
          color: Color(0xFFB42318),
          fontSize: 13,
          height: 1.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
        color: Color(0xFF4285F4),
        fontSize: 21,
        fontWeight: FontWeight.w800,
        fontFamily: 'Arial',
      ),
    );
  }
}
