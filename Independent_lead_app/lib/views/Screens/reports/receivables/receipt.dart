// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:pokakbilling/core/themes/app_assets.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/views/Screens/delivery/delivery_pdf.dart';
// import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';
// import 'package:pokakbilling/views/commonWidgets/buttons/cancel_custom_button.dart';
// import 'package:pokakbilling/views/commonWidgets/buttons/colored_custom_button.dart';
// import 'package:pokakbilling/views/commonWidgets/buttons/pdf_custom_button.dart';

// class Receipt extends StatefulWidget {
//   const Receipt({super.key});

//   @override
//   State<Receipt> createState() => _ReceiptPageState();
// }

// class _ReceiptPageState extends State<Receipt> {
//   late TextEditingController customerNameController = TextEditingController();
//   final formKey = GlobalKey<FormState>();
//   var containerHeight = 55;
//   var spacing = 20;
//   var totalItems = 15;

//   @override
//   void dispose() {
//     customerNameController.dispose();
//     super.dispose();
//   }

//   DateTime? fromDate;
//   DateTime? toDate;
//   String? selectedDateRange;
//   final List<String> dateRanges = [
//     'Today',
//     'This Week',
//     'This Month',
//     'This Quarter',
//     'This Year',
//     'Yesterday',
//   ];

//   Future<void> _selectDate(BuildContext context, bool isFromDate) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null && picked != (isFromDate ? fromDate : toDate)) {
//       setState(() {
//         if (isFromDate) {
//           fromDate = picked;
//         } else {
//           toDate = picked;
//         }
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.violetblue,
//         title: const Text(
//           'Receipt',
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
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Form(
//                 key: formKey,
//                 child: TextFormField(
//                   controller: customerNameController,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'required';
//                     }
//                     return null;
//                   },
//                   decoration: const InputDecoration(
//                     hintText: "Receipt",
//                     hintStyle: TextStyle(
//                       color: AppColors.violetblue,
//                     ),
//                     suffixIcon: Icon(Icons.arrow_drop_down),
//                     labelStyle: TextStyle(
//                       color: AppColors.violetblue,
//                       fontSize: 15,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               GestureDetector(
//                 onTap: () => _selectDate(context, true),
//                 child: AbsorbPointer(
//                   child: TextFormField(
//                     decoration: InputDecoration(
//                       hintText: fromDate != null
//                           ? DateFormat('dd/MM/yyyy').format(fromDate!)
//                           : 'From',
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               GestureDetector(
//                 onTap: () => _selectDate(context, false),
//                 child: AbsorbPointer(
//                   child: TextFormField(
//                     decoration: InputDecoration(
//                       hintText: toDate != null
//                           ? DateFormat('dd/MM/yyyy').format(toDate!)
//                           : 'To',
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.violetblue,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(5),
//                   ),
//                 ),
//                 onPressed: () {
//                   // Handle run report action
//                 },
//                 child: const Text(
//                   'Generate Report',
//                   style: TextStyle(color: AppColors.white),
//                 ),
//               ),
//               SizedBox(
//                 height: (containerHeight * totalItems) +
//                     (spacing * totalItems - 1 + 10),
//                 child: ListView.separated(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   padding: const EdgeInsets.only(
//                     top: 20,
//                   ),
//                   itemBuilder: (context, index) {
//                     return Container(
//                       height: containerHeight.toDouble(),
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         color: AppColors.lightGrey,
//                         borderRadius: BorderRadius.circular(15),
//                         boxShadow: const [
//                           BoxShadow(
//                             color: Colors.grey,
//                             blurRadius: 4,
//                             offset: Offset(4, 4),
//                           ),
//                         ],
//                       ),
//                       child: const Padding(
//                         padding: EdgeInsets.only(
//                           left: 10.0,
//                           right: 10.0,
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Text("Alan Jhan"),
//                             Text("00/00/0000"),
//                             Text("#000001"),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                   separatorBuilder: (context, index) => SizedBox(
//                     height: spacing.toDouble(),
//                   ),
//                   itemCount: totalItems,
//                 ),
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               ColoredCustomButton(
//                 text: "View",
//                 onPressed: () {},
//                 loading: false,
//                 formKey: formKey,
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               PdfCustomButton(
//                 text: "Print",
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const DeliveryPDF(),
//                     ),
//                   );
//                 },
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               const CancelCustomButton(
//                 text: "Back",
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
