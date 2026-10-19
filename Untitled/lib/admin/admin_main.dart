import 'package:ecommerce_app/admin/admin_viewmodel/admin_auth_viewmodel.dart';
import 'package:ecommerce_app/admin/admin_viewmodel/admin_dashboard_viewmodel.dart';
import 'package:ecommerce_app/admin/admin_viewmodel/admin_product_viewmodel.dart';
import 'package:ecommerce_app/views/admin_screens/admin_login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


/// Separate entry point for the ADMIN app — run with:
///   flutter run -t lib/admin_main.dart
/// This never touches lib/main.dart or any customer-facing screen.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminAuthViewModel()),
        ChangeNotifierProvider(create: (_) => AdminDashboardViewModel()),
        ChangeNotifierProvider(create: (_) => AdminProductViewModel()),
      ],
      child: const AdminApp(),
    ),
  );
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kicks Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        colorSchemeSeed: const Color(0xFF6366F1),
      ),
      home: const AdminLoginScreen(),
    );
  }
} 