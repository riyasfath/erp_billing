import 'package:erp_academy/core/app_colors.dart';
import 'package:erp_academy/models/app_user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../admin/admin_shell.dart';
import '../user/user_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _u = TextEditingController();
  final _p = TextEditingController();
  final _passFocus = FocusNode();

  @override
  void dispose() {
    _u.dispose();
    _p.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final vm = context.read<AuthViewModel>();
    vm.clearError();

    // 1. Local validation — no API call if fields are invalid
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // 2. API call — navigate ONLY on success
    final ok = await vm.login(_u.text, _p.text);
    if (!mounted || !ok || vm.user == null) return;

    final page = vm.user!.role == UserRole.admin
        ? const AdminShell()
        : const UserHomeScreen();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  InputDecoration _dec({Widget? suffix, String? hint}) => InputDecoration(
        hintText: hint,
        suffixIcon: suffix,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.red)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.red)),
      );

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 70),
                  Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.school, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                      child: Text('Welcome back, Administrator',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w700))),
                  const SizedBox(height: 14),
                  const Center(
                    child: Text(
                        'Sign in to manage curriculum modules,\nscheduled streams, and academic registries.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.muted, height: 1.4)),
                  ),
                  const SizedBox(height: 60),
                  const Text('Email'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _u,
                    enabled: !vm.loading,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    autofillHints: const [AutofillHints.email],
                    validator: vm.validateEmail,
                    onChanged: (_) => vm.clearError(),
                    onFieldSubmitted: (_) => _passFocus.requestFocus(),
                    decoration: _dec(
                      hint: 'admin@gmail.com',
                      suffix: const Icon(Icons.alternate_email,
                          color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Password'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _p,
                    focusNode: _passFocus,
                    enabled: !vm.loading,
                    obscureText: vm.obscure,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    validator: vm.validatePassword,
                    onChanged: (_) => vm.clearError(),
                    onFieldSubmitted: (_) => _submit(),
                    decoration: _dec(
                      hint: 'Enter password',
                      suffix: IconButton(
                        icon: Icon(
                            vm.obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20),
                        onPressed: vm.toggleObscure,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(children: [
                    SizedBox(
                        width: 24,
                        child: Checkbox(
                            value: vm.remember,
                            onChanged: vm.loading
                                ? null
                                : (v) => vm.setRemember(v ?? false))),
                    const SizedBox(width: 6),
                    const Text('Remember this device',
                        style: TextStyle(fontSize: 13)),
                    const Spacer(),
                    const Text('Forgot Key?',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                  ]),
                  if (vm.error != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.red.withOpacity(0.3)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(vm.error!,
                                style: const TextStyle(
                                    color: AppColors.red, fontSize: 13))),
                      ]),
                    ),
                  const SizedBox(height: 50),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: vm.loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            AppColors.primary.withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: vm.loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                  Text('Sign In to Admin Console',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, size: 18),
                                ]),
                    ),
                  ),
                  const SizedBox(height: 24),
                ]),
          ),
        ),
      ),
    );
  }
}