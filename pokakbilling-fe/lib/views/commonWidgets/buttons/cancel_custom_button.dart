import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

class CancelCustomButton extends StatelessWidget {
  final String text;
  const CancelCustomButton({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: Container(
        height: 40,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
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
