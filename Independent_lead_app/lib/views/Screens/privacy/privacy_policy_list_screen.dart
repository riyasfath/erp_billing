// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:pokakbilling/viewmodels/privacy_policy/privacy_policy_viewmodel.dart';
// import 'package:provider/provider.dart';

// import 'package:pokakbilling/core/themes/app_colors.dart';

// class PrivacyPolicyListScreen extends StatelessWidget {
//   const PrivacyPolicyListScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => PrivacyPolicyViewmodel()..fetchTerms(),
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: AppColors.violetblue,
//           elevation: 0,
//           leading: IconButton(
//             icon: const Icon(CupertinoIcons.arrow_left, color: AppColors.white),
//             onPressed: () => Navigator.pop(context),
//           ),
//           centerTitle: false,
//           titleSpacing: 0,
//           title: const Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(Icons.privacy_tip_outlined,
//                   color: AppColors.white, size: 18),
//               SizedBox(width: 6),
//               Text(
//                 'Privacy Policy',
//                 style: TextStyle(
//                   color: AppColors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         backgroundColor: AppColors.lightGrey,
//         body: Consumer<PrivacyPolicyViewmodel>(
//           builder: (context, vm, child) {
//             if (vm.isLoading) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             if (vm.errorMessage != null) {
//               return Center(child: Text('Error: ${vm.errorMessage}'));
//             }
//             if (vm.terms.isEmpty) {
//               return const Center(child: Text('No policies available'));
//             }
//             return ListView.builder(
//               padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
//               itemCount: vm.terms.length,
//               itemBuilder: (context, index) {
//                 final item = vm.terms[index];
//                 return _PolicyCard(
//                   title: item.title,
//                   subtitle: item.createdAt != null
//                       ? 'Created: ${_formatDate(item.createdAt!)}'
//                       : null,
//                   onTap: () {
//                     // TODO: push a detail screen if needed (terms-points).
//                   },
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }

//   static String _formatDate(DateTime dt) {
//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec'
//     ];
//     final d = dt.day.toString().padLeft(2, '0');
//     final m = months[dt.month - 1];
//     final y = dt.year;
//     return '$d-$m-$y';
//   }
// }

// class _PolicyCard extends StatelessWidget {
//   final String title;
//   final String? subtitle;
//   final VoidCallback? onTap;

//   const _PolicyCard({
//     required this.title,
//     this.subtitle,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     const double rightAreaWidth = 44.0;
//     const double cardHeight = 64.0;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: Align(
//         alignment: Alignment.center,
//         child: SizedBox(
//           width: MediaQuery.of(context).size.width * 0.9,
//           height: cardHeight,
//           child: Stack(
//             children: [
//               Positioned(
//                 top: 0,
//                 left: 8,
//                 right: 8,
//                 child: Container(height: 1.0, color: AppColors.violetblue),
//               ),
//               LayoutBuilder(
//                 builder: (context, constraints) {
//                   final leftWidth = (constraints.maxWidth - rightAreaWidth)
//                       .clamp(0.0, constraints.maxWidth);

//                   return Row(
//                     children: [
//                       InkWell(
//                         onTap: onTap,
//                         child: SizedBox(
//                           width: leftWidth,
//                           height: cardHeight,
//                           child: ClipRRect(
//                             borderRadius: const BorderRadius.only(
//                               topLeft: Radius.circular(8),
//                               bottomLeft: Radius.circular(8),
//                               topRight: Radius.circular(44),
//                             ),
//                             child: Container(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 12),
//                               decoration: const BoxDecoration(
//                                 gradient: LinearGradient(
//                                   colors: [
//                                     AppColors.violetblue,
//                                     AppColors.primaryColor
//                                   ],
//                                   begin: Alignment.centerLeft,
//                                   end: Alignment.centerRight,
//                                 ),
//                               ),
//                               child: Row(
//                                 children: [
//                                   const Icon(Icons.description_outlined,
//                                       color: AppColors.white, size: 20),
//                                   const SizedBox(width: 12),
//                                   Expanded(
//                                     child: Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           title,
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                           style: const TextStyle(
//                                             color: AppColors.white,
//                                             fontSize: 15,
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                         if (subtitle != null) ...[
//                                           const SizedBox(height: 2),
//                                           Text(
//                                             subtitle!,
//                                             maxLines: 1,
//                                             overflow: TextOverflow.ellipsis,
//                                             style: const TextStyle(
//                                               color: AppColors.white,
//                                               fontSize: 11.5,
//                                               fontWeight: FontWeight.w400,
//                                             ),
//                                           ),
//                                         ],
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Container(
//                         width: rightAreaWidth,
//                         height: cardHeight,
//                         decoration: const BoxDecoration(
//                           color: AppColors.transparent,
//                           border: Border(
//                             top: BorderSide(
//                                 color: AppColors.violetblue, width: 1.0),
//                             right: BorderSide(color: AppColors.violetblue),
//                             bottom: BorderSide(color: AppColors.violetblue),
//                           ),
//                           borderRadius: BorderRadius.only(
//                             topRight: Radius.circular(8),
//                             bottomRight: Radius.circular(8),
//                           ),
//                         ),
//                         child: const Center(
//                           child: Icon(Icons.chevron_right,
//                               size: 22, color: AppColors.hintTextGrey),
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
