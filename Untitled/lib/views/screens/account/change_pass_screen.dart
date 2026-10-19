import 'package:flutter/material.dart';
import 'package:ecommerce_app/app_colors.dart';

/// "Change Password" screen — New Password + Confirm New Password with
/// a live checklist (8+ chars, uppercase+number, special character).
/// On success it shows a confirmation dialog then pops back to
/// My Account.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool get _hasMinLength => _newPasswordController.text.length >= 8;
  bool get _hasUpperAndNumber =>
      RegExp(r'[A-Z]').hasMatch(_newPasswordController.text) && RegExp(r'[0-9]').hasMatch(_newPasswordController.text);
  bool get _hasSpecialChar => RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(_newPasswordController.text);

  bool get _canSave =>
      _hasMinLength &&
      _hasUpperAndNumber &&
      _hasSpecialChar &&
      _confirmPasswordController.text == _newPasswordController.text &&
      _confirmPasswordController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (!_canSave) return;
    showDialog(
      context: context,
      barrierDismissible: false,
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
                'Change Password Success',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              const Text(
                "Your password successfully changed, let's shop !",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textGrey, height: 1.4),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    // Pops Change Password, OTP, and Confirm Password —
                    // back to the My Account tab (the first route).
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Text('Continue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('New Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    const SizedBox(height: 8),
                    _passwordField(_newPasswordController, _obscureNew, () => setState(() => _obscureNew = !_obscureNew)),
                    const SizedBox(height: 12),
                    _checklistItem('Password must be at least 8 characters long', _hasMinLength),
                    _checklistItem('At least one uppercase letter and one number', _hasUpperAndNumber),
                    _checklistItem('At least one special character', _hasSpecialChar),
                    const SizedBox(height: 20),
                    const Text('Confirm New Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    const SizedBox(height: 8),
                    _passwordField(_confirmPasswordController, _obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm)),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _canSave ? _saveChanges : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          disabledBackgroundColor: AppColors.borderGrey,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                      ),
                    ),
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
          const Text('Change Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _passwordField(TextEditingController controller, bool obscure, VoidCallback toggle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderGrey)),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          suffixIcon: GestureDetector(
            onTap: toggle,
            child: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: AppColors.iconGrey),
          ),
        ),
      ),
    );
  }

  Widget _checklistItem(String text, bool satisfied) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(Icons.check, size: 14, color: satisfied ? AppColors.success : AppColors.borderGrey),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 11, color: satisfied ? AppColors.success : AppColors.textGrey),
            ),
          ),
        ],
      ),
    );
  }
}