import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_text.dart';

class CustomTextfield extends StatelessWidget {
  final String label;
  final String hintText;
  final double screenWidth;
  final TextEditingController textController;
  final bool isMandatory;
  final Widget? suffixIcon;
  final bool isEnabled;
  final bool isValidationRequired;

  const CustomTextfield({
    super.key,
    required this.label,
    required this.screenWidth,
    required this.hintText,
    required this.textController,
    required this.isMandatory,
    this.suffixIcon,
    this.isEnabled = true,
    this.isValidationRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textController,
      enabled: isEnabled,
      validator: isValidationRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'required';
              }
              return null;
            }
          : null,
      decoration: InputDecoration(
        label: CustomText(
          text: label,
          isMandatory: isMandatory,
        ),
        // hintText: hintText,
        labelStyle: const TextStyle(
          color: AppColors.violetblue,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
