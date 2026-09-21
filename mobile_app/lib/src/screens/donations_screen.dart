import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../models/medicine.dart';
import '../services/customer_service.dart';
import 'medicine_details_screen.dart';

class DonationsScreen extends StatefulWidget {
  const DonationsScreen({super.key});

  @override
  State<DonationsScreen> createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen> {
  late final Future<List<Medicine>> _donationsFuture;

  @override
  void initState() {
    super.initState();
    _donationsFuture = context.read<CustomerService>().getDonationMedicines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: Text('community_donations'.tr()),
        backgroundColor: const Color(0xFF4682B4),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Medicine>>(
        future: _donationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('unable_load_donations'.tr()));
          }

          final medicines = snapshot.data ?? [];
          if (medicines.isEmpty) {
            return Center(child: Text('no_donation_medicines'.tr()));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: medicines.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder:
                (context, index) =>
                    _DonationMedicineTile(medicine: medicines[index]),
          );
        },
      ),
    );
  }
}

class _DonationMedicineTile extends StatelessWidget {
  const _DonationMedicineTile({required this.medicine});

  final Medicine medicine;

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _DonationImage(medicine: medicine),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    medicine.pharmacy?.name ?? 'participating_pharmacy'.tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 7),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE8EE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.favorite,
                          size: 13,
                          color: Color(0xFFE25575),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'free_donation_label'.tr(),
                          style: TextStyle(
                            color: Color(0xFFBE3D5C),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'free'.tr(),
              style: TextStyle(
                color: Color(0xFF4682B4),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DonationImage extends StatelessWidget {
  const _DonationImage({required this.medicine});

  final Medicine medicine;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F8F3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.medication_rounded,
        color: Color(0xFF4682B4),
        size: 30,
      ),
    );
    if (medicine.imagePath == null || medicine.imagePath!.isEmpty)
      return placeholder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        medicine.imagePath!,
        width: 68,
        height: 68,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      ),
    );
  }
}
