import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import '../services/owner_service.dart';
import '../models/pharmacy.dart';

class OwnerProfileScreen extends StatefulWidget {
  final OwnerService ownerService;

  const OwnerProfileScreen({super.key, required this.ownerService});

  @override
  State<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> {
  Pharmacy? _pharmacy;
  bool _loading = true;
  String? _errorMessage;
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await widget.ownerService.getPharmacyProfile();
      if (!mounted) return;
      setState(() {
        _pharmacy = profile;
        _errorMessage = null;
        _nameController.text = profile.name;
        _addressController.text = profile.address;
        _phoneController.text = profile.phone;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _pharmacy = null;
        _errorMessage = 'owner_profile_missing'.tr();
        _loading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_pharmacy == null) return;
    setState(() => _loading = true);
    try {
      await widget.ownerService.updatePharmacyProfile({
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'phone': _phoneController.text.trim(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ بيانات الصيدلية بنجاح')),
      );
      await _loadProfile();
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر حفظ بيانات الصيدلية: $error')),
      );
    }
  }

  Future<void> _pickImage() async {
    final result = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (result == null || _pharmacy == null) return;
    final file = File(result.path);
    await widget.ownerService.uploadPharmacyImage(file);
    await _loadProfile();
  }

  Future<void> _toggleStatus() async {
    if (_pharmacy == null) return;
    final nextStatus = _pharmacy!.status == 'open' ? 'closed' : 'open';
    try {
      final updated = await widget.ownerService.updateStatus(nextStatus);
      if (mounted) setState(() => _pharmacy = updated);
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'unable_update_status'.tr()}: $error')),
        );
    }
  }

  Future<void> _editHours() async {
    if (_pharmacy == null) return;
    final opening = await showTimePicker(
      context: context,
      initialTime:
          _parseTime(_pharmacy!.openingTime) ??
          const TimeOfDay(hour: 8, minute: 0),
    );
    if (opening == null || !mounted) return;
    final closing = await showTimePicker(
      context: context,
      initialTime:
          _parseTime(_pharmacy!.closingTime) ??
          const TimeOfDay(hour: 22, minute: 0),
    );
    if (closing == null) return;
    try {
      final updated = await widget.ownerService.updateWorkingHours(
        _formatTime(opening),
        _formatTime(closing),
      );
      if (mounted) setState(() => _pharmacy = updated);
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'unable_update_hours'.tr()}: $error')),
        );
    }
  }

  TimeOfDay? _parseTime(String? value) {
    if (value == null || value.length < 5) return null;
    final parts = value.substring(0, 5).split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  String _formatTime(TimeOfDay value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text('pharmacy_profile'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Colors.orange.shade900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Text(
              'pharmacy_profile'.tr(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'name'.tr()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'address'.tr()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'phone'.tr()),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save),
              label: Text('save_profile'.tr()),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: Text('upload_pharmacy_image'.tr()),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _toggleStatus,
              icon: Icon(
                _pharmacy?.status == 'open' ? Icons.lock : Icons.lock_open,
              ),
              label: Text(
                _pharmacy?.status == 'open'
                    ? 'close_pharmacy'.tr()
                    : 'open_pharmacy'.tr(),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _editHours,
              icon: const Icon(Icons.access_time),
              label: Text(
                '${'hours'.tr()}: ${_pharmacy?.openingTime ?? '-'} - ${_pharmacy?.closingTime ?? '-'}',
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: Text('logout'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
