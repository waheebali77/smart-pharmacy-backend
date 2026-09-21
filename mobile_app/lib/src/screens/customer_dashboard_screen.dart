import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../models/medicine.dart';
import '../models/offer.dart';
import '../models/pharmacy.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../services/customer_service.dart';
import 'all_pharmacies_screen.dart';
import 'all_offers_screen.dart';
import 'medicine_details_screen.dart';
import 'pharmacy_details_screen.dart';
import 'offer_details_screen.dart';
import 'search_screen.dart';
import 'donations_screen.dart';

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() =>
      _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final Future<List<Pharmacy>> _nearbyPharmaciesFuture;
  late final Future<List<Medicine>> _popularMedicinesFuture;
  late final Future<List<Offer>> _featuredOffersFuture;
  late final Future<List<Medicine>> _donationMedicinesFuture;
  late final Future<List<Medicine>> _clearanceMedicinesFuture;
  String? _locationLabel;
  Offer? _topOffer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: const [SystemUiOverlay.bottom],
    );
    _nearbyPharmaciesFuture = _loadNearbyPharmacies();
    _popularMedicinesFuture =
        context.read<CustomerService>().getPopularMedicines();
    _featuredOffersFuture = context.read<CustomerService>().getFeaturedOffers();
    _featuredOffersFuture.then((offers) {
      if (mounted && offers.isNotEmpty) {
        setState(() => _topOffer = offers.first);
      }
    });
    _donationMedicinesFuture =
        context.read<CustomerService>().getDonationMedicines();
    _clearanceMedicinesFuture =
        context.read<CustomerService>().getClearanceMedicines();
  }

  Future<List<Pharmacy>> _loadNearbyPharmacies() async {
    final service = context.read<CustomerService>();
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return service.getAllPharmacies();

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return service.getAllPharmacies();
      }

      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _locationLabel =
              '${position.latitude.toStringAsFixed(4)}, '
              '${position.longitude.toStringAsFixed(4)}';
        });
      }
      final nearby = await service.getNearbyPharmacies(
        position.latitude,
        position.longitude,
      );
      final pharmacies =
          nearby.isEmpty ? await service.getAllPharmacies() : nearby;
      return CustomerService.sortPharmaciesByDistance(pharmacies, position);
    } catch (_) {
      return service.getAllPharmacies();
    }
  }

  void _openSearch([String? query]) {
    final value = (query ?? _searchController.text).trim();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SearchScreen(initialQuery: value)),
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final displayName = user?.name.trim();
    final location = user?.location?.trim();
    final locationText =
        location?.isNotEmpty == true
            ? location!
            : _locationLabel ?? 'الموقع غير متاح';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: Directionality(
        textDirection: ui.TextDirection.rtl,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: Color(0xFF4682B4),
                          size: 22,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          locationText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.notifications_none_rounded,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'hello_user'.tr(
                          args: [
                            displayName?.isNotEmpty == true
                                ? displayName!
                                : 'user'.tr(),
                          ],
                        ),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _UserAvatar(user: user, radius: 30),
                  ],
                ),
                Text(
                  'good_morning'.tr(),
                  style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: () => _openSearch(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Color(0xFF6B7280)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onSubmitted: (_) => _openSearch(),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              hintText: 'search_medicine_pharmacy'.tr(),
                              hintStyle: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 15,
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _openSearch(),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4682B4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.search,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4682B4), Color(0xFF4682B4)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _topOffer == null
                                  ? 'order_medicine_nearby'.tr()
                                  : '${_topOffer!.discountPercentage}% خصم\n${_topOffer!.title}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap:
                                  () =>
                                      _topOffer == null
                                          ? _openSearch('paracetamol')
                                          : Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder:
                                                  (_) =>
                                                      const AllOffersScreen(),
                                            ),
                                          ),
                              child: SizedBox(
                                height: 38,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _topOffer == null
                                          ? 'search_now'.tr()
                                          : 'استكشف العروض',
                                      style: TextStyle(
                                        color: Color(0xFF4682B4),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 110,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              bottom: 10,
                              child: Container(
                                width: 62,
                                height: 62,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFB7F4D7),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(18),
                                  ),
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.medication_liquid_outlined,
                              color: Colors.white,
                              size: 52,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'nearby_pharmacies'.tr(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextButton(
                      onPressed:
                          () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AllPharmaciesScreen(),
                            ),
                          ),
                      child: Text('see_all'.tr()),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FutureBuilder<List<Pharmacy>>(
                  future: _nearbyPharmaciesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 180,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError) {
                      return SizedBox(
                        height: 180,
                        child: Center(
                          child: Text(
                            'Unable to load pharmacies: ${snapshot.error}',
                          ),
                        ),
                      );
                    }
                    final pharmacies = snapshot.data ?? [];
                    if (pharmacies.isEmpty) {
                      return const SizedBox(
                        height: 180,
                        child: Center(
                          child: Text('No nearby pharmacies found'),
                        ),
                      );
                    }
                    return SizedBox(
                      height: 180,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: pharmacies.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final pharmacy = pharmacies[index];
                          return GestureDetector(
                            onTap:
                                () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (_) => PharmacyDetailsScreen(
                                          pharmacy: pharmacy,
                                        ),
                                  ),
                                ),
                            child: _NearbyPharmacyCard(pharmacy: pharmacy),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'popular_medicines'.tr(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _openSearch(),
                      child: Text('see_all'.tr()),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FutureBuilder<List<Medicine>>(
                  future: _popularMedicinesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 120,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError) {
                      return Text('unable_load_popular'.tr());
                    }
                    final medicines = (snapshot.data ?? []).take(4).toList();
                    if (medicines.isEmpty) {
                      return Text('no_popular_medicines'.tr());
                    }
                    return SizedBox(
                      height: 190,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: medicines.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final medicine = medicines[index];
                          return _PopularMedicineCard(medicine: medicine);
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'top_offers'.tr(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextButton(
                      onPressed:
                          () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AllOffersScreen(),
                            ),
                          ),
                      child: Text('see_all'.tr()),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FutureBuilder<List<Offer>>(
                  future: _featuredOffersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 150,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError) {
                      return Text('unable_load_offers'.tr());
                    }
                    final offers = (snapshot.data ?? []).take(4).toList();
                    if (offers.isEmpty) return Text('no_active_offers'.tr());
                    return SizedBox(
                      height: 155,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: offers.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder:
                            (context, index) =>
                                _OfferCard(offer: offers[index]),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                _buildSpecialMedicineSection(
                  title: 'community_donations'.tr(),
                  future: _donationMedicinesFuture,
                  emptyText: 'no_donation_medicines'.tr(),
                  badge: 'free_donation'.tr(),
                  onSeeAll:
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DonationsScreen(),
                        ),
                      ),
                ),
                const SizedBox(height: 24),
                _buildSpecialMedicineSection(
                  title: 'clearance'.tr(),
                  future: _clearanceMedicinesFuture,
                  emptyText: 'no_clearance_medicines'.tr(),
                  badge: 'clearance'.tr(),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialMedicineSection({
    required String title,
    required Future<List<Medicine>> future,
    required String emptyText,
    required String badge,
    VoidCallback? onSeeAll,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            if (onSeeAll != null)
              TextButton(onPressed: onSeeAll, child: Text('see_all'.tr())),
          ],
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<Medicine>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 150,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) return Text('Unable to load $title');
            final medicines = (snapshot.data ?? []).take(4).toList();
            if (medicines.isEmpty) return Text(emptyText);
            return SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: medicines.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder:
                    (context, index) => _SpecialMedicineCard(
                      medicine: medicines[index],
                      badge: badge,
                    ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.user, required this.radius});

  final User? user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = user?.avatarUrl?.trim();
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF4682B4),
      backgroundImage:
          avatarUrl?.isNotEmpty == true ? NetworkImage(avatarUrl!) : null,
      child:
          avatarUrl?.isNotEmpty == true
              ? null
              : Icon(Icons.person, color: Colors.white, size: radius),
    );
  }
}

class _SpecialMedicineCard extends StatelessWidget {
  const _SpecialMedicineCard({required this.medicine, required this.badge});

  final Medicine medicine;
  final String badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () => Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (_) => MedicineDetailsScreen(
                    medicine: medicine,
                    pharmacy: medicine.pharmacy,
                  ),
            ),
          ),
      child: Container(
        width: 210,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MedicineImage(medicine: medicine),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (medicine.isDonation) ...[
                  const Icon(
                    Icons.favorite,
                    size: 13,
                    color: Color(0xFFE25575),
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  badge,
                  style: const TextStyle(
                    color: Color(0xFF4682B4),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            Text(
              medicine.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Text(
              medicine.isDonation
                  ? 'FREE'
                  : 'ر.ي ${medicine.displayPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Color(0xFF4682B4),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PopularMedicineCard extends StatelessWidget {
  const _PopularMedicineCard({required this.medicine});

  final Medicine medicine;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MedicineDetailsScreen(medicine: medicine),
            ),
          ),
      child: Container(
        width: 170,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE5E5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        '${medicine.discountPercentage}% خصم',
                        style: const TextStyle(
                          color: Color(0xFFE05252),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Center(child: _MedicineImage(medicine: medicine)),
                  const SizedBox(height: 7),
                  Text(
                    medicine.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  Text(
                    'ر.ي ${medicine.displayPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF4682B4),
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

class _MedicineImage extends StatelessWidget {
  const _MedicineImage({required this.medicine});

  final Medicine medicine;

  @override
  Widget build(BuildContext context) {
    final imageUrl = medicine.imagePath;
    final placeholder = Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F8F3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.medication_rounded, color: Color(0xFF4682B4)),
    );
    if (imageUrl == null || imageUrl.isEmpty) return placeholder;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => OfferDetailsScreen(offer: offer)),
          ),
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: const Color(0xFFDDF7EE),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${offer.discountPercentage}% OFF',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: Color(0xFF4682B4),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    offer.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.local_offer_rounded,
              size: 48,
              color: Color(0xFF4682B4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NearbyPharmacyCard extends StatelessWidget {
  const _NearbyPharmacyCard({required this.pharmacy});

  final Pharmacy pharmacy;

  @override
  Widget build(BuildContext context) {
    final isOpen = pharmacy.status.toLowerCase() == 'open';
    final imageUrl = pharmacy.imageUrl;
    return Container(
      width: 190,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child:
                imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 82,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                    : _placeholder(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(9, 7, 9, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pharmacy.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        pharmacy.distance == null
                            ? '--'
                            : '${pharmacy.distance!.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.star,
                        size: 12,
                        color: Color(0xFFF4B400),
                      ),
                      Text(
                        pharmacy.rating?.toStringAsFixed(1) ?? '--',
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    isOpen ? 'Open' : 'Closed',
                    style: TextStyle(
                      color:
                          isOpen ? const Color(0xFF4682B4) : Colors.redAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: double.infinity,
      height: 82,
      color: const Color(0xFFE5F9F2),
      child: const Center(
        child: Icon(Icons.local_pharmacy, color: Color(0xFF4682B4)),
      ),
    );
  }
}
