import 'package:flutter/material.dart';
import 'package:pokakbilling/ERP_UI_KIT.dart';
import 'package:pokakbilling/views/Screens/leads/follow_up/follow_up.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leads.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leadsnewscreen.dart';

class LeadsBottomBar extends StatefulWidget {
  final int index;
  const LeadsBottomBar({super.key, required this.index});

  @override
  State<LeadsBottomBar> createState() => _LeadsBottomBarState();
}

class _LeadsBottomBarState extends State<LeadsBottomBar>
    with TickerProviderStateMixin {
  late int _currentIndex;

  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _scaleAnims;
  late final List<Animation<double>> _slideAnims;

  static const _tabs = [
    _TabItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _TabItem(
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
      label: 'Dashboard',
    ),
    _TabItem(
      icon: Icons.people_alt_outlined,
      activeIcon: Icons.people_alt_rounded,
      label: 'Leads',
    ),
    _TabItem(
      icon: Icons.event_repeat_outlined,
      activeIcon: Icons.event_repeat_rounded,
      label: 'Follow-ups',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;

    _controllers = List.generate(
      _tabs.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 260),
      ),
    );

    _scaleAnims = _controllers.map((ctrl) {
      return Tween<double>(begin: 1.0, end: 1.08).animate(
        CurvedAnimation(parent: ctrl, curve: Curves.easeOutBack),
      );
    }).toList();

    _slideAnims = _controllers.map((ctrl) {
      return Tween<double>(begin: 0.0, end: -2.0).animate(
        CurvedAnimation(parent: ctrl, curve: Curves.easeOut),
      );
    }).toList();

    // Animate the initially active tab
    _controllers[_currentIndex].forward();
  }

  @override
  void dispose() {
    for (final ctrl in _controllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _onTap(int index) {
    if (index == _currentIndex) return;

    _controllers[_currentIndex].reverse();
    setState(() => _currentIndex = index);
    _controllers[index].forward();

    Future.microtask(() {
      if (!mounted) return;
      switch (index) {
        case 0:
          Navigator.of(context).popUntil((route) {
            return route.settings.name == '/' || route.isFirst;
          });
          break;
        case 1:
          Navigator.pushReplacement(
            context,
            _fadeRoute(const LeadScreen()),
          );
          break;
        case 2:
          Navigator.pushReplacement(
            context,
            _fadeRoute(const LeadsNewScreen()),
          );
          break;
        case 3:
          Navigator.pushReplacement(
            context,
            _fadeRoute(const FollowUp()),
          );
          break;
      }
    });
  }

  PageRoute _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(26),
          topRight: Radius.circular(26),
        ),
        border: const Border(top: BorderSide(color: ErpColors.line, width: 1)),
        boxShadow: [
          BoxShadow(
            color: ErpColors.cyan.withValues(alpha: 0.14),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: List.generate(
              _tabs.length,
              (i) => Expanded(child: _buildTabItem(i)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(int index) {
    final isActive = _currentIndex == index;
    final tab = _tabs[index];

    return GestureDetector(
      onTap: () => _onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controllers[index],
        builder: (_, __) {
          return Transform.translate(
            offset: Offset(0, _slideAnims[index].value),
            child: ScaleTransition(
              scale: _scaleAnims[index],
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Icon pill ─────────────────────────────────────────
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeInOut,
                    width: isActive ? 54 : 40,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: isActive ? ErpColors.headerGradient : null,
                      color: isActive ? null : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: ErpColors.cyan.withValues(alpha: 0.40),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : const [],
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Icon(
                          isActive ? tab.activeIcon : tab.icon,
                          key: ValueKey(isActive),
                          size: 21,
                          color: isActive
                              ? Colors.white
                              : ErpColors.slate.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  // ── Label ─────────────────────────────────────────────
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 160),
                    style: TextStyle(
                      fontSize: isActive ? 11.5 : 11,
                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                      color: isActive
                          ? ErpColors.cyanDeep
                          : ErpColors.slate.withValues(alpha: 0.75),
                    ),
                    child: Text(tab.label,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),

                  const SizedBox(height: 4),

                  // ── Active dot indicator ──────────────────────────────
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeInOut,
                    width: isActive ? 18 : 0,
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: isActive
                          ? const LinearGradient(
                              colors: [ErpColors.cyan, ErpColors.cyanLight])
                          : null,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Tab item model ───────────────────────────────────────────────────────────
class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}