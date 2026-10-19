import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'package:pokakbilling/appthemes/themeNotifier.dart';
import 'package:pokakbilling/core/providers.dart';
import 'package:pokakbilling/core/routes.dart';
import 'package:pokakbilling/core/api/sessionExpiredService.dart';

import 'package:pokakbilling/views/splashScreen/splash_Screen.dart';
import 'package:pokakbilling/views/Screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: "assets/.env");
  } catch (e) {
    debugPrint('dotenv load failed: $e');
  }

  runApp(const AppRoot());
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  static void restart(BuildContext context) {
    context.findAncestorStateOfType<_AppRootState>()?.restartApp();
  }

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  Key _key = UniqueKey();

  void restartApp() {
    setState(() {
      _key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: MultiProvider(
        providers: providers,
        child: const MyApp(),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'Pokak Billing',

          navigatorKey: SessionService.instance.navigatorKey,

          routes: {
            '/login': (_) => const LoginScreen(),
          },

          onGenerateRoute: AppRoutes.generateRoute,

          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF4F3FF),
            useMaterial3: true,
          ),

          /// 🌙 DARK THEME
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF1E1B4B),
            useMaterial3: true,
          ),

          themeMode: themeNotifier.mode,

          debugShowCheckedModeBanner: false,

          home: const SplashScreen(),
        );
      },
    );
  }
}
