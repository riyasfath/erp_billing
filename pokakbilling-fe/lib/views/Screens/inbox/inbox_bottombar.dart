import 'package:flutter/material.dart';

class InboxBottomBar extends StatelessWidget {
  const InboxBottomBar({
    super.key,
    required this.activeIndex, // 0=Home, 1=Inbox, 2=AllContacts
    required this.onTapHome,
    required this.onTapInbox,
    required this.onTapAllContacts,
  });

  final int activeIndex;
  final VoidCallback onTapHome;
  final VoidCallback onTapInbox;
  final VoidCallback onTapAllContacts;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barBg = isDark ? const Color(0xFF1E1B4B) : Colors.white;
    final selectedFg =
        isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1);
    final unselectedFg =
        isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black45;
    final shadowColor =
        isDark ? Colors.black.withValues(alpha: 0.4) : const Color(0x22000000);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFF6366F1).withValues(alpha: 0.15);

    return SafeArea(
      top: false,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: barBg,
          border: Border(top: BorderSide(color: borderColor, width: 1)),
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              offset: const Offset(0, -4),
              color: shadowColor,
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Home ──────────────────────────────────────────────────────
            _NavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              selected: activeIndex == 0,
              selectedColor: selectedFg,
              unselectedColor: unselectedFg,
              isDark: isDark,
              onTap: onTapHome,
            ),
            // ── Inbox ─────────────────────────────────────────────────────
            _NavItem(
              icon: Icons.inbox_rounded,
              label: 'Inbox',
              selected: activeIndex == 1,
              selectedColor: selectedFg,
              unselectedColor: unselectedFg,
              isDark: isDark,
              onTap: onTapInbox,
            ),
            // ── All Contacts ──────────────────────────────────────────────
            _NavItem(
              icon: Icons.people_rounded,
              label: 'All Contacts',
              selected: activeIndex == 2,
              selectedColor: selectedFg,
              unselectedColor: unselectedFg,
              isDark: isDark,
              onTap: onTapAllContacts,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color unselectedColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              decoration: BoxDecoration(
                color: selected
                    ? selectedColor.withValues(alpha: isDark ? 0.18 : 0.10)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 22,
                color: selected ? selectedColor : unselectedColor,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? selectedColor : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
