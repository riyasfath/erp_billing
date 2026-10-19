import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

void showOverlayError(BuildContext context, String message) {
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => _AnimatedErrorOverlay(
      message: message,
      onDismiss: () => overlayEntry.remove(),
    ),
  );

  Overlay.of(context).insert(overlayEntry);
}

class _AnimatedErrorOverlay extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;

  const _AnimatedErrorOverlay({
    required this.message,
    required this.onDismiss,
  });

  @override
  State<_AnimatedErrorOverlay> createState() => _AnimatedErrorOverlayState();
}

class _AnimatedErrorOverlayState extends State<_AnimatedErrorOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    // Slides UP from bottom
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    _scale = Tween<double>(begin: 0.88, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));

    _ctrl.forward();

    Future.delayed(const Duration(milliseconds: 3500), _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _ctrl.reverse();
    if (mounted) widget.onDismiss();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 24,
      left: sw * 0.05,
      width: sw * 0.90,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: ScaleTransition(
            scale: _scale,
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: _dismiss,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A0A0A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.red.withOpacity(0.55),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.red.withOpacity(0.22),
                        blurRadius: 24,
                        spreadRadius: 2,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.45),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icon container
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.red.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.red.withOpacity(0.40),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.lock_person_rounded,
                          color: AppColors.red,
                          size: 20,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Text block
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Error',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.message,
                              style: TextStyle(
                                color: AppColors.white.withOpacity(0.65),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Dismiss X button
                      GestureDetector(
                        onTap: _dismiss,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.07),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: AppColors.white.withOpacity(0.55),
                            size: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
