import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/medicine.dart';
import '../services/owner_service.dart';

class OwnerMedicineConfigureScreen extends StatefulWidget {
  final OwnerService service;
  final Medicine medicine;
  final bool fromCatalog;

  const OwnerMedicineConfigureScreen({
    super.key,
    required this.service,
    required this.medicine,
    this.fromCatalog = false,
  });

  @override
  State<OwnerMedicineConfigureScreen> createState() =>
      _OwnerMedicineConfigureScreenState();
}

class _OwnerMedicineConfigureScreenState
    extends State<OwnerMedicineConfigureScreen> {
  final TextEditingController _price = TextEditingController();
  final TextEditingController _discount = TextEditingController();
  final TextEditingController _quantity = TextEditingController();
  final TextEditingController _expiration = TextEditingController();
  final TextEditingController _barcode = TextEditingController();
  bool _available = false;
  bool _isDonation = false;
  bool _isNearExpiry = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final medicine = widget.medicine;
    _price.text = medicine.price.toStringAsFixed(2);
    _discount.text = medicine.discountPercentage.toString();
    _quantity.text = medicine.quantity.toString();
    _expiration.text = medicine.expirationDate ?? '';
    _barcode.text = medicine.barcode ?? '';
    _available = widget.fromCatalog ? false : medicine.isAvailable;
    _isDonation = medicine.isDonation;
    _isNearExpiry = medicine.isNearExpiry;
  }

  @override
  void dispose() {
    _price.dispose();
    _discount.dispose();
    _quantity.dispose();
    _expiration.dispose();
    _barcode.dispose();
    super.dispose();
  }

  Future<void> _chooseExpiration() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 3650)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null && mounted)
      _expiration.text = picked.toIso8601String().split('T').first;
  }

  Future<void> _save() async {
    final price = _isDonation ? 0 : double.tryParse(_price.text.trim());
    final discount = int.tryParse(_discount.text.trim());
    final quantity = int.tryParse(_quantity.text.trim());
    if (price == null ||
        price < 0 ||
        discount == null ||
        discount < 0 ||
        discount > 100 ||
        quantity == null ||
        quantity < 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('invalid_medicine_values'.tr())));
      return;
    }
    setState(() => _saving = true);
    try {
      final data = {
        'price': price,
        'discount_percentage': discount,
        'quantity': quantity,
        'expiration_date':
            _expiration.text.trim().isEmpty ? null : _expiration.text.trim(),
        'barcode': _barcode.text.trim().isEmpty ? null : _barcode.text.trim(),
        'is_available': _available && quantity > 0,
        'is_donation': _isDonation,
        'is_near_expiry': _isNearExpiry,
      };
      if (widget.fromCatalog) {
        await widget.service.addCatalogMedicine(widget.medicine.id, data);
      } else {
        await widget.service.updateMedicine(widget.medicine.id, data);
      }
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('medicine_saved'.tr())));
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'unable_save_medicine'.tr()}: $error')),
        );
      }
    }
  }

  Widget _readOnlyField(String label, String value) => InputDecorator(
    decoration: InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: const OutlineInputBorder(),
    ),
    child: Text(value.isEmpty ? 'not_specified'.tr() : value),
  );

  Future<void> _showImagePreview() async {
    final imagePath = widget.medicine.imagePath;
    if (imagePath == null || imagePath.isEmpty) return;

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder:
          (dialogContext) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(12),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4,
                  child: Image.network(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder:
                        (_, __, ___) => const Padding(
                          padding: EdgeInsets.all(32),
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white,
                            size: 64,
                          ),
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                  tooltip: 'Close image preview',
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final medicine = widget.medicine;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.fromCatalog ? 'configure_medicine'.tr() : 'edit_medicine'.tr(),
        ),
      ),
      body: Form(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (medicine.imagePath != null)
              GestureDetector(
                onTap: _showImagePreview,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    medicine.imagePath!,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
            if (medicine.imagePath != null) const SizedBox(height: 16),
            Text(
              'catalog_information'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _readOnlyField('medicine_name'.tr(), medicine.name),
            const SizedBox(height: 10),
            _readOnlyField('generic_name'.tr(), medicine.genericName ?? ''),
            const SizedBox(height: 10),
            _readOnlyField('category'.tr(), medicine.categoryName ?? ''),
            const SizedBox(height: 10),
            _readOnlyField('description'.tr(), medicine.description),
            const SizedBox(height: 10),
            _readOnlyField('manufacturer'.tr(), medicine.manufacturer ?? ''),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _readOnlyField(
                    'dosage_form'.tr(),
                    medicine.dosageForm ?? '',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _readOnlyField(
                    'strength'.tr(),
                    medicine.strength ?? '',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'pharmacy_information'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _price,
              enabled: !_isDonation,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: '${'price'.tr()} (ر.ي)',
                prefixText: ' ',
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantity,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'quantity'.tr()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _discount,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'discount_percent'.tr(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _expiration,
              readOnly: true,
              onTap: _chooseExpiration,
              decoration: InputDecoration(
                labelText: 'expiration_date'.tr(),
                suffixIcon: Icon(Icons.calendar_today_outlined),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _barcode,
              decoration: InputDecoration(labelText: 'barcode_optional'.tr()),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text('available_to_customers'.tr()),
              subtitle: Text('requires_positive_quantity'.tr()),
              value: _available,
              onChanged: (value) => setState(() => _available = value),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.volunteer_activism),
              title: Text('mark_donation'.tr()),
              subtitle: Text('donation_saved_free'.tr()),
              value: _isDonation,
              onChanged: (value) {
                setState(() {
                  _isDonation = value ?? false;
                  _price.text = _isDonation ? '0.00' : _price.text;
                });
              },
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('near_expiry_clearance'.tr()),
              value: _isNearExpiry,
              onChanged:
                  (value) => setState(() => _isNearExpiry = value ?? false),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon:
                  _saving
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.check),
              label: Text('save_medicine'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
