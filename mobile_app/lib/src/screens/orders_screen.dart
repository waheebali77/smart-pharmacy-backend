import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../services/customer_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Order> _orders = [];
  bool _loading = true;
  String? _error;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final orders = await context.read<CustomerService>().getCustomerOrders();
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'تعذر تحميل الطلبات: $error';
      });
    }
  }

  Future<void> _cancelOrder(Order order) async {
    try {
      await context.read<CustomerService>().cancelOrder(order.id);
      await _loadOrders();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر إلغاء الطلب: $error')));
    }
  }

  bool _isActive(Order order) {
    return !{
      'delivered',
      'completed',
      'cancelled',
      'rejected',
    }.contains(order.status.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _loadOrders,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    final orders =
        _orders.where((order) => _isActive(order) == (_tabIndex == 0)).toList();
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: RefreshIndicator(
        onRefresh: _loadOrders,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(7, 0, 7, 20),
          children: [
            _buildTabs(),
            const SizedBox(height: 10),
            if (orders.isEmpty)
              SizedBox(
                height: 250,
                child: Center(
                  child: Text(
                    _tabIndex == 0 ? 'لا توجد طلبات نشطة' : 'لا يوجد سجل طلبات',
                    style: const TextStyle(color: Color(0xFF7B8490)),
                  ),
                ),
              )
            else
              ...orders.map(
                (order) => _OrderCard(
                  order: order,
                  onCancel:
                      order.status.toLowerCase() == 'pending'
                          ? () => _cancelOrder(order)
                          : null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 43,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5ECEB))),
      ),
      child: Row(
        children: [
          _OrderTab(
            label: 'الطلبات النشطة',
            selected: _tabIndex == 0,
            onTap: () => setState(() => _tabIndex = 0),
          ),
          _OrderTab(
            label: 'السجل',
            selected: _tabIndex == 1,
            onTap: () => setState(() => _tabIndex = 1),
          ),
        ],
      ),
    );
  }
}

class _OrderTab extends StatelessWidget {
  const _OrderTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? const Color(0xFF4682B4) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color:
                  selected ? const Color(0xFF4682B4) : const Color(0xFF7B8490),
              fontSize: 12,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onCancel});

  final Order order;
  final VoidCallback? onCancel;

  String _date(String? value) {
    if (value == null || value.length < 10) return '--';
    return value.substring(0, 10);
  }

  String _status(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return 'قيد الانتظار';
      case 'preparing':
        return 'جاري التجهيز';
      case 'ready_for_pickup':
        return 'جاهز للتسليم';
      case 'out_for_delivery':
        return 'خرج للتوصيل';
      case 'delivered':
      case 'completed':
        return 'تم التوصيل';
      case 'cancelled':
      case 'rejected':
        return 'ملغي';
      default:
        return value;
    }
  }

  Color _statusColor(String value) {
    final lower = value.toLowerCase();
    if (lower == 'cancelled' || lower == 'rejected') {
      return const Color(0xFFFFE5E5);
    }
    if (lower == 'delivered' || lower == 'completed') {
      return const Color(0xFFE5F7F2);
    }
    return const Color(0xFFDDF7EE);
  }

  @override
  Widget build(BuildContext context) {
    final item = order.items.isEmpty ? null : order.items.first;
    return Container(
      height: 106,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 7,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 78,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8F7),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                item?.imagePath != null && item!.imagePath!.isNotEmpty
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.imagePath!,
                        fit: BoxFit.contain,
                        errorBuilder:
                            (_, __, ___) => const Icon(
                              Icons.medication_outlined,
                              color: Color(0xFF4682B4),
                              size: 30,
                            ),
                      ),
                    )
                    : const Icon(
                      Icons.medication_outlined,
                      color: Color(0xFF4682B4),
                      size: 30,
                    ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '#ORD-${order.id.toString().padLeft(5, '0')}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${_date(order.createdAt)} - ${item?.medicineName ?? 'دواء'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(order.status),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    _status(order.status),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ر.ي ${order.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFF4682B4),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (item != null)
                Text(
                  'ر.ي ${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(color: Color(0xFF9AA3AC), fontSize: 9),
                ),
              if (onCancel != null)
                IconButton(
                  onPressed: onCancel,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                  icon: const Icon(
                    Icons.more_horiz,
                    size: 20,
                    color: Color(0xFF7B8490),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
