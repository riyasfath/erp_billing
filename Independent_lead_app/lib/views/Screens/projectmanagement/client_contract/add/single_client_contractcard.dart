// import 'package:flutter/material.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/viewmodels/project_management/client_contract_viewmodel.dart';
// import 'package:pokakbilling/views/Screens/projectmanagement/client_contract/add/create_client_contract.dart';
// import 'package:pokakbilling/views/Screens/projectmanagement/client_contract/view/view_clientcontract.dart';
// import 'package:pokakbilling/views/commonWidgets/buttons/action_button.dart';
// import 'package:pokakbilling/views/commonWidgets/popups/delete_popup.dart';
// import 'package:provider/provider.dart';

// class SingleContractCard extends StatelessWidget {
//   final int index;
//   const SingleContractCard({super.key, required this.index});

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final clientContractProvider =
//         Provider.of<ClientContractViewmodel>(context);
//     var clientContract = clientContractProvider.contractList[index];

//     return Container(
//       height: screenHeight * 0.24,
//       width: screenWidth * screenWidth,
//       decoration: BoxDecoration(
//         color: AppColors.lightGrey,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: const [
//           BoxShadow(
//             color: Colors.grey,
//             blurRadius: 4,
//             offset: Offset(2, 8),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.only(
//           top: 15.0,
//           left: 10.0,
//           right: 12.0,
//           bottom: 15.0,
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text("Contract Date"),
//                       const SizedBox(height: 4),
//                       Text(clientContract.contractDate),
//                     ],
//                   ),
//                 ),
//                 Text(clientContract.client.toString()),
//               ],
//             ),
//             const SizedBox(
//               height: 10,
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text("Start Date"),
//                     const SizedBox(height: 4),
//                     Text(clientContract.startDate)
//                   ],
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text("End Date"),
//                     const SizedBox(height: 4),
//                     Text(clientContract.endDate)
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(
//               height: 10,
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   clientContract.contractName,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w500,
//                     fontSize: 14,
//                   ),
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     ActionButton(
//                       text: "VIEW",
//                       loading: false,
//                       onPressed: () async {
//                         await clientContractProvider
//                             .getClientContractById(clientContract.contractId);
//                         if (clientContractProvider.singleContractLoading) {
//                           const CircularProgressIndicator();
//                         } else {
//                           if (!context.mounted) return;
//                           Navigator.of(context).push(
//                             MaterialPageRoute(
//                               builder: (context) => ViewClientContract(
//                                 contract: clientContract,
//                               ),
//                             ),
//                           );
//                         }
//                       },
//                       isColored: true,
//                     ),
//                     SizedBox(
//                       width: screenWidth * 0.03,
//                     ),
//                     ActionButton(
//                       text: "DELETE",
//                       loading: false,
//                       onPressed: () async {
//                         showDeleteDialog(
//                           context,
//                           "Client Contract",
//                           () => clientContractProvider.deleteClientContract(
//                             clientContract.contractId,
//                             context,
//                           ),
//                         );
//                       },
//                       isColored: false,
//                     ),
//                     SizedBox(
//                       width: screenWidth * 0.03,
//                     ),
//                     ActionButton(
//                       text: "EDIT",
//                       loading: false,
//                       isColored: false,
//                       onPressed: () async {
//                         await clientContractProvider
//                             .getClientContractById(clientContract.contractId);
//                         if (clientContractProvider.singleContractLoading) {
//                           const CircularProgressIndicator();
//                         } else {
//                           if (!context.mounted) return;
//                           Navigator.of(context).push(
//                             MaterialPageRoute(
//                               builder: (context) => CreateClientContract(
//                                 contract: clientContract,
//                                 isEdit: true,
//                               ),
//                             ),
//                           );
//                         }
//                       },
//                     ),
//                   ],
//                 )
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget getButtons(
//     text,
//     loading,
//     final VoidCallback onPressed,
//     isColored,
//   ) {
//     return GestureDetector(
//       onTap: loading
//           ? null
//           : () {
//               onPressed();
//             },
//       child: Container(
//         height: 30,
//         width: 60,
//         decoration: BoxDecoration(
//           color: isColored ? AppColors.violetblue : AppColors.white,
//           borderRadius: BorderRadius.circular(10),
//           border: isColored
//               ? null
//               : Border.all(
//                   color: AppColors.grey,
//                 ),
//         ),
//         child: Center(
//           child: loading
//               ? const SizedBox(
//                   height: 8,
//                   width: 8,
//                   child: CircularProgressIndicator(
//                     color: Colors.white,
//                     strokeWidth: 2,
//                   ),
//                 )
//               : Text(
//                   text,
//                   style: TextStyle(
//                     color: isColored ? AppColors.white : AppColors.grey,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 12,
//                   ),
//                 ),
//         ),
//       ),
//     );
//   }
// }
