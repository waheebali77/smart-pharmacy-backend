import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/offer.dart';

class OwnerOffersScreen extends StatelessWidget {
  final List<Offer> offers;
  final VoidCallback onAddOffer;
  final void Function(Offer offer) onEditOffer;
  final Future<void> Function(Offer offer) onDeleteOffer;

  const OwnerOffersScreen({
    super.key,
    required this.offers,
    required this.onAddOffer,
    required this.onEditOffer,
    required this.onDeleteOffer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: offers.length,
        itemBuilder: (context, index) {
          final offer = offers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading:
                  offer.imagePath != null
                      ? SizedBox(
                        width: 48,
                        height: 48,
                        child: Image.network(
                          offer.imagePath!,
                          fit: BoxFit.cover,
                        ),
                      )
                      : const Icon(Icons.local_offer, size: 36),
              title: Text(offer.title),
              subtitle: Text(
                '${offer.description}\n${'discount'.tr()}: ${offer.discountPercentage}% | ${offer.startDate ?? '-'} ${'to'.tr()} ${offer.endDate ?? '-'}',
              ),
              isThreeLine: true,
              trailing: PopupMenuButton<String>(
                onSelected: (action) {
                  if (action == 'edit') onEditOffer(offer);
                  if (action == 'delete') onDeleteOffer(offer);
                },
                itemBuilder:
                    (_) => [
                      PopupMenuItem(value: 'edit', child: Text('edit'.tr())),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('delete'.tr()),
                      ),
                    ],
              ),
            ),
          );
        },
      ),
    );
  }
}
