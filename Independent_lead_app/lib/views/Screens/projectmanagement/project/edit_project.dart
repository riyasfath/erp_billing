// import 'package:flutter/material.dart';
// import 'package:pokakbilling/models/data-models/project_model.dart';
// import 'package:pokakbilling/viewmodels/project_management/project_viewmodel.dart';
// import 'package:pokakbilling/views/commonWidgets/buttons/colored_custom_button.dart';
// import 'package:pokakbilling/views/commonWidgets/buttons/exit_custom_button.dart';
// import 'package:pokakbilling/views/commonWidgets/textfields/custom_text.dart';
// import 'package:pokakbilling/views/commonWidgets/textfields/custom_textfield.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:provider/provider.dart';

// class EditProjectScreen extends StatefulWidget {
//   final ProjectModel projectModel;
//   const EditProjectScreen({super.key, required this.projectModel});

//   @override
//   State<EditProjectScreen> createState() => _EditProjectScreenState();
// }

// class _EditProjectScreenState extends State<EditProjectScreen> {
//   final formKey = GlobalKey<FormState>();
//   late TextEditingController startDateTextController;
//   late TextEditingController endDateTextController;
//   late TextEditingController customerNameTextController;
//   late TextEditingController contractDurationTextController;
//   late TextEditingController proNameTextController;
//   late TextEditingController descriptionTextController;
//   late TextEditingController statusTextController;

//   @override
//   void initState() {
//     super.initState();
//     startDateTextController =
//         TextEditingController(text: widget.projectModel.startDate);
//     endDateTextController =
//         TextEditingController(text: widget.projectModel.endDate);
//     customerNameTextController = TextEditingController(
//         text:
//             "${widget.projectModel.clientFirstName} ${widget.projectModel.clientLastName}");
//     contractDurationTextController =
//         TextEditingController(text: widget.projectModel.duration);
//     proNameTextController =
//         TextEditingController(text: widget.projectModel.projectName);
//     descriptionTextController =
//         TextEditingController(text: widget.projectModel.projectDescription);
//     statusTextController =
//         TextEditingController(text: widget.projectModel.status);
//   }

//   @override
//   void dispose() {
//     startDateTextController.dispose();
//     endDateTextController.dispose();
//     customerNameTextController.dispose();
//     contractDurationTextController.dispose();
//     proNameTextController.dispose();
//     descriptionTextController.dispose();
//     statusTextController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final projectViewModel = Provider.of<ProjectViewmodel>(context);
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
//                 decoration: const BoxDecoration(color: AppColors.violetblue),
//                 child: AppBar(
//                   leading: IconButton(
//                     icon: const Icon(Icons.arrow_back, color: AppColors.white),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                   title: const Text('Edit Project',
//                       style: TextStyle(color: AppColors.white)),
//                   backgroundColor: Colors.transparent,
//                   elevation: 0,
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
//               decoration:
//                   BoxDecoration(borderRadius: BorderRadius.circular(10)),
//               child: SingleChildScrollView(
//                 child: Form(
//                   key: formKey,
//                   child: Column(
//                     children: [
//                       Card(
//                         elevation: 4,
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10)),
//                         child: Padding(
//                           padding: EdgeInsets.all(screenWidth * 0.03),
//                           child: Column(
//                             children: [
//                               Row(
//                                 children: [
//                                   Expanded(
//                                       child: _buildDateField("Start Date",
//                                           startDateTextController)),
//                                   const SizedBox(width: 8),
//                                   Expanded(
//                                       child: _buildDateField(
//                                           "End Date", endDateTextController)),
//                                 ],
//                               ),
//                               const SizedBox(height: 10),
//                               CustomTextfield(
//                                 label: "Client Name",
//                                 hintText: "Client Name",
//                                 screenWidth: screenWidth * 0.045,
//                                 textController: customerNameTextController,
//                                 isMandatory: false,
//                               ),
//                               const SizedBox(height: 10),
//                               CustomTextfield(
//                                 label: "Contract Duration",
//                                 hintText: "Duration",
//                                 screenWidth: screenWidth * 0.045,
//                                 textController: contractDurationTextController,
//                                 isMandatory: false,
//                               ),
//                               const SizedBox(height: 10),
//                               CustomTextfield(
//                                 label: "Project Name",
//                                 hintText: "Project",
//                                 screenWidth: screenWidth * 0.045,
//                                 textController: proNameTextController,
//                                 isMandatory: false,
//                               ),
//                               const SizedBox(height: 10),
//                               CustomTextfield(
//                                 label: "Description",
//                                 hintText: "Project Description",
//                                 screenWidth: screenWidth * 0.045,
//                                 textController: descriptionTextController,
//                                 isMandatory: false,
//                               ),
//                               const SizedBox(height: 10),
//                               CustomTextfield(
//                                 label: "Status",
//                                 hintText: "Status",
//                                 screenWidth: screenWidth * 0.045,
//                                 textController: statusTextController,
//                                 isMandatory: false,
//                               ),
//                               const SizedBox(height: 20),
//                             ],
//                           ),
//                         ),
//                       ),
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
//                               const Text(
//                                 'Current Project Teammembers',
//                                 style: TextStyle(
//                                   color: AppColors.violetblue,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                               SizedBox(height: screenHeight * 0.02),
//                               const Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text('Sajid'),
//                                   Text('Figma'),
//                                 ],
//                               ),
//                               const Divider(
//                                 color: AppColors.grey,
//                                 thickness: 1.5,
//                               ),
//                               const Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text('Anas'),
//                                   Text('Figma'),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       ColoredCustomButton(
//                         text: "Save",
//                         onPressed: () async {
//                           if (formKey.currentState!.validate()) {
//                             await projectViewModel.updateProject(
//                               widget.projectModel.projectId,
//                               widget.projectModel.contractId,
//                               proNameTextController.text,
//                               descriptionTextController.text,
//                               startDateTextController.text,
//                               endDateTextController.text,
//                               statusTextController.text,
//                               context,
//                             );
//                           }
//                         },
//                       ),
//                       const SizedBox(height: 10),
//                       const ExitCustomButton(text: "Exit"),
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

//   Widget _buildDateField(String label, TextEditingController controller) {
//     return TextField(
//       controller: controller,
//       decoration: InputDecoration(
//         label: CustomText(text: label, isMandatory: false),
//         suffixIcon: IconButton(
//           icon: const Icon(Icons.calendar_today, color: AppColors.grey),
//           onPressed: () => _selectDate(context, controller),
//         ),
//       ),
//     );
//   }

//   Future<void> _selectDate(
//       BuildContext context, TextEditingController controller) async {
//     DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );
//     if (pickedDate != null) {
//       controller.text = "${pickedDate.toLocal()}".split(' ')[0];
//     }
//   }
// }
