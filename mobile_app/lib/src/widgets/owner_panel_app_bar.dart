import 'package:flutter/material.dart';

class OwnerPanelAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onAddPressed;

  const OwnerPanelAppBar({
    super.key,
    required this.title,
    this.onMenuPressed,
    this.onAddPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: kToolbarHeight,
      backgroundColor: const Color(0xFF005A9C),
      foregroundColor: Colors.white,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      leading:
          onMenuPressed == null
              ? null
              : IconButton(
                onPressed: onMenuPressed,
                icon: const Icon(Icons.menu, size: 24),
                tooltip: 'القائمة',
              ),
      actions:
          onAddPressed == null
              ? null
              : [
                IconButton(
                  onPressed: onAddPressed,
                  icon: const Icon(Icons.add, size: 28),
                  tooltip: 'إضافة',
                ),
              ],
    );
  }
}
