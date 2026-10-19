// import 'package:flutter/material.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/viewmodels/settings_viewmodel.dart';
// import 'package:pokakbilling/views/Screens/settings/rate_us_popup.dart';
// import 'package:pokakbilling/views/Screens/settings/settings_customfield.dart';
// import 'package:provider/provider.dart';

// class SettingsScreen extends StatelessWidget {
//   const SettingsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final double width = MediaQuery.of(context).size.width;
//     final double height = MediaQuery.of(context).size.height;
//     final settingsViewmodel = Provider.of<SettingsViewmodel>(context);

//     return Scaffold(
//       appBar: AppBar(
//         leading: null,
//         automaticallyImplyLeading: false,
//         title: const Text(
//           "Settings",
//           style: TextStyle(color: AppColors.white),
//         ),
//         backgroundColor: AppColors.violetblue,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             buildTextFormField(
//                 "Company name & address", "Enter Your Company Name & Address"),
//             const SizedBox(height: 16),
//             buildTextFormField(
//                 "Enter your name & address", "Enter Your Name & Address"),
//             const SizedBox(height: 16),
//             const Text(
//               "Attach your logo",
//               style: TextStyle(
//                 fontSize: 16,
//                 color: AppColors.grey,
//               ),
//             ),
//             const SizedBox(height: 8),
//             GestureDetector(
//               onTap: () => settingsViewmodel.pickImage(),
//               child: Align(
//                 alignment: Alignment.centerRight,
//                 child: Container(
//                   width: width * 0.3,
//                   height: height * 0.14,
//                   decoration: BoxDecoration(
//                     color: const Color.fromARGB(255, 181, 175, 175),
//                     border: Border.all(color: Colors.grey),
//                     borderRadius: BorderRadius.circular(8),
//                     image: settingsViewmodel.selectedImage != null
//                         ? DecorationImage(
//                             image: FileImage(settingsViewmodel.selectedImage!),
//                             fit: BoxFit.cover,
//                           )
//                         : null,
//                   ),
//                   child: settingsViewmodel.selectedImage == null
//                       ? const Center(
//                           child: Text(
//                             "Attach Logo",
//                             style: TextStyle(color: Colors.grey),
//                           ),
//                         )
//                       : null,
//                 ),
//               ),
//             ),
//             RichText(
//               text: const TextSpan(
//                 children: [
//                   TextSpan(
//                     text: "Business type",
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: AppColors.grey,
//                     ),
//                   ),
//                   TextSpan(
//                     text: ' *',
//                     style: TextStyle(
//                       color: AppColors.red,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 10),
//             SettingsCustomfield(
//               customText: "Individual",
//               onPressed: () {
//                 null;
//               },
//             ),
//             const SizedBox(height: 10),
//             SettingsCustomfield(
//               customText: "Contact Us",
//               onPressed: () {
//                 null;
//               },
//             ),
//             const SizedBox(height: 10),
//             SettingsCustomfield(
//               customText: "Rate Us",
//               onPressed: () {
//                 showRateUsDialog(context);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildTextFormField(String label, String hint) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         RichText(
//           text: TextSpan(
//             children: [
//               TextSpan(
//                 text: label,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   color: AppColors.grey,
//                 ),
//               ),
//               const TextSpan(
//                 text: ' *',
//                 style: TextStyle(
//                   color: AppColors.red,
//                   fontSize: 16,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 8),
//         SizedBox(
//           height: 55,
//           child: TextFormField(
//             decoration: InputDecoration(
//               hintText: hint,
//               hintStyle: const TextStyle(color: AppColors.grey),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(15),
//                 borderSide: const BorderSide(color: AppColors.grey),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        automaticallyImplyLeading: false,
        title: const Text(
          "Settings",
          style: TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.violetblue,
      ),
      body: const Center(
        child: Text(
          "Settings feature coming soon!",
          style: TextStyle(
            fontSize: 16,
            color: AppColors.grey,
          ),
        ),
      ),
    );
  }
}
