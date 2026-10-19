import 'package:erp_academy/core/app_colors.dart';
import 'package:erp_academy/models/app_user_model.dart';
import 'package:erp_academy/views/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../admin/admin_shell.dart';
import '../user/user_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    final vm = context.read<AuthViewModel>();

    // Small minimum delay so the splash doesn't just flash
    final results = await Future.wait([
      vm.tryAutoLogin(),
      Future.delayed(const Duration(milliseconds: 700)),
    ]);
    if (!mounted) return;

    final loggedIn = results.first as bool;
    final Widget page;
    if (loggedIn && vm.user != null) {
      page = vm.user!.role == UserRole.admin
          ? const AdminShell()
          : const UserHomeScreen();
    } else {
      page = const LoginScreen();
    }

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(18)),
            child: const Icon(Icons.school, color: Colors.white, size: 38),
          ),
          const SizedBox(height: 24),
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ]),
      ),
    );
  }
}