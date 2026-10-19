import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/widgets/edu_logo.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../home/user_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _u = TextEditingController(text: 'Loisbecket@gmail.com');
  final _p = TextEditingController(text: '1234567');

  @override
  void dispose() {
    _u.dispose();
    _p.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final vm = context.read<AuthViewModel>();
    final ok = await vm.login(_u.text, _p.text);
    if (!mounted || !ok) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const UserShell()));
  }

  InputDecoration _dec({Widget? suffix}) => InputDecoration(
        suffixIcon: suffix,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary)),
      );

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [
            const SizedBox(height: 70),
            const EduLogo(size: 44),
            const SizedBox(height: 50),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 22),
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Center(
                    child: Text('Login',
                        style: TextStyle(
                            fontSize: 34, fontWeight: FontWeight.w700))),
                const SizedBox(height: 28),
                const Text('Username',
                    style: TextStyle(fontSize: 15, color: AppColors.muted)),
                const SizedBox(height: 8),
                TextField(controller: _u, decoration: _dec()),
                const SizedBox(height: 20),
                const Text('Password',
                    style: TextStyle(fontSize: 15, color: AppColors.muted)),
                const SizedBox(height: 8),
                TextField(
                  controller: _p,
                  obscureText: vm.obscure,
                  decoration: _dec(
                      suffix: IconButton(
                    icon: Icon(
                        vm.obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.muted),
                    onPressed: vm.toggleObscure,
                  )),
                ),
                const SizedBox(height: 14),
                Row(children: [
                  SizedBox(
                      width: 24,
                      child: Checkbox(
                          value: vm.remember,
                          onChanged: (v) => vm.setRemember(v ?? false))),
                  const SizedBox(width: 8),
                  const Text('Remember me', style: TextStyle(fontSize: 15)),
                ]),
                if (vm.error != null)
                  Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(vm.error!,
                          style: const TextStyle(color: Colors.red))),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: vm.loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.button,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: vm.loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Log In',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w500)),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 30),
          ]),
        ),
      ),
    );
  }
}