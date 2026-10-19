import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

void showPointsEditDialog({
  required BuildContext context,
  required String initialText,
  required Future<void> Function(String newText) onEdit,
}) {
  final TextEditingController controller =
      TextEditingController(text: initialText);

  showGeneralDialog(
    context: context,
    pageBuilder: (context, animation1, animation2) {
      return Container();
    },
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (context, a1, a2, widget) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(a1),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.5, end: 1.0).animate(a1),
          child: AlertDialog(
            title: const Text(
              "Edit Heading",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13.0),
            ),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Enter new point",
                hintStyle: TextStyle(fontWeight: FontWeight.w500),
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await onEdit(controller.text);
                },
                child: const Text(
                  "Save",
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.violetblue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
