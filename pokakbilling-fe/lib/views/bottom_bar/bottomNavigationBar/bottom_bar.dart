import 'package:flutter/material.dart';
import 'package:pokakbilling/views/bottom_bar/home_screen.dart';
import 'package:pokakbilling/views/bottom_bar/product_screen.dart';
import 'package:pokakbilling/views/bottom_bar/profile_screen.dart';
import 'package:pokakbilling/views/Screens/customer/customer_main.dart';
import 'package:pokakbilling/views/Screens/quotation/quotation_main.dart';

// ═════════════════════════════════════════════════════════════════════════════
// Colour scheme (same as Academy dashboard / ERP home)
// ═════════════════════════════════════════════════════════════════════════════
const Color _kPageBg = Color(0xFFF0FAFD);
const Color _kSlate = Color(0xFF64748B);
const Color _kLine = Color(0xFFD9ECF2);
const Color _kCyan = Color(0xFF06B6D4);
const Color _kCyanLight = Color(0xFF67E8F9);
const Color _kCyanDeep = Color(0xFF0E7490);

const LinearGradient _kActiveGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [_kCyanDeep, _kCyan, _kCyanLight],
);

// ─── Tab model ────────────────────────────────────────────────────────────────
class _Tab {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _Tab({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

// ─── ERP BottomBar ────────────────────────────────────────────────────────────
class ErpBottomBar extends StatefulWidget {
  final int index;
  const ErpBottomBar({super.key, required this.index});

  @override
  State<ErpBottomBar> createState() => _ErpBottomBarState();
}

class _ErpBottomBarState extends State<ErpBottomBar>
    with TickerProviderStateMixin {
  late int _sel;

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
      icon: Icons.people_alt_outlined,
      activeIcon: Icons.people_alt_rounded,
      label: 'Client',
    ),
    _Tab(
      icon: Icons.description_outlined,
      activeIcon: Icons.description_rounded,
      label: 'Quotes',
    ),
    _Tab(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  static final List<Widget> _pages = [
    const ErpHomePage(),
    const ProductScreen(),
    const CustomerMain(),
    const QuotationMain(),
    const ProfileScreen(),
  ];

  late final List<AnimationController> _ctrls;
  late final List<Animation<double>> _scaleAnims;
  late final List<Animation<double>> _slideAnims;

  @override
  void initState() {
    super.initState();
    _sel = widget.index;

    _ctrls = List.generate(
      _tabs.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 260),
      ),
    );

    _scaleAnims = _ctrls
        .map((c) => Tween<double>(begin: 1.0, end: 1.08)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeOutBack)))
        .toList();

    _slideAnims = _ctrls
        .map((c) => Tween<double>(begin: 0.0, end: -2.0)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();

    _ctrls[_sel].forward();
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
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
    return PopScope(
      canPop: _sel == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        // Back from any other tab returns to Home first.
        _onTap(0);
      },
      child: Scaffold(
        backgroundColor: _kPageBg,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
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

  // ── Bottom bar ─────────────────────────────────────────────────────────────
  Widget _bar() => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(26),
            topRight: Radius.circular(26),
          ),
          border: const Border(top: BorderSide(color: _kLine, width: 1)),
          boxShadow: [
            BoxShadow(
              color: _kCyan.withValues(alpha: 0.14),
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
                (i) => Expanded(child: _tabItem(i)),
              ),
            ),
          ),
        ),
      );

  // ── Single tab ─────────────────────────────────────────────────────────────
  Widget _tabItem(int i) {
    final active = _sel == i;
    final tab = _tabs[i];

    return GestureDetector(
      onTap: () => _onTap(i),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _ctrls[i],
        builder: (_, __) => Transform.translate(
          offset: Offset(0, _slideAnims[i].value),
          child: ScaleTransition(
            scale: _scaleAnims[i],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Icon pill ──────────────────────────────────────────────
                AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeInOut,
                  width: active ? 54 : 40,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: active ? _kActiveGradient : null,
                    color: active ? null : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: _kCyan.withValues(alpha: 0.40),
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
                        active ? tab.activeIcon : tab.icon,
                        key: ValueKey(active),
                        size: 21,
                        color: active
                            ? Colors.white
                            : _kSlate.withValues(alpha: .75),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                // ── Label ──────────────────────────────────────────────────
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 160),
                  style: TextStyle(
                    fontSize: active ? 11.5 : 11,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                    color: active ? _kCyanDeep : _kSlate.withValues(alpha: .75),
                  ),
                  child: Text(tab.label,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),

                const SizedBox(height: 4),

                // ── Active dot ─────────────────────────────────────────────
                AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeInOut,
                  width: active ? 18 : 0,
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: active
                        ? const LinearGradient(
                            colors: [_kCyan, _kCyanLight])
                        : null,
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