import 'package:ecommerce_app/core/token_storage.dart';
import 'package:ecommerce_app/views/screens/my_settings/my_settings_screen.dart';
import 'package:ecommerce_app/views/screens/order/my_orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/app_colors.dart';
import 'package:ecommerce_app/views/screens/account/confirm_password_screen.dart';
import 'package:ecommerce_app/views/screens/login/login_screen.dart';

/// The "Me" tab — profile header, quick "My Purchase" shortcuts
/// (Pending/Packaging/Delivery/Ratings all open My Orders for now),
/// and account actions (Change Password, My Settings, Logout).
class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  // Same source and transformation as HomeScreen's header (saved login
  // email, part before '@') so both screens show the same name instead
  // of a hardcoded 'Alexander Putra'.
  String _displayName = 'there';

  @override
  void initState() {
    super.initState();
    _loadDisplayName();
  }

  Future<void> _loadDisplayName() async {
    final email = await TokenStorage.instance.getEmail();
    if (!mounted) return;
    if (email != null && email.contains('@')) {
      setState(() => _displayName = email.split('@').first);
    }
  }

  void _openOrders(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOrdersScreen()));
  }

  void _openChangePassword(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ConfirmPasswordScreen()));
  }

  void _openSettings(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const MySettingsScreen()));
  }

  /// Clears the saved session and sends the user to LoginScreen,
  /// wiping the whole navigation stack so back-button can't return
  /// to any account screen afterwards.
  Future<void> _logout(BuildContext context) async {
    await TokenStorage.instance.clear();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to logout?', style: TextStyle(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textGrey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // close the dialog first
              _logout(context); // then clear session + navigate
            },
            child: const Text('Logout', style: TextStyle(color: AppColors.badgeRed, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Transform.translate(
              offset: const Offset(0, -24),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPurchaseCard(context),
                    const SizedBox(height: 16),
                    _buildMenuTile(Icons.lock_outline, 'Change Password', onTap: () => _openChangePassword(context)),
                    _buildMenuTile(Icons.settings_outlined, 'My Settings', onTap: () => _openSettings(context)),
                    _buildMenuTile(Icons.logout, 'Logout', color: AppColors.badgeRed, onTap: () => _confirmLogout(context)),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 64),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Account',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hi, $_displayName', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                    const Text('Ready to shop again?', style: TextStyle(fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('My Purchase', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              ),
              GestureDetector(
                onTap: () => _openOrders(context),
                child: const Text('See All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryBlue)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _purchaseShortcut(context, Icons.calendar_today_outlined, 'Pending'),
              _purchaseShortcut(context, Icons.inventory_2_outlined, 'Packaging'),
              _purchaseShortcut(context, Icons.local_shipping_outlined, 'Delivery'),
              _purchaseShortcut(context, Icons.star_border, 'Ratings'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _purchaseShortcut(BuildContext context, IconData icon, String label) {
    return GestureDetector(
      onTap: () => _openOrders(context),
      child: Column(
        children: [
          Icon(icon, size: 22, color: AppColors.textDark),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
        ],
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String label, {required VoidCallback onTap, Color color = AppColors.textDark}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color))),
            Icon(Icons.chevron_right, size: 18, color: color),
          ],
        ),
      ),
    );
  }
}