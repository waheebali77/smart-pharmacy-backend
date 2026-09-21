import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../models/medicine.dart';
import '../services/customer_service.dart';
import 'medicine_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  List<Medicine> _items = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _loadRequestId = 0;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery ?? '';
    _loadResults();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadResults() async {
    final service = context.read<CustomerService>();
    final query = _searchController.text.trim();
    final filter = _selectedFilter;
    final requestId = ++_loadRequestId;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      var medicines = await service.searchMedicines(
        query,
        availableOnly: filter == 'available' || filter == 'open',
        openOnly: filter == 'open',
        lowestPrice: filter == 'lowest_price',
        donationsOnly: filter == 'donations',
        clearanceOnly: filter == 'clearance',
      );

      if (filter == 'nearest') {
        final position = await _getCurrentPosition();
        if (position != null) {
          medicines = CustomerService.sortMedicinesByPharmacyDistance(
            medicines,
            position,
          );
        }
      } else if (filter == 'lowest_price') {
        medicines = CustomerService.sortMedicinesByPrice(medicines);
      }

      if (!mounted || requestId != _loadRequestId) return;
      setState(() => _items = medicines);
    } catch (error) {
      if (!mounted || requestId != _loadRequestId) return;
      setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted && requestId == _loadRequestId) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('Location services are disabled.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission was not granted.');
      }

      return await Geolocator.getCurrentPosition();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
      return null;
    }
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = _selectedFilter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedFilter = filter);
          _loadResults();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE5F9F2) : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (filter == 'donations') ...[
                Icon(
                  Icons.favorite,
                  size: 15,
                  color:
                      isSelected
                          ? const Color(0xFFE25575)
                          : const Color(0xFF6B7280),
                ),
                const SizedBox(width: 5),
              ],
              Text(
                filter.tr(),
                style: TextStyle(
                  color: isSelected ? const Color(0xFF4682B4) : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  Expanded(
                    child: Text(
                      'search_results'.tr(),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(Icons.tune_rounded, size: 26),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Color(0xFF6B7280)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _loadResults(),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: 'search_medicine_pharmacy'.tr(),
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B7280),
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        _loadResults();
                      },
                      child: const Icon(
                        Icons.clear_rounded,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final filter in [
                      'all',
                      'nearest',
                      'lowest_price',
                      'available',
                      'open',
                      'donations',
                      'clearance',
                    ])
                      _buildFilterChip(filter),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  '${_items.length} ${'results_found'.tr()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _errorMessage != null
                        ? Center(
                          child: Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                        )
                        : _items.isEmpty
                        ? Center(
                          child: Text(
                            'no_results'.tr(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        )
                        : ListView.separated(
                          itemCount: _items.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final medicine = _items[index];
                            final pharmacyName =
                                medicine.pharmacy?.name ?? 'Pharmacy';
                            final isAvailable = medicine.quantity > 0;

                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (_) => MedicineDetailsScreen(
                                          medicine: medicine,
                                          pharmacy: medicine.pharmacy,
                                        ),
                                  ),
                                );
                              },
                              child: Container(
                                height: 126,
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                  8,
                                  8,
                                  10,
                                  8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  textDirection: ui.TextDirection.ltr,
                                  children: [
                                    Container(
                                      width: 76,
                                      height: double.infinity,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF7FAFA),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child:
                                          medicine.imagePath != null &&
                                                  medicine.imagePath!.isNotEmpty
                                              ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.network(
                                                  medicine.imagePath!,
                                                  width: 76,
                                                  height: double.infinity,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        _,
                                                        __,
                                                        ___,
                                                      ) => const Center(
                                                        child: Icon(
                                                          Icons
                                                              .medication_rounded,
                                                          color: Color(
                                                            0xFF4682B4,
                                                          ),
                                                          size: 30,
                                                        ),
                                                      ),
                                                ),
                                              )
                                              : const Center(
                                                child: Icon(
                                                  Icons.medication_rounded,
                                                  color: Color(0xFF4682B4),
                                                  size: 30,
                                                ),
                                              ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Directionality(
                                        textDirection: ui.TextDirection.rtl,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    medicine.name,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                                const Icon(
                                                  Icons.chevron_right_rounded,
                                                  color: Color(0xFF6B7280),
                                                  size: 20,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              medicine.genericName ??
                                                  'مسكنات الألم',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Color(0xFF7B8490),
                                                fontSize: 11,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Row(
                                              children: [
                                                Text(
                                                  medicine.isDonation
                                                      ? 'FREE'
                                                      : 'ر.ي ${medicine.displayPrice.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    color: Color(0xFF4682B4),
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                if (medicine
                                                        .discountPercentage >
                                                    0) ...[
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'ر.ي ${medicine.price.toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                      color: Color(0xFF9CA3AF),
                                                      fontSize: 10,
                                                      decoration:
                                                          TextDecoration
                                                              .lineThrough,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 3,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFFFE3E1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      '${medicine.discountPercentage}% خصم',
                                                      style: const TextStyle(
                                                        color: Color(
                                                          0xFFE15B55,
                                                        ),
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              pharmacyName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Color(0xFF4682B4),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.location_on_outlined,
                                                  color: Color(0xFF4682B4),
                                                  size: 15,
                                                ),
                                                Text(
                                                  medicine.pharmacy == null
                                                      ? '--'
                                                      : '-- km',
                                                  style: TextStyle(
                                                    color: Color(0xFF6B7280),
                                                    fontSize: 11,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 7,
                                                        vertical: 3,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFFDDF7EE,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    isAvailable
                                                        ? 'متوفر'
                                                        : 'غير متوفر',
                                                    style: TextStyle(
                                                      color:
                                                          isAvailable
                                                              ? const Color(
                                                                0xFF4682B4,
                                                              )
                                                              : Colors
                                                                  .redAccent,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder:
                                                (_) => MedicineDetailsScreen(
                                                  medicine: medicine,
                                                  pharmacy: medicine.pharmacy,
                                                ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4682B4),
                                          borderRadius: BorderRadius.circular(
                                            9,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.shopping_cart_outlined,
                                          color: Colors.white,
                                          size: 17,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
