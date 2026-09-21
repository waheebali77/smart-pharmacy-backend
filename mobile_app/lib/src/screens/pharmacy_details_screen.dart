import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../models/pharmacy.dart';
import '../models/medicine.dart';
import '../providers/auth_provider.dart';
import '../services/customer_service.dart';
import 'customer_home_screen.dart';
import 'login_screen.dart';
import 'pharmacy_map_section.dart';

class PharmacyDetailsScreen extends StatefulWidget {
  final Pharmacy pharmacy;

  const PharmacyDetailsScreen({super.key, required this.pharmacy});

  @override
  State<PharmacyDetailsScreen> createState() => _PharmacyDetailsScreenState();
}

class _PharmacyDetailsScreenState extends State<PharmacyDetailsScreen> {
  final Map<int, int> _quantities = {};
  final TextEditingController _searchController = TextEditingController();
  late final Future<Position> _positionFuture;
  List<Medicine> _allMedicines = [];
  List<Medicine> _filteredMedicines = [];
  bool _loadingMedicines = true;
  String? _medicinesError;
  String? _message;
  late Pharmacy _pharmacy;
  bool _ordering = false;

  @override
  void initState() {
    super.initState();
    _pharmacy = widget.pharmacy;
    _positionFuture = _determinePosition();
    _searchController.addListener(_filterMedicines);
    _loadPharmacyDetails();
    _loadPharmacyMedicines();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPharmacyDetails() async {
    try {
      final service = Provider.of<CustomerService>(context, listen: false);
      final pharmacy = await service.getPharmacyDetails(widget.pharmacy.id);
      if (!mounted) return;
      setState(() => _pharmacy = pharmacy);
    } catch (_) {}
  }

  Future<void> _placeOrder() async {
    final selectedItems =
        _quantities.entries
            .where((entry) => entry.value > 0)
            .map((entry) => {'medicine_id': entry.key, 'quantity': entry.value})
            .toList();
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر دواءً واحدًا على الأقل')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تسجيل الدخول لإتمام الطلب')),
      );
      if (!mounted) return;
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }

    setState(() => _ordering = true);
    try {
      await context.read<CustomerService>().createOrder(
        _pharmacy.id,
        selectedItems,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم إرسال الطلب بنجاح')));
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => CustomerHomeScreen(key: UniqueKey(), initialIndex: 2),
        ),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر إرسال الطلب: $error')));
    } finally {
      if (mounted) setState(() => _ordering = false);
    }
  }

  Future<void> _loadPharmacyMedicines() async {
    try {
      final service = Provider.of<CustomerService>(context, listen: false);
      final medicines = await service.getPharmacyMedicines(widget.pharmacy.id);
      if (!mounted) return;
      setState(() {
        _allMedicines = medicines;
        _filteredMedicines = medicines;
        _loadingMedicines = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingMedicines = false;
        _medicinesError = 'Unable to load medicines: $error';
      });
    }
  }

  void _filterMedicines() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredMedicines =
          query.isEmpty
              ? _allMedicines
              : _allMedicines.where((medicine) {
                return medicine.name.toLowerCase().contains(query) ||
                    medicine.description.toLowerCase().contains(query) ||
                    (medicine.genericName?.toLowerCase().contains(query) ??
                        false) ||
                    (medicine.barcode?.toLowerCase().contains(query) ?? false);
              }).toList();
    });
  }

  void _updateQuantity(Medicine medicine, int delta) {
    final updated = ((_quantities[medicine.id] ?? 0) + delta).clamp(
      0,
      medicine.quantity,
    );
    setState(() {
      if (updated == 0) {
        _quantities.remove(medicine.id);
      } else {
        _quantities[medicine.id] = updated;
      }
    });
  }

  Widget _pharmacyImagePlaceholder() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Image.asset(
        'assets/pharmacy_default.jpg',
        width: double.infinity,
        height: 176,
        fit: BoxFit.cover,
        errorBuilder:
            (_, __, ___) => Container(
              width: double.infinity,
              height: 176,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE5F9F2), Color(0xFFD7F4EA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Center(
                child: Icon(
                  Icons.local_pharmacy,
                  size: 62,
                  color: Color(0xFF4682B4),
                ),
              ),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pharmacy = _pharmacy;
    final medicines = _filteredMedicines;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F7),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.favorite_border_rounded,
                            color: Color(0xFF4682B4),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 196,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child:
                          pharmacy.imageUrl != null &&
                                  pharmacy.imageUrl!.isNotEmpty
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Image.network(
                                  pharmacy.imageUrl!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder:
                                      (_, __, ___) =>
                                          _pharmacyImagePlaceholder(),
                                ),
                              )
                              : _pharmacyImagePlaceholder(),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pharmacy.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                pharmacy.address,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _StatusBadge(
                          isOpen: pharmacy.status.toLowerCase() == 'open',
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            color: Color(0xFF4682B4),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${pharmacy.openingTime?.trim().isNotEmpty == true ? pharmacy.openingTime : '--:--'} - ${pharmacy.closingTime?.trim().isNotEmpty == true ? pharmacy.closingTime : '--:--'}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF374151),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE9FBF6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'مفتوح الآن',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF4682B4),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'الأدوية المتاحة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'ابحث عن دواء...',
                        hintStyle: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF64748B),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF4682B4),
                            width: 1.5,
                          ),
                        ),
                        suffixIcon:
                            _searchController.text.isEmpty
                                ? null
                                : IconButton(
                                  onPressed: _searchController.clear,
                                  icon: const Icon(
                                    Icons.clear_rounded,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (_loadingMedicines)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_medicinesError != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          _medicinesError!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      )
                    else if (medicines.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'لا توجد أدوية متاحة في هذه الصيدلية.',
                          style: TextStyle(color: Color(0xFF6B7280)),
                        ),
                      )
                    else
                      ...medicines.map((medicine) {
                        final quantity = _quantities[medicine.id] ?? 0;
                        final price =
                            medicine.price *
                            (1 - medicine.discountPercentage / 100);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8FAF5),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child:
                                    medicine.imagePath != null &&
                                            medicine.imagePath!.isNotEmpty
                                        ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          child: Image.network(
                                            medicine.imagePath!,
                                            fit: BoxFit.cover,
                                            width: 58,
                                            height: 58,
                                            errorBuilder:
                                                (_, __, ___) => const Icon(
                                                  Icons.medication_rounded,
                                                  color: Color(0xFF4682B4),
                                                ),
                                          ),
                                        )
                                        : const Icon(
                                          Icons.medication_rounded,
                                          color: Color(0xFF4682B4),
                                          size: 28,
                                        ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      medicine.name,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      medicine.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Text(
                                          '${price.toStringAsFixed(2)} ر.ي',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE9FBF6),
                                            borderRadius: BorderRadius.circular(
                                              9,
                                            ),
                                          ),
                                          child: Text(
                                            medicine.quantity > 0
                                                ? 'متوفر'
                                                : 'غير متوفر',
                                            style: const TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF4682B4),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed:
                                          quantity > 0
                                              ? () =>
                                                  _updateQuantity(medicine, -1)
                                              : null,
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      child: Text(
                                        '$quantity',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed:
                                          quantity < medicine.quantity
                                              ? () =>
                                                  _updateQuantity(medicine, 1)
                                              : null,
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                        color: Color(0xFF4682B4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _ordering ? null : _placeOrder,
                        icon: const Icon(Icons.shopping_bag_outlined),
                        label: Text(
                          _ordering ? 'جارٍ إرسال الطلب...' : 'إرسال الطلب',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4682B4),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFF9DD8CD),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<Position>(
                      future: _positionFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const SizedBox(
                            height: 180,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final position = snapshot.data;
                        return PharmacyMapSection(
                          pharmacyLatitude: pharmacy.latitude,
                          pharmacyLongitude: pharmacy.longitude,
                          userLatitude: position?.latitude,
                          userLongitude: position?.longitude,
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    if (_message != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _message!,
                          style: const TextStyle(color: Color(0xFFB91C1C)),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Position> _determinePosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return Geolocator.getCurrentPosition();
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isOpen});

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? const Color(0xFF4682B4) : const Color(0xFFEF4444);
    final bg = isOpen ? const Color(0xFFE8FAF5) : const Color(0xFFFFEEF0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 6),
          Text(
            isOpen ? 'مفتوح' : 'مغلق',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
