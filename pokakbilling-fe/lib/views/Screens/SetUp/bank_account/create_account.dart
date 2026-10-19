// import 'package:flutter/material.dart';
// import 'package:pokakbilling/core/themes/app_assets.dart';
// import 'package:pokakbilling/models/data-models/setup/category_model.dart';
// import 'package:pokakbilling/viewmodels/setup/bankaccount_viewmodel.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';
// import 'package:pokakbilling/views/commonWidgets/buttons/exit_custom_button.dart';
// import 'package:pokakbilling/views/commonWidgets/buttons/colored_custom_button.dart';
// import 'package:pokakbilling/views/commonWidgets/buttons/cancel_custom_button.dart';
// import 'package:provider/provider.dart';

// class CreateAccount extends StatefulWidget {
//   final bool isEdit;
//   final CategoryModel? category;
//   const CreateAccount({super.key, required this.isEdit, this.category});

//   @override
//   State<CreateAccount> createState() => _CreateAccountState();
// }

// class _CreateAccountState extends State<CreateAccount> {
//   late TextEditingController banknameController;
//   late TextEditingController holdernameController;
//   late TextEditingController accountNumberController;
//   late TextEditingController ifscCodeController;
//   var loading = false;

//   @override
//   void initState() {
//     super.initState();
//     banknameController =
//         TextEditingController(text: widget.category?.categoryName ?? '');
//     holdernameController =
//         TextEditingController(text: widget.category?.categoryDescription ?? '');
//     accountNumberController =
//         TextEditingController(text: widget.category?.categoryName ?? '');
//     ifscCodeController =
//         TextEditingController(text: widget.category?.categoryDescription ?? '');
//   }

//   @override
//   void dispose() {
//     banknameController.dispose();
//     holdernameController.dispose();
//     accountNumberController.dispose();
//     ifscCodeController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final formKey = GlobalKey<FormState>();

//     return Scaffold(
//       backgroundColor: AppColors.white,
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               Container(
//                 height: 150,
//                 decoration: const BoxDecoration(
//                   color: AppColors.violetblue,
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 10,
//                   ),
//                   child: AppBar(
//                     leading: IconButton(
//                       icon: Image.asset(AppAssets.homeIcon),
//                       onPressed: () {
//                         Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (context) => const BottomBar(index: 0),
//                           ),
//                         );
//                       },
//                     ),
//                     title: Text(
//                       widget.isEdit
//                           ? 'Edit Bank Account'
//                           : 'Create Bank Account',
//                       style: const TextStyle(
//                         color: AppColors.white,
//                         fontWeight: FontWeight.w500,
//                         fontSize: 18,
//                       ),
//                     ),
//                     backgroundColor: Colors.transparent,
//                     elevation: 0,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           Positioned(
//             top: 120,
//             left: 20,
//             right: 20,
//             bottom: 20,
//             child: Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     Card(
//                       color: AppColors.white,
//                       elevation: 4,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Form(
//                         key: formKey,
//                         child: Padding(
//                           padding: const EdgeInsets.all(20),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               TextFormField(
//                                 controller: banknameController,
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) {
//                                     return 'required';
//                                   }
//                                   return null;
//                                 },
//                                 decoration: const InputDecoration(
//                                   labelText: 'Bank Name',
//                                   hintText: "",
//                                   labelStyle: TextStyle(
//                                     color: AppColors.violetblue,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(height: 15),
//                               TextFormField(
//                                 controller: holdernameController,
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) {
//                                     return 'required';
//                                   }
//                                   return null;
//                                 },
//                                 decoration: const InputDecoration(
//                                   labelText: 'Account Holder Name',
//                                   hintText: "",
//                                   labelStyle: TextStyle(
//                                     color: AppColors.violetblue,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(height: 15),
//                               TextFormField(
//                                 controller: accountNumberController,
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) {
//                                     return 'required';
//                                   }
//                                   return null;
//                                 },
//                                 decoration: const InputDecoration(
//                                   labelText: 'Account Number',
//                                   hintText: "",
//                                   labelStyle: TextStyle(
//                                     color: AppColors.violetblue,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(height: 15),
//                               TextFormField(
//                                 controller: ifscCodeController,
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) {
//                                     return 'required';
//                                   }
//                                   return null;
//                                 },
//                                 decoration: const InputDecoration(
//                                   labelText: 'IFSC Code',
//                                   hintText: "",
//                                   labelStyle: TextStyle(
//                                     color: AppColors.violetblue,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 60),
//                     Consumer<BankaccountViewmodel>(
//                         builder: (context, provider, child) {
//                       return ColoredCustomButton(
//                         text: widget.isEdit ? "Edit" : "Save",
//                         onPressed: () async {
//                           provider.createBankAccount(
//                             banknameController.text,
//                             holdernameController.text,
//                             accountNumberController.text,
//                             ifscCodeController.text,
//                             context,
//                           );
//                         },
//                         loading: provider.createLoading,
//                         formKey: formKey,
//                       );
//                     }),
//                     const SizedBox(height: 20),
//                     const ExitCustomButton(
//                       text: "Exit",
//                     ),
//                     const SizedBox(height: 20),
//                     const CancelCustomButton(
//                       text: "Back",
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
