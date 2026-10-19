import 'package:ecommerce_app/core/token_storage.dart';
import 'package:ecommerce_app/viewmodel/password_reset_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/app_colors.dart';
import 'package:ecommerce_app/views/screens/login/reset_otp_screen.dart';

/// Entry point for "Change Password" from My Account. There is no
/// change-password API that takes an old password to verify — so
/// instead of a fake "enter current password" step, this reuses the
/// REAL, already-working forgot-password flow: send an OTP to the
/// user's own registered email, then verify it and set a new password
/// via ResetOtpVerifyScreen -> ResetPasswordScreen (same screens, same
/// PasswordResetViewModel, same /forgot-password/ -> /verify-otp/ ->
/// /reset-password/ endpoints already used from the login screen).
class ConfirmPasswordScreen extends StatefulWidget {
  const ConfirmPasswordScreen({super.key});

  @override
  State<ConfirmPasswordScreen> createState() => _ConfirmPasswordScreenState();
}

class _ConfirmPasswordScreenState extends State<ConfirmPasswordScreen> {
  String? _email;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  Future<void> _loadEmail() async {
    final email = await TokenStorage.instance.getEmail();
    if (!mounted) return;
    setState(() => _email = email);
  }

  Future<void> _sendCode() async {
    if (_email == null || _email!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not find your account email. Please log in again.'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isSending = true);
    final viewModel = context.read<PasswordResetViewModel>();
    final success = await viewModel.forgotPassword(email: _email!);

    if (!mounted) return;
    setState(() => _isSending = false);

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResetOtpVerifyScreen(email: _email!)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.forgotError ?? 'Could not send verification code'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 30),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.lock_outline, color: AppColors.primaryBlue, size: 32),
                ),
              ),
              const SizedBox(height: 20),
              // Both wrapped in SizedBox(width: double.infinity) inside
              // a Center so textAlign.center actually positions them
              // in the middle of the screen — the Column's own
              // crossAxisAlignment.start (kept for the back button and
              // everything else) was shrinking these to their content
              // width and leaving them stuck on the left, even though
              // textAlign was already set.
              const Center(
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Change your password',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.textDark),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    _email != null
                        ? "We'll send a verification code to $_email to confirm it's you before changing your password."
                        : "We'll send a verification code to your registered email to confirm it's you before changing your password.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: AppColors.textGrey, height: 1.4),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: (_isSending || _email == null) ? null : _sendCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    disabledBackgroundColor: AppColors.borderGrey,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: _isSending
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : const Text('Send Verification Code', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}