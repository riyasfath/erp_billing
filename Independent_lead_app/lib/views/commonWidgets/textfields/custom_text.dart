import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

class CustomText extends StatelessWidget {
  final String text;
  final bool isMandatory;
  const CustomText({super.key, required this.text, required this.isMandatory});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.ctext,
            ),
          ),
          if (isMandatory)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                color: AppColors.red,
                fontSize: 16,
              ),
            ),
        ],
      ),
    );
  }
}
