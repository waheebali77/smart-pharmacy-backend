import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medicine.dart';
import '../models/pharmacy.dart';
import '../providers/auth_provider.dart';
import '../services/customer_service.dart';
import 'customer_home_screen.dart';
import 'login_screen.dart';
import 'pharmacy_details_screen.dart';

class PharmacyCardForMedicine extends StatelessWidget {
  final Pharmacy pharmacy;

  const PharmacyCardForMedicine({super.key, required this.pharmacy});

  String _initials(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'P';

    final words = trimmed.split(RegExp(r'\s+'));
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    }

    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  String _getPharmacyName() {
    return pharmacy.name;
  }

  String? _getPharmacyImageUrl() {
    final dynamicImage =
        pharmacy.imagePath ?? pharmacy.logoPath ?? pharmacy.image;
    return dynamicImage != null && dynamicImage.isNotEmpty
        ? dynamicImage
        : null;
  }

  double _getRating() {
    return pharmacy.rating ?? 4.8;
  }

  String _getDistanceText() {
    final distance = pharmacy.distance ?? 1.2;
    return '${distance.toStringAsFixed(1)} km away';
  }

  @override
  Widget build(BuildContext context) {
    final pharmacyName = _getPharmacyName();
    final imageUrl = _getPharmacyImageUrl();
    final isOpen = pharmacy.status.toLowerCase() == 'open';
    final rating = _getRating();
    final distanceText = _getDistanceText();

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PharmacyDetailsScreen(pharmacy: pharmacy),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFEAFBF7),
          border: Border.all(color: const Color(0xFFBFEAE0), width: 1.2),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFF4682B4),
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
              child:
                  imageUrl == null
                      ? Text(
                        _initials(pharmacyName),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      )
                      : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          pharmacyName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isOpen
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isOpen ? 'Open' : 'Closed',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color:
                                isOpen
                                    ? const Color(0xFF166534)
                                    : const Color(0xFFB91C1C),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 15,
                        color: Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          distanceText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4682B4).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View pharmacy profile',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF4682B4),
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: Color(0xFF4682B4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MedicineDetailsScreen extends StatefulWidget {
  const MedicineDetailsScreen({
    super.key,
    required this.medicine,
    this.pharmacy,
  });

  final Medicine medicine;
  final Pharmacy? pharmacy;

  @override
  State<MedicineDetailsScreen> createState() => _MedicineDetailsScreenState();
}

class _MedicineDetailsScreenState extends State<MedicineDetailsScreen> {
  bool _ordering = false;
  List<Medicine> _availableMedicines = const [];

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    try {
      final medicines = await context
          .read<CustomerService>()
          .getMedicineAvailability(widget.medicine.id);
      if (mounted && medicines.isNotEmpty) {
        setState(() => _availableMedicines = medicines);
      }
    } catch (_) {
      // Keep the selected result when the availability request is unavailable.
    }
  }

  Future<void> _placeOrder({Pharmacy? pharmacy}) async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to place an order.')),
      );
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }
    setState(() => _ordering = true);
    try {
      final service = context.read<CustomerService>();
      final selectedPharmacy = pharmacy ?? widget.pharmacy;
      if (selectedPharmacy != null) {
        await service.createOrder(selectedPharmacy.id, [
          {'medicine_id': widget.medicine.id, 'quantity': 1},
        ]);
      } else {
        await service.requestMedicine(widget.medicine.id);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully.')),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => CustomerHomeScreen(key: UniqueKey(), initialIndex: 2),
        ),
        (route) => false,
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Order failed: $error')));
      }
    } finally {
      if (mounted) setState(() => _ordering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final medicine = widget.medicine;
    final name = medicine.name.isNotEmpty ? medicine.name : 'Paracetamol 500mg';
    final description =
        medicine.description.isNotEmpty ? medicine.description : 'Tablet';
    final availableMedicines =
        _availableMedicines.isNotEmpty ? _availableMedicines : [medicine];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      body: Directionality(
        textDirection: ui.TextDirection.rtl,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(10, 4, 10, 16),
                  children: [
                    Row(
                      textDirection: ui.TextDirection.ltr,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.favorite,
                            color: Color(0xFF4682B4),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 190,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InteractiveViewer(
                        minScale: 1,
                        maxScale: 4,
                        boundaryMargin: const EdgeInsets.all(32),
                        child:
                            medicine.imagePath == null
                                ? const Icon(
                                  Icons.medication_rounded,
                                  color: Color(0xFF4682B4),
                                  size: 70,
                                )
                                : Image.network(
                                  medicine.imagePath!,
                                  fit: BoxFit.contain,
                                  errorBuilder:
                                      (_, __, ___) => const Icon(
                                        Icons.medication_rounded,
                                        color: Color(0xFF4682B4),
                                        size: 70,
                                      ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      medicine.genericName ?? 'Paracetamol',
                      style: const TextStyle(
                        color: Color(0xFF7B8490),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      medicine.categoryName ?? 'مسكنات الألم',
                      style: const TextStyle(
                        color: Color(0xFF4682B4),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _InfoTile(
                          icon: Icons.medication_outlined,
                          label: 'شكل الدواء',
                          value: medicine.dosageForm ?? 'أقراص',
                        ),
                        _InfoTile(
                          icon: Icons.science_outlined,
                          label: 'التركيز',
                          value: medicine.strength ?? '500mg',
                        ),
                        _InfoTile(
                          icon: Icons.factory_outlined,
                          label: 'الشركة',
                          value: medicine.manufacturer ?? 'GSK',
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'الوصف',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Color(0xFF68727D),
                        height: 1.5,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'متوفر في الصيدليات',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 7),
                    ...availableMedicines.map(
                      (availableMedicine) => _PharmacyPriceRow(
                        medicine: availableMedicine,
                        onOrder:
                            _ordering
                                ? null
                                : () => _placeOrder(
                                  pharmacy: availableMedicine.pharmacy,
                                ),
                        onOpenPharmacy:
                            availableMedicine.pharmacy == null
                                ? null
                                : () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (_) => PharmacyDetailsScreen(
                                          pharmacy: availableMedicine.pharmacy!,
                                        ),
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
              _DetailsBottomBar(
                ordering: _ordering,
                onOrder: _placeOrder,
                onMap:
                    widget.pharmacy == null
                        ? null
                        : () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (_) => PharmacyDetailsScreen(
                                  pharmacy: widget.pharmacy!,
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

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 58,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(left: BorderSide(color: Color(0xFFF0F2F2))),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF475569)),
            Text(
              label,
              style: const TextStyle(fontSize: 9, color: Color(0xFF69737D)),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _PharmacyPriceRow extends StatelessWidget {
  const _PharmacyPriceRow({
    required this.medicine,
    required this.onOrder,
    required this.onOpenPharmacy,
  });

  final Medicine medicine;
  final VoidCallback? onOrder;
  final VoidCallback? onOpenPharmacy;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onOpenPharmacy,
        borderRadius: BorderRadius.circular(10),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFFE5F7F2),
              child: Icon(
                Icons.local_pharmacy_outlined,
                size: 18,
                color: Color(0xFF4682B4),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine.pharmacy?.name ?? 'Pharmacy',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    '📍 2 كم',
                    style: TextStyle(fontSize: 10, color: Color(0xFF7B8490)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDF7EE),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      medicine.quantity > 0 && medicine.isAvailable
                          ? 'متوفر'
                          : 'غير متوفر',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFF4682B4),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'ر.ي ${medicine.finalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text(
                  'ر.ي 1.60',
                  style: TextStyle(
                    fontSize: 9,
                    color: Color(0xFF9CA3AF),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            SizedBox(
              height: 27,
              child: FilledButton(
                onPressed: onOrder,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF4682B4),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  textStyle: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('اطلب الآن'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsBottomBar extends StatelessWidget {
  const _DetailsBottomBar({
    required this.ordering,
    required this.onOrder,
    required this.onMap,
  });

  final bool ordering;
  final VoidCallback onOrder;
  final VoidCallback? onMap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onMap,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4682B4),
                side: const BorderSide(color: Color(0xFF4682B4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: const Text('عرض على الخريطة'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton(
              onPressed: ordering ? null : onOrder,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4682B4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child:
                  ordering
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text('اطلب الآن'),
            ),
          ),
        ],
      ),
    );
  }
}
