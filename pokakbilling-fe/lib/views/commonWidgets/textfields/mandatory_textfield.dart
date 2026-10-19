import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

class MandatoryTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isRequired;
  final String? Function(String?)? validator;

  const MandatoryTextField({
    super.key,
    required this.controller,
    required this.label,
    this.isRequired = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.violetblue,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            isDense: true,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFDDDDDD)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.violetblue),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
