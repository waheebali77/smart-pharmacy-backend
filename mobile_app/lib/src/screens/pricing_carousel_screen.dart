import 'package:flutter/material.dart';

import '../services/owner_service.dart';

class PricingCarouselScreen extends StatefulWidget {
  final OwnerService ownerService;

  const PricingCarouselScreen({super.key, required this.ownerService});

  @override
  State<PricingCarouselScreen> createState() => _PricingCarouselScreenState();
}

class _PricingCarouselScreenState extends State<PricingCarouselScreen> {
  static const _defaultPlans = <_PricingPlan>[
    _PricingPlan(
      name: 'BASIC',
      price: '15.99',
      color: Color(0xFF11A99A),
      icon: Icons.send_rounded,
      features: ['FREE SUPPORT 24/7', 'DATABASE DOWNLOAD'],
    ),
    _PricingPlan(
      name: 'STANDARD',
      price: '25.99',
      color: Color(0xFFFF9418),
      icon: Icons.flight_takeoff_rounded,
      features: ['FREE SUPPORT 24/7', 'DATABASE DOWNLOAD', 'MAINTENANCE EMAIL'],
    ),
    _PricingPlan(
      name: 'PREMIUM',
      price: '35.99',
      color: Color(0xFF703DB3),
      icon: Icons.rocket_launch_rounded,
      features: [
        'FREE SUPPORT 24/7',
        'DATABASE DOWNLOAD',
        'MAINTENANCE EMAIL',
        'UNLIMITED TRAFFIC',
      ],
    ),
  ];

  List<_PricingPlan> _plans = _defaultPlans;
  bool _loading = true;
  String? _error;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    try {
      final packages = await widget.ownerService.getPackages();
      if (!mounted) return;
      setState(() {
        _plans = List.generate(
          _defaultPlans.length,
          (index) => _defaultPlans[index].withPackage(
            index < packages.length ? packages[index] : null,
          ),
        );
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'تعذر تحميل الباقات حاليًا';
        _loading = false;
      });
    }
  }

  void _selectPlan(int index) {
    if (index != _selectedIndex) {
      setState(() => _selectedIndex = index);
    }
  }

  int _slotFor(int index) {
    if (index == _selectedIndex) return 0;
    if (_selectedIndex == 0) return index == 2 ? -1 : 1;
    if (_selectedIndex == 1) return index == 0 ? -1 : 1;
    return index == 0 ? -1 : 1;
  }

  Widget _buildCard({
    required _PricingPlan plan,
    required int index,
    required double width,
    required double height,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _selectPlan(index),
      child: AnimatedScale(
        scale: isSelected ? 1 : 0.84,
        duration: const Duration(milliseconds: 460),
        curve: Curves.easeInOutCubic,
        child: AnimatedOpacity(
          opacity: isSelected ? 1 : 0.76,
          duration: const Duration(milliseconds: 460),
          curve: Curves.easeInOutCubic,
          child: Material(
            color: Colors.transparent,
            elevation: isSelected ? 18 : 5,
            shadowColor: Colors.black.withValues(
              alpha: isSelected ? 0.28 : 0.14,
            ),
            borderRadius: BorderRadius.circular(20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: width,
                height: height,
                color: Colors.white,
                child: Column(
                  children: [
                    Expanded(
                      flex: 45,
                      child: ClipPath(
                        clipper: _HeaderWaveClipper(),
                        child: Container(
                          color: plan.color,
                          padding: const EdgeInsets.fromLTRB(14, 17, 14, 58),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: Icon(
                                  plan.icon,
                                  color: Colors.white,
                                  size: 37,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                plan.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 55,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 13),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'ر.ي ${plan.price}',
                                  style: const TextStyle(
                                    color: Color(0xFF202124),
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 3),
                                  child: Text(
                                    'PER\nMONTH',
                                    style: TextStyle(
                                      color: Color(0xFF4B4D52),
                                      fontSize: 8,
                                      height: 1.05,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:
                                    plan.features
                                        .map(
                                          (feature) => Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 7,
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 3,
                                                      ),
                                                  child: Icon(
                                                    Icons.circle,
                                                    size: 5,
                                                    color: plan.color,
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                Expanded(
                                                  child: Text(
                                                    feature,
                                                    style: const TextStyle(
                                                      color: Color(0xFF9C7B43),
                                                      fontSize: 8,
                                                      height: 1.15,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                        .toList(),
                              ),
                            ),
                            SizedBox(
                              height: 34,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF303236),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                ),
                                child: const Text(
                                  'BUY',
                                  style: TextStyle(
                                    fontSize: 15,
                                    letterSpacing: 1.2,
                                  ),
                                ),
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
          ),
        ),
      ),
    );
  }

  Widget _buildPositionedCard({
    required int index,
    required double cardWidth,
    required double cardHeight,
    required double sideOffset,
    required double viewportWidth,
  }) {
    final slot = _slotFor(index);
    final isSelected = slot == 0;
    final left = (viewportWidth - cardWidth) / 2 + (slot * sideOffset);

    return AnimatedPositioned(
      key: ValueKey('pricing-card-$index'),
      duration: const Duration(milliseconds: 460),
      curve: Curves.easeInOutCubic,
      left: left,
      top: isSelected ? 0 : cardHeight * 0.08,
      width: cardWidth,
      height: cardHeight,
      child: _buildCard(
        plan: _plans[index],
        index: index,
        width: cardWidth,
        height: cardHeight,
        isSelected: isSelected,
      ),
    );
  }

  Widget _buildCarousel() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final widthBasedCardWidth =
            (constraints.maxWidth * 0.49).clamp(210.0, 220.0).toDouble();
        final heightBasedCardWidth =
            constraints.hasBoundedHeight
                ? constraints.maxHeight / 1.8
                : widthBasedCardWidth;
        final cardWidth =
            widthBasedCardWidth < heightBasedCardWidth
                ? widthBasedCardWidth
                : heightBasedCardWidth;
        final cardHeight = (cardWidth * 1.72).clamp(400.0, 400.0).toDouble();
        final sideOffset = cardWidth * 0.54;

        final cards = [0, 1, 2]..sort((first, second) {
          final firstSelected = _slotFor(first) == 0;
          final secondSelected = _slotFor(second) == 0;
          return (firstSelected ? 1 : 0).compareTo(secondSelected ? 1 : 0);
        });

        return SizedBox.expand(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (final index in cards)
                _buildPositionedCard(
                  index: index,
                  cardWidth: cardWidth,
                  cardHeight: cardHeight,
                  sideOffset: sideOffset,
                  viewportWidth: constraints.maxWidth,
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F4),
      appBar: AppBar(title: const Text('العروض والباقات المميزة')),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text(_error!))
              : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 22, 0, 28),
                  child: Column(
                    children: [
                      const Text(
                        'اختر الباقة الأنسب لصيدليتك',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF202124),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Transform.translate(
                            offset: const Offset(0, 90),
                            child: _buildCarousel(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          3,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: index == _selectedIndex ? 24 : 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color:
                                  index == _selectedIndex
                                      ? _plans[index].color
                                      : Colors.black26,
                              borderRadius: BorderRadius.circular(8),
                            ),
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

class _PricingPlan {
  final String name;
  final String price;
  final Color color;
  final IconData icon;
  final List<String> features;

  const _PricingPlan({
    required this.name,
    required this.price,
    required this.color,
    required this.icon,
    required this.features,
  });

  _PricingPlan withPackage(Map<String, dynamic>? package) {
    if (package == null) return this;
    final description = package['description']?.toString() ?? '';
    final dashboardFeatures =
        description
            .replaceAll(
              RegExp(
                r'(?=FREE SUPPORT|DATABASE DOWNLOAD|MAINTENANCE EMAIL|UNLIMITED TRAFFIC)',
                caseSensitive: false,
              ),
              '\n',
            )
            .split(RegExp(r'[\r\n;|]+'))
            .map(
              (feature) =>
                  feature.replaceFirst(RegExp(r'^\s*[-•]\s*'), '').trim(),
            )
            .where((feature) => feature.isNotEmpty)
            .toList();

    return _PricingPlan(
      name: package['name']?.toString().trim().toUpperCase() ?? name,
      price: package['price']?.toString() ?? price,
      color: color,
      icon: icon,
      features: dashboardFeatures.isEmpty ? features : dashboardFeatures,
    );
  }
}

class _HeaderWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()..lineTo(0, size.height * 0.78);
    path.cubicTo(
      size.width * 0.22,
      size.height * 0.61,
      size.width * 0.42,
      size.height * 0.93,
      size.width * 0.63,
      size.height * 0.76,
    );
    path.cubicTo(
      size.width * 0.78,
      size.height * 0.64,
      size.width * 0.89,
      size.height * 0.84,
      size.width,
      size.height * 0.68,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
