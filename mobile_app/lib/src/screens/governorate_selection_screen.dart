import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/location.dart';
import '../theme/onboarding_colors.dart';

class GovernorateSelectionScreen extends StatefulWidget {
  final Country country;
  final Future<void> Function() onContinue;

  const GovernorateSelectionScreen({
    super.key,
    required this.country,
    required this.onContinue,
  });

  @override
  State<GovernorateSelectionScreen> createState() =>
      _GovernorateSelectionScreenState();
}

class _GovernorateSelectionScreenState
    extends State<GovernorateSelectionScreen> {
  Governorate? _selectedGovernorate;
  bool _continuing = false;

  Future<void> _continue() async {
    if (_continuing || _selectedGovernorate == null) return;
    setState(() => _continuing = true);
    try {
      await widget.onContinue();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر المتابعة: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _continuing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final governorates = widget.country.governorates;
    return Scaffold(
      backgroundColor: const Color(0xFFFCFEFD),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Directionality(
                    textDirection: ui.TextDirection.ltr,
                    child: Icon(Icons.arrow_back, size: 23),
                  ),
                  color: const Color(0xFF20354A),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              const SizedBox(height: 2),
              const Icon(Icons.map_outlined, size: 100, color: onboardingPrimaryColor),
              const SizedBox(height: 10),
              const Text(
                'اختر المحافظة',
                textDirection: ui.TextDirection.rtl,
                style: TextStyle(
                  color: onboardingPrimaryColor,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'الرجاء اختيار المحافظة التي تتواجد فيها',
                textDirection: ui.TextDirection.rtl,
                style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 20),
              ),
              const SizedBox(height: 22),
              const Align(
                alignment: AlignmentDirectional.center,
                child: Text(
                  'Select Governorate',
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
                  'Please choose your governorate',
                  style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 15),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: governorates.isEmpty
                    ? const _Message(text: 'لا توجد محافظات مضافة لهذه الدولة.')
                    : ListView(
                        padding: EdgeInsets.zero,
                        children: governorates
                            .map(
                              (governorate) => _Option(
                                title: governorate.nameAr,
                                subtitle: governorate.nameEn,
                                selected:
                                    _selectedGovernorate?.id == governorate.id,
                                onTap: () => setState(
                                  () => _selectedGovernorate = governorate,
                                ),
                              ),
                            )
                            .toList(),
                      ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _continuing || _selectedGovernorate == null
                      ? null
                      : _continue,
                  style: FilledButton.styleFrom(
                    backgroundColor: onboardingPrimaryColor,
                    disabledBackgroundColor: onboardingPrimaryDisabledColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: _continuing
                      ? const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
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

class _Message extends StatelessWidget {
  final String text;

  const _Message({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(text, textAlign: TextAlign.center));
  }
}

class _Option extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _Option({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? onboardingPrimaryLightColor : Colors.white,
          border: Border.all(
            color: selected ? onboardingPrimaryColor : const Color(0xFFE4ECEC),
            width: selected ? 1.3 : 1,
          ),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    textDirection: ui.TextDirection.rtl,
                    style: const TextStyle(
                      color: Color(0xFF20354A),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? onboardingPrimaryColor : const Color(0xFFB8C9D1),
              size: 19,
            ),
          ],
        ),
      ),
    );
  }
}
