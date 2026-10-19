import 'package:flutter/material.dart';

import '../../views/auth/login_screen.dart';

class AppNavigator {
  AppNavigator._();

  static final navigatorKey = GlobalKey<NavigatorState>();
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();

  static bool _redirecting = false;

  /// Clears every screen and opens Login. Safe to call multiple times.
  static void toLogin({String? message}) {
    final nav = navigatorKey.currentState;
    if (nav == null || _redirecting) return;
    _redirecting = true;

    nav.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _redirecting = false;
      if (message != null) {
        messengerKey.currentState
          ?..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      }
    });
  }
}