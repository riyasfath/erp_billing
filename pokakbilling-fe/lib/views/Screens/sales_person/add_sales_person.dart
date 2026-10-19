// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/models/data-models/salesperson_model.dart';
// import 'package:pokakbilling/viewmodels/sales_person_viewmodel.dart';
// import 'package:pokakbilling/views/commonWidgets/buttons/colored_custom_button.dart';
// import 'package:provider/provider.dart';

// class AddSalesPerson extends StatefulWidget {
//   final bool isEdit;
//   final SalesPersonModel? salesPerson;
//   const AddSalesPerson({super.key, required this.isEdit, this.salesPerson});

//   @override
//   State<AddSalesPerson> createState() => _AddSalesPersonState();
// }

// class _AddSalesPersonState extends State<AddSalesPerson> {
//   late TextEditingController firstNameTextController;
//   late TextEditingController lastNameTextController;
//   late TextEditingController countryTextController;
//   late TextEditingController stateTextController;
//   late TextEditingController addressTextController;
//   late TextEditingController emailIdTextController;
//   late TextEditingController phoneTextController;
//   late TextEditingController mobileTextController;
//   late TextEditingController incentiveTextController;
//   late TextEditingController designationTextController;

//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   @override
//   void initState() {
//     super.initState();
//     firstNameTextController =
//         TextEditingController(text: widget.salesPerson?.firstName ?? '');
//     lastNameTextController =
//         TextEditingController(text: widget.salesPerson?.lastName ?? '');
//     countryTextController =
//         TextEditingController(text: widget.salesPerson?.country ?? '');
//     stateTextController =
//         TextEditingController(text: widget.salesPerson?.state ?? '');
//     addressTextController =
//         TextEditingController(text: widget.salesPerson?.address ?? '');
//     emailIdTextController =
//         TextEditingController(text: widget.salesPerson?.email ?? '');
//     phoneTextController =
//         TextEditingController(text: widget.salesPerson?.phone ?? '');
//     mobileTextController =
//         TextEditingController(text: widget.salesPerson?.mobile ?? '');
//     incentiveTextController =
//         TextEditingController(text: widget.salesPerson?.incentive ?? '');
//     designationTextController =
//         TextEditingController(text: widget.salesPerson?.designation ?? '');
//   }

//   @override
//   void dispose() {
//     firstNameTextController.dispose();
//     lastNameTextController.dispose();
//     countryTextController.dispose();
//     stateTextController.dispose();
//     addressTextController.dispose();
//     emailIdTextController.dispose();
//     phoneTextController.dispose();
//     mobileTextController.dispose();
//     incentiveTextController.dispose();
//     designationTextController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final salesPersonProvider = Provider.of<SalesPersonViewmodel>(context);

//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       backgroundColor: AppColors.violetblue,
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back,
//             color: AppColors.white,
//           ),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: Text(
//           widget.isEdit ? 'Edit Sales Person' : 'Create Sales Person',
//           style: const TextStyle(
//             color: AppColors.white,
//             fontWeight: FontWeight.w500,
//             fontSize: 18,
//           ),
//         ),
//         backgroundColor: AppColors.violetblue,
//         elevation: 0,
//       ),
//       // ── Button pinned at bottom, always above system navigation bar ──────
//       bottomNavigationBar: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
//           child: ColoredCustomButton(
//             text: widget.isEdit ? 'Edit' : 'Save',
//             onPressed: () {
//               if (_formKey.currentState?.validate() ?? false) {
//                 widget.isEdit
//                     ? salesPersonProvider.editSalesPerson(
//                         widget.salesPerson!.salesPersonId,
//                         firstNameTextController.text.trim(),
//                         lastNameTextController.text.trim(),
//                         designationTextController.text.trim(),
//                         countryTextController.text.trim(),
//                         stateTextController.text.trim(),
//                         addressTextController.text.trim(),
//                         emailIdTextController.text.trim(),
//                         phoneTextController.text.trim(),
//                         mobileTextController.text.trim(),
//                         incentiveTextController.text.trim(),
//                         context,
//                       )
//                     : salesPersonProvider.createSalesPerson(
//                         firstNameTextController.text.trim(),
//                         lastNameTextController.text.trim(),
//                         designationTextController.text.trim(),
//                         countryTextController.text.trim(),
//                         stateTextController.text.trim(),
//                         addressTextController.text.trim(),
//                         emailIdTextController.text.trim(),
//                         phoneTextController.text.trim(),
//                         mobileTextController.text.trim(),
//                         incentiveTextController.text.trim(),
//                         context,
//                       );
//               }
//             },
//             loading: widget.isEdit
//                 ? salesPersonProvider.editLoading
//                 : salesPersonProvider.addSalesPersonLoading,
//             formKey: _formKey,
//           ),
//         ),
//       ),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           return SingleChildScrollView(
//             physics: const ClampingScrollPhysics(),
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     Card(
//                       elevation: 4,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(20),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // First Name - Required, letters only
//                             TextFormField(
//                               controller: firstNameTextController,
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.allow(
//                                   RegExp(r"[a-zA-Z\s\-']"),
//                                 ),
//                               ],
//                               validator: (value) {
//                                 if (value == null || value.trim().isEmpty) {
//                                   return 'First Name is required';
//                                 }
//                                 if (value.trim().length < 2) {
//                                   return 'First Name must be at least 2 characters';
//                                 }
//                                 if (value.trim().length > 50) {
//                                   return 'First Name must not exceed 50 characters';
//                                 }
//                                 final nameRegex = RegExp(r"^[a-zA-Z\s\-']+$");
//                                 if (!nameRegex.hasMatch(value.trim())) {
//                                   return 'First Name can only contain letters';
//                                 }
//                                 return null;
//                               },
//                               decoration: const InputDecoration(
//                                 labelText: 'First Name *',
//                                 hintText: 'Enter first name',
//                               ),
//                             ),
//                             const SizedBox(height: 12),

//                             // Last Name - Optional, letters only if provided
//                             TextFormField(
//                               controller: lastNameTextController,
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.allow(
//                                   RegExp(r"[a-zA-Z\s\-']"),
//                                 ),
//                               ],
//                               validator: (value) {
//                                 if (value == null || value.trim().isEmpty) {
//                                   return null; // optional
//                                 }
//                                 if (value.trim().length < 2) {
//                                   return 'Last Name must be at least 2 characters';
//                                 }
//                                 if (value.trim().length > 50) {
//                                   return 'Last Name must not exceed 50 characters';
//                                 }
//                                 final nameRegex = RegExp(r"^[a-zA-Z\s\-']+$");
//                                 if (!nameRegex.hasMatch(value.trim())) {
//                                   return 'Last Name can only contain letters';
//                                 }
//                                 return null;
//                               },
//                               decoration: const InputDecoration(
//                                 labelText: 'Last Name',
//                                 hintText: 'Enter last name',
//                               ),
//                             ),
//                             const SizedBox(height: 12),

//                             // Designation - Required, letters and spaces
//                             TextFormField(
//                               controller: designationTextController,
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.allow(
//                                   RegExp(r"[a-zA-Z\s\-]"),
//                                 ),
//                               ],
//                               validator: (value) {
//                                 if (value == null || value.trim().isEmpty) {
//                                   return 'Designation is required';
//                                 }
//                                 if (value.trim().length < 2) {
//                                   return 'Designation must be at least 2 characters';
//                                 }
//                                 if (value.trim().length > 50) {
//                                   return 'Designation must not exceed 50 characters';
//                                 }
//                                 final designationRegex =
//                                     RegExp(r"^[a-zA-Z\s\-]+$");
//                                 if (!designationRegex.hasMatch(value.trim())) {
//                                   return 'Designation can only contain letters';
//                                 }
//                                 return null;
//                               },
//                               decoration: const InputDecoration(
//                                 labelText: 'Designation *',
//                                 hintText: 'Enter designation',
//                               ),
//                             ),
//                             const SizedBox(height: 12),

//                             // Country - Required, letters only
//                             TextFormField(
//                               controller: countryTextController,
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.allow(
//                                   RegExp(r"[a-zA-Z\s\-]"),
//                                 ),
//                               ],
//                               validator: (value) {
//                                 if (value == null || value.trim().isEmpty) {
//                                   return 'Country is required';
//                                 }
//                                 if (value.trim().length < 2) {
//                                   return 'Country must be at least 2 characters';
//                                 }
//                                 if (value.trim().length > 50) {
//                                   return 'Country must not exceed 50 characters';
//                                 }
//                                 final countryRegex = RegExp(r"^[a-zA-Z\s\-]+$");
//                                 if (!countryRegex.hasMatch(value.trim())) {
//                                   return 'Country can only contain letters';
//                                 }
//                                 return null;
//                               },
//                               decoration: const InputDecoration(
//                                 labelText: 'Country *',
//                                 hintText: 'Enter country',
//                               ),
//                             ),
//                             const SizedBox(height: 12),

//                             // State - Required, letters only
//                             TextFormField(
//                               controller: stateTextController,
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.allow(
//                                   RegExp(r"[a-zA-Z\s\-]"),
//                                 ),
//                               ],
//                               validator: (value) {
//                                 if (value == null || value.trim().isEmpty) {
//                                   return 'State is required';
//                                 }
//                                 if (value.trim().length < 2) {
//                                   return 'State must be at least 2 characters';
//                                 }
//                                 if (value.trim().length > 50) {
//                                   return 'State must not exceed 50 characters';
//                                 }
//                                 final stateRegex = RegExp(r"^[a-zA-Z\s\-]+$");
//                                 if (!stateRegex.hasMatch(value.trim())) {
//                                   return 'State can only contain letters';
//                                 }
//                                 return null;
//                               },
//                               decoration: const InputDecoration(
//                                 labelText: 'State *',
//                                 hintText: 'Enter state',
//                               ),
//                             ),
//                             const SizedBox(height: 12),

//                             // Address - Optional, alphanumeric with common punctuation
//                             TextFormField(
//                               controller: addressTextController,
//                               validator: (value) {
//                                 if (value == null || value.trim().isEmpty) {
//                                   return null; // optional
//                                 }
//                                 if (value.trim().length < 5) {
//                                   return 'Address must be at least 5 characters';
//                                 }
//                                 if (value.trim().length > 200) {
//                                   return 'Address must not exceed 200 characters';
//                                 }
//                                 final addressRegex =
//                                     RegExp(r"^[A-Za-z0-9\s,.\-/#]+$");
//                                 if (!addressRegex.hasMatch(value.trim())) {
//                                   return 'Address contains invalid characters';
//                                 }
//                                 return null;
//                               },
//                               decoration: const InputDecoration(
//                                 labelText: 'Address',
//                                 hintText: 'Enter address',
//                               ),
//                               maxLines: 2,
//                             ),
//                             const SizedBox(height: 12),

//                             // Email - Required, valid email format
//                             TextFormField(
//                               controller: emailIdTextController,
//                               keyboardType: TextInputType.emailAddress,
//                               validator: (value) {
//                                 if (value == null || value.trim().isEmpty) {
//                                   return 'Email is required';
//                                 }
//                                 if (value.trim().length < 5) {
//                                   return 'Email must be at least 5 characters';
//                                 }
//                                 if (value.trim().length > 100) {
//                                   return 'Email must not exceed 100 characters';
//                                 }
//                                 final emailRegex = RegExp(
//                                     r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
//                                 if (!emailRegex.hasMatch(value.trim())) {
//                                   return 'Please enter a valid email address';
//                                 }
//                                 return null;
//                               },
//                               decoration: const InputDecoration(
//                                 labelText: 'Email *',
//                                 hintText: 'Enter email address',
//                               ),
//                             ),
//                             const SizedBox(height: 12),

//                             // Phone - Optional, exactly 10 digits if filled
//                             TextFormField(
//                               controller: phoneTextController,
//                               keyboardType: TextInputType.phone,
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.digitsOnly,
//                                 LengthLimitingTextInputFormatter(10),
//                               ],
//                               validator: (value) {
//                                 if (value == null || value.trim().isEmpty) {
//                                   return null; // optional
//                                 }
//                                 final digitsOnly = RegExp(r'^[0-9]+$');
//                                 if (!digitsOnly.hasMatch(value.trim())) {
//                                   return 'Phone can only contain digits (0-9)';
//                                 }
//                                 if (value.trim().length != 10) {
//                                   return 'Phone must be exactly 10 digits';
//                                 }
//                                 return null;
//                               },
//                               decoration: const InputDecoration(
//                                 labelText: 'Phone',
//                                 hintText: 'Enter phone number (10 digits)',
//                               ),
//                             ),
//                             const SizedBox(height: 12),

//                             // Mobile - Required, exactly 10 digits
//                             TextFormField(
//                               controller: mobileTextController,
//                               keyboardType: TextInputType.phone,
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.digitsOnly,
//                                 LengthLimitingTextInputFormatter(10),
//                               ],
//                               validator: (value) {
//                                 if (value == null || value.trim().isEmpty) {
//                                   return 'Mobile is required';
//                                 }
//                                 final digitsOnly = RegExp(r'^[0-9]+$');
//                                 if (!digitsOnly.hasMatch(value.trim())) {
//                                   return 'Mobile can only contain digits (0-9)';
//                                 }
//                                 if (value.trim().length != 10) {
//                                   return 'Mobile must be exactly 10 digits';
//                                 }
//                                 return null;
//                               },
//                               decoration: const InputDecoration(
//                                 labelText: 'Mobile *',
//                                 hintText: 'Enter mobile number',
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Card(
//                       elevation: 4,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(15),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'Other Details',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             const SizedBox(height: 12),

//                             // Incentive - Required, numbers only (max value: 10)
//                             TextFormField(
//                               controller: incentiveTextController,
//                               keyboardType:
//                                   const TextInputType.numberWithOptions(
//                                 decimal: true,
//                               ),
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.allow(
//                                   RegExp(r'^\d+\.?\d{0,2}'),
//                                 ),
//                               ],
//                               validator: (value) {
//                                 if (value == null || value.trim().isEmpty) {
//                                   return 'Incentive is required';
//                                 }
//                                 final numberRegex =
//                                     RegExp(r'^\d+(\.\d{1,2})?$');
//                                 if (!numberRegex.hasMatch(value.trim())) {
//                                   return 'Incentive must be a valid number';
//                                 }
//                                 final number = double.tryParse(value.trim());
//                                 if (number == null || number < 0) {
//                                   return 'Incentive must be a positive number';
//                                 }
//                                 if (number > 10) {
//                                   return 'Incentive must not exceed 10';
//                                 }
//                                 return null;
//                               },
//                               decoration: const InputDecoration(
//                                 labelText: 'Incentive *',
//                                 hintText: 'Enter incentive amount (max 10)',
//                                 prefixText: '₹ ',
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/salesperson_model.dart';
import 'package:pokakbilling/viewmodels/sales_person_viewmodel.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/colored_custom_button.dart';
import 'package:provider/provider.dart';

class AddSalesPerson extends StatefulWidget {
  final bool isEdit;
  final SalesPersonModel? salesPerson;
  const AddSalesPerson({super.key, required this.isEdit, this.salesPerson});

  @override
  State<AddSalesPerson> createState() => _AddSalesPersonState();
}

class _AddSalesPersonState extends State<AddSalesPerson> {
  late TextEditingController firstNameTextController;
  late TextEditingController lastNameTextController;
  late TextEditingController countryTextController;
  late TextEditingController stateTextController;
  late TextEditingController addressTextController;
  late TextEditingController emailIdTextController;
  late TextEditingController phoneTextController;
  late TextEditingController mobileTextController;
  late TextEditingController incentiveTextController;
  late TextEditingController designationTextController;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    firstNameTextController =
        TextEditingController(text: widget.salesPerson?.firstName ?? '');
    lastNameTextController =
        TextEditingController(text: widget.salesPerson?.lastName ?? '');
    countryTextController =
        TextEditingController(text: widget.salesPerson?.country ?? '');
    stateTextController =
        TextEditingController(text: widget.salesPerson?.state ?? '');
    addressTextController =
        TextEditingController(text: widget.salesPerson?.address ?? '');
    emailIdTextController =
        TextEditingController(text: widget.salesPerson?.email ?? '');
    phoneTextController =
        TextEditingController(text: widget.salesPerson?.phone ?? '');
    mobileTextController =
        TextEditingController(text: widget.salesPerson?.mobile ?? '');
    incentiveTextController =
        TextEditingController(text: widget.salesPerson?.incentive ?? '');
    designationTextController =
        TextEditingController(text: widget.salesPerson?.designation ?? '');
  }

  @override
  void dispose() {
    firstNameTextController.dispose();
    lastNameTextController.dispose();
    countryTextController.dispose();
    stateTextController.dispose();
    addressTextController.dispose();
    emailIdTextController.dispose();
    phoneTextController.dispose();
    mobileTextController.dispose();
    incentiveTextController.dispose();
    designationTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final salesPersonProvider = Provider.of<SalesPersonViewmodel>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.violetblue,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.isEdit ? 'Edit Sales Person' : 'Create Sales Person',
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.violetblue,
        elevation: 0,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
          child: ColoredCustomButton(
            text: widget.isEdit ? 'Edit' : 'Save',
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                widget.isEdit
                    ? salesPersonProvider.editSalesPerson(
                        widget.salesPerson!.salesPersonId,
                        firstNameTextController.text.trim(),
                        lastNameTextController.text.trim(),
                        designationTextController.text.trim(),
                        countryTextController.text.trim(),
                        stateTextController.text.trim(),
                        addressTextController.text.trim(),
                        emailIdTextController.text.trim(),
                        phoneTextController.text.trim(),
                        mobileTextController.text.trim(),
                        incentiveTextController.text.trim(),
                        context,
                      )
                    : salesPersonProvider.createSalesPerson(
                        firstNameTextController.text.trim(),
                        lastNameTextController.text.trim(),
                        designationTextController.text.trim(),
                        countryTextController.text.trim(),
                        stateTextController.text.trim(),
                        addressTextController.text.trim(),
                        emailIdTextController.text.trim(),
                        phoneTextController.text.trim(),
                        mobileTextController.text.trim(),
                        incentiveTextController.text.trim(),
                        context,
                      );
              }
            },
            loading: widget.isEdit
                ? salesPersonProvider.editLoading
                : salesPersonProvider.addSalesPersonLoading,
            formKey: _formKey,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // First Name - Required, letters only
                            TextFormField(
                              controller: firstNameTextController,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r"[a-zA-Z\s\-']"),
                                ),
                              ],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'First Name is required';
                                }
                                if (value.trim().length < 2) {
                                  return 'First Name must be at least 2 characters';
                                }
                                if (value.trim().length > 50) {
                                  return 'First Name must not exceed 50 characters';
                                }
                                final nameRegex = RegExp(r"^[a-zA-Z\s\-']+$");
                                if (!nameRegex.hasMatch(value.trim())) {
                                  return 'First Name can only contain letters';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: 'First Name *',
                                hintText: 'Enter first name',
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Last Name - Optional, letters only if provided
                            TextFormField(
                              controller: lastNameTextController,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r"[a-zA-Z\s\-']"),
                                ),
                              ],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return null; // optional
                                }
                                if (value.trim().length < 2) {
                                  return 'Last Name must be at least 2 characters';
                                }
                                if (value.trim().length > 50) {
                                  return 'Last Name must not exceed 50 characters';
                                }
                                final nameRegex = RegExp(r"^[a-zA-Z\s\-']+$");
                                if (!nameRegex.hasMatch(value.trim())) {
                                  return 'Last Name can only contain letters';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Last Name',
                                hintText: 'Enter last name',
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Designation - Required, letters and spaces
                            TextFormField(
                              controller: designationTextController,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r"[a-zA-Z\s\-]"),
                                ),
                              ],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Designation is required';
                                }
                                if (value.trim().length < 2) {
                                  return 'Designation must be at least 2 characters';
                                }
                                if (value.trim().length > 50) {
                                  return 'Designation must not exceed 50 characters';
                                }
                                final designationRegex =
                                    RegExp(r"^[a-zA-Z\s\-]+$");
                                if (!designationRegex.hasMatch(value.trim())) {
                                  return 'Designation can only contain letters';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Designation *',
                                hintText: 'Enter designation',
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Country - Required, letters only
                            TextFormField(
                              controller: countryTextController,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r"[a-zA-Z\s\-]"),
                                ),
                              ],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Country is required';
                                }
                                if (value.trim().length < 2) {
                                  return 'Country must be at least 2 characters';
                                }
                                if (value.trim().length > 50) {
                                  return 'Country must not exceed 50 characters';
                                }
                                final countryRegex = RegExp(r"^[a-zA-Z\s\-]+$");
                                if (!countryRegex.hasMatch(value.trim())) {
                                  return 'Country can only contain letters';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Country *',
                                hintText: 'Enter country',
                              ),
                            ),
                            const SizedBox(height: 12),

                            // State - Required, letters only
                            TextFormField(
                              controller: stateTextController,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r"[a-zA-Z\s\-]"),
                                ),
                              ],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'State is required';
                                }
                                if (value.trim().length < 2) {
                                  return 'State must be at least 2 characters';
                                }
                                if (value.trim().length > 50) {
                                  return 'State must not exceed 50 characters';
                                }
                                final stateRegex = RegExp(r"^[a-zA-Z\s\-]+$");
                                if (!stateRegex.hasMatch(value.trim())) {
                                  return 'State can only contain letters';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: 'State *',
                                hintText: 'Enter state',
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Address - Optional, alphanumeric with common punctuation
                            TextFormField(
                              controller: addressTextController,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return null; // optional
                                }
                                if (value.trim().length < 5) {
                                  return 'Address must be at least 5 characters';
                                }
                                if (value.trim().length > 200) {
                                  return 'Address must not exceed 200 characters';
                                }
                                final addressRegex =
                                    RegExp(r"^[A-Za-z0-9\s,.\-/#]+$");
                                if (!addressRegex.hasMatch(value.trim())) {
                                  return 'Address contains invalid characters';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Address',
                                hintText: 'Enter address',
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 12),

                            // Email - Required, valid email format
                            TextFormField(
                              controller: emailIdTextController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                if (value.trim().length < 5) {
                                  return 'Email must be at least 5 characters';
                                }
                                if (value.trim().length > 100) {
                                  return 'Email must not exceed 100 characters';
                                }
                                final emailRegex = RegExp(
                                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                                if (!emailRegex.hasMatch(value.trim())) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Email *',
                                hintText: 'Enter email address',
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Phone - Optional, exactly 10 digits if filled
                            TextFormField(
                              controller: phoneTextController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return null; // optional
                                }
                                final digitsOnly = RegExp(r'^[0-9]+$');
                                if (!digitsOnly.hasMatch(value.trim())) {
                                  return 'Phone can only contain digits (0-9)';
                                }
                                if (value.trim().length != 10) {
                                  return 'Phone must be exactly 10 digits';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Phone',
                                hintText: 'Enter phone number (10 digits)',
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Mobile - Required, exactly 10 digits
                            TextFormField(
                              controller: mobileTextController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Mobile is required';
                                }
                                final digitsOnly = RegExp(r'^[0-9]+$');
                                if (!digitsOnly.hasMatch(value.trim())) {
                                  return 'Mobile can only contain digits (0-9)';
                                }
                                if (value.trim().length != 10) {
                                  return 'Mobile must be exactly 10 digits';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Mobile *',
                                hintText: 'Enter mobile number',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Other Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Incentive - Required, max 10 digits
                            TextFormField(
                              controller: incentiveTextController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}'),
                                ),
                              ],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Incentive is required';
                                }
                                final numberRegex =
                                    RegExp(r'^\d+(\.\d{1,2})?$');
                                if (!numberRegex.hasMatch(value.trim())) {
                                  return 'Incentive must be a valid number';
                                }
                                final number = double.tryParse(value.trim());
                                if (number == null || number < 0) {
                                  return 'Incentive must be a positive number';
                                }
                                // CHANGED: Now validates digit count (not value <= 10)
                                if (value.trim().length > 10) {
                                  return 'Incentive must not exceed 10 digits';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Incentive *',
                                hintText: 'Enter incentive amount',
                                prefixText: '₹ ',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
