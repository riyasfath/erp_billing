import 'package:erp_academy/views/admin/course/admin_course_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/nav_viewmodel.dart';

class CoursesTab extends StatefulWidget {
  const CoursesTab({super.key});

  @override
  State<CoursesTab> createState() => _CoursesTabState();
}

class _CoursesTabState extends State<CoursesTab> {
  final _navKey = GlobalKey<NavigatorState>();

  static const _coursesTabIndex = 1; // position of Courses in AdminShell

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavViewModel>();

    return PopScope(
      // Only intercept the back button while the Courses tab is visible
      canPop: nav.index != _coursesTabIndex,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final inner = _navKey.currentState;
        if (inner != null && inner.canPop()) {
          inner.pop(); // detail → course list
        } else {
          context.read<NavViewModel>().setIndex(0); // course list → Home tab
        }
      },
      child: Navigator(
        key: _navKey,
        onGenerateRoute: (settings) => MaterialPageRoute(
          settings: settings,
          builder: (_) => const AdminCoursesScreen(),
        ),
      ),
    );
  }
}