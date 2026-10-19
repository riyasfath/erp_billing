import 'package:erp_user/viewmodels/my_course_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'services/auth_service.dart';
import 'services/course_service.dart';
import 'services/home_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/home_viewmodel.dart';
import 'viewmodels/nav_viewmodel.dart';
import 'views/splash/splash_screen.dart';

class ErpUserApp extends StatelessWidget {
  const ErpUserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel(AuthService())),
        ChangeNotifierProvider(create: (_) => HomeViewModel(HomeService())),
        ChangeNotifierProvider(create: (_) => NavViewModel()),
        ChangeNotifierProvider(
            create: (_) => MyCoursesViewModel(CourseService())),
      ],
      child: MaterialApp(
        title: 'ERP Student',
        debugShowCheckedModeBanner: false,
        theme: appTheme(),
        home: const SplashScreen(),
      ),
    );
  }
}