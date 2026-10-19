import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

class MainPageCustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const MainPageCustomButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onPressed(),
      child: Container(
        height: 30,
        width: 150,
        decoration: BoxDecoration(
          color: AppColors.violetblue,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.white),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
