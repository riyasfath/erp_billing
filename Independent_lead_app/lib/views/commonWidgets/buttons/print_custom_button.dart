import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

class PrintCustomButton extends StatelessWidget {
  final String text;
  const PrintCustomButton({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // onTap: () => Navigator.pop(context),
      child: Container(
        height: 45,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.violetblue),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.violetblue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
