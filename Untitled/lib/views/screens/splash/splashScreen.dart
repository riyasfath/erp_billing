import 'package:ecommerce_app/core/token_storage.dart';
import 'package:ecommerce_app/views/screens/dashboard/maintab.dart';
import 'package:ecommerce_app/views/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/app_colors.dart';

/// App entry point. Decides where to land:
///   - A saved session exists (user logged in before, hasn't logged out,
///     app hasn't been reinstalled) -> straight to MainTabScreen.
///   - No saved session -> LoginScreen.
///
/// This check is local/optimistic — it only confirms a token is SAVED,
/// not that it's still valid server-side. If it's actually expired, the
/// first real API call on Home will get a 401 and SessionManager's
/// auto-logout (wired in ApiClient) bounces the user back to Login
/// automatically — so both "logged in" and "session expired" end up
/// correct without this screen needing to call the API itself.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _decideNextScreen();
  }

  Future<void> _decideNextScreen() async {
    // Minimum splash duration so the branding is actually visible,
    // even on a fast/cached session check.
    final sessionCheck = TokenStorage.instance.hasSession();
    final minDuration = Future.delayed(const Duration(milliseconds: 1200));

    final results = await Future.wait([sessionCheck, minDuration]);
    final bool hasSession = results[0] as bool;

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => hasSession ? const MainTabScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 64),
            SizedBox(height: 16),
            Text(
              'Kicks',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}