import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'customer_dashboard_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import 'all_offers_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_controller.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  late int _selectedIndex;
  bool _notificationsEnabled = true;
  final List<Widget> _pages = const [
    CustomerDashboardScreen(),
    SearchScreen(),
    OrdersScreen(),
    AllOffersScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, _pages.length - 1);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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

  void _openProfile() {
    Navigator.of(context).pop();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  String get _pageTitle {
    switch (_selectedIndex) {
      case 1:
        return 'search'.tr();
      case 2:
        return 'my_orders'.tr();
      case 3:
        return 'offers'.tr();
      default:
        return 'app_name'.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitle),
        backgroundColor: const Color(0xFFF8FAFA),
        foregroundColor: const Color(0xFF173B3A),
        elevation: 0,
      ),
      body: _pages[_selectedIndex],
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
                        Text(
                          'الملف الشخصي',
                          style: const TextStyle(
                            color: Color(0xFF173B3A),
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CircleAvatar(
                          radius: 38,
                          backgroundColor: const Color(0xFFE8F0F0),
                          backgroundImage:
                              user?.avatarUrl != null &&
                                      user!.avatarUrl!.isNotEmpty
                                  ? NetworkImage(user.avatarUrl!)
                                  : null,
                          child:
                              user?.avatarUrl == null ||
                                      user!.avatarUrl!.isEmpty
                                  ? const Icon(
                                    Icons.person,
                                    size: 42,
                                    color: Color(0xFF173B3A),
                                  )
                                  : null,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user?.name.isNotEmpty == true
                              ? user!.name
                              : 'user'.tr(),
                          style: const TextStyle(
                            color: Color(0xFF173B3A),
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
                      icon: Icons.edit_outlined,
                      title: 'تعديل البيانات الشخصية',
                      onTap: _openProfile,
                    ),
                    _drawerTile(
                      icon: Icons.lock_outline,
                      title: 'تغيير كلمة المرور',
                      onTap: _openProfile,
                    ),
                    _drawerTile(
                      icon: Icons.language,
                      title: 'اللغة',
                      trailing: Text(
                        context.locale.languageCode == 'ar' ? 'العربية' : 'English',
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
                      onChanged: (value) =>
                          context.read<ThemeController>().toggle(value),
                    ),
                    _drawerSwitchTile(
                      icon: Icons.notifications_none,
                      title: 'الإشعارات',
                      value: _notificationsEnabled,
                      onChanged: (value) =>
                          setState(() => _notificationsEnabled = value),
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
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                label: 'home'.tr(),
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                isSelected: _selectedIndex == 0,
                onTap: () => _onItemTapped(0),
              ),
              _NavItem(
                label: 'search'.tr(),
                icon: Icons.search_outlined,
                selectedIcon: Icons.search,
                isSelected: _selectedIndex == 1,
                onTap: () => _onItemTapped(1),
              ),
              _NavItem(
                label: 'orders'.tr(),
                icon: Icons.shopping_bag_outlined,
                selectedIcon: Icons.shopping_bag,
                isSelected: _selectedIndex == 2,
                onTap: () => _onItemTapped(2),
              ),
              _NavItem(
                label: 'offers'.tr(),
                icon: Icons.local_offer_outlined,
                selectedIcon: Icons.local_offer,
                isSelected: _selectedIndex == 3,
                onTap: () => _onItemTapped(3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSettings() {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  Widget _drawerTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = const Color(0xFF173B3A),
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
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: const Color(0xFF173B3A), size: 21),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF173B3A),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF4682B4),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        isSelected ? const Color(0xFF4682B4) : const Color(0xFF9CA3AF);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? selectedIcon : icon, color: color, size: 24),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
