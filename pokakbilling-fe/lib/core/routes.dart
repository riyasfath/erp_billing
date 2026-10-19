import 'package:flutter/material.dart';
import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';

class AppRoutes {
  static const String home = '/home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const ErpBottomBar(index: 0));

      default:
        return MaterialPageRoute(builder: (_) => const ErpBottomBar(index: 0));
    }
  }
}
