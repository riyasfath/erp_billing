import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pokakbilling/viewmodels/login_viewmodel.dart';
import 'package:pokakbilling/viewmodels/customer_viewmodel.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
import 'package:pokakbilling/viewmodels/meeting_viewmodel.dart';
import 'package:pokakbilling/viewmodels/reminder/reminder_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/followup_viewmodel.dart';
import 'package:pokakbilling/viewmodels/chat_users_viewmodel.dart';
import 'package:pokakbilling/viewmodels/chat_viewmodel.dart';
import 'package:pokakbilling/viewmodels/profile_viewmodel.dart';

class SessionService {
  SessionService._();
  static final SessionService instance = SessionService._();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  bool _isHandling = false;

  Future<void> handleSessionExpired() async {
    if (_isHandling) return;
    _isHandling = true;

    try {
      final context = navigatorKey.currentContext;
      if (context == null) return;

      _resetAllViewModels(context);

      await navigatorKey.currentState?.push(
        PageRouteBuilder(
          opaque: false,
          barrierDismissible: false, // user MUST tap Sign Out
          barrierColor: Colors.black.withValues(alpha: 0.55),
          pageBuilder: (ctx, _, __) => const _SessionExpiredDialog(),
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (ctx, a1, a2, child) {
            final curved =
                CurvedAnimation(parent: a1, curve: Curves.easeOutBack);
            return ScaleTransition(
              scale: Tween<double>(begin: 0.75, end: 1.0).animate(curved),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(a1),
                child: child,
              ),
            );
          },
        ),
      );
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    } finally {
      await Future.delayed(const Duration(seconds: 4));
      _isHandling = false;
    }
  }

  void _resetAllViewModels(BuildContext context) {
    _safe(() => _vm<LoginViewModel>(context)?.clearSession());
    _safe(() => _vm<CustomerViewmodel>(context)?.reset());
    _safe(() => _vm<LeadViewmodel>(context)?.reset());
    _safe(() => _vm<MeetingViewmodel>(context)?.reset());
    _safe(() => _vm<ReminderViewmodel>(context)?.reset());
    _safe(() => _vm<FollowupViewmodel>(context)?.reset());
    _safe(() => _vm<ChatUsersViewModel>(context)?.reset());
    _safe(() => _vm<ChatInboxViewModel>(context)?.reset());
    _safe(() => _vm<ProfileViewmodel>(context)?.reset());
  }

  T? _vm<T>(BuildContext context) {
    try {
      return Provider.of<T>(context, listen: false);
    } catch (_) {
      return null;
    }
  }

  void _safe(void Function() fn) {
    try {
      fn();
    } catch (_) {}
  }
}

class _SessionExpiredDialog extends StatelessWidget {
  const _SessionExpiredDialog();

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
        const Color(0xFFEF4444).withValues(alpha: isDark ? 0.15 : 0.08);
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
            Container(
              height: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFFCA5A5)],
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
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: iconRingBg,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.lock_clock_outlined,
                      color: Color(0xFFEF4444),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 18),

                  Text(
                    'Session Expired',
                    style: TextStyle(
                      color: fg,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Your session has expired due to inactivity.\nPlease sign in again to continue.',
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

                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFF87171)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.login_rounded,
                              color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Sign In Again',
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
