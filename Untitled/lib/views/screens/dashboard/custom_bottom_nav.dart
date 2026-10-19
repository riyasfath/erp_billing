import 'package:flutter/material.dart';
import 'package:ecommerce_app/app_colors.dart';

class NavBarItem {
  final IconData icon;
  final String label;
  final int badge;
  const NavBarItem(this.icon, this.label, {this.badge = 0});
}

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int cartCount;
  final int favoritesCount;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.cartCount = 0,
    this.favoritesCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      const NavBarItem(Icons.home_rounded, 'Home'),
      const NavBarItem(Icons.search, 'Shop'),
      NavBarItem(Icons.shopping_bag_outlined, 'Cart', badge: cartCount),
      NavBarItem(Icons.favorite_border, 'Favorites', badge: favoritesCount),
      const NavBarItem(Icons.person_outline, 'Me'),
    ];

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final bool active = index == currentIndex;
            final item = items[index];
            return GestureDetector(
              onTap: () => onTap(index), // actually switches the tab
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        item.icon,
                        color: active ? AppColors.primaryBlue : AppColors.textGrey,
                        size: 24,
                      ),
                      if (item.badge > 0)
                        Positioned(
                          right: -6,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: const BoxDecoration(
                              color: AppColors.badgeRed,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${item.badge}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: active ? AppColors.primaryBlue : AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}