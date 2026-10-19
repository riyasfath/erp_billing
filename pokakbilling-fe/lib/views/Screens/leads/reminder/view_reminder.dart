// import 'package:flutter/material.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/models/data-models/meeting_model.dart';
// import 'package:pokakbilling/views/Screens/delivery/delivery_pdf.dart';
// import 'package:pokakbilling/views/commonWidgets/buttons/pdf_custom_button.dart';
// import 'package:pokakbilling/views/commonWidgets/buttons/print_custom_button.dart';
// import 'package:pokakbilling/views/commonWidgets/view_widget/view_buildfield.dart';
// import 'package:pokakbilling/views/commonWidgets/view_widget/view_namecontainer.dart';

// class ViewReminder extends StatelessWidget {
//   final MeetingModel reminder;
//   const ViewReminder({super.key, required this.reminder});

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       backgroundColor: AppColors.white,
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
//                       'Reminder View',
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
//                 physics: const BouncingScrollPhysics(),
//                 child: Column(
//                   children: [
//                     ViewNamecontainer(
//                       screenHeight: screenHeight,
//                       screenWidth: screenWidth,
//                       id: reminder.leadId,
//                       name: reminder.leadName,
//                     ),
//                     SizedBox(
//                       height: screenHeight * 0.03,
//                     ),
//                     Container(
//                       margin: const EdgeInsets.symmetric(horizontal: 4.0),
//                       padding: const EdgeInsets.all(16.0),
//                       decoration: BoxDecoration(
//                         color: AppColors.white,
//                         borderRadius: BorderRadius.circular(8.0),
//                         boxShadow: const [
//                           BoxShadow(
//                             color: AppColors.grey,
//                             blurRadius: 1,
//                             spreadRadius: 1,
//                             offset: Offset(0, 0),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         children: [
//                           ViewBuildfield(
//                               label: "Subject", value: reminder.subject),
//                           ViewBuildfield(label: "Date", value: reminder.date),
//                           ViewBuildfield(label: "Time", value: reminder.time),
//                           ViewBuildfield(
//                               label: "Status", value: reminder.status),
//                           ViewBuildfield(label: "Phone", value: reminder.phone),
//                         ],
//                       ),
//                     ),
//                     SizedBox(
//                       height: screenHeight * 0.03,
//                     ),
//                     PdfCustomButton(
//                       text: "PDF File",
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const DeliveryPDF(),
//                           ),
//                         );
//                       },
//                     ),
//                     SizedBox(
//                       height: screenHeight * 0.03,
//                     ),
//                     const PrintCustomButton(
//                       text: "Print",
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
