import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

class SettingsCustomfield extends StatelessWidget {
  final String customText;
  final VoidCallback onPressed;
  const SettingsCustomfield({
    super.key,
    required this.customText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onPressed();
      },
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey, width: 1.5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 10.0,
            bottom: 8.0,
            left: 16,
          ),
          child: Text(
            customText,
            style: const TextStyle(
              color: AppColors.black,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
