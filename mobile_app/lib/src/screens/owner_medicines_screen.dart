import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/medicine.dart';

class OwnerMedicinesScreen extends StatefulWidget {
  final List<Medicine> medicines;
  final String initialFilter;
  final VoidCallback onAddMedicine;
  final void Function(Medicine medicine) onEditMedicine;
  final Future<void> Function(Medicine medicine) onDeleteMedicine;
  final Future<List<Medicine>> Function(String query) onSearchCatalog;
  final Future<void> Function(Medicine medicine, bool fromCatalog)
  onConfigureMedicine;

  const OwnerMedicinesScreen({
    super.key,
    required this.medicines,
    this.initialFilter = 'all',
    required this.onAddMedicine,
    required this.onEditMedicine,
    required this.onDeleteMedicine,
    required this.onSearchCatalog,
    required this.onConfigureMedicine,
  });

  @override
  State<OwnerMedicinesScreen> createState() => OwnerMedicinesScreenState();
}

class _CatalogCustomAction {
  const _CatalogCustomAction();
}

class OwnerMedicinesScreenState extends State<OwnerMedicinesScreen> {
  final _searchController = TextEditingController();
  late String _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
  }

  @override
  void didUpdateWidget(covariant OwnerMedicinesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialFilter != widget.initialFilter) {
      _filter = widget.initialFilter;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _status(Medicine medicine) {
    if (!medicine.isAdded) return 'not_added';
    if (!medicine.isAvailable || medicine.quantity == 0) return 'out_of_stock';
    if (medicine.quantity < 5) return 'low_stock';
    return 'available';
  }

  Color _statusColor(String status) {
    if (status == 'available') return Colors.green.shade700;
    if (status == 'low_stock') return Colors.orange.shade800;
    if (status == 'not_added') return Colors.blueGrey.shade700;
    return Colors.red.shade700;
  }

  List<Medicine> get _visibleMedicines {
    final query = _searchController.text.trim().toLowerCase();
    return widget.medicines.where((medicine) {
      final matchesQuery =
          query.isEmpty ||
          [medicine.name, medicine.genericName, medicine.barcode]
              .whereType<String>()
              .any((value) => value.toLowerCase().contains(query));
      final status = _status(medicine);
      final isDonation = medicine.isDonation || medicine.price == 0;
      final matchesFilter =
          _filter == 'all' ||
          (_filter == 'my_medicines' && medicine.isAdded) ||
          (_filter == 'catalog' && !medicine.isAdded) ||
          (_filter == 'donations' && isDonation) ||
          status == _filter;
      return matchesQuery && matchesFilter;
    }).toList();
  }

  Future<void> openCatalog() async {
    final queryController = TextEditingController();
    List<Medicine> results = [];
    bool loading = false;
    String? error;
    int requestVersion = 0;

    final action = await showDialog<Object?>(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder: (context, setDialogState) {
              Future<void> search(String query) async {
                final version = ++requestVersion;
                if (query.trim().isEmpty) {
                  setDialogState(() {
                    results = [];
                    error = null;
                    loading = false;
                  });
                  return;
                }
                setDialogState(() {
                  loading = true;
                  error = null;
                });
                try {
                  final found = await widget.onSearchCatalog(query.trim());
                  if (!dialogContext.mounted || version != requestVersion)
                    return;
                  setDialogState(() {
                    results = found;
                    loading = false;
                  });
                } catch (_) {
                  if (!dialogContext.mounted || version != requestVersion)
                    return;
                  setDialogState(() {
                    error = 'Could not search catalog';
                    loading = false;
                  });
                }
              }

              return AlertDialog(
                title: Text('add_medicine'.tr()),
                content: SizedBox(
                  width: double.maxFinite,
                  height: 430,
                  child: Column(
                    children: [
                      TextField(
                        controller: queryController,
                        autofocus: true,
                        onChanged: search,
                        decoration: InputDecoration(
                          hintText: 'search_medicines'.tr(),
                          prefixIcon: const Icon(Icons.search),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () {
                              queryController.clear();
                              search('');
                            },
                            icon: const Icon(Icons.close),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (loading) const LinearProgressIndicator(),
                      if (error != null)
                        Text(
                          error!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      if (!loading && results.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          color: Colors.green.shade50,
                          child: Text(
                            'found_in_catalog'.tr(),
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      Expanded(
                        child:
                            results.isEmpty
                                ? (queryController.text.isEmpty
                                    ? Center(
                                      child: Text('search_master_catalog'.tr()),
                                    )
                                    : loading
                                    ? const SizedBox.shrink()
                                    : _notFound(dialogContext))
                                : ListView.separated(
                                  itemCount: results.length,
                                  separatorBuilder:
                                      (_, __) => const Divider(height: 1),
                                  itemBuilder: (_, index) {
                                    final medicine = results[index];
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: _image(medicine, size: 48),
                                      title: Text(
                                        medicine.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${medicine.categoryName ?? 'medicine'.tr()}${medicine.strength == null ? '' : ' • ${medicine.strength}'}',
                                      ),
                                      trailing: Text(
                                        medicine.isAdded
                                            ? 'added'.tr()
                                            : 'add'.tr(),
                                        style: TextStyle(
                                          color:
                                              medicine.isAdded
                                                  ? Colors.green
                                                  : const Color(0xFF005A9C),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onTap:
                                          () => Navigator.of(
                                            dialogContext,
                                          ).pop(medicine),
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton.icon(
                    onPressed:
                        () => Navigator.of(
                          dialogContext,
                        ).pop(const _CatalogCustomAction()),
                    icon: const Icon(Icons.edit_note),
                    label: Text('add_custom_medicine'.tr()),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text('cancel'.tr()),
                  ),
                ],
              );
            },
          ),
    );
    if (!mounted) return;
    if (action is Medicine) {
      await widget.onConfigureMedicine(action, true);
    } else if (action is _CatalogCustomAction) {
      widget.onAddMedicine();
    }
  }

  Widget _notFound(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.search_off, color: Colors.red.shade600, size: 34),
        const SizedBox(height: 8),
        Text(
          'not_found_catalog'.tr(),
          style: TextStyle(
            color: Colors.red.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed:
              () => Navigator.of(context).pop(const _CatalogCustomAction()),
          icon: const Icon(Icons.add),
          label: Text('add_new_medicine'.tr()),
        ),
      ],
    ),
  );

  Widget _image(Medicine medicine, {double size = 54}) {
    if (medicine.imagePath == null)
      return Icon(
        Icons.medical_services_outlined,
        size: size,
        color: const Color(0xFF005A9C),
      );
    return GestureDetector(
      onTap: () => _showImagePreview(medicine),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          medicine.imagePath!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) => Icon(
                Icons.medical_services_outlined,
                size: size,
                color: const Color(0xFF005A9C),
              ),
        ),
      ),
    );
  }

  Future<void> _showImagePreview(Medicine medicine) async {
    final imagePath = medicine.imagePath;
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
    const filters = [
      'all',
      'my_medicines',
      'catalog',
      'donations',
      'available',
      'low_stock',
      'out_of_stock',
    ];
    final medicines = _visibleMedicines;
    return Scaffold(
      body: Column(
        children: [
          if (_filter == 'low_stock')
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    color: Colors.orange.shade800,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'الأدوية منخفضة المخزون',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'search_medicines'.tr(),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children:
                  filters
                      .map(
                        (filter) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(filter.tr()),
                            avatar:
                                filter == 'donations'
                                    ? const Icon(Icons.volunteer_activism)
                                    : null,
                            selected: _filter == filter,
                            onSelected: (_) => setState(() => _filter = filter),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child:
                medicines.isEmpty
                    ? Center(child: Text('no_medicines'.tr()))
                    : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: medicines.length,
                      itemBuilder: (_, index) {
                        final medicine = medicines[index];
                        final status = _status(medicine);
                        final color = _statusColor(status);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(8),
                            leading: _image(medicine),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    medicine.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: .12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    status.tr(),
                                    style: TextStyle(
                                      color: color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                '${medicine.genericName ?? medicine.categoryName ?? 'medicine'.tr()}\n${'price'.tr()}: ر.ي ${medicine.price.toStringAsFixed(2)} | ${'quantity_short'.tr()}: ${medicine.quantity} | ${'discount_short'.tr()}: ${medicine.discountPercentage}%',
                              ),
                            ),
                            trailing: PopupMenuButton<String>(
                              enabled: medicine.isAdded,
                              onSelected: (action) {
                                if (action == 'edit')
                                  widget.onConfigureMedicine(medicine, false);
                                if (action == 'delete')
                                  widget.onDeleteMedicine(medicine);
                              },
                              itemBuilder:
                                  (_) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text('edit'.tr()),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('delete'.tr()),
                                    ),
                                  ],
                            ),
                            onTap:
                                medicine.isAdded
                                    ? () => widget.onConfigureMedicine(
                                      medicine,
                                      false,
                                    )
                                    : null,
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
