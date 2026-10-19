import 'package:erp_academy/core/provider/app_providers.dart';
import 'package:erp_academy/views/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/env_config.dart';
import 'core/navigation/app_navigator.dart';
import 'core/network/dio_client.dart';
import 'core/storage/token_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.load();

  final tokenStorage = TokenStorage();
  final dioClient = DioClient(tokenStorage);

  runApp(
    MultiProvider(
      providers: AppProviders.build(
        tokenStorage: tokenStorage,
        dioClient: dioClient,
      ),
      child: const ErpAcademyApp(),
    ),
  );
}

class ErpAcademyApp extends StatelessWidget {
  const ErpAcademyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ERP Academy',
      debugShowCheckedModeBanner: false,
      navigatorKey: AppNavigator.navigatorKey,
      scaffoldMessengerKey: AppNavigator.messengerKey,
      home: const SplashScreen(), // decides: Home (remembered) or Login
    );
  }
}