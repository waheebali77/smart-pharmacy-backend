import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pharmacy.dart';
import '../services/customer_service.dart';
import 'pharmacy_details_screen.dart';

class AllPharmaciesScreen extends StatelessWidget {
  const AllPharmaciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Pharmacies')),
      body: FutureBuilder<List<Pharmacy>>(
        future: context.read<CustomerService>().getAllPharmacies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Unable to load pharmacies'));
          }
          final pharmacies = snapshot.data ?? [];
          if (pharmacies.isEmpty) {
            return const Center(child: Text('No pharmacies available'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: pharmacies.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final pharmacy = pharmacies[index];
              final isOpen = pharmacy.status.toLowerCase() == 'open';
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PharmacyDetailsScreen(pharmacy: pharmacy),
                    ),
                  ),
                  leading: _PharmacyImage(pharmacy: pharmacy, size: 58),
                  title: Text(
                    pharmacy.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pharmacy.address, maxLines: 1, overflow: TextOverflow.ellipsis),
                      _StatusBadge(isOpen: isOpen),
                    ],
                  ),
                  trailing: Text(
                    pharmacy.rating?.toStringAsFixed(1) ?? '--',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isOpen});

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? Colors.green.shade700 : Colors.red.shade700;
    return Text(
      isOpen ? 'Open' : 'Closed',
      style: TextStyle(color: color, fontWeight: FontWeight.w700),
    );
  }
}

class _PharmacyImage extends StatelessWidget {
  const _PharmacyImage({required this.pharmacy, required this.size});

  final Pharmacy pharmacy;
  final double size;

  @override
  Widget build(BuildContext context) {
    final imageUrl = pharmacy.imageUrl;
    final placeholder = Container(
      width: size,
      height: size,
      color: const Color(0xFFE5F9F2),
      child: const Icon(Icons.local_pharmacy, color: Color(0xFF4682B4)),
    );
    if (imageUrl == null || imageUrl.isEmpty) return placeholder;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      ),
    );
  }
}
