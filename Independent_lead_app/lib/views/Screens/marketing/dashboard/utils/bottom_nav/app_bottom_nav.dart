// lib/views/bottom_bar/marketing_bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

class MarketingBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MarketingBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: AppColors.violetblue,
      unselectedItemColor: const Color(0xFF8D8D9A),
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),

        // 🟣 Dashboard
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/images/dashboard_icon.png',
            height: 24,
            width: 24,
            color: const Color(0xFF8D8D9A),
          ),
          activeIcon: Image.asset(
            'assets/images/dashboard_icon.png',
            height: 24,
            width: 24,
            color: AppColors.violetblue,
          ),
          label: 'Dashboard',
        ),

        // 🟢 Data
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/images/data_icon.png',
            height: 24,
            width: 24,
            color: const Color(0xFF8D8D9A),
          ),
          activeIcon: Image.asset(
            'assets/images/data_icon.png',
            height: 24,
            width: 24,
            color: AppColors.violetblue,
          ),
          label: 'Data',
        ),

        // 🔵 Reports
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/images/reports_icon.png',
            height: 24,
            width: 24,
            color: const Color(0xFF8D8D9A),
          ),
          activeIcon: Image.asset(
            'assets/images/reports_icon.png',
            height: 24,
            width: 24,
            color: AppColors.violetblue,
          ),
          label: 'Reports',
        ),
      ],
    );
  }
}
