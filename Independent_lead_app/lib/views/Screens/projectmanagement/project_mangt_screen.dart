// import 'package:flutter/material.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/core/themes/app_assets.dart';
// import 'package:pokakbilling/core/navigations.dart';
// import 'package:pokakbilling/views/Screens/projectmanagement/client_contract/client_contract_main.dart';
// import 'package:pokakbilling/views/Screens/projectmanagement/team_members/create_TM_Main.dart';
// import 'package:pokakbilling/views/Screens/projectmanagement/project/create_project.dart';
// import 'package:pokakbilling/views/Screens/projectmanagement/project/project_main.dart';
// import 'package:pokakbilling/views/Screens/projectmanagement/stack/stack_main.dart';
// import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';

// class ProjectManagemnetScreen extends StatefulWidget {
//   const ProjectManagemnetScreen({super.key});

//   @override
//   State<ProjectManagemnetScreen> createState() =>
//       _ProjectManagemnetScreenState();
// }

// class _ProjectManagemnetScreenState extends State<ProjectManagemnetScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final double height = MediaQuery.of(context).size.height;
//     final double width = MediaQuery.of(context).size.width;
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.violetblue,
//         title: const Text(
//           'Project Management',
//           style: TextStyle(
//             color: AppColors.white,
//             fontSize: 17,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         leading: IconButton(
//           icon: Image.asset(AppAssets.homeIcon),
//           onPressed: () {
//             pushNavigation(context, const BottomBar(index: 0));
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
//                 _setUpTile('Projects', () {
//                   pushNavigation(context, const ProjectMain());
//                 }),
//                 _setUpTile('Create Project', () {
//                   pushNavigation(context, const CreateProject());
//                 }),
//                 _setUpTile('Team Members', () {
//                   pushNavigation(context, const CreateTeamMemberMain());
//                 }),
//                 _setUpTile('Stack', () {
//                   pushNavigation(context, const StackMain());
//                 }),
//                 _setUpTile('Client Contract', () {
//                   pushNavigation(context, const ClientContractMain());
//                 }),
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
