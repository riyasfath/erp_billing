// import 'package:flutter/material.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/views/Screens/payments/add_payment.dart';
// import 'package:pokakbilling/views/Screens/payments/single_payment_card.dart';
// import 'package:pokakbilling/views/commonWidgets/buttons/colored_custom_button.dart';
// import 'package:pokakbilling/views/commonWidgets/buttons/main_page_custom_button.dart';
// import 'package:pokakbilling/views/commonWidgets/textfields/custom_text.dart';

// class PaymentMain extends StatelessWidget {
//   const PaymentMain({super.key});

//   @override
//   Widget build(BuildContext context) {
//     late TextEditingController fromTextController =
//         TextEditingController(text: "From");
//     late TextEditingController toTextController =
//         TextEditingController(text: "To");
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final formKey = GlobalKey<FormState>();
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
//                       icon: const Icon(
//                         Icons.arrow_back,
//                         color: AppColors.white,
//                       ),
//                       onPressed: () {
//                         Navigator.pop(context);
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
//                     actions: [
//                       MainPageCustomButton(
//                         text: "New Payment",
//                         onPressed: () {
//                           Navigator.of(context).push(
//                             MaterialPageRoute(
//                               builder: (context) => const AddPayment(),
//                             ),
//                           );
//                         },
//                       )
//                     ],
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
//               child: Column(
//                 children: [
//                   _buildSearchCard(
//                     context,
//                     fromTextController,
//                     toTextController,
//                   ),
//                   Expanded(
//                     child: ListView.separated(
//                       padding: const EdgeInsets.only(
//                         top: 20,
//                       ),
//                       itemBuilder: (context, index) {
//                         return const SinglePaymentCard();
//                       },
//                       separatorBuilder: (context, index) => const SizedBox(
//                         height: 20,
//                       ),
//                       itemCount: 5,
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 15,
//                   ),
//                   ColoredCustomButton(
//                     text: "Confirm",
//                     onPressed: () {},
//                     loading: false,
//                     formKey: formKey,
//                   ),
//                 ],
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchCard(
//     BuildContext context,
//     fromTextController,
//     toTextController,
//   ) {
//     return Container(
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: AppColors.lightGrey,
//         borderRadius: BorderRadius.circular(8.0),
//         boxShadow: const [
//           BoxShadow(
//             color: Colors.grey,
//             blurRadius: 4,
//             offset: Offset(2, 8),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const CustomText(
//             text: "Search",
//             isMandatory: true,
//           ),
//           const SizedBox(height: 8),
//           TextField(
//             controller: fromTextController,
//             decoration: InputDecoration(
//               contentPadding:
//                   const EdgeInsets.symmetric(vertical: 2.0, horizontal: 1.0),
//               suffixIcon: IconButton(
//                 icon: const Icon(
//                   Icons.calendar_month,
//                   color: AppColors.grey,
//                 ),
//                 onPressed: () => _selectDate(context, fromTextController),
//               ),
//             ),
//           ),
//           const SizedBox(height: 8),
//           TextField(
//             controller: toTextController,
//             decoration: InputDecoration(
//               contentPadding:
//                   const EdgeInsets.symmetric(vertical: 2.0, horizontal: 1.0),
//               suffixIcon: IconButton(
//                 icon: const Icon(
//                   Icons.calendar_month,
//                   color: AppColors.grey,
//                 ),
//                 onPressed: () => _selectDate(context, toTextController),
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           const Text(
//             "Select Supplier",
//             style: TextStyle(
//               color: AppColors.violetblue,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           DropdownButtonFormField<String>(
//             items:
//                 ["Customer 1", "Customer 2", "Customer 3"].map((String value) {
//               return DropdownMenuItem<String>(
//                 value: value,
//                 child: Text(value),
//               );
//             }).toList(),
//             onChanged: (value) {},
//             decoration: const InputDecoration(
//               filled: true,
//               fillColor: AppColors.lightGrey,
//               contentPadding: EdgeInsets.symmetric(horizontal: 12),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _selectDate(BuildContext context, fromTextController) async {
//     DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );

//     if (pickedDate != null) {
//       fromTextController.text =
//           "${pickedDate.toLocal()}".split(' ')[0]; // Format date
//     }
//   }
// }
