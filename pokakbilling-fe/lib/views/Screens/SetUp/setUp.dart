// import 'package:flutter/material.dart';
// import 'package:pokakbilling/core/themes/app_assets.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/views/Screens/SetUp/bank_account/bank_account.dart';
// import 'package:pokakbilling/views/Screens/SetUp/category/category.dart';
// import 'package:pokakbilling/views/Screens/SetUp/contract_details/contract_header/contract_header.dart';
// import 'package:pokakbilling/views/Screens/SetUp/terms_and_condition/terms_main_header/terms_header_.dart';
// import 'package:pokakbilling/views/Screens/SetUp/unit/unit.dart';
// import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';
// import 'package:pokakbilling/views/commonWidgets/buttons/cancel_custom_button.dart';

// class SetupScreen extends StatefulWidget {
//   const SetupScreen({super.key});

//   @override
//   State<SetupScreen> createState() => _SetupScreenState();
// }

// class _SetupScreenState extends State<SetupScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final double height = MediaQuery.of(context).size.height;
//     final double width = MediaQuery.of(context).size.width;
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.violetblue,
//         title: const Text(
//           'Set Up',
//           style: TextStyle(
//             color: AppColors.white,
//             fontSize: 17,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         leading: IconButton(
//           icon: Image.asset(AppAssets.homeIcon),
//           onPressed: () {
//             Navigator.of(context).push(
//               MaterialPageRoute(
//                 builder: (context) => const BottomBar(index: 0),
//               ),
//             );
//           },
//         ),
//       ),
//       body: SizedBox(
//         height: height,
//         width: width,
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 10),
//                 _setUpTile('Category', () {
//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (context) => const CategoryMain(),
//                     ),
//                   );
//                 }),
//                 _setUpTile('Create Unit', () {
//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (context) => const UnitMain(),
//                     ),
//                   );
//                 }),
//                 _setUpTile('Bank Account', () {
//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (context) => const BankAccountMain(),
//                     ),
//                   );
//                 }),
//                 _setUpTile('Terms and Condition', () {
//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (context) => const TermsConditionHeaderScreen(),
//                     ),
//                   );
//                 }),
//                 _setUpTile('Contract Details', () {
//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (context) => const ContractDetailsHeaderScreen(),
//                     ),
//                   );
//                 }),
//                 const SizedBox(height: 150),
//                 const CancelCustomButton(
//                   text: "Back",
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// Widget _setUpTile(String title, VoidCallback onTap) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 10),
//     child: ListTile(
//       shape: RoundedRectangleBorder(
//         side: const BorderSide(color: AppColors.grey, width: 1.5),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       title: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//       trailing:
//           const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.grey),
//       onTap: onTap,
//     ),
//   );
// }
