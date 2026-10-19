import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../network/dio_client.dart';
import '../storage/token_storage.dart';

// Services
import '../../services/auth_service.dart';
import '../../services/class_service.dart';
import '../../services/course_service.dart';
import '../../services/dashboard_service.dart';
import '../../services/live_service.dart';
import '../../services/module_service.dart';
import '../../services/student_service.dart';

// ViewModels
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/class_viewmodel.dart';
import '../../viewmodels/nav_viewmodel.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../viewmodels/course_viewmodel.dart';
import '../../viewmodels/live_viewmodel.dart';
import '../../viewmodels/shedule_live_viewmodel.dart';
import '../../viewmodels/upload_video_viewmodel.dart';
import '../../viewmodels/student_viewmodel.dart';

/// Every app-wide provider is registered here.
/// Order matters: core → services → viewmodels.
///
/// NOT registered here (created inside their own screens):
///   - CourseDetailViewModel, StudentProfileViewModel,
///     ClassDetailViewModel, ModuleDetailViewModel
class AppProviders {
  AppProviders._();

  static List<SingleChildWidget> build({
    required TokenStorage tokenStorage,
    required DioClient dioClient,
  }) =>
      [
        // ---------- Core ----------
        Provider<TokenStorage>.value(value: tokenStorage),
        Provider<DioClient>.value(value: dioClient),

        // ---------- Services ----------
        Provider<AuthService>(
          create: (ctx) =>
              AuthService(ctx.read<DioClient>(), ctx.read<TokenStorage>()),
        ),
        Provider<DashboardService>(
          create: (ctx) => DashboardService(ctx.read<DioClient>()),
        ),
        Provider<CourseService>(
          create: (ctx) => CourseService(ctx.read<DioClient>()),
        ),
        Provider<StudentService>(
          create: (ctx) => StudentService(ctx.read<DioClient>()),
        ),
        Provider<ClassService>(
          create: (ctx) => ClassService(ctx.read<DioClient>()),
        ),
        Provider<LiveService>(create: (_) => LiveService()),
        Provider<ModuleService>(create: (_) => ModuleService()),

        // ---------- ViewModels ----------
        ChangeNotifierProvider<AuthViewModel>(
          lazy: false,
          create: (ctx) {
            final vm = AuthViewModel(ctx.read<AuthService>());
            ctx.read<DioClient>().onUnauthorized = vm.handleSessionExpired;
            return vm;
          },
        ),
        ChangeNotifierProvider<NavViewModel>(
          create: (_) => NavViewModel(),
        ),
        ChangeNotifierProvider<DashboardViewModel>(
          create: (ctx) => DashboardViewModel(ctx.read<DashboardService>()),
        ),
        ChangeNotifierProvider<CourseViewModel>(
          create: (ctx) => CourseViewModel(ctx.read<CourseService>()),
        ),
        ChangeNotifierProvider<StudentViewModel>(
          create: (ctx) => StudentViewModel(ctx.read<StudentService>()),
        ),
        ChangeNotifierProvider<ClassViewModel>(
          create: (ctx) => ClassViewModel(ctx.read<ClassService>()),
        ),
        ChangeNotifierProvider<LiveViewModel>(
          create: (ctx) => LiveViewModel(ctx.read<LiveService>()),
        ),
        ChangeNotifierProvider<ScheduleLiveViewModel>(
          create: (ctx) => ScheduleLiveViewModel(ctx.read<LiveService>()),
        ),
       
      ];
}