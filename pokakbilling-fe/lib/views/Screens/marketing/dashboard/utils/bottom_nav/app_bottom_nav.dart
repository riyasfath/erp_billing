// // lib/views/bottom_bar/marketing_bottom_nav.dart
// import 'package:flutter/material.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';

// class MarketingBottomNav extends StatelessWidget {
//   final int currentIndex;
//   final ValueChanged<int> onTap;

//   const MarketingBottomNav({
//     super.key,
//     required this.currentIndex,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       currentIndex: currentIndex,
//       onTap: onTap,
//       selectedItemColor: AppColors.violetblue,
//       unselectedItemColor: const Color(0xFF8D8D9A),
//       showUnselectedLabels: true,
//       type: BottomNavigationBarType.fixed,
//       items: [
//         const BottomNavigationBarItem(
//           icon: Icon(Icons.home_outlined),
//           label: 'Home',
//         ),

//         // 🟣 Dashboard
//         BottomNavigationBarItem(
//           icon: Image.asset(
//             'assets/images/dashboard_icon.png',
//             height: 24,
//             width: 24,
//             color: const Color(0xFF8D8D9A),
//           ),
//           activeIcon: Image.asset(
//             'assets/images/dashboard_icon.png',
//             height: 24,
//             width: 24,
//             color: AppColors.violetblue,
//           ),
//           label: 'Dashboard',
//         ),

//         // 🟢 Data
//         BottomNavigationBarItem(
//           icon: Image.asset(
//             'assets/images/data_icon.png',
//             height: 24,
//             width: 24,
//             color: const Color(0xFF8D8D9A),
//           ),
//           activeIcon: Image.asset(
//             'assets/images/data_icon.png',
//             height: 24,
//             width: 24,
//             color: AppColors.violetblue,
//           ),
//           label: 'Data',
//         ),

//         // 🔵 Reports
//         BottomNavigationBarItem(
//           icon: Image.asset(
//             'assets/images/reports_icon.png',
//             height: 24,
//             width: 24,
//             color: const Color(0xFF8D8D9A),
//           ),
//           activeIcon: Image.asset(
//             'assets/images/reports_icon.png',
//             height: 24,
//             width: 24,
//             color: AppColors.violetblue,
//           ),
//           label: 'Reports',
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

const _kIndigo = Color(0xFF6366F1);
const _kIndigoLight = Color(0xFF818CF8);

class MarketingBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MarketingBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  bool get _isDark =>
      WidgetsBinding.instance.platformDispatcher.platformBrightness ==
      Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1730) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? _kIndigoLight.withValues(alpha: 0.12)
                : _kIndigo.withValues(alpha: 0.10),
            width: 1,
          ),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: _kIndigo.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: _kIndigo,
        unselectedItemColor: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 11,
          color: _kIndigo,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Icon(Icons.home_outlined, size: 22),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Icon(Icons.home_rounded, size: 22),
            ),
            label: 'Home',
          ),

          // Dashboard
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Image.asset(
                'assets/images/dashboard_icon.png',
                height: 22,
                width: 22,
                color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
              ),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Image.asset(
                'assets/images/dashboard_icon.png',
                height: 22,
                width: 22,
                color: _kIndigo,
              ),
            ),
            label: 'Dashboard',
          ),

          // Data
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Image.asset(
                'assets/images/data_icon.png',
                height: 22,
                width: 22,
                color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
              ),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Image.asset(
                'assets/images/data_icon.png',
                height: 22,
                width: 22,
                color: _kIndigo,
              ),
            ),
            label: 'Data',
          ),

          // Reports
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Image.asset(
                'assets/images/reports_icon.png',
                height: 22,
                width: 22,
                color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
              ),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Image.asset(
                'assets/images/reports_icon.png',
                height: 22,
                width: 22,
                color: _kIndigo,
              ),
            ),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}
