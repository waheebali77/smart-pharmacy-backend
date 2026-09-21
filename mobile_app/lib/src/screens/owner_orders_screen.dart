import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/owner_service.dart';

class OwnerOrdersScreen extends StatefulWidget {
  final OwnerService ownerService;

  const OwnerOrdersScreen({super.key, required this.ownerService});

  @override
  State<OwnerOrdersScreen> createState() => _OwnerOrdersScreenState();
}

class _OwnerOrdersScreenState extends State<OwnerOrdersScreen> {
  List<Order> _orders = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  String _normalizeStatus(String status) {
    final value = status.trim();
    return value.isEmpty ? 'PENDING' : value.toUpperCase();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ready':
      case 'delivered':
        return const Color(0xFF005A9C);
      case 'accepted':
      case 'preparing':
        return const Color(0xFF1C78B5);
      default:
        return const Color(0xFF4A90C2);
    }
  }

  String _formatCreatedAt(String? value) {
    if (value == null || value.isEmpty) {
      return 'Created: --';
    }

    final parsed = DateTime.tryParse(value.replaceAll(' ', 'T'));
    if (parsed == null) {
      return 'Created: $value';
    }

    final formatted = parsed.toLocal().toString();
    return 'Created: ${formatted.replaceFirst('T', ' ').substring(0, 19)}';
  }

  Future<void> _loadOrders() async {
    try {
      final orders = await widget.ownerService.getOwnerOrders();
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
        _error = 'Unable to load orders: $error';
      });
    }
  }

  Future<void> _updateOrder(Order order, String action) async {
    try {
      await widget.ownerService.updateOrderStatus(order.id, action);
      await _loadOrders();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not update order: $error')));
    }
  }

  Widget _buildActionButtons(Order order) {
    final status = order.status.toLowerCase();

    if (status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: FilledButton(
              onPressed: () => _updateOrder(order, 'accept'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF005A9C),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Accept'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () => _updateOrder(order, 'reject'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF005A9C),
                side: const BorderSide(color: Color(0xFF005A9C), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Reject'),
            ),
          ),
        ],
      );
    }

    if (status == 'accepted') {
      return SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: () => _updateOrder(order, 'preparing'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF005A9C),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text('Start Preparing'),
        ),
      );
    }

    if (status == 'preparing') {
      return SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: () => _updateOrder(order, 'ready'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF005A9C),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text('Mark as Ready'),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed:
            status == 'ready' ? () => _updateOrder(order, 'delivered') : null,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF005A9C),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text('Mark as Delivered'),
      ),
    );
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
            FilledButton(onPressed: _loadOrders, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_orders.isEmpty) return const Center(child: Text('No orders yet.'));

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          final statusLabel = _normalizeStatus(order.status);
          final statusColor = _statusColor(order.status);

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Order #${order.id}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _formatCreatedAt(order.createdAt),
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Items',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                if (order.items.isEmpty)
                  const Text(
                    'No items',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  )
                else
                  ...order.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  color: Color(0xFF111827),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                                children: [
                                  TextSpan(text: item.medicineName),
                                  const TextSpan(text: '\n'),
                                  TextSpan(
                                    text: 'Qty: ${item.quantity}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            'ر.ي ${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 12),
                Divider(color: const Color(0xFFE5E7EB), thickness: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 17,
                        color: Color(0xFF111827),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'ر.ي ${order.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 17,
                        color: Color(0xFF111827),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildActionButtons(order),
              ],
            ),
          );
        },
      ),
    );
  }
}
