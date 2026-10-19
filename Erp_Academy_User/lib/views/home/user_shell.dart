import 'package:erp_user/views/courses/my_course_screen.dart';
import 'package:erp_user/views/home/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../viewmodels/nav_viewmodel.dart';

class UserShell extends StatelessWidget {
  const UserShell({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavViewModel>();
    const items = [
      (Icons.home_outlined, Icons.home, 'Home'),
      (Icons.menu_book_outlined, Icons.menu_book, 'My Courses'),
      (Icons.sensors, Icons.sensors, 'Live'),
      (Icons.description_outlined, Icons.description, 'Resources'),
      (Icons.person_outline, Icons.person, 'Profile'),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: nav.index, children: const [
          HomeScreen(),
          MyCoursesScreen(),
          Center(child: Text('Live')),
          Center(child: Text('Resources')),
          Center(child: Text('Profile')),
        ]),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 14)
            ]),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (i) {
                final sel = nav.index == i;
                final c = sel ? AppColors.primary : AppColors.muted;
                return InkWell(
                  onTap: () => nav.setIndex(i),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(sel ? items[i].$2 : items[i].$1, color: c, size: 26),
                    const SizedBox(height: 4),
                    Text(items[i].$3,
                        style: TextStyle(
                            fontSize: 10,
                            color: c,
                            fontWeight:
                                sel ? FontWeight.w700 : FontWeight.w400)),
                  ]),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}