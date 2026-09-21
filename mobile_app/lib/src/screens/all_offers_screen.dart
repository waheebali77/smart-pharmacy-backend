import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/offer.dart';
import '../services/customer_service.dart';
import 'offer_details_screen.dart';

class AllOffersScreen extends StatefulWidget {
  const AllOffersScreen({super.key});

  @override
  State<AllOffersScreen> createState() => _AllOffersScreenState();
}

class _AllOffersScreenState extends State<AllOffersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      body: Directionality(
        textDirection: ui.TextDirection.rtl,
        child: FutureBuilder<List<Offer>>(
          future: _offersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('تعذر تحميل العروض'));
            }
            final offers = snapshot.data ?? [];
            if (offers.isEmpty) {
              return const Center(child: Text('لا توجد عروض متاحة حاليًا'));
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(7, 2, 7, 20),
              children: [
                _OfferHero(offer: offers.first),
                const SizedBox(height: 12),
                _buildFilters(),
                const SizedBox(height: 10),
                ...offers.map((offer) => _OfferListCard(offer: offer)),
              ],
            );
          },
        ),
      ),
    );
  }

  late final Future<List<Offer>> _offersFuture;
  String _selectedFilter = 'الكل';

  @override
  void initState() {
    super.initState();
    _offersFuture = context.read<CustomerService>().getFeaturedOffers();
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        children:
            ['الكل', 'أدوية', 'صيدليات قريبة'].map((filter) {
              final selected = filter == _selectedFilter;
              return Padding(
                padding: const EdgeInsetsDirectional.only(start: 7),
                child: ChoiceChip(
                  label: Text(filter),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedFilter = filter),
                  selectedColor: const Color(0xFF4682B4),
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color:
                        selected
                            ? const Color(0xFF4682B4)
                            : const Color(0xFFD8E9E5),
                  ),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF45605D),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}

class _OfferHero extends StatelessWidget {
  const _OfferHero({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => OfferDetailsScreen(offer: offer)),
          ),
      child: Container(
        height: 130,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF4682B4), Color(0xFF4682B4)],
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    offer.title.isEmpty ? 'خصومات مميزة' : offer.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    offer.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Text(
                      'تصفح العروض',
                      style: TextStyle(
                        color: Color(0xFF4682B4),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 105,
              height: 105,
              child:
                  offer.imagePath == null
                      ? const Icon(
                        Icons.medication_rounded,
                        color: Colors.white,
                        size: 62,
                      )
                      : Image.network(
                        offer.imagePath!,
                        fit: BoxFit.contain,
                        errorBuilder:
                            (_, __, ___) => const Icon(
                              Icons.medication_rounded,
                              color: Colors.white,
                              size: 62,
                            ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfferListCard extends StatelessWidget {
  const _OfferListCard({required this.offer});

  final Offer offer;

  String _date(String? value) {
    if (value == null || value.isEmpty) return '--';
    return value.length >= 10 ? value.substring(0, 10) : value;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => OfferDetailsScreen(offer: offer)),
          ),
      child: Container(
        height: 92,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(11),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF3FAF8),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  offer.imagePath == null
                      ? const Icon(
                        Icons.local_offer_outlined,
                        color: Color(0xFF4682B4),
                      )
                      : Image.network(
                        offer.imagePath!,
                        fit: BoxFit.contain,
                        errorBuilder:
                            (_, __, ___) => const Icon(
                              Icons.local_offer_outlined,
                              color: Color(0xFF4682B4),
                            ),
                      ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    offer.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    offer.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${_date(offer.startDate)} - ${_date(offer.endDate)}',
                    style: const TextStyle(
                      color: Color(0xFF9AA3AC),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFF5B56),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${offer.discountPercentage}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
