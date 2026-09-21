import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/order.dart';
import '../services/owner_service.dart';
import '../widgets/owner_panel_app_bar.dart';
import 'owner_order_details_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  final OwnerService ownerService;
  final VoidCallback onMenuPressed;
  final VoidCallback onMedicinesPressed;
  final VoidCallback onLowStockPressed;
  final VoidCallback onOffersPressed;
  final VoidCallback onOrdersPressed;

  const OwnerDashboardScreen({
    super.key,
    required this.ownerService,
    required this.onMenuPressed,
    required this.onMedicinesPressed,
    required this.onLowStockPressed,
    required this.onOffersPressed,
    required this.onOrdersPressed,
  });

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  bool _loading = true;
  Map<String, dynamic>? _dashboard;
  List<Order> _orders = const [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final data = await widget.ownerService.getOwnerDashboard();
      List<Order> orders = const [];
      try {
        orders = await widget.ownerService.getOwnerOrders();
      } catch (_) {
        // Orders are optional for the dashboard and may fail independently.
      }
      if (!mounted) return;
      setState(() {
        _dashboard = data;
        _orders = orders;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر تحميل لوحة التحكم: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F7F8),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pharmacy = _dashboard?['pharmacy'] as Map<String, dynamic>?;
    final medicines = _dashboard?['medicines'] as List<dynamic>? ?? const [];
    final totalMedicines = _dashboard?['total_medicines'] ?? medicines.length;
    final totalOffers = _dashboard?['total_offers'] ?? 0;
    final lowStock =
        medicines.where((item) {
          if (item is! Map) return false;
          final quantity = int.tryParse(item['quantity']?.toString() ?? '');
          return quantity != null && quantity <= 5;
        }).length;
    final status = _dashboard?['open_status']?.toString() ?? 'closed';
    final image =
        pharmacy?['image_url'] ??
        pharmacy?['image_path'] ??
        pharmacy?['logo_path'] ??
        pharmacy?['image'];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF005A9C),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F8),
        appBar: OwnerPanelAppBar(
          title: 'لوحة المالك',
          onMenuPressed: widget.onMenuPressed,
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadDashboard,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                  child: _buildPharmacyCard(pharmacy, image, status),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const gap = 10.0;
                      final cardWidth = (constraints.maxWidth - (gap * 2)) / 3;

                      return SizedBox(
                        height: 124,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            SizedBox(
                              width: cardWidth,
                              child: _buildStatCard(
                                title: 'الأدوية',
                                value: '$totalMedicines',
                                icon: Icons.medication_rounded,
                                color: const Color(0xFF2684D9),
                                onTap: widget.onMedicinesPressed,
                              ),
                            ),
                            const SizedBox(width: gap),
                            SizedBox(
                              width: cardWidth,
                              child: _buildStatCard(
                                title: 'الطلبات',
                                value: '${_orders.length}',
                                icon: Icons.assignment_rounded,
                                color: const Color(0xFF318CE7),
                                onTap: widget.onOrdersPressed,
                              ),
                            ),
                            const SizedBox(width: gap),
                            SizedBox(
                              width: cardWidth,
                              child: _buildStatCard(
                                title: 'العروض',
                                value: '$totalOffers',
                                icon: Icons.local_offer_rounded,
                                color: const Color(0xFFF28C28),
                                onTap: widget.onOffersPressed,
                              ),
                            ),
                            const SizedBox(width: gap),
                            SizedBox(
                              width: cardWidth,
                              child: _buildStatCard(
                                title: 'مخزون منخفض',
                                value: '$lowStock',
                                icon: Icons.inventory_2_outlined,
                                color: const Color(0xFF8273C6),
                                onTap: widget.onLowStockPressed,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    textDirection: ui.TextDirection.rtl,
                    children: [
                      const Text(
                        'أحدث الطلبات',
                        style: TextStyle(
                          color: Color(0xFF173B4D),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: widget.onOrdersPressed,
                        child: const Text(
                          'عرض الكل',
                          style: TextStyle(
                            color: Color(0xFF008A72),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_orders.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('لا توجد طلبات حديثة')),
                  )
                else
                  ..._orders.take(5).map(_buildOrderCard),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPharmacyCard(
    Map<String, dynamic>? pharmacy,
    dynamic imagePath,
    String status,
  ) {
    final image = imagePath?.toString();
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        textDirection: ui.TextDirection.rtl,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Color(0xFF55717B)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  pharmacy?['name']?.toString() ?? 'صيدلية النور',
                  style: const TextStyle(
                    color: Color(0xFF173B4D),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                _buildStatusChip(status),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: Color(0xFF6D8790),
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        pharmacy?['address']?.toString() ??
                            'صنعاء - شارع الستين',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF6D8790),
                          fontSize: 10,
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
            width: 58,
            height: 58,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2F2),
              borderRadius: BorderRadius.circular(9),
            ),
            child:
                image != null && image.isNotEmpty
                    ? Image.network(image, fit: BoxFit.cover)
                    : const Icon(
                      Icons.local_pharmacy_rounded,
                      color: Color(0xFF008A72),
                      size: 32,
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String value) {
    final isOpen = value == 'open';
    final color = isOpen ? const Color(0xFF159B73) : const Color(0xFFE55353);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 7, color: color),
          const SizedBox(width: 4),
          Text(
            isOpen ? 'مفتوحة' : 'مغلقة',
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        height: 116,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8EFF0)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 7),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF20354A),
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF647B84),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final item = order.items.isNotEmpty ? order.items.first : null;
    final status = _orderStatus(order.status);
    final image = item?.imagePath;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (_) => OwnerOrderDetailsScreen(
                      order: order,
                      ownerService: widget.ownerService,
                    ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 25),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE7EFF0)),
            ),
            child: Row(
              textDirection: ui.TextDirection.rtl,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildOrderStatus(status.$1, status.$2),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '#ORD-${order.id.toString().padLeft(6, '0')}',
                        style: const TextStyle(
                          color: Color(0xFF314A57),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item?.medicineName ?? 'طلب صيدلية'}  •  ${order.createdAt ?? ''}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Color(0xFF8A9AA0),
                          fontSize: 10,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'ر.ي ${order.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFF314A57),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 48,
                  height: 48,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F5F5),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child:
                      image != null && image.isNotEmpty
                          ? Image.network(image, fit: BoxFit.cover)
                          : const Icon(
                            Icons.medication_rounded,
                            color: Color(0xFF008A72),
                            size: 25,
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  (String, Color) _orderStatus(String value) {
    switch (value) {
      case 'accepted':
        return ('تم القبول', const Color(0xFF159B73));
      case 'out_of_stock':
        return ('نفذ المخزون', const Color(0xFFE55353));
      default:
        return ('قيد التحضير', const Color(0xFFF0A33A));
    }
  }

  Widget _buildOrderStatus(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
