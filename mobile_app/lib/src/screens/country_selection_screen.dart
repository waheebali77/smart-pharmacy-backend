import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/location.dart';
import '../services/location_service.dart';
import 'governorate_selection_screen.dart';
import '../theme/onboarding_colors.dart';

class CountrySelectionScreen extends StatefulWidget {
  final Future<void> Function() onContinue;

  const CountrySelectionScreen({super.key, required this.onContinue});

  @override
  State<CountrySelectionScreen> createState() => _CountrySelectionScreenState();
}

class _CountrySelectionScreenState extends State<CountrySelectionScreen> {
  List<Country> _countries = const [];
  Country? _selectedCountry;
  bool _loading = true;
  bool _continuing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    try {
      final countries = await context.read<LocationService>().getCountries();
      if (!mounted) return;
      setState(() {
        _countries = countries;
        _selectedCountry = countries.isEmpty ? null : countries.first;
        _loading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'تعذر تحميل الدول. تحقق من الاتصال وحاول مرة أخرى.';
      });
    }
  }

  Future<void> _continue() async {
    final country = _selectedCountry;
    if (_continuing || country == null) return;
    setState(() => _continuing = true);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GovernorateSelectionScreen(
          country: country,
          onContinue: widget.onContinue,
        ),
      ),
    );
    if (mounted) setState(() => _continuing = false);
  }

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 8),
              const Icon(Icons.public, size: 100, color: onboardingPrimaryColor),
              const SizedBox(height: 12),
              const Text(
                'اختر الدولة',
                textDirection: ui.TextDirection.rtl,
                style: TextStyle(
                  color: onboardingPrimaryColor,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'من فضلك اختر الدولة التي تقيم فيها',
                textDirection: ui.TextDirection.rtl,
                style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 20),
              ),
              const SizedBox(height: 23),
              const Align(
                alignment: AlignmentDirectional.center,
                child: Text(
                  'Select Country',
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
                  'Please choose the country where you live',
                  style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 15),
                ),
              ),
              const SizedBox(height: 13),
              Expanded(child: _buildContent()),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _continuing || _selectedCountry == null
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

  Widget _buildContent() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return _Message(
        text: _error!,
        action: TextButton(
          onPressed: _loadCountries,
          child: const Text('إعادة المحاولة'),
        ),
      );
    }
    if (_countries.isEmpty) {
      return const _Message(text: 'لا توجد دول مضافة حاليًا.');
    }
    return ListView(
      padding: EdgeInsets.zero,
      children: _countries
          .map(
            (country) => _Option(
              title: country.nameAr,
              subtitle: country.nameEn,
              leading: _flagForCode(country.code),
              selected: _selectedCountry?.id == country.id,
              onTap: () => setState(() => _selectedCountry = country),
            ),
          )
          .toList(),
    );
  }

  String _flagForCode(String code) {
    final normalized = code.toUpperCase();
    if (normalized.length != 2) return '🌍';
    return String.fromCharCodes([
      normalized.codeUnitAt(0) + 127397,
      normalized.codeUnitAt(1) + 127397,
    ]);
  }
}

class _Message extends StatelessWidget {
  final String text;
  final Widget? action;

  const _Message({required this.text, this.action});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [Text(text, textAlign: TextAlign.center), if (action != null) action!],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  final String title;
  final String subtitle;
  final String leading;
  final bool selected;
  final VoidCallback onTap;

  const _Option({
    required this.title,
    required this.subtitle,
    required this.leading,
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
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
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
            Text(leading, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
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
