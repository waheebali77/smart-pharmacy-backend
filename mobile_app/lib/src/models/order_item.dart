class OrderItem {
  final int id;
  final int medicineId;
  final String medicineName;
  final String? imagePath;
  final int quantity;
  final double price;

  const OrderItem({
    required this.id,
    required this.medicineId,
    required this.medicineName,
    this.imagePath,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final medicine = json['medicine'];
    return OrderItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      medicineId:
          (json['medicine_id'] as num?)?.toInt() ??
          (medicine is Map ? (medicine['id'] as num?)?.toInt() ?? 0 : 0),
      medicineName:
          medicine is Map
              ? medicine['name']?.toString() ?? 'Medicine'
              : json['medicine_name']?.toString() ?? 'Medicine',
      imagePath: medicine is Map ? medicine['image_path']?.toString() : null,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      price: _parseDouble(json['price']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
