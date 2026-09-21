import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../models/medicine.dart';
import '../models/offer.dart';
import '../models/pharmacy.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_controller.dart';
import '../screens/owner_dashboard_screen.dart';
import '../screens/owner_medicines_screen.dart';
import '../screens/owner_medicine_configure_screen.dart';
import '../screens/owner_offers_screen.dart';
import '../screens/owner_orders_screen.dart';
import '../screens/login_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/owner_profile_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/pharmacy_location_picker_screen.dart';
import '../services/owner_service.dart';
import '../widgets/owner_panel_app_bar.dart';

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  int _selectedIndex = 0;
  String _medicinesFilter = 'all';
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late final OwnerService ownerService;
  bool _initialized = false;
  bool _loading = true;
  List<Medicine> _medicines = [];
  List<Offer> _offers = [];
  List<Map<String, dynamic>> _categories = [];
  Pharmacy? _pharmacy;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _openingTimeController = TextEditingController();
  final TextEditingController _closingTimeController = TextEditingController();
  bool _profileFieldsInitialized = false;
  bool _savingProfile = false;
  bool _savingEmergencyClose = false;
  bool _notificationsEnabled = true;
  double? _selectedLatitude;
  double? _selectedLongitude;
  int _dashboardVersion = 0;
  File? _pendingPharmacyImage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      ownerService = Provider.of<OwnerService>(context, listen: false);
      _initialized = true;
      _loadLists();
      _loadPharmacy();
    }
  }

  Future<void> _loadPharmacy() async {
    try {
      final pharmacy = await ownerService.getPharmacyProfile();
      if (mounted) {
        setState(() {
          _pharmacy = pharmacy;
          _selectedLatitude = pharmacy.latitude == 0 ? null : pharmacy.latitude;
          _selectedLongitude =
              pharmacy.longitude == 0 ? null : pharmacy.longitude;
          if (!_profileFieldsInitialized) {
            _nameController.text = pharmacy.name;
            _addressController.text = pharmacy.address;
            _phoneController.text = pharmacy.phone;
            _openingTimeController.text = pharmacy.openingTime ?? '';
            _closingTimeController.text = pharmacy.closingTime ?? '';
            _profileFieldsInitialized = true;
          }
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _openingTimeController.dispose();
    _closingTimeController.dispose();
    super.dispose();
  }

  Future<void> _saveDrawerChanges() async {
    if (_pharmacy == null || _savingProfile) return;

    setState(() => _savingProfile = true);
    try {
      var latestPharmacy = await ownerService.updatePharmacyProfile({
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'phone': _phoneController.text.trim(),
        if (_selectedLatitude != null) 'latitude': _selectedLatitude,
        if (_selectedLongitude != null) 'longitude': _selectedLongitude,
      });
      latestPharmacy = await ownerService.updateWorkingHours(
        _normalizeTime(_openingTimeController.text),
        _normalizeTime(_closingTimeController.text),
      );
      if (_pendingPharmacyImage != null) {
        latestPharmacy = await ownerService.uploadPharmacyImage(
          _pendingPharmacyImage!,
        );
      }
      if (!mounted) return;
      setState(() {
        _pharmacy = latestPharmacy;
        _pendingPharmacyImage = null;
        _dashboardVersion++;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved successfully.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not save changes: $error')));
    } finally {
      if (mounted) setState(() => _savingProfile = false);
    }
  }

  Future<void> _toggleEmergencyClose(bool value) async {
    if (_pharmacy == null || _savingEmergencyClose) return;

    final previous = _pharmacy!;
    setState(() {
      _savingEmergencyClose = true;
      _pharmacy = _pharmacy!.copyWith(
        status: value ? 'closed' : 'open',
        isManuallyClosed: value,
      );
    });

    try {
      final updated = await ownerService.updateEmergencyClose(value);
      if (!mounted) return;
      setState(() {
        _pharmacy = updated;
        _dashboardVersion++;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _pharmacy = previous;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update emergency status: $error')),
      );
    } finally {
      if (mounted) setState(() => _savingEmergencyClose = false);
    }
  }

  String _normalizeTime(String value) {
    final parts = value.trim().split(':');
    if (parts.length < 2) return value.trim();
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return value.trim();
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDrawerImage() async {
    final result = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (result == null || !mounted) return;
    setState(() => _pendingPharmacyImage = File(result.path));
  }

  Future<void> _pickPharmacyLocation() async {
    final location = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder:
            (_) => PharmacyLocationPickerScreen(
              initialLocation:
                  _selectedLatitude != null && _selectedLongitude != null
                      ? LatLng(_selectedLatitude!, _selectedLongitude!)
                      : null,
            ),
      ),
    );

    if (!mounted || location == null) return;
    setState(() {
      _selectedLatitude = location.latitude;
      _selectedLongitude = location.longitude;
    });
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _openOwnerProfile() {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OwnerProfileScreen(ownerService: ownerService),
      ),
    );
  }

  void _openSettings() {
    Navigator.of(context).pop();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
  }

  void _openUserProfile() {
    Navigator.of(context).pop();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  Widget _drawerTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = const Color(0xFF005A9C),
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: color, size: 21),
        title: Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_left, size: 19),
        onTap: onTap,
      ),
    );
  }

  Widget _drawerSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile.adaptive(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        secondary: Icon(icon, color: const Color(0xFF005A9C), size: 21),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF005A9C),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF005A9C),
      ),
    );
  }

  Future<void> _loadLists() async {
    setState(() => _loading = true);
    try {
      final medicines = await ownerService.getMedicines();
      final offers = await ownerService.getOffers();
      final categories = await ownerService.getCategories();
      if (mounted) {
        setState(() {
          _medicines = medicines;
          _offers = offers;
          _categories = categories;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _addMedicine() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final manufacturerController = TextEditingController();
    final dosageFormController = TextEditingController();
    final strengthController = TextEditingController();
    final barcodeController = TextEditingController();
    final priceController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final discountController = TextEditingController(text: '0');
    final minStockController = TextEditingController(text: '5');
    final expirationController = TextEditingController();
    final imagePicker = ImagePicker();
    XFile? selectedImage;
    XFile? selectedVideo;
    bool available = true;
    bool isDonation = false;
    bool isNearExpiry = false;
    int? categoryId;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickImage() async {
              final file = await imagePicker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 85,
              );
              if (file != null) {
                setDialogState(() => selectedImage = file);
              }
            }

            Future<void> pickVideo() async {
              final file = await imagePicker.pickVideo(
                source: ImageSource.gallery,
              );
              if (file != null) {
                setDialogState(() => selectedVideo = file);
              }
            }

            return AlertDialog(
              title: const Text('Add Medicine'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: pickImage,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 130,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF005A9C),
                              ),
                            ),
                            child:
                                selectedImage != null
                                    ? ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.file(
                                        File(selectedImage!.path),
                                        width: double.infinity,
                                        height: 130,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                    : const Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.camera_alt_outlined,
                                            size: 36,
                                            color: const Color(0xFF005A9C),
                                          ),
                                          SizedBox(height: 8),
                                          Text('Add medicine image'),
                                        ],
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: pickVideo,
                            icon: const Icon(Icons.video_library_outlined),
                            label: Text(
                              selectedVideo == null
                                  ? 'Add usage video'
                                  : 'Change usage video',
                            ),
                          ),
                        ),
                        if (selectedVideo != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Video selected: ${selectedVideo!.name}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: const Color(0xFF005A9C),
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Medicine name',
                          ),
                          validator:
                              (value) =>
                                  value?.trim().isEmpty == true
                                      ? 'Required'
                                      : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          decoration: const InputDecoration(
                            labelText: 'Category',
                          ),
                          value: categoryId,
                          items:
                              _categories
                                  .map(
                                    (category) => DropdownMenuItem<int>(
                                      value: int.tryParse(
                                        category['id'].toString(),
                                      ),
                                      child: Text(category['name'].toString()),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (value) =>
                                  setDialogState(() => categoryId = value),
                          validator:
                              (value) =>
                                  value == null
                                      ? 'Please choose a category'
                                      : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: manufacturerController,
                                decoration: const InputDecoration(
                                  labelText: 'Manufacturer',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: dosageFormController,
                                decoration: const InputDecoration(
                                  labelText: 'Dosage form',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: strengthController,
                          decoration: const InputDecoration(
                            labelText: 'Strength',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: priceController,
                                enabled: !isDonation,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: const InputDecoration(
                                  labelText: 'Price',
                                ),
                                validator:
                                    (value) =>
                                        value?.trim().isEmpty == true
                                            ? 'Required'
                                            : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: discountController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Discount %',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: quantityController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Quantity',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: minStockController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Min stock',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: expirationController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Expiration date',
                            suffixIcon: Icon(Icons.calendar_today_outlined),
                          ),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now().subtract(
                                const Duration(days: 3650),
                              ),
                              lastDate: DateTime.now().add(
                                const Duration(days: 3650),
                              ),
                            );
                            if (picked != null) {
                              expirationController.text =
                                  picked.toIso8601String().split('T').first;
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: barcodeController,
                          decoration: const InputDecoration(
                            labelText: 'Barcode',
                          ),
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Available for sale'),
                          value: available,
                          onChanged:
                              (value) =>
                                  setDialogState(() => available = value),
                        ),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          secondary: const Icon(Icons.volunteer_activism),
                          title: const Text('Mark as Donation / Free Item'),
                          subtitle: const Text(
                            'Donation items are saved with a price of 0.00',
                          ),
                          value: isDonation,
                          onChanged:
                              (value) => setDialogState(() {
                                isDonation = value ?? false;
                                if (isDonation) priceController.text = '0';
                              }),
                        ),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Near-Expiry Clearance'),
                          value: isNearExpiry,
                          onChanged:
                              (value) => setDialogState(
                                () => isNearExpiry = value ?? false,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      Navigator.of(context).pop(true);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true) return;

    print(
      'Creating medicine with categoryId: $categoryId, name: ${nameController.text}',
    );

    try {
      final result = await ownerService.createMedicine({
        'name': nameController.text,
        'category_id': categoryId,
        'description': descriptionController.text,
        'manufacturer': manufacturerController.text,
        'dosage_form': dosageFormController.text,
        'strength': strengthController.text,
        'price': isDonation ? 0 : (double.tryParse(priceController.text) ?? 0),
        'quantity': int.tryParse(quantityController.text) ?? 0,
        'discount_percentage': int.tryParse(discountController.text) ?? 0,
        'expiration_date':
            expirationController.text.isNotEmpty
                ? expirationController.text
                : null,
        'barcode':
            barcodeController.text.trim().isEmpty
                ? null
                : barcodeController.text.trim(),
        'min_stock_alert': int.tryParse(minStockController.text) ?? 0,
        'is_available': available,
        'is_donation': isDonation,
        'is_near_expiry': isNearExpiry,
        if (selectedImage != null) 'image': File(selectedImage!.path),
        if (selectedVideo != null) 'video': File(selectedVideo!.path),
      });

      if (result['exists'] == true) {
        // Show beautiful dialog for existing medicine
        if (mounted) {
          await _showMedicineExistsDialog(result);
        }
        return;
      }

      print('Medicine created successfully, reloading lists...');
      await _loadLists();
      print('Lists reloaded');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم إضافة العلاج بنجاح')));
      }
    } catch (error) {
      print('Error creating medicine: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل الإضافة: $error'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _showMedicineExistsDialog(Map<String, dynamic> result) async {
    final medicineData = result['medicine'] as Map<String, dynamic>;
    final message = result['message'] as String;
    final suggestedActions =
        result['suggested_actions'] as Map<String, dynamic>?;

    final medicine = Medicine.fromJson(medicineData);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.blue.shade50],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 48,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  'تنبيه',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),

                // Message
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),

                // Medicine Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.medical_services,
                            color: const Color(0xFF005A9C),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              medicine.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'التصنيف: ${medicine.categoryName ?? "غير محدد"}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'السعر: ر.ي ${medicine.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'الكمية المتوفرة: ${medicine.quantity}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                if (suggestedActions != null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        _editMedicine(medicine);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('تعديل السعر والكمية'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF005A9C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('إلغاء'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _editMedicine(Medicine medicine) async {
    final name = TextEditingController(text: medicine.name);
    final price = TextEditingController(text: medicine.price.toString());
    final quantity = TextEditingController(text: medicine.quantity.toString());
    final discount = TextEditingController(
      text: medicine.discountPercentage.toString(),
    );
    final description = TextEditingController(text: medicine.description);
    final barcode = TextEditingController();
    final expiration = TextEditingController();
    final imagePicker = ImagePicker();
    XFile? selectedImage;
    bool available = true;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickImage() async {
              final file = await imagePicker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 85,
              );
              if (file != null) {
                setDialogState(() => selectedImage = file);
              }
            }

            return AlertDialog(
              title: const Text('Edit Medicine'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: pickImage,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF005A9C)),
                          ),
                          child:
                              medicine.imagePath != null &&
                                      selectedImage == null
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      medicine.imagePath!,
                                      width: double.infinity,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                  : selectedImage != null
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.file(
                                      File(selectedImage!.path),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                  : const Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.image_outlined,
                                          size: 32,
                                          color: const Color(0xFF005A9C),
                                        ),
                                        SizedBox(height: 8),
                                        Text('Update image'),
                                      ],
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: name,
                        decoration: const InputDecoration(labelText: 'Name'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: description,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: price,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'Price',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: quantity,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Quantity',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: discount,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Discount %',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: barcode,
                              decoration: const InputDecoration(
                                labelText: 'Barcode',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: expiration,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Expiration date',
                          suffixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 3650),
                            ),
                            lastDate: DateTime.now().add(
                              const Duration(days: 3650),
                            ),
                          );
                          if (picked != null) {
                            expiration.text =
                                picked.toIso8601String().split('T').first;
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Available for sale'),
                        value: available,
                        onChanged:
                            (value) => setDialogState(() => available = value),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
    if (result != true) return;
    try {
      final payload = {
        'name': name.text,
        'description': description.text,
        'price': double.tryParse(price.text) ?? medicine.price,
        'quantity': int.tryParse(quantity.text) ?? medicine.quantity,
        'discount_percentage':
            int.tryParse(discount.text) ?? medicine.discountPercentage,
        'expiration_date': expiration.text.isNotEmpty ? expiration.text : null,
        'barcode': barcode.text.trim().isEmpty ? null : barcode.text.trim(),
        'is_available': available,
        if (selectedImage != null) 'image': File(selectedImage!.path),
      };
      await ownerService.updateMedicine(medicine.id, payload);
      await _loadLists();
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update medicine: $error')),
        );
    }
  }

  Future<void> _deleteMedicine(Medicine medicine) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete medicine?'),
            content: Text('Delete ${medicine.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (confirmed != true) return;
    try {
      await ownerService.deleteMedicine(medicine.id);
      await _loadLists();
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete medicine: $error')),
        );
    }
  }

  Future<void> _configureMedicine(
    Medicine medicine, {
    bool fromCatalog = false,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => OwnerMedicineConfigureScreen(
              service: ownerService,
              medicine: medicine,
              fromCatalog: fromCatalog,
            ),
      ),
    );
    await _loadLists();
  }

  Future<void> _addOffer() async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final discountController = TextEditingController(text: '0');
    final startController = TextEditingController(
      text: DateTime.now().toIso8601String().split('T').first,
    );
    final endController = TextEditingController(
      text:
          DateTime.now()
              .add(const Duration(days: 30))
              .toIso8601String()
              .split('T')
              .first,
    );
    final imagePicker = ImagePicker();
    XFile? selectedImage;
    bool active = true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickImage() async {
              final file = await imagePicker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 85,
              );
              if (file != null) {
                setDialogState(() => selectedImage = file);
              }
            }

            return AlertDialog(
              title: const Text('Add Offer'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: pickImage,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: double.infinity,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF005A9C),
                              ),
                            ),
                            child:
                                selectedImage != null
                                    ? ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.file(
                                        File(selectedImage!.path),
                                        width: double.infinity,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                    : const Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.local_offer_outlined,
                                            size: 34,
                                            color: const Color(0xFF005A9C),
                                          ),
                                          SizedBox(height: 8),
                                          Text('Add offer image'),
                                        ],
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(labelText: 'Title'),
                          validator:
                              (value) =>
                                  value?.trim().isEmpty == true
                                      ? 'Required'
                                      : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: discountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Discount %',
                          ),
                          validator:
                              (value) =>
                                  value?.trim().isEmpty == true
                                      ? 'Required'
                                      : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: descriptionController,
                          minLines: 2,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: startController,
                                readOnly: true,
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now().subtract(
                                      const Duration(days: 3650),
                                    ),
                                    lastDate: DateTime.now().add(
                                      const Duration(days: 3650),
                                    ),
                                  );
                                  if (picked != null) {
                                    startController.text =
                                        picked
                                            .toIso8601String()
                                            .split('T')
                                            .first;
                                  }
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Start date',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: endController,
                                readOnly: true,
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now().add(
                                      const Duration(days: 1),
                                    ),
                                    firstDate: DateTime.now().subtract(
                                      const Duration(days: 3650),
                                    ),
                                    lastDate: DateTime.now().add(
                                      const Duration(days: 3650),
                                    ),
                                  );
                                  if (picked != null) {
                                    endController.text =
                                        picked
                                            .toIso8601String()
                                            .split('T')
                                            .first;
                                  }
                                },
                                decoration: const InputDecoration(
                                  labelText: 'End date',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Offer active'),
                          value: active,
                          onChanged:
                              (value) => setDialogState(() => active = value),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      Navigator.of(context).pop(true);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true) return;

    try {
      await ownerService.createOffer({
        'title': titleController.text,
        'description': descriptionController.text,
        'discount_percentage': int.tryParse(discountController.text) ?? 0,
        'start_date': startController.text,
        'end_date': endController.text,
        if (selectedImage != null) 'image': File(selectedImage!.path),
      });
      await _loadLists();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not add offer: $error')));
      }
    }
  }

  Future<void> _editOffer(Offer offer) async {
    final title = TextEditingController(text: offer.title);
    final description = TextEditingController(text: offer.description);
    final discount = TextEditingController(
      text: offer.discountPercentage.toString(),
    );
    final start = TextEditingController(text: offer.startDate ?? '');
    final end = TextEditingController(text: offer.endDate ?? '');
    final imagePicker = ImagePicker();
    XFile? selectedImage;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickImage() async {
              final file = await imagePicker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 85,
              );
              if (file != null) {
                setDialogState(() => selectedImage = file);
              }
            }

            return AlertDialog(
              title: const Text('Edit Offer'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      InkWell(
                        onTap: pickImage,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          height: 110,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF005A9C)),
                          ),
                          child:
                              offer.imagePath != null && selectedImage == null
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      offer.imagePath!,
                                      width: double.infinity,
                                      height: 110,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                  : selectedImage != null
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.file(
                                      File(selectedImage!.path),
                                      width: double.infinity,
                                      height: 110,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                  : const Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.image_outlined,
                                          size: 32,
                                          color: const Color(0xFF005A9C),
                                        ),
                                        SizedBox(height: 8),
                                        Text('Update image'),
                                      ],
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: title,
                        decoration: const InputDecoration(labelText: 'Title'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: description,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: discount,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Discount %',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: start,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'Start date',
                              ),
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now().subtract(
                                    const Duration(days: 3650),
                                  ),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 3650),
                                  ),
                                );
                                if (picked != null) {
                                  start.text =
                                      picked.toIso8601String().split('T').first;
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: end,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'End date',
                              ),
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now().add(
                                    const Duration(days: 1),
                                  ),
                                  firstDate: DateTime.now().subtract(
                                    const Duration(days: 3650),
                                  ),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 3650),
                                  ),
                                );
                                if (picked != null) {
                                  end.text =
                                      picked.toIso8601String().split('T').first;
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
    if (result != true) return;
    try {
      await ownerService.updateOffer(offer.id, {
        'title': title.text,
        'description': description.text,
        'discount_percentage':
            int.tryParse(discount.text) ?? offer.discountPercentage,
        'start_date': start.text,
        'end_date': end.text,
        if (selectedImage != null) 'image': File(selectedImage!.path),
      });
      await _loadLists();
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update offer: $error')),
        );
    }
  }

  Future<void> _deleteOffer(Offer offer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete offer?'),
            content: Text('Delete ${offer.title}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (confirmed != true) return;
    try {
      await ownerService.deleteOffer(offer.id);
      await _loadLists();
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete offer: $error')),
        );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        _medicinesFilter = 'all';
      }
    });
  }

  void _openLowStockMedicines() {
    setState(() {
      _selectedIndex = 1;
      _medicinesFilter = 'low_stock';
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      OwnerDashboardScreen(
        key: ValueKey(_dashboardVersion),
        ownerService: ownerService,
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
        onMedicinesPressed: () => _onItemTapped(1),
        onLowStockPressed: _openLowStockMedicines,
        onOffersPressed: () => _onItemTapped(2),
        onOrdersPressed: () => _onItemTapped(3),
      ),
      OwnerMedicinesScreen(
        key: ValueKey(_medicinesFilter),
        medicines: _medicines,
        initialFilter: _medicinesFilter,
        onAddMedicine: _addMedicine,
        onEditMedicine: _editMedicine,
        onDeleteMedicine: _deleteMedicine,
        onSearchCatalog: ownerService.searchCatalogMedicines,
        onConfigureMedicine:
            (medicine, fromCatalog) =>
                _configureMedicine(medicine, fromCatalog: fromCatalog),
      ),
      OwnerOffersScreen(
        offers: _offers,
        onAddOffer: _addOffer,
        onEditOffer: _editOffer,
        onDeleteOffer: _deleteOffer,
      ),
      OwnerOrdersScreen(ownerService: ownerService),
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar:
          _selectedIndex == 0
              ? null
              : OwnerPanelAppBar(
                title:
                    _selectedIndex == 1
                        ? (_medicinesFilter == 'low_stock'
                            ? 'الأدوية منخفضة المخزون'
                            : 'medicines'.tr())
                        : _selectedIndex == 2
                        ? 'offers'.tr()
                        : 'orders'.tr(),
                onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
                onAddPressed:
                    _selectedIndex == 1
                        ? _addMedicine
                        : _selectedIndex == 2
                        ? _addOffer
                        : null,
              ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.78,
        backgroundColor: const Color(0xFFF8FAFA),
        child: SafeArea(
          child: Column(
            children: [
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  final user = authProvider.user;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                    child: Column(
                      children: [
                        const Text(
                          'الملف الشخصي',
                          style: TextStyle(
                            color: Color(0xFF005A9C),
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 14),
                        CircleAvatar(
                          radius: 38,
                          backgroundColor: const Color(0xFFE8F0F0),
                          backgroundImage:
                              _pendingPharmacyImage != null
                                  ? FileImage(_pendingPharmacyImage!)
                                  : _pharmacy?.imageUrl != null &&
                                      _pharmacy!.imageUrl!.isNotEmpty
                                  ? NetworkImage(_pharmacy!.imageUrl!)
                                  : user?.avatarUrl != null &&
                                      user!.avatarUrl!.isNotEmpty
                                  ? NetworkImage(user.avatarUrl!)
                                  : const AssetImage(
                                    'assets/pharmacy_default.jpg',
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user?.name.isNotEmpty == true
                              ? user!.name
                              : (_pharmacy?.name ?? 'Pharmacy Panel'),
                          style: const TextStyle(
                            color: Color(0xFF005A9C),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (user?.email.isNotEmpty == true) ...[
                          const SizedBox(height: 4),
                          Text(
                            user!.email,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 11,
                            ),
                          ),
                        ],
                        if (_pharmacy?.phone.isNotEmpty == true) ...[
                          const SizedBox(height: 3),
                          Text(
                            _pharmacy!.phone,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: [
                    _drawerTile(
                      icon: Icons.add_circle_outline,
                      title: 'إضافة دواء',
                      onTap: () {
                        Navigator.of(context).pop();
                        _addMedicine();
                      },
                    ),
                    _drawerTile(
                      icon: Icons.local_offer_outlined,
                      title: 'إضافة عرض',
                      onTap: () {
                        Navigator.of(context).pop();
                        _addOffer();
                      },
                    ),
                    _drawerTile(
                      icon: Icons.edit_outlined,
                      title: 'تعديل بيانات الصيدلية',
                      onTap: _openOwnerProfile,
                    ),
                    _drawerTile(
                      icon: Icons.person_outline,
                      title: 'تعديل البيانات الشخصية',
                      onTap: _openUserProfile,
                    ),
                    _drawerTile(
                      icon: Icons.language,
                      title: 'اللغة',
                      trailing: Text(
                        context.locale.languageCode == 'ar'
                            ? 'العربية'
                            : 'English',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                        ),
                      ),
                      onTap: _openSettings,
                    ),
                    _drawerSwitchTile(
                      icon: Icons.dark_mode_outlined,
                      title: 'الوضع الليلي',
                      value:
                          context.watch<ThemeController>().mode ==
                          ThemeMode.dark,
                      onChanged:
                          (value) =>
                              context.read<ThemeController>().toggle(value),
                    ),
                    _drawerSwitchTile(
                      icon: Icons.notifications_none,
                      title: 'الإشعارات',
                      value: _notificationsEnabled,
                      onChanged:
                          (value) =>
                              setState(() => _notificationsEnabled = value),
                    ),
                    _drawerSwitchTile(
                      icon: Icons.warning_amber_rounded,
                      title: 'إغلاق الصيدلية العاجل',
                      value: _pharmacy?.isManuallyClosed ?? false,
                      onChanged:
                          _pharmacy == null || _savingEmergencyClose
                              ? (_) {}
                              : _toggleEmergencyClose,
                    ),
                    _drawerTile(
                      icon: Icons.local_pharmacy_outlined,
                      title: 'تغيير شعار الصيدلية',
                      onTap: _pickDrawerImage,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                child: _drawerTile(
                  icon: Icons.logout,
                  title: 'تسجيل الخروج',
                  color: Colors.redAccent,
                  onTap: _logout,
                ),
              ),
            ],
          ),
        ),
      ),
      body:
          (_selectedIndex == 1 || _selectedIndex == 2 || _selectedIndex == 3) &&
                  _loading
              ? const Center(child: CircularProgressIndicator())
              : pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'dashboard'.tr(),
          ),
          NavigationDestination(
            icon: Icon(Icons.medication),
            label: 'medicines'.tr(),
          ),
          NavigationDestination(
            icon: Icon(Icons.local_offer),
            label: 'offers'.tr(),
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'orders'.tr(),
          ),
        ],
      ),
    );
  }
}
