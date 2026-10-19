import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/widgets/edu_logo.dart';
import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.primary,
        body: SafeArea(
          child: SizedBox(
            width: double.infinity, // full width, so content centers
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                const EduLogo(size: 64),
                const Spacer(),
                const Text('App Version 1.0',
                    style: TextStyle(color: Colors.white, fontSize: 15)),
                const SizedBox(height: 18),
                Container(
                  width: 130,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3)),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      );
}