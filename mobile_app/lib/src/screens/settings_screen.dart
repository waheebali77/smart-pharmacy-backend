import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/pharmacy.dart';
import '../services/owner_service.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Pharmacy? _pharmacy;
  bool _loadingPharmacy = true;
  bool _savingEmergencyClose = false;

  @override
  void initState() {
    super.initState();
    _loadPharmacy();
  }

  Future<void> _loadPharmacy() async {
    if (!context.read<AuthProvider>().isOwner) {
      if (mounted) setState(() => _loadingPharmacy = false);
      return;
    }

    try {
      final pharmacy = await context.read<OwnerService>().getPharmacyProfile();
      if (mounted) setState(() => _pharmacy = pharmacy);
    } catch (_) {
      // Customer accounts do not have an owner pharmacy profile.
    } finally {
      if (mounted) setState(() => _loadingPharmacy = false);
    }
  }

  Future<void> _toggleEmergencyClose(bool value) async {
    if (_pharmacy == null || _savingEmergencyClose) return;
    final previous = _pharmacy!;
    setState(() {
      _savingEmergencyClose = true;
      _pharmacy = previous.copyWith(
        status: value ? 'closed' : previous.status,
        isManuallyClosed: value,
      );
    });

    try {
      final updated = await context.read<OwnerService>().updateEmergencyClose(value);
      if (mounted) setState(() => _pharmacy = updated);
    } catch (error) {
      if (!mounted) return;
      setState(() => _pharmacy = previous);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update emergency status: $error')),
      );
    } finally {
      if (mounted) setState(() => _savingEmergencyClose = false);
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text('delete_account'.tr()),
            content: Text('delete_account_warning'.tr()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text('cancel'.tr()),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text('delete'.tr()),
              ),
            ],
          ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await context.read<AuthProvider>().deleteAccount();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('delete_account_failed'.tr(args: ['$error']))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(title: Text('settings'.tr())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.language),
              title: Text('language'.tr()),
              subtitle: Text(isArabic ? 'العربية' : 'English'),
              trailing: DropdownButton<Locale>(
                value: context.locale,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: Locale('en'), child: Text('English')),
                  DropdownMenuItem(value: Locale('ar'), child: Text('العربية')),
                ],
                onChanged: (locale) {
                  if (locale != null) context.setLocale(locale);
                },
              ),
            ),
          ),
          if (!_loadingPharmacy && _pharmacy != null) ...[
            const SizedBox(height: 12),
            Card(
              child: SwitchListTile.adaptive(
                secondary: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                ),
                title: const Text('Emergency Close'),
                subtitle: const Text('Force the pharmacy closed immediately'),
                value: _pharmacy!.isManuallyClosed,
                onChanged: _savingEmergencyClose ? null : _toggleEmergencyClose,
              ),
            ),
          ],
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _deleteAccount(context),
            icon: const Icon(Icons.delete_forever_outlined),
            label: Text('delete_account'.tr()),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
