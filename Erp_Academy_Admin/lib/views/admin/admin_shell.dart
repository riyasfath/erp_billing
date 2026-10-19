import 'package:erp_academy/core/app_colors.dart';
import 'package:erp_academy/views/admin/classes/classes_tab.dart';
import 'package:erp_academy/views/admin/course/course_tab.dart';
import 'package:erp_academy/views/admin/home/admin_homescreen.dart';
import 'package:erp_academy/views/admin/student/student_tab.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/nav_viewmodel.dart';
import 'live/admin_live_screen.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavViewModel>();
    const items = [
      (Icons.home_outlined, Icons.home, 'Home'),
      (Icons.menu_book_outlined, Icons.menu_book, 'Courses'),
      (Icons.videocam_outlined, Icons.videocam, 'Live'),
      (Icons.school_outlined, Icons.school, 'Students'),
      (Icons.layers_outlined, Icons.layers, 'Classes'),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: nav.index, children: const [
          AdminHomeScreen(),
          CoursesTab(),
          AdminLiveScreen(),
          StudentsTab(),
          ClassesTab(),
        ]),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 12)
            ]),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: List.generate(items.length, (i) {
                final sel = nav.index == i;
                final c = sel ? AppColors.primary : AppColors.muted;
                return Expanded(
                  child: InkWell(
                    onTap: () => nav.setIndex(i),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: sel
                                ? AppColors.primary.withOpacity(.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(sel ? items[i].$2 : items[i].$1,
                              color: c, size: 24),
                        ),
                        const SizedBox(height: 4),
                        Text(items[i].$3,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 11,
                                color: c,
                                fontWeight: sel
                                    ? FontWeight.w700
                                    : FontWeight.w500)),
                      ]),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}