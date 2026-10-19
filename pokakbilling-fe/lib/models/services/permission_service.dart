import 'package:flutter/material.dart';
import 'package:pokakbilling/core/api/sessionExpiredService.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PermissionService
//
// HOW IT WORKS (mirrors SessionService):
//
//  1. DioClient._SessionInterceptor (or ApiHelper) sees a 403 response.
//  2. It calls PermissionService.instance.showNoPermissionPopup().
//  3. This shows a small "Access Denied" popup using the SAME global
//     navigatorKey already wired into MaterialApp for session expiry — no
//     extra main.dart wiring needed.
//  4. Unlike session expiry, this does NOT reset ViewModels or navigate —
//     the user just dismisses it and stays where they are.
//
//  Duplicate triggers are blocked by _isShowing so rapid parallel requests
//  that all 403 at once don't stack multiple popups.
// ─────────────────────────────────────────────────────────────────────────────
class PermissionService {
  PermissionService._();
  static final PermissionService instance = PermissionService._();

  bool _isShowing = false;

  Future<void> showNoPermissionPopup({
    String message =
        "You don't have permission to perform this action. Please contact your admin if you think this is a mistake.",
  }) async {
    if (_isShowing) return;

    final context = SessionService.instance.navigatorKey.currentContext;
    if (context == null) return;

    _isShowing = true;
    try {
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => _NoPermissionDialog(message: message),
      );
    } finally {
      _isShowing = false;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _NoPermissionDialog
// Same visual language as _SessionExpiredDialog (dark-mode aware, gradient
// accent bar) but amber/orange to distinguish "blocked action" from
// "session expired", and dismiss-only — no navigation, no sign out.
// ─────────────────────────────────────────────────────────────────────────────
class _NoPermissionDialog extends StatelessWidget {
  final String message;
  const _NoPermissionDialog({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF1E1A3C) : Colors.white;
    final cardBorder = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFF6366F1).withValues(alpha: 0.15);
    final fg = isDark ? Colors.white : const Color(0xFF1E1B4B);
    final fgMuted = isDark
        ? Colors.white.withValues(alpha: 0.55)
        : const Color(0xFF1E1B4B).withValues(alpha: 0.5);
    final iconRingBg =
        const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.15 : 0.08);
    final divider = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFF6366F1).withValues(alpha: 0.10);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cardBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Top accent bar ───────────────────────────────────────────
            Container(
              height: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFFCD34D)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Icon ─────────────────────────────────────────────
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: iconRingBg,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      color: Color(0xFFF59E0B),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── Title ─────────────────────────────────────────────
                  Text(
                    'Access Denied',
                    style: TextStyle(
                      color: fg,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Subtitle ──────────────────────────────────────────
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: fgMuted,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Divider(color: divider, height: 1, thickness: 0.5),
                  const SizedBox(height: 20),

                  // ── Single dismiss button ──────────────────────────────
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_rounded,
                              color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Got It',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
