import 'package:flutter/material.dart';

void showDeleteDialog(
  BuildContext context,
  text,
  Future<void> Function() deleteFunction,
) {
  showGeneralDialog(
    context: context,
    pageBuilder: (context, animation1, animation2) {
      return Container();
    },
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (context, a1, a2, widget) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1), // Start from bottom
          end: Offset.zero, // End at center
        ).animate(a1),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.5, end: 1.0).animate(a1),
          child: AlertDialog(
            title: const Text(
              "Confirm Delete",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13.0),
            ),
            content: Text(
              "Are you sure you want to delete this $text?",
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await deleteFunction();
                },
                child: const Text(
                  "Delete",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.red,
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
