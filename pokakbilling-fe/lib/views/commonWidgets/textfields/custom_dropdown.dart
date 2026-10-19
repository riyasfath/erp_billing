// import 'package:flutter/material.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/views/commonWidgets/textfields/custom_text.dart';

// class CustomDropdown extends StatefulWidget {
//   final String? selectedValue;
//   final String hint;
//   final List<String>? dropdownItems;
//   final Function(String?)? onChanged;
//   const CustomDropdown({
//     super.key,
//     required this.selectedValue,
//     required this.hint,
//     required this.dropdownItems,
//     required this.onChanged,
//   });

//   @override
//   State<CustomDropdown> createState() => _CustomDropdownState();
// }

// class _CustomDropdownState extends State<CustomDropdown> {
//   @override
//   Widget build(BuildContext context) {
//     return DropdownButtonFormField<String>(
//       initialValue:
//           widget.selectedValue?.isEmpty ?? true ? null : widget.selectedValue,
//       decoration: InputDecoration(
//         label: CustomText(
//           text: widget.hint,
//           isMandatory: true,
//         ),
//         contentPadding: const EdgeInsets.symmetric(vertical: 8),
//       ),
//       items: widget.dropdownItems?.map((item) {
//         return DropdownMenuItem<String>(
//           value: item,
//           child: Text(
//             item,
//             style: const TextStyle(
//               color: AppColors.black,
//               fontWeight: FontWeight.w400,
//             ),
//           ),
//         );
//       }).toList(),
//       onChanged: widget.onChanged,
//       dropdownColor: Colors.white,
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_text.dart';

class CustomDropdown extends StatefulWidget {
  final String? selectedValue;
  final String hint;
  final List<String>? dropdownItems;
  final Function(String?)? onChanged;
  const CustomDropdown({
    super.key,
    required this.selectedValue,
    required this.hint,
    required this.dropdownItems,
    required this.onChanged,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      isExpanded: true, // prevents unbounded width expansion inside Row
      initialValue:
          widget.selectedValue?.isEmpty ?? true ? null : widget.selectedValue,
      decoration: InputDecoration(
        label: CustomText(
          text: widget.hint,
          isMandatory: true,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
      items: widget.dropdownItems?.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            overflow:
                TextOverflow.ellipsis, // prevents item text from overflowing
            style: const TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      }).toList(),
      onChanged: widget.onChanged,
      dropdownColor: Colors.white,
    );
  }
}
