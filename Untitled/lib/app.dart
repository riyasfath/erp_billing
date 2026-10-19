import 'package:ecommerce_app/core/navigation_service.dart';
import 'package:ecommerce_app/views/screens/splash/splashScreen.dart';
import 'package:flutter/material.dart';

class KicksApp extends StatelessWidget {
  const KicksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kicks',
      debugShowCheckedModeBanner: false,
      // Needed so SessionManager (no BuildContext of its own — it's
      // called from ApiClient) can navigate to LoginScreen and show a
      // "session expired" SnackBar on an auto-logout.
      navigatorKey: NavigationService.navigatorKey,
      scaffoldMessengerKey: NavigationService.scaffoldMessengerKey,
      theme: ThemeData(fontFamily: 'Inter', useMaterial3: true),
      // Changed from HomeScreen -> MainTabScreen.
      // HomeScreen now requires favoriteIds/onToggleFavorite/onAddToCart
      // params (owned by MainTabScreen) and no longer has its own bottom
      // nav bar, so it can't be set as `home:` directly anymore.
      home: const SplashScreen(),
    );
  }
}