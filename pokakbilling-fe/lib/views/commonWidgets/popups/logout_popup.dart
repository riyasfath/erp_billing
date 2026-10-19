// import 'package:flutter/material.dart';
// import 'package:pokakbilling/core/api/dio_client.dart';
// import 'package:pokakbilling/core/services.dart';
// import 'package:pokakbilling/viewmodels/access_viewmodel.dart';
// import 'package:pokakbilling/views/Screens/auth/login_screen.dart';
// import 'package:pokakbilling/main.dart';
// import 'package:provider/provider.dart';

// void showLogoutDialog(BuildContext context) {
//   showGeneralDialog(
//     context: context,
//     pageBuilder: (_, __, ___) => const SizedBox.shrink(),
//     transitionDuration: const Duration(milliseconds: 300),
//     transitionBuilder: (ctx, a1, a2, _) {
//       return ScaleTransition(
//         scale: Tween<double>(begin: 0.5, end: 1.0).animate(a1),
//         child: FadeTransition(
//           opacity: Tween<double>(begin: 0.5, end: 1.0).animate(a1),
//           child: AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             title: const Text(
//               "Confirm Logout",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             content: const Text(
//               "Are you sure you want to logout?",
//               style: TextStyle(fontSize: 16),
//             ),
//             actions: [
//               // ── Cancel ───────────────────────────────────────────────────
//               TextButton(
//                 onPressed: () => Navigator.pop(ctx),
//                 child: const Text(
//                   "Cancel",
//                   style: TextStyle(
//                     fontSize: 15,
//                     color: Colors.black,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),

//               // ── Logout ───────────────────────────────────────────────────
//               TextButton(
//                 onPressed: () async {
//                   // 1. Close dialog
//                   Navigator.pop(ctx);

//                   // 2. Delete token from secure storage
//                   await SecureStorageService().deleteToken();

//                   // 3. Strip the Authorization header from Dio immediately
//                   //    This is the critical step — prevents the old user's
//                   //    token from being sent in any subsequent API calls
//                   DioClient.clearAuth();

//                   // 4. Mark logged out in AccessViewModel
//                   if (context.mounted) {
//                     Provider.of<AccessViewModel>(context, listen: false)
//                         .isLogout();
//                   }

//                   // 5. Restart provider tree — wipes all ViewModel data
//                   if (context.mounted) {
//                     AppRoot.restart(context);
//                   }

//                   // 6. Navigate to LoginScreen with clean stack
//                   if (context.mounted) {
//                     Navigator.of(context).pushAndRemoveUntil(
//                       MaterialPageRoute(
//                         builder: (_) => const LoginScreen(),
//                       ),
//                       (route) => false,
//                     );
//                   }
//                 },
//                 child: const Text(
//                   "Logout",
//                   style: TextStyle(
//                     fontSize: 15,
//                     color: Colors.red,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }
import 'package:flutter/material.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/core/services.dart';
import 'package:pokakbilling/viewmodels/access_viewmodel.dart';
import 'package:pokakbilling/views/Screens/auth/login_screen.dart';
import 'package:pokakbilling/main.dart';
import 'package:provider/provider.dart';

void showLogoutDialog(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withValues(alpha: 0.55),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionDuration: const Duration(milliseconds: 350),
    transitionBuilder: (ctx, a1, a2, _) {
      final curved = CurvedAnimation(parent: a1, curve: Curves.easeOutBack);
      return ScaleTransition(
        scale: Tween<double>(begin: 0.75, end: 1.0).animate(curved),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(a1),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: _LogoutDialogContent(isDark: isDark),
          ),
        ),
      );
    },
  );
}

class _LogoutDialogContent extends StatefulWidget {
  final bool isDark;
  const _LogoutDialogContent({required this.isDark});

  @override
  State<_LogoutDialogContent> createState() => _LogoutDialogContentState();
}

class _LogoutDialogContentState extends State<_LogoutDialogContent> {
  bool _loading = false;

  bool get _isDark => widget.isDark;

  Color get _bg => _isDark ? const Color(0xFF1E1A3C) : Colors.white;
  Color get _cardBorder => _isDark
      ? Colors.white.withValues(alpha: 0.10)
      : const Color(0xFF6366F1).withValues(alpha: 0.15);
  Color get _fg => _isDark ? Colors.white : const Color(0xFF1E1B4B);
  Color get _fgMuted => _isDark
      ? Colors.white.withValues(alpha: 0.55)
      : const Color(0xFF1E1B4B).withValues(alpha: 0.5);
  Color get _iconRingBg => _isDark
      ? const Color(0xFFEF4444).withValues(alpha: 0.15)
      : const Color(0xFFEF4444).withValues(alpha: 0.08);
  Color get _divider => _isDark
      ? Colors.white.withValues(alpha: 0.08)
      : const Color(0xFF6366F1).withValues(alpha: 0.10);
  Color get _cancelBg => _isDark
      ? Colors.white.withValues(alpha: 0.07)
      : const Color(0xFF6366F1).withValues(alpha: 0.06);
  Color get _cancelBorder => _isDark
      ? Colors.white.withValues(alpha: 0.12)
      : const Color(0xFF6366F1).withValues(alpha: 0.2);

  Future<void> _doLogout() async {
    setState(() => _loading = true);

    Navigator.pop(context);
    await SecureStorageService().deleteToken();
    DioClient.clearAuth();

    if (context.mounted) {
      Provider.of<AccessViewModel>(context, listen: false).isLogout();
    }
    if (context.mounted) {
      AppRoot.restart(context);
    }
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _isDark ? 0.45 : 0.12),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Top accent bar ─────────────────────────────────────────────
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
                // ── Icon ────────────────────────────────────────────────
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _iconRingBg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFEF4444),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 18),

                // ── Title ────────────────────────────────────────────────
                Text(
                  'Sign Out',
                  style: TextStyle(
                    color: _fg,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),

                // ── Subtitle ─────────────────────────────────────────────
                Text(
                  'You will be signed out of your account\nand returned to the login screen.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _fgMuted,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                Divider(color: _divider, height: 1, thickness: 0.5),
                const SizedBox(height: 20),

                // ── Buttons ──────────────────────────────────────────────
                Row(children: [
                  // Cancel
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: _cancelBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _cancelBorder, width: 1),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: _fg,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Logout
                  Expanded(
                    child: GestureDetector(
                      onTap: _loading ? null : _doLogout,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFEF4444),
                              Color(0xFFF87171),
                            ],
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
                        child: Center(
                          child: _loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.logout_rounded,
                                        color: Colors.white, size: 15),
                                    SizedBox(width: 6),
                                    Text(
                                      'Sign Out',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
