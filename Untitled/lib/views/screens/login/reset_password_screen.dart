import 'package:ecommerce_app/utils/validators.dart';
import 'package:ecommerce_app/viewmodel/password_reset_viewmodel.dart';
import 'package:ecommerce_app/views/screens/login/reset_success_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit(PasswordResetViewModel viewModel) async {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) return;

    final success = await viewModel.resetPassword(
      email: widget.email,
      otp: widget.otp,
      newPassword: _newPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ResetPasswordSuccessScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.resetError ?? 'Could not reset password'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PasswordResetViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // Was: SingleChildScrollView wrapping a SizedBox forced to
        // EXACTLY the screen height — that made the scroll view's
        // content never taller than the viewport, so there was never
        // anything to actually scroll. Combined with the Spacer below
        // (which can't shrink past zero), landscape mode — where the
        // available height is much smaller — just overflowed instead
        // of scrolling. Now the Column sizes to its real content and
        // the ScrollView is free to scroll it whenever it doesn't fit.
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2562E8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    text: 'Reset ',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF121926),
                    ),
                    children: [
                      TextSpan(
                        text: 'password',
                        style: TextStyle(color: Color(0xFF2562E8)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Let’s get you back on track. Set a new\npassword to secure your account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Color(0xFF9AA4B2),
                  ),
                ),
                const SizedBox(height: 30),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'New Password',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF121926),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _buildInput(
                  controller: _newPasswordController,
                  hint: 'Enter new password',
                  icon: Icons.lock_outline,
                  obscure: _obscurePassword,
                  suffixIcon: _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  onSuffixTap: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  validator: Validators.password,
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Confirm New Password',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF121926),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _buildInput(
                  controller: _confirmPasswordController,
                  hint: 'Confirm new password',
                  icon: Icons.lock_outline,
                  obscure: _obscurePassword,
                  validator: (v) => Validators.confirmPassword(
                    v,
                    _newPasswordController.text,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 58,
                  child: ElevatedButton(
                    onPressed: viewModel.isResetting
                        ? null
                        : () => _submit(viewModel),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2562E8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: viewModel.isResetting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Reset Password',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
    String? Function(String?)? validator,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 60),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE6E8EF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFFB9C0CC), size: 22),
          suffixIcon: suffixIcon != null
              ? GestureDetector(
                  onTap: onSuffixTap,
                  child: Icon(
                    suffixIcon,
                    color: const Color(0xFFB9C0CC),
                    size: 22,
                  ),
                )
              : null,
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFC3C8D1), fontSize: 15),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
        ),
      ),
    );
  }
}