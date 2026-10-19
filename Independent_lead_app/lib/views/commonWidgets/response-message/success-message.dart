// import 'package:flash/flash.dart';
// import 'package:flutter/material.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';

// void showSuccessMessage(BuildContext context, String message) {
//   showFlash(
//     context: context,
//     duration: const Duration(seconds: 3),
//     builder: (context, controller) {
//       return FlashBar(
//         controller: controller,
//         position: FlashPosition.bottom,
//         forwardAnimationCurve: Curves.easeOut,
//         reverseAnimationCurve: Curves.easeIn,
//         content: Row(
//           children: [
//             const Icon(Icons.check_circle, color: AppColors.green),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 message,
//                 style: const TextStyle(color: AppColors.black),
//               ),
//             ),
//           ],
//         ),
//       );
//     },import 'package:flash/flash.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
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

// ── Success message ───────────────────────────────────────────────────────────
void showSuccessMessage(BuildContext context, String message) {
  _showToast(
    context: context,
    message: message,
    icon: Icons.check_circle_rounded,
    iconColor: _C.cyan,
    accentColor: _C.cyan,
  );
}

// ── Error message ─────────────────────────────────────────────────────────────
void showErrorMessage(BuildContext context, String message) {
  _showToast(
    context: context,
    message: message,
    icon: Icons.error_rounded,
    iconColor: _C.red,
    accentColor: _C.red,
  );
}

// ── Info message ──────────────────────────────────────────────────────────────
void showInfoMessage(BuildContext context, String message) {
  _showToast(
    context: context,
    message: message,
    icon: Icons.info_rounded,
    iconColor: _C.navy,
    accentColor: _C.navy,
  );
}

// ── Core toast builder ────────────────────────────────────────────────────────
void _showToast({
  required BuildContext context,
  required String message,
  required IconData icon,
  required Color iconColor,
  required Color accentColor,
}) {
  showFlash(
    context: context,
    duration: const Duration(seconds: 3),
    builder: (context, controller) {
      return FlashBar(
        controller: controller,
        position: FlashPosition.bottom,
        forwardAnimationCurve: Curves.easeOutBack,
        reverseAnimationCurve: Curves.easeIn,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        behavior: FlashBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: _ToastContent(
          message: message,
          icon: icon,
          iconColor: iconColor,
          accentColor: accentColor,
        ),
      );
    },
  );
}

// ── Animated toast content ────────────────────────────────────────────────────
class _ToastContent extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color iconColor;
  final Color accentColor;

  const _ToastContent({
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.accentColor,
  });

  @override
  State<_ToastContent> createState() => _ToastContentState();
}

class _ToastContentState extends State<_ToastContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _iconScale;
  late final Animation<double> _iconRotate;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _iconScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    _iconRotate = Tween<double>(begin: -0.3, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _C.navy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.accentColor.withOpacity(0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: _C.navy.withOpacity(0.30),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: widget.accentColor.withOpacity(0.20),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Animated icon
          ScaleTransition(
            scale: _iconScale,
            child: RotationTransition(
              turns: _iconRotate,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: widget.accentColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.accentColor.withOpacity(0.30),
                  ),
                ),
                child: Center(
                  child: Icon(
                    widget.icon,
                    color: widget.iconColor,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Left accent bar
          Container(
            width: 2,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.accentColor,
                  widget.accentColor.withOpacity(0.20),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),

          const SizedBox(width: 12),

          // Message
          Expanded(
            child: Text(
              widget.message,
              style: const TextStyle(
                color: _C.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Cyan dot accent
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: widget.accentColor.withOpacity(0.60),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
//   );
// }
