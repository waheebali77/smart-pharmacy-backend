import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final email = _emailController.text.trim();
      await context.read<AuthProvider>().authService.requestPasswordReset(
        email,
      );
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ResetPasswordScreen(email: email)),
      );
    } catch (error) {
      if (mounted) setState(() => _error = _friendlyError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(Object error) {
    final text = error.toString().replaceFirst('Exception: ', '').trim();
    return text.isEmpty ? 'تعذر إرسال رمز التحقق، حاول مرة أخرى' : text;
  }

  @override
  Widget build(BuildContext context) {
    return _ResetScaffold(
      title: 'نسيت كلمة المرور',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _ResetIcon(icon: Icons.lock_reset_rounded),
            const SizedBox(height: 22),
            const Text(
              'استعادة كلمة المرور',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            const Text(
              'أدخل بريدك الإلكتروني وسنرسل لك رمز التحقق.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF718096), height: 1.6),
            ),
            const SizedBox(height: 28),
            _EmailField(
              controller: _emailController,
              onChanged: (_) => setState(() => _error = null),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              _ResetError(message: _error!),
            ],
            const SizedBox(height: 24),
            _PrimaryButton(
              label: 'التالي',
              loading: _loading,
              onPressed: _requestOtp,
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed:
                  () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
              child: const Text('تذكرت كلمة المرور؟ تسجيل الدخول'),
            ),
          ],
        ),
      ),
    );
  }
}

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, required this.email});
  final String email;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otp = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _otp.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.authService.resetPasswordWithOtp(
        email: widget.email,
        otp: _otp.text.trim(),
        password: _password.text,
        confirmation: _confirmation.text,
      );
      await authProvider.logout();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تغيير كلمة المرور بنجاح')),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => LoginScreen(initialIdentifier: widget.email),
        ),
        (route) => false,
      );
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ResetScaffold(
      title: 'التحقق وإعادة تعيين كلمة المرور',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _ResetIcon(icon: Icons.password_rounded),
            const SizedBox(height: 22),
            const Text(
              'تحقق من الرمز وأنشئ كلمة مرور جديدة',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            const Text(
              'أدخل رمز التحقق المرسل إلى بريدك الإلكتروني ثم كلمة المرور الجديدة.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF718096)),
            ),
            const SizedBox(height: 28),
            TextFormField(
              controller: _otp,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if ((value ?? '').length != 6) {
                  return 'أدخل رمز التحقق المكون من 6 أرقام';
                }
                return null;
              },
              decoration: _inputDecoration(
                'رمز التحقق المكون من 6 أرقام',
                Icons.sms_outlined,
              ).copyWith(counterText: ''),
            ),
            const SizedBox(height: 16),
            _PasswordField(
              controller: _password,
              label: 'كلمة المرور الجديدة',
              obscure: _obscurePassword,
              onToggle:
                  () => setState(() => _obscurePassword = !_obscurePassword),
              onChanged: (_) => setState(() => _error = null),
            ),
            const SizedBox(height: 8),
            const Text(
              '✓ كلمة مرور قوية: 8 أحرف أو أكثر',
              style: TextStyle(color: Color(0xFF199473), fontSize: 13),
            ),
            const SizedBox(height: 16),
            _PasswordField(
              controller: _confirmation,
              label: 'تأكيد كلمة المرور الجديدة',
              obscure: _obscureConfirmation,
              onToggle:
                  () => setState(
                    () => _obscureConfirmation = !_obscureConfirmation,
                  ),
              validator: (value) {
                if ((value ?? '').length < 8) {
                  return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
                }
                if (value != _password.text) {
                  return 'كلمتا المرور غير متطابقتين';
                }
                return null;
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              _ResetError(message: _error!),
            ],
            const SizedBox(height: 24),
            _PrimaryButton(
              label: 'حفظ كلمة المرور',
              loading: _loading,
              onPressed: _reset,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResetScaffold extends StatelessWidget {
  const _ResetScaffold({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FAFC),
        appBar: AppBar(
          title: Text(title),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: const Color(0xFF173B4D),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _ResetIcon extends StatelessWidget {
  const _ResetIcon({required this.icon});
  final IconData icon;
  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: 36,
    backgroundColor: const Color(0xFFE5F0FF),
    child: Icon(icon, size: 36, color: const Color(0xFF2675D8)),
  );
}

class _EmailField extends StatelessWidget {
  const _EmailField({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: TextInputType.emailAddress,
    onChanged: onChanged,
    validator: (value) {
      final email = value?.trim() ?? '';
      if (email.isEmpty) {
        return 'أدخل البريد الإلكتروني';
      }
      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
        return 'أدخل بريدًا إلكترونيًا صحيحًا';
      }
      return null;
    },
    decoration: _inputDecoration(
      'example@email.com',
      Icons.email_outlined,
    ).copyWith(
      suffixIcon: IconButton(
        icon: const Icon(Icons.clear),
        onPressed: controller.clear,
      ),
    ),
  );
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggle,
    this.onChanged,
    this.validator,
  });
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    obscureText: obscure,
    onChanged: onChanged,
    validator:
        validator ??
        (value) {
          if ((value ?? '').length < 8) {
            return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
          }
          return null;
        },
    decoration: _inputDecoration(label, Icons.lock_outline).copyWith(
      suffixIcon: IconButton(
        icon: Icon(
          obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        ),
        onPressed: onToggle,
      ),
    ),
  );
}

InputDecoration _inputDecoration(String hint, IconData icon) => InputDecoration(
  hintText: hint,
  prefixIcon: Icon(icon, color: const Color(0xFF2675D8)),
  filled: true,
  fillColor: Colors.white,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide.none,
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: Color(0xFFDCE7F5)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: Color(0xFF2675D8), width: 1.5),
  ),
);

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });
  final String label;
  final bool loading;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 52,
    child: ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2675D8),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child:
          loading
              ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
              : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
    ),
  );
}

class _ResetError extends StatelessWidget {
  const _ResetError({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF1F2),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFFECACA)),
    ),
    child: Text(
      message,
      style: const TextStyle(color: Color(0xFFB42318), fontSize: 13),
    ),
  );
}
