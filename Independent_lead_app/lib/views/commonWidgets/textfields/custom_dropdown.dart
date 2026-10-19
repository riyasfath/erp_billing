import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_text.dart';

class CustomDropdown extends StatefulWidget {
  final String? selectedValue;
  final String hint;
  final List<String>? dropdownItems;
  final Function(String?)? onChanged;
  final String? Function(String?)? validator;
  const CustomDropdown({
    super.key,
    required this.selectedValue,
    required this.hint,
    required this.dropdownItems,
    required this.onChanged,
    this.validator,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue:
          widget.selectedValue?.isEmpty ?? true ? null : widget.selectedValue,
      validator: widget.validator,
      style: const TextStyle(
        color: AppColors.cdark, // or AppColors.ice
        fontSize: 14,
      ),
      hint: Text(
        widget.hint,
        style: const TextStyle(
          color: AppColors.cdark,
          fontSize: 14,
        ),
      ),
      decoration: InputDecoration(
        label: CustomText(
          text: widget.hint,
          isMandatory: false,
        ),
        suffixIcon: const Icon(
          Icons.keyboard_arrow_down,
          size: 20,
          color: AppColors.c1,
        ),
        filled: true,
        fillColor: AppColors.cxl,
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.cborder),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.cborder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.c1, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.tagRed.withOpacity(0.6)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.tagRed, width: 1.5),
        ),
      ),
      items: widget.dropdownItems?.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: const TextStyle(
              color: AppColors.cdark,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      }).toList(),
      onChanged: widget.onChanged,
      dropdownColor: AppColors.cxl,
    );
  }
}
