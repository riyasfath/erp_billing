// import 'package:flutter/material.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/views/commonWidgets/buttons/colored_custom_button.dart';
// import 'package:pokakbilling/views/commonWidgets/buttons/exit_custom_button.dart';
// import 'package:pokakbilling/views/commonWidgets/textfields/custom_dropdown.dart';
// import 'package:pokakbilling/views/commonWidgets/textfields/custom_text.dart';
// import 'package:pokakbilling/views/commonWidgets/textfields/custom_textfield.dart';
// import 'package:pokakbilling/viewmodels/project_management/client_contract_viewmodel.dart';
// import 'package:pokakbilling/viewmodels/customer_viewmodel.dart';
// import 'package:provider/provider.dart';

// class EditClientContract extends StatefulWidget {
//   const EditClientContract({super.key});
//   @override
//   State<EditClientContract> createState() => _EditClientContractState();
// }

// class _EditClientContractState extends State<EditClientContract> {
//   late TextEditingController contractDateTextController =
//       TextEditingController();
//   late TextEditingController clientNameTextController = TextEditingController();
//   late TextEditingController startDateTextController = TextEditingController();
//   late TextEditingController endDateTextController = TextEditingController();
//   late TextEditingController produrationTextController =
//       TextEditingController();
//   late TextEditingController proNameTextController = TextEditingController();
//   late TextEditingController prodescriptionTextController =
//       TextEditingController();
//   final formKey = GlobalKey<FormState>();

//   @override
//   void dispose() {
//     contractDateTextController.dispose();
//     startDateTextController.dispose();
//     endDateTextController.dispose();
//     clientNameTextController.dispose();
//     produrationTextController.dispose();
//     proNameTextController.dispose();
//     prodescriptionTextController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final clientContractProvider =
//         Provider.of<ClientContractViewmodel>(context);

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
//                       'Edit Contract',
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
//                               TextField(
//                                 controller: contractDateTextController,
//                                 decoration: InputDecoration(
//                                   label: const CustomText(
//                                     text: "Contract Date",
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
//                                       contractDateTextController,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: screenHeight * 0.02),
//                               Consumer<CustomerViewmodel>(
//                                 builder: (context, provider, child) {
//                                   return CustomDropdown(
//                                     selectedValue: provider.customerList.any(
//                                             (c) =>
//                                                 c.firstName ==
//                                                 clientNameTextController.text)
//                                         ? clientNameTextController.text
//                                         : null,
//                                     hint: "Client Name",
//                                     dropdownItems: provider.customerList
//                                         .map((c) => c.firstName)
//                                         .toSet()
//                                         .toList(),
//                                     onChanged: (String? newValue) async {
//                                       if (newValue != null) {
//                                         String selectedName =
//                                             newValue.split(" (")[0];
//                                         clientNameTextController.text =
//                                             selectedName;

//                                         var selectedCustomer =
//                                             provider.customerList.firstWhere(
//                                           (c) => c.firstName == selectedName,
//                                         );

//                                         await provider.getCustomerById(
//                                             selectedCustomer.customerId);
//                                         clientContractProvider.updateCustomerId(
//                                             selectedCustomer.customerId);
//                                       }
//                                     },
//                                   );
//                                 },
//                               ),
//                               SizedBox(height: screenHeight * 0.02),
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Expanded(
//                                     child: TextField(
//                                       controller: startDateTextController,
//                                       decoration: InputDecoration(
//                                         label: const CustomText(
//                                           text: "Project Start Date",
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
//                                             startDateTextController,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 2),
//                                   Expanded(
//                                     child: TextField(
//                                       controller: endDateTextController,
//                                       decoration: InputDecoration(
//                                         label: const CustomText(
//                                           text: "Project End Date",
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
//                                             endDateTextController,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: screenHeight * 0.02),
//                               CustomTextfield(
//                                 label: "Project Duration",
//                                 hintText: "00000000",
//                                 screenWidth: screenWidth * 0.045,
//                                 textController: produrationTextController,
//                                 isMandatory: false,
//                               ),
//                               SizedBox(height: screenHeight * 0.02),
//                               CustomTextfield(
//                                 label: "Project Name",
//                                 hintText: "Project Name",
//                                 screenWidth: screenWidth * 0.045,
//                                 textController: proNameTextController,
//                                 isMandatory: false,
//                               ),
//                               SizedBox(height: screenHeight * 0.02),
//                               CustomTextfield(
//                                 label: "Description",
//                                 hintText: "Description",
//                                 screenWidth: screenWidth * 0.045,
//                                 textController: prodescriptionTextController,
//                                 isMandatory: false,
//                               ),
//                               SizedBox(height: screenHeight * 0.02),
//                             ],
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       Consumer<ClientContractViewmodel>(
//                         builder: (context, provider, child) {
//                           return ColoredCustomButton(
//                             text: "Save",
//                             onPressed: () {},
//                             loading: provider.addContractLoader,
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
