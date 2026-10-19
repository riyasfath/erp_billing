import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

void showDeleteDialog(
  BuildContext context,
  String text,
  Future<void> Function() deleteFunction,
) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: Colors.black.withOpacity(0.35),
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (_, __, ___) => const SizedBox(),
    transitionBuilder: (context, animation, _, __) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack);

      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.15),
            end: Offset.zero,
          ).animate(curved),
          child: _DeleteDialogUI(
            text: text,
            deleteFunction: deleteFunction,
          ),
        ),
      );
    },
  );
}

class _DeleteDialogUI extends StatefulWidget {
  final String text;
  final Future<void> Function() deleteFunction;

  const _DeleteDialogUI({
    required this.text,
    required this.deleteFunction,
  });

  @override
  State<_DeleteDialogUI> createState() => _DeleteDialogUIState();
}

class _DeleteDialogUIState extends State<_DeleteDialogUI>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _iconScale;
  late final Animation<double> _iconRotate;

  bool isLoading = false;

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

    _iconRotate = Tween<double>(begin: -0.15, end: 0).animate(
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
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cborder),
            boxShadow: [
              BoxShadow(
                color: AppColors.c1.withOpacity(0.10),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: AppColors.tagRed.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Animated delete icon ─────────────────────────────────
              ScaleTransition(
                scale: _iconScale,
                child: RotationTransition(
                  turns: _iconRotate,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.tagRedBg,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.tagRed.withOpacity(0.30),
                      ),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.tagRed,
                      size: 24,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Title ─────────────────────────────────────────────────
              const Text(
                'Confirm Delete',
                style: TextStyle(
                  color: AppColors.cdark,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 6),

              // ── Message ───────────────────────────────────────────────
              Text(
                'Are you sure you want to delete this ${widget.text}?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.ctext,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 20),

              // ── Divider ───────────────────────────────────────────────
              const Divider(height: 1, thickness: 1, color: AppColors.cborder),

              const SizedBox(height: 16),

              // ── Buttons ───────────────────────────────────────────────
              Row(
                children: [
                  // Cancel
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.cxl,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.cborder),
                        ),
                        child: const Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: AppColors.cdark,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Delete
                  Expanded(
                    child: GestureDetector(
                      onTap: isLoading
                          ? null
                          : () async {
                              setState(() => isLoading = true);
                              await widget.deleteFunction();
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.tagRed,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.tagRed.withOpacity(0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: isLoading
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.white,
                                  ),
                                )
                              : const Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
