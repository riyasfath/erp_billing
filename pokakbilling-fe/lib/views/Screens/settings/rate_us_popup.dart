import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

void showRateUsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: "How is your experience with",
                style: TextStyle(
                  fontSize: 20,
                  color: AppColors.black,
                ),
              ),
              TextSpan(
                text: ' Pokak Billing',
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        content: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("😃", style: TextStyle(fontSize: 32)),
                SizedBox(height: 4),
                Text("Great")
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("😐", style: TextStyle(fontSize: 32)),
                SizedBox(height: 4),
                Text("Okay")
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("😡", style: TextStyle(fontSize: 32)),
                SizedBox(height: 4),
                Text("Bad")
              ],
            ),
          ],
        ),
      );
    },
  );
}
