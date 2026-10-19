// lib/views/Screens/leads/lead_screens/leads_bottomBar.dart
// UPDATED: 5th tab "AI" → AI Email / WhatsApp generator.
// index: 0 Home, 1 Dashboard, 2 Leads, 3 Follow-ups, 4 AI

import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/views/Screens/leads/follow_up/follow_up.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/ai_generator_screen.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leads.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leadsNewScreen.dart';

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
    _TabItem(icon: Icons.home_rounded, activeIcon: Icons.home_rounded, label: 'Home'),
    _TabItem(
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard_rounded,
        label: 'Dashboard'),
    _TabItem(
        icon: Icons.people_outline, activeIcon: Icons.people_rounded, label: 'Leads'),
    _TabItem(
        icon: Icons.event_note_outlined,
        activeIcon: Icons.event_note_rounded,
        label: 'Follow-ups'),
    _TabItem(
        icon: Icons.auto_awesome_outlined,
        activeIcon: Icons.auto_awesome_rounded,
        label: 'AI'),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index.clamp(0, _tabs.length - 1);

    _controllers = List.generate(
      _tabs.length,
      (i) => AnimationController(
          vsync: this, duration: const Duration(milliseconds: 300)),
    );

    _scaleAnims = _controllers
        .map((c) => Tween<double>(begin: 1.0, end: 1.18)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeOutBack)))
        .toList();

    _slideAnims = _controllers
        .map((c) => Tween<double>(begin: 0.0, end: -4.0)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();

    _controllers[_currentIndex].forward();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
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
          Navigator.popUntil(context, (route) => route.isFirst);
          break;
        case 1:
          Navigator.pushReplacement(context, _fadeRoute(const LeadScreen()));
          break;
        case 2:
          Navigator.pushReplacement(context, _fadeRoute(const LeadsNewScreen()));
          break;
        case 3:
          Navigator.pushReplacement(context, _fadeRoute(const FollowUp()));
          break;
        case 4:
          Navigator.pushReplacement(
              context, _fadeRoute(const AiGeneratorScreen()));
          break;
        default:
          Navigator.popUntil(context, (route) => route.isFirst);
      }
    });
  }

  PageRoute _fadeRoute(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 220),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.cborder, width: 1.0)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 70,
          child: Row(
            children: List.generate(
                _tabs.length, (i) => Expanded(child: _buildTabItem(i))),
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
        builder: (_, __) => Transform.translate(
          offset: Offset(0, _slideAnims[index].value),
          child: ScaleTransition(
            scale: _scaleAnims[index],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOut,
                  width: isActive ? 52 : 40,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.c1 : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Icon(
                        isActive ? tab.activeIcon : tab.icon,
                        key: ValueKey(isActive),
                        size: isActive ? 20 : 22,
                        color: isActive
                            ? AppColors.white
                            : AppColors.c1.withOpacity(.40),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: isActive ? 10.5 : 10.0,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? AppColors.c1 : AppColors.c1.withOpacity(.40),
                  ),
                  child: Text(tab.label),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.only(top: 3),
                  width: isActive ? 16 : 0,
                  height: 2.5,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.c1 : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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