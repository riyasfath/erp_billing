// import 'package:flutter/material.dart';
// import 'package:pokakbilling/core/themes/app_assets.dart';
// import 'package:pokakbilling/viewmodels/invoice_viewmodel.dart';
// import 'package:pokakbilling/views/commonWidgets/buttons/colored_custom_button.dart';
// import 'package:pokakbilling/views/commonWidgets/buttons/exit_custom_button.dart';
// import 'package:pokakbilling/views/commonWidgets/textfields/custom_text.dart';
// import 'package:pokakbilling/views/commonWidgets/textfields/custom_textfield.dart';
// import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:provider/provider.dart';

// class AddPayment extends StatefulWidget {
//   const AddPayment({super.key});

//   @override
//   State<AddPayment> createState() => _AddPaymentState();
// }

// class _AddPaymentState extends State<AddPayment> {
//   late TextEditingController invoiceNumberTextController =
//       TextEditingController();
//   late TextEditingController invoiceDateTextController =
//       TextEditingController();
//   late TextEditingController customerNameTextController =
//       TextEditingController();
//   late TextEditingController salesOrderNumberTextController =
//       TextEditingController();
//   late TextEditingController deliveryNumberTextController =
//       TextEditingController();
//   final formKey = GlobalKey<FormState>();

//   @override
//   void dispose() {
//     invoiceNumberTextController.dispose();
//     invoiceDateTextController.dispose();
//     customerNameTextController.dispose();
//     salesOrderNumberTextController.dispose();
//     deliveryNumberTextController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               Container(
//                 height: screenHeight * 0.18,
//                 decoration: const BoxDecoration(
//                   color: AppColors.violetblue,
//                 ),
//                 child: Padding(
//                   padding: EdgeInsets.only(
//                     left: screenWidth * 0.02,
//                     right: screenWidth * 0.03,
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
//                       'Payment',
//                       style: TextStyle(
//                         color: AppColors.white,
//                         fontWeight: FontWeight.w500,
//                         fontSize: screenWidth * 0.05,
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
//             top: screenHeight * 0.15,
//             left: screenWidth * 0.04,
//             right: screenWidth * 0.04,
//             child: Container(
//               height: screenHeight - screenHeight * 0.18,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: SingleChildScrollView(
//                 child: Form(
//                   key: formKey,
//                   child: Column(
//                     children: [
//                       Card(
//                         elevation: 4,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Padding(
//                           padding: EdgeInsets.all(screenWidth * 0.03),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: CustomTextfield(
//                                       label: "Invoice Number",
//                                       hintText: "INV-00001",
//                                       screenWidth: screenWidth * 0.045,
//                                       textController:
//                                           invoiceNumberTextController,
//                                       isMandatory: false,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 2),
//                                   Expanded(
//                                     child: TextField(
//                                       controller: invoiceDateTextController,
//                                       decoration: InputDecoration(
//                                         label: const CustomText(
//                                           text: "Payment Date",
//                                           isMandatory: false,
//                                         ),
//                                         contentPadding:
//                                             const EdgeInsets.symmetric(
//                                                 vertical: 2.0, horizontal: 1.0),
//                                         suffixIcon: IconButton(
//                                           icon: const Icon(
//                                             Icons.calendar_month,
//                                             color: AppColors.grey,
//                                           ),
//                                           onPressed: () => _selectDate(
//                                             context,
//                                             invoiceDateTextController,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: screenHeight * 0.02),
//                               CustomTextfield(
//                                 label: "Supplier",
//                                 hintText: "INV-00001",
//                                 screenWidth: screenWidth * 0.045,
//                                 textController: customerNameTextController,
//                                 isMandatory: false,
//                                 suffixIcon: IconButton(
//                                     onPressed: () {},
//                                     icon: const Icon(
//                                       Icons.arrow_drop_down,
//                                       color: AppColors.grey,
//                                     )),
//                               ),
//                               SizedBox(height: screenHeight * 0.02),
//                               CustomTextfield(
//                                 label: "Address",
//                                 hintText: "00000000",
//                                 screenWidth: screenWidth * 0.045,
//                                 textController: salesOrderNumberTextController,
//                                 isMandatory: false,
//                               ),
//                               SizedBox(height: screenHeight * 0.02),
//                               CustomTextfield(
//                                 label: "Received Amount",
//                                 hintText: "00000000",
//                                 screenWidth: screenWidth * 0.045,
//                                 textController: deliveryNumberTextController,
//                                 isMandatory: false,
//                               ),
//                               SizedBox(height: screenHeight * 0.02),
//                               CustomTextfield(
//                                 label: "Invoice#",
//                                 hintText: "00000000",
//                                 screenWidth: screenWidth * 0.045,
//                                 textController: deliveryNumberTextController,
//                                 isMandatory: false,
//                                 suffixIcon: IconButton(
//                                     onPressed: () {},
//                                     icon: const Icon(Icons.add)),
//                               ),
//                               SizedBox(height: screenHeight * 0.02),
//                               CustomTextfield(
//                                 label: "Total Amount",
//                                 hintText: "00000000",
//                                 screenWidth: screenWidth * 0.045,
//                                 textController: deliveryNumberTextController,
//                                 isMandatory: false,
//                               ),
//                               SizedBox(height: screenHeight * 0.02),
//                             ],
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: screenHeight * 0.02),
//                       SizedBox(height: screenHeight * 0.02),
//                       Card(
//                         elevation: 4,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Padding(
//                           padding: EdgeInsets.all(screenWidth * 0.03),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               CustomTextfield(
//                                 label: "Terms",
//                                 hintText: "Due on Receipt",
//                                 screenWidth: screenWidth * 0.045,
//                                 textController: customerNameTextController,
//                                 isMandatory: true,
//                               ),
//                               SizedBox(height: screenHeight * 0.02),
//                               TextField(
//                                 controller: invoiceDateTextController,
//                                 decoration: InputDecoration(
//                                   label: const CustomText(
//                                     text: "Due Date",
//                                     isMandatory: false,
//                                   ),
//                                   contentPadding: const EdgeInsets.symmetric(
//                                       vertical: 2.0, horizontal: 1.0),
//                                   suffixIcon: IconButton(
//                                     icon: const Icon(
//                                       Icons.calendar_month,
//                                       color: AppColors.grey,
//                                     ),
//                                     onPressed: () => _selectDate(
//                                       context,
//                                       invoiceDateTextController,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: screenHeight * 0.02),
//                       Consumer<InvoiceViewmodel>(
//                         builder: (context, notifier, child) {
//                           return ColoredCustomButton(
//                             text: "Save",
//                             onPressed: () {},
//                             loading: notifier.addInvoiceLoader,
//                             formKey: formKey,
//                           );
//                         },
//                       ),
//                       SizedBox(
//                         height: screenHeight * 0.02,
//                       ),
//                       const ExitCustomButton(text: "Exit")
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _selectDate(BuildContext context, dateTextController) async {
//     DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );

//     if (pickedDate != null) {
//       dateTextController.text =
//           "${pickedDate.toLocal()}".split(' ')[0]; // Format date
//     }
//   }
// }
