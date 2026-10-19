// lib/views/Screens/common/MeetingScheduledDialog.dart
// ✅ FIXED: Provider pattern + LeadModel navigation - NO UI CHANGES

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leads.dart';

class MeetingScheduledDialog extends StatelessWidget {
  final LeadModel? lead; // ✅ Pass selected lead from meeting screen

  const MeetingScheduledDialog({
    super.key,
    this.lead,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context); // Close dialog

        // ✅ Navigate based on context - use Provider pattern
        if (lead != null) {
          // If we have specific lead from meeting, go to LeadsViewScreen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => LeadScreen(), // or LeadsViewScreen(lead: lead!)
            ),
          );
        } else {
          // Default navigation to main leads list
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const LeadScreen(),
            ),
          );
        }
      },
      child: Dialog(
        insetPadding: const EdgeInsets.all(40),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent, // ✅ Modern Flutter fix [web:160]
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320, maxHeight: 320),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFECE2FF),
                ),
                padding: const EdgeInsets.all(20),
                child: const Icon(
                  Icons.check_circle,
                  size: 40,
                  color: AppColors.violetblue,
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                "Meeting Scheduled!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Your meeting has been successfully scheduled.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              const Spacer(),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (lead != null) {
                      // Navigate to specific lead detail
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => LeadScreen(),
                        ),
                      );
                    } else {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const LeadScreen(),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.violetblue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "View Leads",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
