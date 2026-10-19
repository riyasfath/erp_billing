// import 'package:flutter/material.dart';
// import 'package:pokakbilling/viewmodels/project_management/project_viewmodel.dart';
// import 'package:pokakbilling/views/commonWidgets/buttons/exit_custom_button.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/views/commonWidgets/view_widget/view_buildfield.dart';
// import 'package:provider/provider.dart';

// class ProjectDetailsScreen extends StatelessWidget {
//   const ProjectDetailsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final projectProvider = Provider.of<ProjectViewmodel>(context);
//     var project = projectProvider.singleProjectList[0];
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       resizeToAvoidBottomInset: true,
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
//                       'Project Details',
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
//             bottom: screenHeight * 0.04,
//             child: Container(
//               height: screenHeight - screenHeight * 0.18,
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
//                       child: Padding(
//                         padding: EdgeInsets.all(screenWidth * 0.03),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Expanded(
//                                   child: ViewBuildfield(
//                                     label: "Start Date",
//                                     value: project.startDate,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 2),
//                                 Expanded(
//                                   child: ViewBuildfield(
//                                     label: "End Date",
//                                     value: project.endDate,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: screenHeight * 0.01),
//                             ViewBuildfield(
//                               label: "Client Name",
//                               value:
//                                   "${project.clientFirstName} ${project.clientLastName}",
//                             ),
//                             SizedBox(height: screenHeight * 0.01),
//                             ViewBuildfield(
//                               label: "Contract Duration",
//                               value: project.duration,
//                             ),
//                             SizedBox(height: screenHeight * 0.01),
//                             ViewBuildfield(
//                               label: "Project Name",
//                               value: project.projectName,
//                             ),
//                             SizedBox(height: screenHeight * 0.01),
//                             ViewBuildfield(
//                               label: "Description",
//                               value: project.projectDescription,
//                             ),
//                             SizedBox(height: screenHeight * 0.01),
//                             ViewBuildfield(
//                               label: "Status",
//                               value: project.displayStatus,
//                             ),
//                             SizedBox(height: screenHeight * 0.02),
//                           ],
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: screenHeight * 0.02),
//                     Card(
//                       color: AppColors.white,
//                       elevation: 4,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Padding(
//                         padding: EdgeInsets.all(screenWidth * 0.03),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'Current Project Teammembers',
//                               style: TextStyle(
//                                 color: AppColors.violetblue,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             SizedBox(height: screenHeight * 0.02),
//                             Column(
//                               children: List.generate(
//                                   project.projectMembers!.length, (index) {
//                                 final member = project.projectMembers![index];
//                                 return Column(
//                                   children: [
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text(
//                                           member.memberName,
//                                           style: const TextStyle(
//                                             fontSize: 15.5,
//                                             fontWeight: FontWeight.w400,
//                                           ),
//                                         ),
//                                         Text(
//                                           member.stackName,
//                                           style: const TextStyle(
//                                             fontSize: 15.5,
//                                             fontWeight: FontWeight.w400,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     const Divider(
//                                       color: AppColors.grey,
//                                       thickness: 1.0,
//                                     ),
//                                     const SizedBox(height: 7),
//                                   ],
//                                 );
//                               }),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       height: screenHeight * 0.02,
//                     ),
//                     const ExitCustomButton(text: "Exit")
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
