import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_assets.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

class PdfCustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const PdfCustomButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 45,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.grey),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppAssets.pdfImg, width: 80, height: 100),
            Text(
              text,
              style: const TextStyle(
                color: AppColors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
