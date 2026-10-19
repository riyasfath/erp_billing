import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

class CommonDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;
  final IconData prefixIcon;

  const CommonDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.validator,
    required this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<T>(
        dropdownColor: AppColors.cxl,
        isExpanded: true,
        isDense: true,
        value: value,
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(
              itemLabel(item),
              style: const TextStyle(
                color: AppColors.cdark,
                fontSize: 14,
              ),
              overflow: TextOverflow.visible,
              softWrap: false,
            ),
          );
        }).toList(),
        selectedItemBuilder: (context) {
          return items.map((item) {
            return Align(
              alignment: Alignment.centerLeft,
              child: Text(
                itemLabel(item),
                style: const TextStyle(
                  color: AppColors.cdark,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          }).toList();
        },
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontSize: 13,
            color: AppColors.cdark,
          ),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          suffixIcon: const Icon(
            Icons.keyboard_arrow_down,
            size: 20,
            color: AppColors.c1,
          ),
          filled: true,
          fillColor: AppColors.cxl,
          prefixIcon: Icon(prefixIcon, color: AppColors.c1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.cborder),
          ),
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
      ),
    );
  }
}
