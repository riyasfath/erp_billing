import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/nav_viewmodel.dart';
import 'admin_classes_screen.dart';

class ClassesTab extends StatefulWidget {
  const ClassesTab({super.key});

  @override
  State<ClassesTab> createState() => _ClassesTabState();
}

class _ClassesTabState extends State<ClassesTab> {
  final _navKey = GlobalKey<NavigatorState>();

  static const _classesTabIndex = 4; // position of Classes in AdminShell

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavViewModel>();

    return PopScope(
      canPop: nav.index != _classesTabIndex,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final inner = _navKey.currentState;
        if (inner != null && inner.canPop()) {
          inner.pop(); // detail → list
        } else {
          context.read<NavViewModel>().setIndex(0); // list → Home tab
        }
      },
      child: Navigator(
        key: _navKey,
        onGenerateRoute: (settings) => MaterialPageRoute(
          settings: settings,
          builder: (_) => const AdminClassesScreen(),
        ),
      ),
    );
  }
}