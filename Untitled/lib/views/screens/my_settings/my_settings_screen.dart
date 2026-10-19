import 'package:ecommerce_app/views/screens/my_settings/help_support_screen.dart';
import 'package:ecommerce_app/views/screens/my_settings/legal_privacy_screen.dart';
import 'package:ecommerce_app/views/screens/my_settings/security_settings_screen.dart';
import 'package:ecommerce_app/views/screens/my_settings/select_lang_screen.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/app_colors.dart';

/// "My Settings" screen — entry point for Notifications, Security
/// Settings, Language Preference, Legal & Privacy, and Help & Support.
class MySettingsScreen extends StatefulWidget {
  const MySettingsScreen({super.key});

  @override
  State<MySettingsScreen> createState() => _MySettingsScreenState();
}

class _MySettingsScreenState extends State<MySettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _toggleTile(Icons.notifications_none_rounded, 'Notifications', _notificationsEnabled,
                      (v) => setState(() => _notificationsEnabled = v)),
                  _navTile(Icons.shield_outlined, 'Security Settings',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SecuritySettingsScreen()))),
                  _navTile(Icons.flag_outlined, 'Language Preference',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SelectLanguageScreen()))),
                  _navTile(Icons.lock_outline, 'Legal & Privacy',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalPrivacyScreen()))),
                  _navTile(Icons.help_outline, 'Help & Support',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen()))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          const Text('My Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _toggleTile(IconData icon, String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textDark),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textDark))),
          Switch(value: value, onChanged: onChanged, activeColor: AppColors.primaryBlue),
        ],
      ),
    );
  }

  Widget _navTile(IconData icon, String label, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textDark),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textDark))),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }
}