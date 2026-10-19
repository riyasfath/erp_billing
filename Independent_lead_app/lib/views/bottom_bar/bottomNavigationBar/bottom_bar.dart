import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/views/Screens/customer/customer_main.dart';
import 'package:pokakbilling/views/Screens/products/productmain.dart';
import 'package:pokakbilling/views/Screens/quotation/quotation_main.dart';
import 'package:pokakbilling/views/bottom_bar/home_screen.dart';
import 'package:pokakbilling/views/bottom_bar/profile_screen.dart';

// ─── Tab model ────────────────────────────────────────────────────────────────
// Simplified: every tab now shares ONE consistent accent color (the app's
// primary cyan) instead of a different color per tab — cleaner & calmer,
// matching the reference UI where the bottom bar uses a single active color.
class _Tab {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String? badge;
  const _Tab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badge,
  });
}

// ─── BottomBar ────────────────────────────────────────────────────────────────
class BottomBar extends StatefulWidget {
  final int index;
  const BottomBar({super.key, required this.index});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> with TickerProviderStateMixin {
  late int _sel;

  // Flat icon+label tabs with a light divider between each tab. Every tab
  // now lights up in the SAME primary cyan color when active, and sits in a
  // neutral grey when inactive — simple & consistent instead of a rainbow
  // of per-tab colors.
  static const _tabs = [
    _Tab(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _Tab(
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2_rounded,
      label: 'Products',
    ),
    _Tab(
      icon: Icons.groups_outlined,
      activeIcon: Icons.groups_rounded,
      label: 'Client',
    ),
    _Tab(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      label: 'Quotes',
    ),
    _Tab(
      icon: Icons.account_circle_outlined,
      activeIcon: Icons.account_circle_rounded,
      label: 'Profile',
    ),
  ];

  // Instance-level (not static) now, because ProfileScreen needs an
  // `onBack` callback that switches this widget's own _sel index back to
  // the Home tab — a static list can't reach into instance state.
  // Rebuilt fresh on every build() call, which is fine here since only the
  // page at _pages[_sel] is ever mounted at a time (via AnimatedSwitcher),
  // so no state is lost by recreating the list.
  List<Widget> get _pages => [
        const HomePage(),
        const ProductMainScreen(),
        const CustomerMain(),
        const QuotationMain(),
        ProfileScreen(onBack: () => _onTap(0)),
      ];

  late final List<AnimationController> _ctrls;
  late final List<Animation<double>> _scaleAnims;

  @override
  void initState() {
    super.initState();
    _sel = widget.index;

    _ctrls = List.generate(
      _tabs.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      ),
    );

    _scaleAnims = _ctrls
        .map((c) => Tween<double>(begin: 1.0, end: 1.08)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeOutBack)))
        .toList();

    _ctrls[_sel].forward();
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    super.dispose();
  }

  void _onTap(int i) {
    if (i == _sel) return;
    _ctrls[_sel].reverse();
    _ctrls[i].forward();
    setState(() => _sel = i);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_sel != 0) {
          _ctrls[_sel].reverse();
          _ctrls[0].forward();
          setState(() => _sel = 0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: KeyedSubtree(
            key: ValueKey(_sel),
            child: _pages[_sel],
          ),
        ),
        bottomNavigationBar: _bar(),
      ),
    );
  }

  // ── Bottom bar — taller, bigger icons, light divider between each tab ─────
  Widget _bar() => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.cborder, width: 1.0)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 76,
            child: Row(
              children: List.generate(_tabs.length * 2 - 1, (i) {
                // Odd indices are the thin divider slots between two tabs.
                if (i.isOdd) {
                  return const _TabDivider();
                }
                final tabIndex = i ~/ 2;
                return Expanded(child: _tabItem(tabIndex));
              }),
            ),
          ),
        ),
      );

  // ── Single tab: icon on top, label below. One shared accent color when
  //    active, neutral grey when inactive — simple & consistent.
  Widget _tabItem(int i) {
    final active = _sel == i;
    final tab = _tabs[i];

    final Color color = active ? AppColors.c1 : AppColors.textTertiary;

    return GestureDetector(
      onTap: () => _onTap(i),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _ctrls[i],
        builder: (_, __) => ScaleTransition(
          scale: _scaleAnims[i],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      active ? tab.activeIcon : tab.icon,
                      key: ValueKey(active),
                      size: 28,
                      color: color,
                    ),
                  ),
                  if (tab.badge != null)
                    Positioned(
                      right: -10,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.tagRed,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        constraints: const BoxConstraints(minWidth: 18),
                        child: Text(
                          tab.badge!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                tab.label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Thin, light vertical divider placed between each bottom-bar tab ─────────
class _TabDivider extends StatelessWidget {
  const _TabDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(vertical: 22),
      color: AppColors.cborder.withOpacity(.6),
    );
  }
}