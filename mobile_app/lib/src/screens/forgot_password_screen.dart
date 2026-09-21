import 'dart:async';

import 'package:flutter/material.dart';
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
  final _phoneController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final phone = _phoneController.text.trim();
      await context.read<AuthProvider>().authService.requestOtpReset(phone);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => OtpVerificationScreen(phone: phone)),
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
              'أدخل رقم هاتفك أدناه وسنساعدك على استعادة حسابك.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF718096), height: 1.6),
            ),
            const SizedBox(height: 28),
            _PhoneField(
              controller: _phoneController,
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

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key, required this.phone});
  final String phone;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  final _otpFocusNode = FocusNode();
  Timer? _countdownTimer;
  int _secondsRemaining = 45;
  bool _loading = false;
  bool _resending = false;
  bool _verificationStarted = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _otpController.addListener(_onOtpChanged);
    _startCountdown();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _otpFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _otpController.removeListener(_onOtpChanged);
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _secondsRemaining = 45);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  void _onOtpChanged() {
    if (!mounted) return;
    setState(() => _error = null);
    if (_otpController.text.length == 6 && !_verificationStarted && !_loading) {
      _verificationStarted = true;
      _verify();
    }
  }

  Future<void> _verify() async {
    if (_otpController.text.trim().length != 6) {
      setState(() => _error = 'أدخل رمز التحقق المكون من 6 أرقام');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final payload = await context
          .read<AuthProvider>()
          .authService
          .verifyOtpReset(phone: widget.phone, otp: _otpController.text.trim());
      final token =
          payload['token']?.toString() ??
          (payload['data'] is Map
              ? (payload['data'] as Map)['token']?.toString()
              : null);
      if (token == null || token.isEmpty) {
        throw Exception('لم يتم استلام رمز التحقق من الخادم');
      }
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (_) => ResetPasswordScreen(phone: widget.phone, token: token),
        ),
      );
    } catch (error) {
      if (mounted) {
        _verificationStarted = false;
        setState(
          () => _error = error.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resendCode() async {
    if (_secondsRemaining > 0 || _resending) return;
    setState(() {
      _resending = true;
      _error = null;
    });
    try {
      await context.read<AuthProvider>().authService.requestOtpReset(
        widget.phone,
      );
      _otpController.clear();
      _verificationStarted = false;
      _startCountdown();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال رمز جديد إلى هاتفك')),
      );
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  String get _countdownLabel {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return _ResetScaffold(
      title: 'أدخل رمز التحقق',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _ResetIcon(icon: Icons.sms_outlined),
          const SizedBox(height: 22),
          const Text(
            'أدخل رمز التحقق',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            'أرسلنا رمزًا إلى ${widget.phone}. أدخله هنا لتأكيد حسابك.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF718096), height: 1.6),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () => _otpFocusNode.requestFocus(),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    final value = _otpController.text;
                    final hasDigit = index < value.length;
                    return Container(
                      width: 45,
                      height: 52,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              index == value.length
                                  ? const Color(0xFF2675D8)
                                  : const Color(0xFFDCE7F5),
                          width: index == value.length ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        hasDigit ? value[index] : '',
                        style: const TextStyle(
                          color: Color(0xFF173B4D),
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }),
                ),
                Opacity(
                  opacity: 0,
                  child: SizedBox(
                    width: 1,
                    height: 1,
                    child: TextField(
                      controller: _otpController,
                      focusNode: _otpFocusNode,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      maxLength: 6,
                      showCursor: false,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        counterText: '',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            _ResetError(message: _error!),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _secondsRemaining > 0
                    ? 'إعادة إرسال الرمز خلال $_countdownLabel'
                    : 'لم يصلك الرمز؟',
                style: const TextStyle(color: Color(0xFF718096)),
              ),
              if (_secondsRemaining == 0)
                TextButton(
                  onPressed: _resending ? null : _resendCode,
                  child: Text(_resending ? 'جارٍ الإرسال...' : 'إعادة إرسال'),
                ),
            ],
          ),
          const SizedBox(height: 22),
          _PrimaryButton(
            label: 'تأكيد الرمز',
            loading: _loading,
            onPressed: _verify,
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('تغيير رقم الهاتف'),
          ),
        ],
      ),
    );
  }
}

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.phone,
    required this.token,
  });
  final String phone;
  final String token;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
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
      await authProvider.authService.resetPasswordPhone(
        phone: widget.phone,
        token: widget.token,
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
          builder: (_) => LoginScreen(initialIdentifier: widget.phone),
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
      title: 'إنشاء كلمة مرور جديدة',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _ResetIcon(icon: Icons.password_rounded),
            const SizedBox(height: 22),
            const Text(
              'رائع!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            const Text(
              'أنشئ كلمة مرور جديدة وآمنة لحسابك.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF718096)),
            ),
            const SizedBox(height: 28),
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

class _PhoneField extends StatelessWidget {
  const _PhoneField({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: TextInputType.phone,
    onChanged: onChanged,
    validator: (value) {
      final phone = value?.trim() ?? '';
      if (phone.isEmpty) return 'أدخل رقم الهاتف';
      if (!RegExp(r'^\+?[0-9]{9,15}$').hasMatch(phone))
        return 'أدخل رقم هاتف صحيح';
      return null;
    },
    decoration: _inputDecoration('012345678', Icons.phone_outlined).copyWith(
      prefixText: '🇾🇪 +967  ',
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
  });
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;
  final ValueChanged<String>? onChanged;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    obscureText: obscure,
    onChanged: onChanged,
    validator: (value) {
      if ((value ?? '').length < 8)
        return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
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
