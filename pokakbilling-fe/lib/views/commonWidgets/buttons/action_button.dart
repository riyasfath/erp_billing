
import 'package:flutter/material.dart';

const Color _kAccent = Color(0xFF818CF8);

class ActionButton extends StatelessWidget {
  final String text;
  final bool loading;
  final VoidCallback onPressed;
  final bool isColored;

  const ActionButton({
    super.key,
    required this.text,
    required this.loading,
    required this.onPressed,
    required this.isColored,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // ── Colored (filled) button — same indigo accent in both themes ────────
    const Color filledBg = _kAccent;
    const Color filledText = Colors.white;

    // ── Outlined button — theme-aware border + text ────────────────────────
    final Color outlineBg =
        isDark ? Colors.white.withValues(alpha: 0.07) : Colors.white;
    final Color outlineBorder = isDark
        ? Colors.white.withValues(alpha: 0.20)
        : const Color(0xFF6366F1).withValues(alpha: 0.35);
    final Color outlineText = isDark
        ? Colors.white.withValues(alpha: 0.80)
        : const Color(0xFF1E1B4B).withValues(alpha: 0.65);

    return GestureDetector(
      onTap: loading ? null : onPressed,
      child: Container(
        height: 26,
        width: 60,
        decoration: BoxDecoration(
          color: isColored ? filledBg : outlineBg,
          borderRadius: BorderRadius.circular(8),
          border: isColored ? null : Border.all(color: outlineBorder, width: 1),
          boxShadow: isColored
              ? [
                  BoxShadow(
                    color: _kAccent.withValues(alpha: 0.30),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: loading
              ? SizedBox(
                  height: 10,
                  width: 10,
                  child: CircularProgressIndicator(
                    color: isColored ? Colors.white : _kAccent,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  text,
                  style: TextStyle(
                    color: isColored ? filledText : outlineText,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
        ),
      ),
    );
  }
}
