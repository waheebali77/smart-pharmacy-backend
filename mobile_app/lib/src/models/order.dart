import 'order_item.dart';

class Order {
  final int id;
  final String status;
  final double totalPrice;
  final List<OrderItem> items;
  final String? createdAt;
  final String? customerName;
  final String? customerPhone;

  const Order({
    required this.id,
    required this.status,
    required this.totalPrice,
    required this.items,
    this.createdAt,
    this.customerName,
    this.customerPhone,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return Order(
      id: (json['id'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'pending',
      totalPrice: _parseDouble(json['total_price']),
      items:
          rawItems is List
              ? rawItems
                  .whereType<Map>()
                  .map(
                    (item) =>
                        OrderItem.fromJson(Map<String, dynamic>.from(item)),
                  )
                  .toList()
              : const [],
      createdAt: json['created_at']?.toString(),
      customerName: (json['customer'] as Map?)?['name']?.toString(),
      customerPhone: (json['customer'] as Map?)?['phone']?.toString(),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
