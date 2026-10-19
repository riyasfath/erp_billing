import 'package:flutter/material.dart';
import 'package:ecommerce_app/app_colors.dart';

/// "Security Settings" screen — 2FA toggle, Security Notifications,
/// Data Privacy Options, and a "Reset to default" flow (confirm ->
/// success dialogs).
class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _twoFactorAuth = true;
  bool _loginAlerts = false;
  bool _suspiciousActivityAlerts = false;
  bool _anonymousReviews = false;
  bool _shareUsageData = false;

  void _resetToDefault() {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: AppColors.bgLight, shape: BoxShape.circle),
                child: const Icon(Icons.settings_backup_restore, color: AppColors.textDark, size: 30),
              ),
              const SizedBox(height: 16),
              const Text(
                'Reset settings to default',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              const Text(
                'Are you sure to reset settings to default',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textGrey),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.borderGrey),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _twoFactorAuth = true;
                          _loginAlerts = false;
                          _suspiciousActivityAlerts = false;
                          _anonymousReviews = false;
                          _shareUsageData = false;
                        });
                        Navigator.pop(dialogContext);
                        _showResetSuccess();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      child: const Text('Reset', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetSuccess() {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: AppColors.success.withOpacity(0.12), shape: BoxShape.circle),
                child: const Icon(Icons.check, color: AppColors.success, size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                'Reset settings success',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your settings successfully changed to default',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textGrey, height: 1.4),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Text('Back to settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
                  _toggleTile(
                    'Two-Factor Authentication (2FA)',
                    'Add an extra security layer with 2FA, requiring a code sent via SMS or email for login.',
                    _twoFactorAuth,
                    (v) => setState(() => _twoFactorAuth = v),
                  ),
                  const SizedBox(height: 20),
                  const Text('Security Notifications', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 10),
                  _toggleTile(
                    'Login Alerts',
                    'Notify via email/SMS for new device logins.',
                    _loginAlerts,
                    (v) => setState(() => _loginAlerts = v),
                  ),
                  const SizedBox(height: 12),
                  _toggleTile(
                    'Suspicious Activity Alerts',
                    'Notify if unusual activity is detected (e.g., multiple failed login attempts).',
                    _suspiciousActivityAlerts,
                    (v) => setState(() => _suspiciousActivityAlerts = v),
                  ),
                  const SizedBox(height: 20),
                  const Text('Data Privacy Options', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 10),
                  _toggleTile(
                    'Anonymous Reviews',
                    'Set your review & rating default review settings as anonymous data.',
                    _anonymousReviews,
                    (v) => setState(() => _anonymousReviews = v),
                  ),
                  const SizedBox(height: 12),
                  _toggleTile(
                    'Share Usage Data',
                    'Allow Shopivia to collect anonymized usage data for analytics & learning.',
                    _shareUsageData,
                    (v) => setState(() => _shareUsageData = v),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Reset Settings', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                            SizedBox(height: 4),
                            Text(
                              'Reset all of your settings to Shopivia default settings.',
                              style: TextStyle(fontSize: 11, color: AppColors.textGrey, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: _resetToDefault,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primaryBlue),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Reset to default', style: TextStyle(color: AppColors.primaryBlue, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
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
          const Text('Security Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _toggleTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textGrey, height: 1.4)),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Switch(value: value, onChanged: onChanged, activeColor: AppColors.primaryBlue),
      ],
    );
  }
}