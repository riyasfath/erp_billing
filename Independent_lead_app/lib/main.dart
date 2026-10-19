import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pokakbilling/core/providers.dart';
import 'package:pokakbilling/core/routes.dart';
import 'package:pokakbilling/core/api/session_service.dart';
import 'package:pokakbilling/models/services/call_activity/twilo_call_host.dart';
import 'package:pokakbilling/notification/notification_service.dart';
import 'package:pokakbilling/viewmodels/notifica_state.dart';
import 'package:pokakbilling/views/splashScreen/splash_Screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: "assets/.env");
  } catch (e) {
    debugPrint('dotenv load failed: $e');
  }

  await NotificationService.instance.init();

  runApp(
    MultiProvider(
      providers: providers,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationController notificationController =
        NotificationController();

    return MaterialApp(
      title: 'Billing',

      // ✅ Wire the global navigator key for session expiry
      navigatorKey: SessionService.instance.navigatorKey,

      onGenerateRoute: AppRoutes.generateRoute,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,

      // ✅ Keeps the hidden Twilio call WebView mounted across every
      // screen in the app (not just the active-call screen), so a call
      // survives navigation instead of dying when a screen is popped.
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            const TwilioCallHost(),
          ],
        );
      },

      home: const SplashScreen(),
    );
  }
}
