import 'package:flutter/material.dart';

import '../models/order.dart';
import '../services/owner_service.dart';

class OwnerOrderDetailsScreen extends StatefulWidget {
  final Order order;
  final OwnerService ownerService;

  const OwnerOrderDetailsScreen({
    super.key,
    required this.order,
    required this.ownerService,
  });

  @override
  State<OwnerOrderDetailsScreen> createState() =>
      _OwnerOrderDetailsScreenState();
}

class _OwnerOrderDetailsScreenState extends State<OwnerOrderDetailsScreen> {
  late Order _order;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  Future<void> _updateStatus(String action) async {
    if (_updating) return;
    setState(() => _updating = true);
    try {
      final updatedOrder = await widget.ownerService.updateOrderStatus(
        _order.id,
        action,
      );
      if (!mounted) return;
      setState(() => _order = updatedOrder);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث حالة الطلب بنجاح')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر تحديث الطلب: $error')));
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return 'مقبول';
      case 'delivered':
      case 'completed':
        return 'مكتمل';
      case 'rejected':
      case 'cancelled':
        return 'ملغي';
      case 'ready':
        return 'جاهز';
      default:
        return 'قيد الانتظار';
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'ready':
        return const Color(0xFF159B73);
      case 'delivered':
      case 'completed':
        return const Color(0xFF005A9C);
      case 'rejected':
      case 'cancelled':
        return const Color(0xFFE55353);
      default:
        return const Color(0xFFF0A33A);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(_order.status);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('تفاصيل الطلب #${_order.id}'),
          backgroundColor: const Color(0xFF005A9C),
          foregroundColor: Colors.white,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionCard(
              title: 'ملخص الطلب',
              child: Column(
                children: [
                  _InfoRow(
                    label: 'الحالة',
                    value: _statusLabel(_order.status),
                    valueColor: statusColor,
                  ),
                  _InfoRow(
                    label: 'التاريخ',
                    value: _order.createdAt ?? 'غير متوفر',
                  ),
                  _InfoRow(
                    label: 'الإجمالي',
                    value: 'ر.ي ${_order.totalPrice.toStringAsFixed(2)}',
                  ),
                ],
              ),
            ),
            _sectionCard(
              title: 'بيانات العميل',
              child: Column(
                children: [
                  _InfoRow(
                    label: 'الاسم',
                    value: _order.customerName ?? 'غير متوفر',
                  ),
                  _InfoRow(
                    label: 'رقم الهاتف',
                    value: _order.customerPhone ?? 'غير متوفر',
                  ),
                ],
              ),
            ),
            _sectionCard(
              title: 'الاستلام والتوصيل',
              child: const Column(
                children: [
                  _InfoRow(label: 'طريقة الاستلام', value: 'غير متوفر'),
                  _InfoRow(label: 'العنوان', value: 'غير متوفر'),
                ],
              ),
            ),
            _sectionCard(
              title: 'الأدوية',
              child: Column(
                children:
                    _order.items
                        .map(
                          (item) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(item.medicineName),
                            subtitle: Text('الكمية: ${item.quantity}'),
                            trailing: Text(
                              'ر.ي ${item.price.toStringAsFixed(2)}',
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    final status = _order.status.toLowerCase();
    final canAccept = status == 'pending';
    final canPrepare = status == 'accepted';
    final canMarkReady = status == 'preparing';
    final canReject =
        status == 'pending' ||
        status == 'accepted' ||
        status == 'preparing' ||
        status == 'ready';
    final canDeliver = status == 'ready';
    if (!canAccept &&
        !canPrepare &&
        !canMarkReady &&
        !canReject &&
        !canDeliver) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(top: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'تحديث حالة الطلب',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            if (canAccept)
              FilledButton.icon(
                onPressed: _updating ? null : () => _updateStatus('accept'),
                icon: const Icon(Icons.check),
                label: const Text('قبول الطلب'),
              ),
            if (canPrepare)
              FilledButton.icon(
                onPressed: _updating ? null : () => _updateStatus('preparing'),
                icon: const Icon(Icons.pending_actions),
                label: const Text('بدء تجهيز الطلب'),
              ),
            if (canMarkReady)
              FilledButton.icon(
                onPressed: _updating ? null : () => _updateStatus('ready'),
                icon: const Icon(Icons.inventory_2_outlined),
                label: const Text('جاهز للاستلام'),
              ),
            if (canDeliver)
              FilledButton.icon(
                onPressed: _updating ? null : () => _updateStatus('delivered'),
                icon: const Icon(Icons.done_all),
                label: const Text('تحديد كمكتمل'),
              ),
            if (canReject)
              OutlinedButton.icon(
                onPressed: _updating ? null : () => _updateStatus('reject'),
                icon: const Icon(Icons.close),
                label: const Text('إلغاء الطلب'),
              ),
            if (_updating)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B))),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: valueColor ?? const Color(0xFF172B4D),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
