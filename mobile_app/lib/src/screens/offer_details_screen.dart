import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/offer.dart';
import '../services/customer_service.dart';
import 'customer_home_screen.dart';

class OfferDetailsScreen extends StatefulWidget {
  final Offer offer;
  final CustomerService? customerService;

  const OfferDetailsScreen({
    super.key,
    required this.offer,
    this.customerService,
  });

  @override
  State<OfferDetailsScreen> createState() => _OfferDetailsScreenState();
}

class _OfferDetailsScreenState extends State<OfferDetailsScreen> {
  bool _isRequesting = false;
  String? _message;
  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;

    return Scaffold(
      appBar: AppBar(title: Text(offer.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (offer.imagePath != null)
              Center(
                child: Image.network(
                  offer.imagePath!,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              )
            else
              const Center(
                child: Icon(Icons.local_offer, size: 100, color: Color(0xFF4682B4)),
              ),
            const SizedBox(height: 24),
            Text(
              offer.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              offer.description,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (offer.discountPercentage > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${offer.discountPercentage}% Discount',
                  style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 16),
            if (offer.startDate != null && offer.endDate != null) ...[
              Row(
                children: [
                  const Icon(Icons.calendar_today, color: Color(0xFF4682B4)),
                  const SizedBox(width: 8),
                  Text('Valid from: ${offer.startDate}'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.event, color: Color(0xFF4682B4)),
                  const SizedBox(width: 8),
                  Text('Until: ${offer.endDate}'),
                ],
              ),
              const SizedBox(height: 24),
            ],
            const Spacer(),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_message!, style: const TextStyle(color: Colors.redAccent)),
              ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isRequesting ? null : _requestOffer,
                    child: _isRequesting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Request Offer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestOffer() async {
    setState(() {
      _isRequesting = true;
      _message = null;
    });
    try {
      final service = widget.customerService ?? context.read<CustomerService>();
      await service.requestOffer(widget.offer.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request submitted for ${widget.offer.title}')),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => CustomerHomeScreen(key: UniqueKey(), initialIndex: 2),
        ),
        (route) => false,
      );
    } catch (error) {
      if (mounted) setState(() => _message = 'Failed to request offer: $error');
    } finally {
      if (mounted) setState(() => _isRequesting = false);
    }
  }
}
