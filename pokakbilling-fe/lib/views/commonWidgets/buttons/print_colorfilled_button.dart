import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

class PrintFilledCustomButton extends StatelessWidget {
  final String text;
  const PrintFilledCustomButton({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // onTap: () => Navigator.pop(context),
      child: Container(
        height: 45,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.violetblue,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.violetblue),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
