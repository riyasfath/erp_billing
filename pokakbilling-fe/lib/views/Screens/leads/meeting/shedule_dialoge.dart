import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leads.dart';

class MeetingScheduledDialog extends StatelessWidget {
  const MeetingScheduledDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context); // Close dialog
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LeadScreen()),
        );
      },
      child: Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent, // Make outside clickable
        child: GestureDetector(
          onTap: () {}, // Prevent tap inside from closing
          child: Container(
            height: 250,
            width: 250,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFECE2FF),
                  ),
                  padding: const EdgeInsets.all(25),
                  child: const Icon(
                    Icons.thumb_up,
                    size: 40,
                    color: AppColors.violetblue,
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  "Meeting Scheduled",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
