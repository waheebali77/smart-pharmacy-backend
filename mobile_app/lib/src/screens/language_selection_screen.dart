import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'country_selection_screen.dart';
import '../theme/onboarding_colors.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final Future<void> Function() onContinue;

  const LanguageSelectionScreen({super.key, required this.onContinue});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedLanguage = 'ar';
  bool _continuing = false;

  Future<void> _continue() async {
    if (_continuing) return;
    setState(() => _continuing = true);
    try {
      await context.setLocale(Locale(_selectedLanguage));
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CountrySelectionScreen(onContinue: widget.onContinue),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to change language: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _continuing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFEFD),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
          child: Column(
            children: [
              const SizedBox(height: 22),
              const _LanguageIllustration(),
              const SizedBox(height: 20),
              const Text(
                'اختر اللغة',
                textDirection: ui.TextDirection.rtl,
                style: TextStyle(
                  color: onboardingPrimaryColor,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'الرجاء اختيار اللغة المفضلة لديك',
                textDirection: ui.TextDirection.rtl,
                style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 14),
              ),
              const SizedBox(height: 26),
              const Align(
                alignment: AlignmentDirectional.center,
                child: Text(
                  'Select Language',
                  style: TextStyle(
                    color: Color(0xFF20354A),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: AlignmentDirectional.center,
                child: Text(
                  'Please choose your preferred language',
                  style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 15),
                ),
              ),
              const SizedBox(height: 18),
              _LanguageOption(
                title: 'العربية',
                subtitle: 'Arabic',
                value: 'ar',
                selected: _selectedLanguage == 'ar',
                onTap: () => setState(() => _selectedLanguage = 'ar'),
              ),
              const SizedBox(height: 10),
              _LanguageOption(
                title: 'English',
                subtitle: 'English',
                value: 'en',
                selected: _selectedLanguage == 'en',
                onTap: () => setState(() => _selectedLanguage = 'en'),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _continuing ? null : _continue,
                  style: FilledButton.styleFrom(
                    backgroundColor: onboardingPrimaryColor,
                    disabledBackgroundColor: onboardingPrimaryDisabledColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: _continuing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'التالي',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 14),
                            Directionality(
                              textDirection: ui.TextDirection.ltr,
                              child: Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? onboardingPrimaryLightColor : Colors.white,
          border: Border.all(
            color: selected
                ? onboardingPrimaryColor
                : const Color(0xFFE4ECEC),
            width: selected ? 1.3 : 1,
          ),
          borderRadius: BorderRadius.circular(11),
          boxShadow: selected
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.035),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    textDirection: value == 'ar'
                        ? ui.TextDirection.rtl
                        : ui.TextDirection.ltr,
                    style: const TextStyle(
                      color: Color(0xFF20354A),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.blueGrey.shade400,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected
                  ? onboardingPrimaryColor
                  : const Color(0xFFB8C9D1),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageIllustration extends StatelessWidget {
  const _LanguageIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 142,
      height: 112,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 12,
            top: 20,
            child: Transform.rotate(
              angle: -0.16,
              child: Container(
                width: 59,
                height: 66,
                decoration: BoxDecoration(
                  color: onboardingPrimaryColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  'ع',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 12,
            top: 35,
            child: Transform.rotate(
              angle: 0.13,
              child: Container(
                width: 59,
                height: 66,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDF6F0),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFB7E9DE)),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'A',
                  style: TextStyle(
                    color: onboardingPrimaryColor,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          const Positioned(
            top: 2,
            right: 20,
            child: Text(
              '✦',
              style: TextStyle(
                color: onboardingPrimaryColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Positioned(
            bottom: 2,
            left: 27,
            child: Text(
              '⁙',
              style: TextStyle(
                color: onboardingPrimaryColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
