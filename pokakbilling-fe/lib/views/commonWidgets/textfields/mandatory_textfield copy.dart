import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

class MandatoryTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final String hintText;
  final bool isRequired;

  const MandatoryTextField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.hintText = '',
    this.isRequired = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        label: RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              color: AppColors.violetblue,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            children: isRequired
                ? [
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: AppColors.red,
                        fontSize: 16,
                      ),
                    ),
                  ]
                : [],
          ),
        ),
        hintText: hintText,
      ),
    );
  }
}
