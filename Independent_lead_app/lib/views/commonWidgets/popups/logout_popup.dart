// import 'package:flutter/material.dart';
// import 'package:pokakbilling/core/services.dart';
// import 'package:pokakbilling/viewmodels/access_viewmodel.dart';
// import 'package:pokakbilling/views/Screens/auth/login_screen.dart';
// import 'package:provider/provider.dart';

// void showLogoutDialog(BuildContext context) {
//   final accessProvider = Provider.of<AccessViewModel>(context, listen: false);
//   SecureStorageService secureStorage = SecureStorageService();
//   accessProvider.isLogin();
//   showGeneralDialog(
//     context: context,
//     pageBuilder: (context, animation1, animation2) {
//       return Container();
//     },
//     transitionDuration: const Duration(milliseconds: 300),
//     transitionBuilder: (context, a1, a2, widget) {
//       return ScaleTransition(
//         scale: Tween<double>(begin: 0.5, end: 1.0).animate(a1),
//         child: FadeTransition(
//           opacity: Tween<double>(begin: 0.5, end: 1.0).animate(a1),
//           child: AlertDialog(
//             title: const Text(
//               "Confirm Logout",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(13.0),
//             ),
//             content: const Text(
//               "Are you sure you want to logout?",
//               style: TextStyle(fontSize: 16),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: const Text(
//                   "Cancel",
//                   style: TextStyle(
//                     fontSize: 15,
//                     color: Colors.black,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               TextButton(
//                 onPressed: () async {
//                   accessProvider.isLogout();
//                   secureStorage.deleteToken();
//                   Navigator.of(context).pushAndRemoveUntil(
//                     MaterialPageRoute(
//                         builder: (context) => const LoginScreen()),
//                     (route) => false,
//                   );
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
import 'package:pokakbilling/core/services.dart';
import 'package:pokakbilling/viewmodels/access_viewmodel.dart';
import 'package:pokakbilling/views/Screens/auth/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

// ─── Strict 3-color palette ───────────────────────────────────────────────────
class _C {
  _C._();
  static const Color navy = AppColors.navy;
  static const Color cyan = AppColors.cyan;
  static const Color ice = AppColors.ice;
  static const Color white = AppColors.white;
  static const Color red = AppColors.red;
}
// ─────────────────────────────────────────────────────────────────────────────

void showLogoutDialog(BuildContext context) {
  final accessProvider = Provider.of<AccessViewModel>(context, listen: false);
  final secureStorage = SecureStorageService();
  accessProvider.isLogin();

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Logout',
    barrierColor: _C.navy.withOpacity(0.55),
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (context, a1, a2, _) {
      final curved = CurvedAnimation(parent: a1, curve: Curves.easeOutBack);

      return ScaleTransition(
        scale: Tween<double>(begin: 0.75, end: 1.0).animate(curved),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: a1, curve: Curves.easeOut),
          ),
          child: _LogoutDialog(
            onCancel: () => Navigator.pop(context),
            onLogout: () async {
              accessProvider.isLogout();
              secureStorage.deleteToken();
              Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const LoginScreen(),
                  transitionDuration: const Duration(milliseconds: 300),
                  transitionsBuilder: (_, anim, __, child) =>
                      FadeTransition(opacity: anim, child: child),
                ),
                (route) => false,
              );
            },
          ),
        ),
      );
    },
  );
}

// ─── Logout dialog widget ─────────────────────────────────────────────────────
class _LogoutDialog extends StatefulWidget {
  final VoidCallback onCancel;
  final VoidCallback onLogout;

  const _LogoutDialog({
    required this.onCancel,
    required this.onLogout,
  });

  @override
  State<_LogoutDialog> createState() => _LogoutDialogState();
}

class _LogoutDialogState extends State<_LogoutDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _iconCtrl;
  late final Animation<double> _iconScale;
  late final Animation<double> _iconRotate;

  @override
  void initState() {
    super.initState();
    _iconCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _iconScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconCtrl, curve: Curves.easeOutBack),
    );
    _iconRotate = Tween<double>(begin: -0.15, end: 0.0).animate(
      CurvedAnimation(parent: _iconCtrl, curve: Curves.easeOut),
    );
    _iconCtrl.forward();
  }

  @override
  void dispose() {
    _iconCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: _C.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _C.navy.withOpacity(0.20),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Gradient header ──────────────────────────────────
            _buildHeader(),

            // ── Body ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                children: [
                  // Message
                  Text(
                    'Are you sure you want to\nlog out of your account?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: _C.navy.withOpacity(0.60),
                      height: 1.6,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      // Cancel
                      Expanded(
                        child: GestureDetector(
                          onTap: widget.onCancel,
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: _C.ice,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: _C.navy.withOpacity(0.12),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _C.navy.withOpacity(0.60),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Logout
                      Expanded(
                        child: _LogoutButton(
                          onTap: widget.onLogout,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _C.navy,
            Color.lerp(_C.navy, _C.red, 0.15)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // Animated icon
          ScaleTransition(
            scale: _iconScale,
            child: RotationTransition(
              turns: _iconRotate,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Glow ring
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _C.red.withOpacity(0.12),
                    ),
                  ),
                  // Icon container
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _C.red.withOpacity(0.15),
                      border: Border.all(
                        color: _C.red.withOpacity(0.30),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: _C.red,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Title
          const Text(
            'Confirm Logout',
            style: TextStyle(
              color: _C.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'You will be signed out',
            style: TextStyle(
              color: _C.ice.withOpacity(0.55),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Logout button with press animation ──────────────────────────────────────
class _LogoutButton extends StatefulWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0,
      upperBound: 1,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _C.red,
                Color.lerp(_C.red, _C.navy, 0.35)!,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _C.red.withOpacity(0.30),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                color: _C.white,
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                'Logout',
                style: TextStyle(
                  color: _C.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
