import 'package:ecommerce_app/viewmodel/admin_notification_viewmodel.dart';
import 'package:ecommerce_app/views/admin_screens/admin_customers.dart';
import 'package:ecommerce_app/views/admin_screens/admin_employee_screen.dart';
import 'package:ecommerce_app/views/admin_screens/admin_notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/views/screens/login/login_screen.dart';
import 'package:ecommerce_app/views/admin_screens/admin_dashboard.dart';
import 'package:ecommerce_app/views/admin_screens/admin_orders_screen.dart';
import 'package:ecommerce_app/views/admin_screens/admin_payment_screen.dart';
import 'package:ecommerce_app/views/admin_screens/admin_products.dart';
import 'package:ecommerce_app/views/admin_screens/admin_returns_screen.dart';
import 'package:ecommerce_app/views/admin_screens/admin_support_screen.dart';
import 'admin_viewmodel/admin_auth_viewmodel.dart';

const Color _accent = Color(0xFF6366F1);

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminNotificationViewModel>().fetchNotifications();
    });
  }

  static const List<_NavItem> _items = [
    _NavItem('Dashboard', Icons.dashboard_rounded),
    _NavItem('Products', Icons.inventory_2_rounded),
    _NavItem('Orders', Icons.receipt_long_rounded),
    _NavItem('Returns', Icons.assignment_return_rounded),
    _NavItem('Payments', Icons.payments_rounded),
    _NavItem('Employees', Icons.badge_rounded),
    _NavItem('Customers', Icons.people_alt_rounded),
    _NavItem('Support', Icons.support_agent_rounded),
  ];

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to manage the store.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Log out')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await context.read<AdminAuthViewModel>().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = const [
      AdminDashboardScreen(),
      AdminProductsScreen(),
      AdminOrdersScreen(),
      AdminReturnsScreen(),
      AdminPaymentsScreen(),
      AdminEmployeesScreen(),
      AdminCustomersScreen(),
      AdminSupportScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF0F172A),
        title: Text(_items[_index].label, style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          Consumer<AdminNotificationViewModel>(
            builder: (context, notificationViewModel, _) => Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminNotificationsScreen()));
                    if (mounted) context.read<AdminNotificationViewModel>().fetchNotifications();
                  },
                  icon: const Icon(Icons.notifications_none_rounded),
                ),
                if (notificationViewModel.unreadCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          notificationViewModel.unreadCount > 9 ? '9+' : '${notificationViewModel.unreadCount}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(),
      body: SafeArea(child: IndexedStack(index: _index, children: tabs)),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_accent, Color(0xFF8B5CF6)]),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 36),
                  SizedBox(height: 12),
                  Text('Kicks Admin', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  SizedBox(height: 2),
                  Text('Store management', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _items.length,
                itemBuilder: (context, i) {
                  final selected = i == _index;
                  final item = _items[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                    child: Material(
                      color: selected ? _accent.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        leading: Icon(item.icon, color: selected ? _accent : const Color(0xFF64748B), size: 22),
                        title: Text(
                          item.label,
                          style: TextStyle(fontSize: 14, fontWeight: selected ? FontWeight.w800 : FontWeight.w600, color: selected ? _accent : const Color(0xFF0F172A)),
                        ),
                        onTap: () {
                          setState(() => _index = i);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
                title: const Text('Log out', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w700, fontSize: 14)),
                onTap: _confirmLogout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  const _NavItem(this.label, this.icon);
}