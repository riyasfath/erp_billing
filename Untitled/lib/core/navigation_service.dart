import 'package:flutter/material.dart';

/// Global keys so code with no BuildContext (like ApiClient, when a
/// request comes back with an expired/invalid token) can still
/// navigate and show a message. Wired into MaterialApp in app.dart.
class NavigationService {
  NavigationService._();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
}