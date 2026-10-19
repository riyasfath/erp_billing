import 'package:ecommerce_app/admin/admin_shell.dart';
import 'package:ecommerce_app/admin/admin_viewmodel/admin_auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  static const Color _bg = Color(0xFF0F172A);
  static const Color _accent = Color(0xFF6366F1);
  static const Color _card = Color(0xFF1E293B);

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit(AdminAuthViewModel viewModel) async {
    final userId = _userIdController.text.trim();
    final password = _passwordController.text;
    if (userId.isEmpty || password.isEmpty) return;

    final success = await viewModel.login(userId, password);
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AdminShell()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminAuthViewModel>();

    return Scaffold(
      backgroundColor: _bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [_accent, Color(0xFF8B5CF6)]),
                  boxShadow: [BoxShadow(color: _accent.withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 10))],
                ),
                child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 38),
              ),
              const SizedBox(height: 20),
              const Text(
                'Kicks Admin',
                style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text('Sign in to manage the store', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
              const SizedBox(height: 32),
              Container(
                constraints: const BoxConstraints(maxWidth: 380),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('USER ID'),
                    const SizedBox(height: 8),
                    _textField(controller: _userIdController, hint: 'admin1', icon: Icons.person_outline),
                    const SizedBox(height: 18),
                    _fieldLabel('PASSWORD'),
                    const SizedBox(height: 8),
                    _textField(
                      controller: _passwordController,
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      obscure: _obscure,
                      suffix: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: Colors.white38, size: 20),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    if (viewModel.error != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(viewModel.error!, style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading ? null : () => _submit(viewModel),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accent,
                          disabledBackgroundColor: _accent.withOpacity(0.4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: viewModel.isLoading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Sign In', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) =>
      Text(text, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8));

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.08))),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24),
          prefixIcon: Icon(icon, color: Colors.white38, size: 20),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}