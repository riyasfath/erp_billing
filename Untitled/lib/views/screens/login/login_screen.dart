import 'package:ecommerce_app/admin/admin_shell.dart';
import 'package:ecommerce_app/admin/admin_viewmodel/admin_auth_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/login_viewmodel.dart';
import 'package:ecommerce_app/views/screens/dashboard/maintab.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

const Color _accent = Color(0xFF6366F1);
const Color _accent2 = Color(0xFF8B5CF6);
const Color _textDark = Color(0xFF0F172A);
const Color _textGrey = Color(0xFF64748B);
const Color _fieldBg = Color(0xFFF5F6FA);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  // Tracks the WHOLE sign-in attempt (customer login, then possibly an
  // admin-login fallback) — loginViewModel.isLoggingIn alone would flip
  // back to false between the two attempts and make the button flicker.
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn(LoginViewModel loginViewModel) async {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) return;

    setState(() => _isSubmitting = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final success = await loginViewModel.login(email: email, password: password);

    if (!mounted) return;

    if (success) {
      setState(() => _isSubmitting = false);
      _goToMainTab();
      return;
    }

    // Customer login failed — the same email/password fields double as
    // an admin's user_id/password, so try that before showing an error.
    // This is what lets one login screen serve both kinds of accounts.
    final adminAuthViewModel = context.read<AdminAuthViewModel>();
    final isAdmin = await adminAuthViewModel.login(email, password);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (isAdmin) {
      _goToAdminShell();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loginViewModel.loginError ?? 'Login failed'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _goToMainTab() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainTabScreen()),
      (route) => false,
    );
  }

  void _goToAdminShell() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AdminShell()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginViewModel = context.watch<LoginViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 36),
                  Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [_accent, _accent2],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _accent.withOpacity(0.35),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 40),
                    ),
                  ),
                  const SizedBox(height: 36),
                  const Text(
                    'Hello Again!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Welcome back, you've been missed!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: _textGrey),
                  ),
                  const SizedBox(height: 40),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Email',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _emailController,
                    hint: 'Enter your email',
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Password',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _passwordController,
                    hint: 'Enter your password',
                    icon: Icons.lock_outline_rounded,
                    obscure: _obscurePassword,
                    suffixIcon: _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                        );
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: _accent, fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 60,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(colors: [_accent, _accent2]),
                        boxShadow: [
                          BoxShadow(
                            color: _accent.withOpacity(0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : () => _signIn(loginViewModel),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                              )
                            : const Text(
                                'Sign In',
                                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: Text.rich(
                        TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(fontSize: 14, color: _textGrey),
                          children: [
                            TextSpan(
                              text: 'Sign Up For Free',
                              style: TextStyle(color: _accent, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
    String? Function(String?)? validator,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 58),
      decoration: BoxDecoration(
        color: _fieldBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontSize: 15, color: _textDark),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: _textGrey, size: 21),
          suffixIcon: suffixIcon != null
              ? GestureDetector(
                  onTap: onSuffixTap,
                  child: Icon(suffixIcon, color: _textGrey, size: 21),
                )
              : null,
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFA1A8B5), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 17, horizontal: 4),
        ),
      ),
    );
  }
}