// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/models/data-models/salesperson_model.dart';
// import 'package:pokakbilling/viewmodels/sales_person_viewmodel.dart';
// import 'package:pokakbilling/views/commonWidgets/buttons/colored_custom_button.dart';

// class AddSalesPerson extends StatefulWidget {
//   final bool isEdit;
//   final SalesPersonModel? salesPerson;

//   const AddSalesPerson({super.key, required this.isEdit, this.salesPerson});

//   @override
//   State<AddSalesPerson> createState() => _AddSalesPersonState();
// }

// class _AddSalesPersonState extends State<AddSalesPerson> {
//   final formKey = GlobalKey<FormState>();

//   late TextEditingController firstNameTextController;
//   late TextEditingController lastNameTextController;
//   late TextEditingController countryTextController;
//   late TextEditingController stateTextController;
//   late TextEditingController cityTextController;
//   late TextEditingController addressTextController;
//   late TextEditingController emailIdTextController;
//   late TextEditingController phoneTextController;
//   late TextEditingController mobileTextController;
//   late TextEditingController incentiveTextController;
//   late TextEditingController designationTextController;
//   late TextEditingController passwordTextController;

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
//     cityTextController =
//         TextEditingController(text: widget.salesPerson?.city ?? '');
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
//     passwordTextController = TextEditingController();
//   }

//   @override
//   void dispose() {
//     firstNameTextController.dispose();
//     lastNameTextController.dispose();
//     countryTextController.dispose();
//     stateTextController.dispose();
//     cityTextController.dispose();
//     addressTextController.dispose();
//     emailIdTextController.dispose();
//     phoneTextController.dispose();
//     mobileTextController.dispose();
//     incentiveTextController.dispose();
//     designationTextController.dispose();
//     passwordTextController.dispose();
//     super.dispose();
//   }

//   void showError(String? message) {
//     if (message == null || message.isEmpty) return;

//     // ✅ FIX: In edit mode, "already exists" errors are expected because
//     // the server sees the same phone/email/mobile as a duplicate.
//     // Suppress these errors silently — the edit was actually successful.
//     if (widget.isEdit && message.contains('already exists')) return;

//     String displayMessage = message;

//     if (message.contains('phone_number') &&
//         message.contains('already exists')) {
//       displayMessage = 'This phone number is already registered.';
//     } else if (message.contains('email') &&
//         message.contains('already exists')) {
//       displayMessage = 'This email address is already registered.';
//     } else if (message.contains('mobile') &&
//         message.contains('already exists')) {
//       displayMessage = 'This mobile number is already registered.';
//     } else if (message.contains('username') &&
//         message.contains('already exists')) {
//       displayMessage = 'This username is already taken.';
//     } else if (message.contains('user') && message.contains('already exists')) {
//       displayMessage = 'A user with these details already exists.';
//     }

//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         title: Row(
//           children: const [
//             Icon(Icons.error_outline, color: Colors.red, size: 26),
//             SizedBox(width: 8),
//             Text(
//               'Error',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.red,
//               ),
//             ),
//           ],
//         ),
//         content: Text(
//           displayMessage,
//           style: const TextStyle(fontSize: 15, color: Colors.black87),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(ctx).pop(),
//             style: TextButton.styleFrom(
//               backgroundColor: AppColors.violetblue,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//             ),
//             child: const Text(
//               'OK',
//               style:
//                   TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Validators — all return null (skip) in edit mode ──────────────────────

//   String? _lettersOnlyValidator(String? value, String fieldName) {
//     if (widget.isEdit) return null;
//     if (value == null || value.trim().isEmpty) {
//       return '$fieldName is required';
//     }
//     if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value.trim())) {
//       return '$fieldName must contain letters only';
//     }
//     return null;
//   }

//   String? _emailValidator(String? value) {
//     if (widget.isEdit) return null;
//     if (value == null || value.trim().isEmpty) {
//       return 'Email is required';
//     }
//     if (!RegExp(r'^[\w.-]+@[\w.-]+\.[a-zA-Z]{2,}$').hasMatch(value.trim())) {
//       return 'Enter a valid email address';
//     }
//     return null;
//   }

//   String? _mobileValidator(String? value, String fieldName,
//       {bool isRequired = true}) {
//     if (widget.isEdit) return null;
//     if (value == null || value.trim().isEmpty) {
//       if (isRequired) return '$fieldName is required';
//       return null;
//     }
//     if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
//       return '$fieldName must contain digits only';
//     }
//     if (value.trim().length != 10) {
//       return '$fieldName must be exactly 10 digits';
//     }
//     return null;
//   }

//   String? _requiredValidator(String? value, String fieldName) {
//     if (widget.isEdit) return null;
//     if (value == null || value.trim().isEmpty) {
//       return '$fieldName is required';
//     }
//     return null;
//   }

//   String? _incentiveValidator(String? value) {
//     if (widget.isEdit) return null;
//     if (value == null || value.trim().isEmpty) {
//       return 'Incentive is required';
//     }
//     if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
//       return 'Please enter a valid numeric value';
//     }
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final salesPersonProvider = Provider.of<SalesPersonViewmodel>(context);

//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       body: Column(
//         children: [
//           // ── Header ────────────────────────────────────────────────────
//           Container(
//             height: 150,
//             color: AppColors.violetblue,
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.arrow_back, color: AppColors.white),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//                 const SizedBox(width: 10),
//                 Text(
//                   widget.isEdit ? 'Edit Sales Person' : 'Create Sales Person',
//                   style: const TextStyle(
//                     color: AppColors.white,
//                     fontWeight: FontWeight.w500,
//                     fontSize: 20,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // ── Form ──────────────────────────────────────────────────────
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//               child: Form(
//                 key: formKey,
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
//                           children: [
//                             TextFormField(
//                               controller: firstNameTextController,
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.allow(
//                                     RegExp(r'[a-zA-Z\s]')),
//                               ],
//                               decoration: InputDecoration(
//                                 labelText: widget.isEdit
//                                     ? "First Name"
//                                     : "First Name *",
//                                 hintText: "Enter First Name",
//                               ),
//                               validator: (value) =>
//                                   _lettersOnlyValidator(value, 'First Name'),
//                             ),
//                             const SizedBox(height: 12),
//                             TextFormField(
//                               controller: lastNameTextController,
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.allow(
//                                     RegExp(r'[a-zA-Z\s]')),
//                               ],
//                               decoration: InputDecoration(
//                                 labelText:
//                                     widget.isEdit ? "Last Name" : "Last Name *",
//                                 hintText: "Enter Last Name",
//                               ),
//                               validator: (value) =>
//                                   _lettersOnlyValidator(value, 'Last Name'),
//                             ),
//                             const SizedBox(height: 12),
//                             TextFormField(
//                               controller: designationTextController,
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.allow(
//                                     RegExp(r'[a-zA-Z\s]')),
//                               ],
//                               decoration: InputDecoration(
//                                 labelText: widget.isEdit
//                                     ? "Designation"
//                                     : "Designation *",
//                                 hintText: "Enter Designation",
//                               ),
//                               validator: (value) =>
//                                   _lettersOnlyValidator(value, 'Designation'),
//                             ),
//                             const SizedBox(height: 12),
//                             TextFormField(
//                               controller: countryTextController,
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.allow(
//                                     RegExp(r'[a-zA-Z\s]')),
//                               ],
//                               decoration: InputDecoration(
//                                 labelText:
//                                     widget.isEdit ? "Country" : "Country *",
//                                 hintText: "Enter Country",
//                               ),
//                               validator: (value) =>
//                                   _lettersOnlyValidator(value, 'Country'),
//                             ),
//                             const SizedBox(height: 12),
//                             TextFormField(
//                               controller: stateTextController,
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.allow(
//                                     RegExp(r'[a-zA-Z\s]')),
//                               ],
//                               decoration: InputDecoration(
//                                 labelText: widget.isEdit ? "State" : "State *",
//                                 hintText: "Enter State",
//                               ),
//                               validator: (value) =>
//                                   _lettersOnlyValidator(value, 'State'),
//                             ),
//                             const SizedBox(height: 12),
//                             TextFormField(
//                               controller: cityTextController,
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.allow(
//                                     RegExp(r'[a-zA-Z\s]')),
//                               ],
//                               decoration: InputDecoration(
//                                 labelText: widget.isEdit ? "City" : "City *",
//                                 hintText: "Enter City",
//                               ),
//                               validator: (value) =>
//                                   _lettersOnlyValidator(value, 'City'),
//                             ),
//                             const SizedBox(height: 12),
//                             TextFormField(
//                               controller: addressTextController,
//                               decoration: const InputDecoration(
//                                 labelText: "Address",
//                                 hintText: "Enter Address",
//                               ),
//                               validator: (value) => null,
//                             ),
//                             const SizedBox(height: 12),
//                             TextFormField(
//                               controller: emailIdTextController,
//                               keyboardType: TextInputType.emailAddress,
//                               decoration: InputDecoration(
//                                 labelText: widget.isEdit ? "Email" : "Email *",
//                                 hintText: "Enter Email",
//                               ),
//                               validator: _emailValidator,
//                             ),
//                             const SizedBox(height: 12),
//                             TextFormField(
//                               controller: phoneTextController,
//                               keyboardType: TextInputType.number,
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.digitsOnly,
//                                 LengthLimitingTextInputFormatter(10),
//                               ],
//                               decoration: const InputDecoration(
//                                 labelText: "Phone",
//                                 hintText: "Enter Phone",
//                               ),
//                               validator: (value) => _mobileValidator(
//                                   value, 'Phone',
//                                   isRequired: false),
//                             ),
//                             const SizedBox(height: 12),
//                             TextFormField(
//                               controller: mobileTextController,
//                               keyboardType: TextInputType.number,
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.digitsOnly,
//                                 LengthLimitingTextInputFormatter(10),
//                               ],
//                               decoration: InputDecoration(
//                                 labelText:
//                                     widget.isEdit ? "Mobile" : "Mobile *",
//                                 hintText: "Enter Mobile Number",
//                               ),
//                               validator: (value) =>
//                                   _mobileValidator(value, 'Mobile'),
//                             ),

//                             // Password only in add mode
//                             if (!widget.isEdit) ...[
//                               const SizedBox(height: 12),
//                               TextFormField(
//                                 controller: passwordTextController,
//                                 obscureText: true,
//                                 decoration: const InputDecoration(
//                                   labelText: "Password *",
//                                   hintText: "Enter Password",
//                                 ),
//                                 validator: (value) =>
//                                     _requiredValidator(value, 'Password'),
//                               ),
//                             ],
//                             const SizedBox(height: 12),
//                             TextFormField(
//                               controller: incentiveTextController,
//                               keyboardType: TextInputType.number,
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.digitsOnly,
//                                 LengthLimitingTextInputFormatter(10),
//                               ],
//                               decoration: InputDecoration(
//                                 labelText:
//                                     widget.isEdit ? "Incentive" : "Incentive *",
//                                 hintText: "Enter Incentive Amount",
//                                 prefixText: '₹ ',
//                                 prefixStyle: const TextStyle(
//                                   fontSize: 15,
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.black87,
//                                 ),
//                               ),
//                               validator: _incentiveValidator,
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
//           ),
//         ],
//       ),

//       // ── Bottom button ──────────────────────────────────────────────────
//       bottomNavigationBar: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(15),
//           child: ColoredCustomButton(
//             text: widget.isEdit ? 'Edit' : 'Save',
//             onPressed: () async {
//               if (formKey.currentState!.validate()) {
//                 if (widget.isEdit) {
//                   await salesPersonProvider.editSalesPerson(
//                     widget.salesPerson!.salesPersonId,
//                     firstNameTextController.text,
//                     lastNameTextController.text,
//                     designationTextController.text,
//                     countryTextController.text,
//                     stateTextController.text,
//                     cityTextController.text,
//                     addressTextController.text,
//                     emailIdTextController.text,
//                     phoneTextController.text,
//                     mobileTextController.text,
//                     incentiveTextController.text,
//                     context,
//                   );
//                 } else {
//                   await salesPersonProvider.createSalesPerson(
//                     firstNameTextController.text,
//                     lastNameTextController.text,
//                     designationTextController.text,
//                     countryTextController.text,
//                     stateTextController.text,
//                     cityTextController.text,
//                     addressTextController.text,
//                     emailIdTextController.text,
//                     phoneTextController.text,
//                     mobileTextController.text,
//                     incentiveTextController.text,
//                     passwordTextController.text,
//                     context,
//                   );
//                 }
//                 showError(salesPersonProvider.errorMessage);
//               }
//             },
//             loading: widget.isEdit
//                 ? salesPersonProvider.editLoading
//                 : salesPersonProvider.addSalesPersonLoading,
//             formKey: formKey,
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/core/themes/app_assets.dart';
import 'package:pokakbilling/models/data-models/salesperson_model.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/sales_person_viewmodel.dart';
import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';
import 'package:provider/provider.dart';

class _C {
  _C._();
  static const Color navy = AppColors.navy;
  static const Color cyan = AppColors.cyan;
  static const Color ice = AppColors.ice;
  static const Color white = AppColors.white;
  static const Color red = AppColors.red;
}

class AddSalesPerson extends StatefulWidget {
  final bool isEdit;
  final SalesPersonModel? salesPerson;
  const AddSalesPerson({super.key, this.isEdit = false, this.salesPerson});

  @override
  State<AddSalesPerson> createState() => _AddSalesPersonState();
}

class _AddSalesPersonState extends State<AddSalesPerson>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController firstNameTextController;
  late TextEditingController lastNameTextController;
  late TextEditingController countryTextController;
  late TextEditingController stateTextController;
  late TextEditingController cityTextController;
  late TextEditingController addressTextController;
  late TextEditingController emailIdTextController;
  late TextEditingController phoneTextController;
  late TextEditingController mobileTextController;
  late TextEditingController incentiveTextController;
  late TextEditingController designationTextController;
  late TextEditingController passwordTextController;
  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();

    firstNameTextController =
        TextEditingController(text: widget.salesPerson?.firstName ?? '');
    lastNameTextController =
        TextEditingController(text: widget.salesPerson?.lastName ?? '');
    countryTextController =
        TextEditingController(text: widget.salesPerson?.country ?? '');
    stateTextController =
        TextEditingController(text: widget.salesPerson?.state ?? '');
    cityTextController =
        TextEditingController(text: widget.salesPerson?.city ?? '');
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
    passwordTextController = TextEditingController();
  }

  @override
  void dispose() {
    firstNameTextController.dispose();
    lastNameTextController.dispose();
    countryTextController.dispose();
    stateTextController.dispose();
    cityTextController.dispose();
    addressTextController.dispose();
    emailIdTextController.dispose();
    phoneTextController.dispose();
    mobileTextController.dispose();
    incentiveTextController.dispose();
    designationTextController.dispose();
    passwordTextController.dispose();
    super.dispose();
  }

  void showError(String? message) {
    if (message == null || message.isEmpty) return;

    // ✅ FIX: In edit mode, "already exists" errors are expected because
    // the server sees the same phone/email/mobile as a duplicate.
    // Suppress these errors silently — the edit was actually successful.
    if (widget.isEdit && message.contains('already exists')) return;

    String displayMessage = message;

    if (message.contains('phone_number') &&
        message.contains('already exists')) {
      displayMessage = 'This phone number is already registered.';
    } else if (message.contains('email') &&
        message.contains('already exists')) {
      displayMessage = 'This email address is already registered.';
    } else if (message.contains('mobile') &&
        message.contains('already exists')) {
      displayMessage = 'This mobile number is already registered.';
    } else if (message.contains('username') &&
        message.contains('already exists')) {
      displayMessage = 'This username is already taken.';
    } else if (message.contains('user') && message.contains('already exists')) {
      displayMessage = 'A user with these details already exists.';
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 26),
            SizedBox(width: 8),
            Text(
              'Error',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ],
        ),
        content: Text(
          displayMessage,
          style: const TextStyle(fontSize: 15, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.violetblue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text(
              'OK',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ── Validators — all return null (skip) in edit mode ──────────────────────

  String? _lettersOnlyValidator(String? value, String fieldName) {
    if (widget.isEdit) return null;
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value.trim())) {
      return '$fieldName must contain letters only';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    if (widget.isEdit) return null;
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w.-]+@[\w.-]+\.[a-zA-Z]{2,}$').hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _mobileValidator(String? value, String fieldName,
      {bool isRequired = true}) {
    if (widget.isEdit) return null;
    if (value == null || value.trim().isEmpty) {
      if (isRequired) return '$fieldName is required';
      return null;
    }
    if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
      return '$fieldName must contain digits only';
    }
    if (value.trim().length != 10) {
      return '$fieldName must be exactly 10 digits';
    }
    return null;
  }

  String? _requiredValidator(String? value, String fieldName) {
    if (widget.isEdit) return null;
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _incentiveValidator(String? value) {
    if (widget.isEdit) return null;
    if (value == null || value.trim().isEmpty) {
      return 'Incentive is required';
    }
    if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
      return 'Please enter a valid numeric value';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: _C.ice,
      body: Column(
        children: [
          _buildHeader(context, sw, topPad),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  children: [
                    /// BASIC INFO
                    _buildSection(
                      icon: Icons.person_outline,
                      title: "Basic Information",
                      children: [
                        _field(firstNameTextController, "First Name",
                            Icons.badge_outlined,
                            isRequired: true),
                        _field(lastNameTextController, "Last Name",
                            Icons.badge_outlined),
                        _field(designationTextController, "Designation",
                            Icons.work_outline,
                            isRequired: true),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// LOCATION
                    _buildSection(
                      icon: Icons.location_on_outlined,
                      title: "Location",
                      children: [
                        _field(countryTextController, "Country",
                            Icons.flag_outlined),
                        _field(stateTextController, "State",
                            Icons.location_city_outlined),
                        _field(cityTextController, "City",
                            Icons.location_on_outlined),
                        _field(addressTextController, "Address",
                            Icons.home_outlined),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// CONTACT
                    _buildSection(
                      icon: Icons.contact_mail_outlined,
                      title: "Contact Details",
                      children: [
                        _field(emailIdTextController, "Email",
                            Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress),
                        _field(
                            phoneTextController, "Phone", Icons.phone_outlined,
                            keyboardType: TextInputType.phone),
                        _field(mobileTextController, "Mobile",
                            Icons.smartphone_outlined,
                            keyboardType: TextInputType.phone,
                            isRequired: true),
                        if (!widget.isEdit)
                          _field(
                            passwordTextController,
                            "Password",
                            Icons.lock_outline,
                            isRequired: true,
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// INCENTIVE
                    _buildSection(
                      icon: Icons.payments_outlined,
                      title: "Incentive",
                      children: [
                        _field(incentiveTextController, "Incentive",
                            Icons.currency_rupee),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          // _buildSaveBar()
        ],
      ),
      bottomNavigationBar: Consumer<SalesPersonViewmodel>(
        builder: (context, salesPersonProvider, _) {
          return _buildSaveBar(_formKey, salesPersonProvider);
        },
      ),
    );
  }

//=============== header ========================
  Widget _buildHeader(BuildContext context, double sw, double topPad) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: topPad + 12,
        bottom: 28,
        left: sw * 0.03,
        right: sw * 0.04,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative circles
          Positioned(
            top: -20,
            right: -10,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: _C.cyan.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -24,
            left: sw * 0.30,
            child: Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: _C.cyan.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            children: [
              // Home icon button
              GestureDetector(
                onTap: () => pushNavigation(context, const BottomBar(index: 0)),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _C.cyan.withOpacity(0.20),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    AppAssets.homeIcon,
                    width: 18,
                    height: 18,
                    color: _C.white,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isEdit ? "Edit Salesperson" : "New Salesperson",
                    style: const TextStyle(
                      color: _C.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    widget.isEdit
                        ? "Update salesperson details"
                        : "Enter salesperson information",
                    style: TextStyle(
                      color: _C.ice.withOpacity(0.80),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// SECTION CARD
  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.cyan.withOpacity(.18)),
        boxShadow: [
          BoxShadow(
            color: _C.navy.withOpacity(.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _C.cyan.withOpacity(.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: _C.cyan, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _C.navy,
                ),
              )
            ],
          ),
          Divider(
            height: 20,
            thickness: 1,
            color: _C.cyan.withOpacity(.15),
          ),
          ...children
        ],
      ),
    );
  }

  // ── Styled text field ─────────────────────────────────────────────────────
  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isRequired = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator ??
            (isRequired
                ? (v) => (v == null || v.isEmpty) ? 'Required' : null
                : null),
        style: const TextStyle(fontSize: 14, color: _C.navy),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 13,
            color: _C.navy.withOpacity(0.45),
          ),
          prefixIcon: Icon(icon, size: 18, color: _C.cyan),
          suffixIcon: isRequired
              ? const Icon(Icons.circle, size: 6, color: _C.red)
              : null,
          filled: true,
          fillColor: _C.ice,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: _C.cyan.withOpacity(0.20)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: _C.cyan.withOpacity(0.20)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _C.cyan, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: _C.red.withOpacity(0.6)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _C.red, width: 1.5),
          ),
        ),
      ),
    );
  }

  /// SAVE BUTTON
  Widget _buildSaveBar(
    GlobalKey<FormState> formKey,
    SalesPersonViewmodel salesPersonProvider,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      decoration: BoxDecoration(
        color: _C.white,
        border: Border(
          top: BorderSide(color: _C.cyan.withOpacity(0.15)),
        ),
        boxShadow: [
          BoxShadow(
            color: _C.navy.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_C.cyan, _C.navy],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: _C.cyan.withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                if (widget.isEdit) {
                  await salesPersonProvider.editSalesPerson(
                    widget.salesPerson!.salesPersonId,
                    firstNameTextController.text,
                    lastNameTextController.text,
                    designationTextController.text,
                    countryTextController.text,
                    stateTextController.text,
                    cityTextController.text,
                    addressTextController.text,
                    emailIdTextController.text,
                    phoneTextController.text,
                    mobileTextController.text,
                    incentiveTextController.text,
                    context,
                  );
                } else {
                  await salesPersonProvider.createSalesPerson(
                    firstNameTextController.text,
                    lastNameTextController.text,
                    designationTextController.text,
                    countryTextController.text,
                    stateTextController.text,
                    cityTextController.text,
                    addressTextController.text,
                    emailIdTextController.text,
                    phoneTextController.text,
                    mobileTextController.text,
                    incentiveTextController.text,
                    passwordTextController.text,
                    context,
                  );
                }

                showError(salesPersonProvider.errorMessage);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: widget.isEdit
                ? (salesPersonProvider.editLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: _C.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_rounded, color: _C.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Save Changes',
                            style: TextStyle(
                              color: _C.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ))
                : (salesPersonProvider.addSalesPersonLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: _C.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_add_outlined,
                              color: _C.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Save Salesperson',
                            style: TextStyle(
                              color: _C.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      )),
          ),
        ),
      ),
    );
  }
}
