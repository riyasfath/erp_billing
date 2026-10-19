import 'package:erp_academy/views/admin/student/admin_student_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/nav_viewmodel.dart';

class StudentsTab extends StatefulWidget {
  const StudentsTab({super.key});

  @override
  State<StudentsTab> createState() => _StudentsTabState();
}

class _StudentsTabState extends State<StudentsTab> {
  final _navKey = GlobalKey<NavigatorState>();

  static const _studentsTabIndex = 3; // position of Students in AdminShell

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavViewModel>();

    return PopScope(
      canPop: nav.index != _studentsTabIndex,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final inner = _navKey.currentState;
        if (inner != null && inner.canPop()) {
          inner.pop(); // profile → list
        } else {
          context.read<NavViewModel>().setIndex(0); // list → Home tab
        }
      },
      child: Navigator(
        key: _navKey,
        onGenerateRoute: (settings) => MaterialPageRoute(
          settings: settings,
          builder: (_) => const AdminStudentsScreen(),
        ),
      ),
    );
  }
}