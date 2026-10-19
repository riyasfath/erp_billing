// import 'package:flutter/material.dart';
// import 'package:pokakbilling/core/navigations.dart';
// import 'package:pokakbilling/core/themes/app_assets.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/models/data-models/addQuotation_model.dart';
// import 'package:pokakbilling/viewmodels/customer_viewmodel.dart';
// import 'package:pokakbilling/viewmodels/quotation/quotation_viewmodel.dart';
// import 'package:pokakbilling/viewmodels/setup/contract_viewmodel.dart';
// import 'package:pokakbilling/viewmodels/setup/terms&condition_viewmodel.dart';
// import 'package:pokakbilling/views/Screens/quotation/edit/edit_quotation_items.dart';
// import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';
// import 'package:pokakbilling/views/commonWidgets/buttons/colored_custom_button.dart';
// import 'package:pokakbilling/views/commonWidgets/buttons/exit_custom_button.dart';
// import 'package:pokakbilling/views/commonWidgets/textfields/custom_dropdown.dart';
// import 'package:pokakbilling/views/commonWidgets/textfields/custom_textfield.dart';
// import 'package:provider/provider.dart';

// class EditQuotation extends StatefulWidget {
//   final int quotationId;
//   const EditQuotation({super.key, required this.quotationId});

//   @override
//   State<EditQuotation> createState() => _EditQuotationState();
// }

// class _EditQuotationState extends State<EditQuotation> {
//   final formKey = GlobalKey<FormState>();
//   late TextEditingController quotationNumberController;
//   late TextEditingController quotationDateController;
//   late TextEditingController customerNameController;
//   late TextEditingController termsTextController;
//   late TextEditingController deliveryAddressTextController;
//   late TextEditingController deliveryLocationTextController;
//   late TextEditingController contractDetailsTextController;
//   late TextEditingController projectNameController;

//   @override
//   void initState() {
//     super.initState();
//     quotationNumberController = TextEditingController();
//     quotationDateController = TextEditingController();
//     customerNameController = TextEditingController();
//     termsTextController = TextEditingController();
//     deliveryAddressTextController = TextEditingController();
//     deliveryLocationTextController = TextEditingController();
//     contractDetailsTextController = TextEditingController();
//     projectNameController = TextEditingController();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       loadQuotationDetails();
//     });
//   }

//   Future<void> loadQuotationDetails() async {
//     final quotationProvider =
//         Provider.of<QuotationViewmodel>(context, listen: false);
//     quotationProvider.removeAll();

//     final items = quotationProvider.singleQuotationList;
//     if (items.isNotEmpty) {
//       final quotationItems = items[0];

//       quotationNumberController.text = quotationItems.quotationNumber;
//       quotationDateController.text = quotationItems.quotationDate;
//       customerNameController.text = quotationItems.clientName;
//       termsTextController.text = quotationItems.termsAndConditionsTitle;
//       deliveryAddressTextController.text = quotationItems.address;
//       deliveryLocationTextController.text = quotationItems.deliveryLocation;
//       contractDetailsTextController.text = quotationItems.contractTitle;
//       projectNameController.text = quotationItems.projectName;

//       quotationProvider.updateSalesPersonName(quotationItems.salespersonName);
//       quotationProvider.addGrandTotal(quotationItems.grandTotal.toString());
//       quotationProvider.updateClientId(quotationItems.clientId);
//       quotationProvider
//           .updateSelectedTermsId(quotationItems.termsAndConditionsId);
//       quotationProvider.updateContractId(quotationItems.contractId);

//       for (int i = 0; i < quotationItems.items.length; i++) {
//         final item = quotationItems.items[i];

//         quotationProvider.addEditItem(
//           AddQuotationModel(
//             itemNumber: i,
//             tabId: item.id,
//             productId: item.productId,
//             selectedProduct: item.name,
//             quantity: item.quantity.toString(),
//             unitPrice: item.unitPrice.toString(),
//             total: item.total.toString(),
//             cgst: item.cgstPercentage.toString(),
//             sgst: item.sgstPercentage.toString(),
//             subTotal: item.subTotal.toString(),
//           ),
//         );
//       }
//     }
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     quotationNumberController.dispose();
//     quotationDateController.dispose();
//     customerNameController.dispose();
//     termsTextController.dispose();
//     deliveryAddressTextController.dispose();
//     deliveryLocationTextController.dispose();
//     contractDetailsTextController.dispose();
//     projectNameController.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
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
//                       icon: Image.asset(AppAssets.homeIcon),
//                       onPressed: () {
//                         pushReplacementNavigation(
//                           context,
//                           const BottomBar(index: 0),
//                         );
//                       },
//                     ),
//                     title: Text(
//                       'Edit Quotation',
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
//             bottom: screenWidth * 0.04,
//             child: Container(
//               height: screenHeight - screenHeight * 0.18,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.only(bottom: 20),
//                 child: SingleChildScrollView(
//                   child: Form(
//                     key: formKey,
//                     child: Column(
//                       children: [
//                         Consumer<QuotationViewmodel>(
//                           builder: (context, quotationProvider, child) {
//                             return Card(
//                               elevation: 4,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: Padding(
//                                 padding: EdgeInsets.all(screenWidth * 0.03),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     CustomTextfield(
//                                       label: "Quotation Number",
//                                       hintText: "",
//                                       screenWidth: screenWidth * 0.045,
//                                       textController: quotationNumberController,
//                                       isMandatory: false,
//                                       isEnabled: false,
//                                     ),
//                                     SizedBox(height: screenHeight * 0.015),
//                                     CustomTextfield(
//                                       label: "Quotation Date",
//                                       hintText: "",
//                                       screenWidth: 5,
//                                       textController: quotationDateController,
//                                       isMandatory: false,
//                                       isEnabled: true,
//                                     ),
//                                     SizedBox(height: screenHeight * 0.02),
//                                     Consumer2<CustomerViewmodel,
//                                         QuotationViewmodel>(
//                                       builder: (context, provider,
//                                           quotationProvider, child) {
//                                         // 👇 Combine first and last name for each customer
//                                         final dropdownItems = provider
//                                             .customerList
//                                             .map((c) =>
//                                                 "${c.firstName} ${c.lastName}")
//                                             .toSet()
//                                             .toList();

//                                         final selectedValue =
//                                             dropdownItems.contains(
//                                                     customerNameController.text)
//                                                 ? customerNameController.text
//                                                 : null;

//                                         return CustomDropdown(
//                                           selectedValue: selectedValue,
//                                           hint: "Client Name",
//                                           dropdownItems: dropdownItems,
//                                           onChanged: (String? newValue) async {
//                                             if (newValue != null) {
//                                               // 👇 Extract both first and last name
//                                               newValue.split(" ");
//                                               final selectedCustomer = provider
//                                                   .customerList
//                                                   .firstWhere(
//                                                 (c) =>
//                                                     "${c.firstName} ${c.lastName}" ==
//                                                     newValue,
//                                               );

//                                               await provider.getCustomerById(
//                                                   selectedCustomer.customerId);

//                                               final customer = provider
//                                                       .singleCustomerList
//                                                       .isNotEmpty
//                                                   ? provider
//                                                       .singleCustomerList[0]
//                                                   : null;

//                                               if (customer != null) {
//                                                 quotationProvider
//                                                     .updateSalesPersonId(
//                                                         customer.salesPersonId);
//                                                 quotationProvider
//                                                     .updateSalesPersonName(
//                                                         customer
//                                                             .salesPersonName);
//                                               }

//                                               quotationProvider.updateClientId(
//                                                   selectedCustomer.customerId);
//                                               quotationProvider.updateClientName(
//                                                   "${selectedCustomer.firstName} ${selectedCustomer.lastName}");
//                                               customerNameController.text =
//                                                   "${selectedCustomer.firstName} ${selectedCustomer.lastName}";
//                                             }
//                                           },
//                                         );
//                                       },
//                                     ),
//                                     SizedBox(height: screenHeight * 0.02),
//                                     CustomTextfield(
//                                       label: "Project Name",
//                                       hintText: "",
//                                       screenWidth: 5,
//                                       textController: projectNameController,
//                                       isMandatory: false,
//                                       isEnabled: true,
//                                     ),
//                                     SizedBox(height: screenHeight * 0.02),
//                                     const Text(
//                                       "Product",
//                                       style: TextStyle(
//                                         color: AppColors.violetblue,
//                                         fontSize: 17,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 5),
//                                     Consumer<QuotationViewmodel>(
//                                         builder: (context, provider, child) {
//                                       return Column(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: List.generate(
//                                           provider.singleQuotationList[0].items
//                                               .length,
//                                           (index) => Padding(
//                                             padding: const EdgeInsets.only(
//                                                 bottom: 8),
//                                             child: EditQuotationItems(
//                                               itemNumber: index,
//                                               quotationId: widget.quotationId,
//                                             ),
//                                           ),
//                                         ),
//                                       );
//                                     }),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                         const SizedBox(height: 15),
//                         Card(
//                           elevation: 4,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: SizedBox(
//                             width: double.infinity,
//                             child: Padding(
//                               padding: const EdgeInsets.all(10),
//                               child: Align(
//                                 alignment: Alignment.centerRight,
//                                 child: Column(
//                                   children: [
//                                     const Text(
//                                       "Grand Total Amount",
//                                       style: TextStyle(
//                                         color: AppColors.violetblue,
//                                         fontSize: 13,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 5),
//                                     SizedBox(
//                                       height: 30,
//                                       width: 120,
//                                       child: Consumer<QuotationViewmodel>(
//                                           builder: (context, provider, child) {
//                                         return TextFormField(
//                                           enabled: false,
//                                           controller: TextEditingController(
//                                               text: provider.grandTotal),
//                                           onChanged: (value) {},
//                                           textAlign: TextAlign.center,
//                                           style: const TextStyle(
//                                               fontSize: 12,
//                                               color: AppColors.black),
//                                           decoration: const InputDecoration(
//                                             contentPadding:
//                                                 EdgeInsets.symmetric(
//                                               vertical: 5,
//                                               horizontal: 10,
//                                             ),
//                                             isDense: true,
//                                             border: OutlineInputBorder(
//                                               borderSide: BorderSide(
//                                                   color:
//                                                       AppColors.textfieldGrey),
//                                             ),
//                                             disabledBorder: OutlineInputBorder(
//                                               borderSide: BorderSide(
//                                                   color: AppColors.grey),
//                                             ),
//                                           ),
//                                         );
//                                       }),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 15),
//                         Card(
//                           elevation: 4,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.all(15),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text(
//                                   "Terms and Conditions",
//                                   style: TextStyle(
//                                     fontSize: 15,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 Consumer2<TermsViewmodel, QuotationViewmodel>(
//                                   builder: (context, provider,
//                                       quotationProvider, child) {
//                                     return CustomDropdown(
//                                       selectedValue: provider.termsTitleList
//                                               .any((c) =>
//                                                   c.title ==
//                                                   termsTextController.text)
//                                           ? termsTextController.text
//                                           : null,
//                                       hint: "Select Terms and Condition",
//                                       dropdownItems: provider.termsTitleList
//                                           .map((c) => c.title)
//                                           .toSet()
//                                           .toList(),
//                                       onChanged: (String? newValue) {
//                                         if (newValue != null) {
//                                           String selectedName =
//                                               newValue.split(" (")[0];
//                                           var selectedSalesPerson = provider
//                                               .termsTitleList
//                                               .firstWhere(
//                                             (c) => c.title == selectedName,
//                                           );

//                                           quotationProvider
//                                               .updateSelectedTermsId(
//                                             selectedSalesPerson.titleId,
//                                           );
//                                           quotationProvider.selectTermsTitle(
//                                               selectedSalesPerson.title);
//                                           termsTextController.text =
//                                               selectedSalesPerson.title
//                                                   .toString();
//                                         }
//                                       },
//                                     );
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 15),
//                         Card(
//                           elevation: 4,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.all(15),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text(
//                                   "Address",
//                                   style: TextStyle(
//                                     fontSize: 15,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 CustomTextfield(
//                                   label: "Delivery Address",
//                                   hintText: "",
//                                   screenWidth: 5,
//                                   textController: deliveryAddressTextController,
//                                   isMandatory: false,
//                                   isValidationRequired: true,
//                                 ),
//                                 CustomTextfield(
//                                   label: "Delivery Location",
//                                   hintText: "",
//                                   screenWidth: 5,
//                                   textController:
//                                       deliveryLocationTextController,
//                                   isMandatory: false,
//                                   isValidationRequired: true,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 15),
//                         Card(
//                           elevation: 4,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.all(15),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     const Text(
//                                       "Sales Person",
//                                       style: TextStyle(
//                                         color: AppColors.violetblue,
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Consumer<QuotationViewmodel>(
//                                       builder: (context, provider, child) {
//                                         return Container(
//                                           width: double.infinity,
//                                           padding:
//                                               const EdgeInsets.only(bottom: 6),
//                                           decoration: const BoxDecoration(
//                                             border: Border(
//                                               bottom: BorderSide(
//                                                 color: AppColors.grey,
//                                                 width: 1.5,
//                                               ),
//                                             ),
//                                           ),
//                                           child: Text(
//                                             provider.selectedSalesPersonName,
//                                             style: const TextStyle(
//                                               fontSize: 14,
//                                               color: Colors.black,
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 10),
//                                 Consumer2<ContractViewmodel,
//                                     QuotationViewmodel>(
//                                   builder: (context, provider,
//                                       quotationProvider, child) {
//                                     return CustomDropdown(
//                                       selectedValue: provider
//                                               .contractHeadingList
//                                               .any((c) =>
//                                                   c.contractHeading ==
//                                                   contractDetailsTextController
//                                                       .text)
//                                           ? contractDetailsTextController.text
//                                           : null,
//                                       hint: "Select Contract Details",
//                                       dropdownItems: provider
//                                           .contractHeadingList
//                                           .map((c) => c.contractHeading)
//                                           .toSet()
//                                           .toList(),
//                                       onChanged: (String? newValue) {
//                                         if (newValue != null) {
//                                           String selectedName =
//                                               newValue.split(" (")[0];
//                                           var selectedContractDetails = provider
//                                               .contractHeadingList
//                                               .firstWhere(
//                                             (c) =>
//                                                 c.contractHeading ==
//                                                 selectedName,
//                                           );

//                                           quotationProvider.updateContractId(
//                                             selectedContractDetails.contractId,
//                                           );
//                                           quotationProvider.updateContractName(
//                                               selectedContractDetails
//                                                   .contractHeading);
//                                           termsTextController.text =
//                                               selectedContractDetails
//                                                   .contractHeading
//                                                   .toString();
//                                         }
//                                       },
//                                     );
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         Consumer2<QuotationViewmodel, TermsViewmodel>(
//                           builder: (context, quotationProvider, termsQuotation,
//                               child) {
//                             return ColoredCustomButton(
//                               text: "Save",
//                               onPressed: () {
//                                 quotationProvider.editQuotation(
//                                   widget.quotationId,
//                                   quotationNumberController.text,
//                                   quotationDateController.text,
//                                   quotationProvider.selectedClientId,
//                                   quotationProvider.selectedTermsId,
//                                   deliveryAddressTextController.text,
//                                   deliveryLocationTextController.text,
//                                   quotationProvider.selectedContractId,
//                                   projectNameController.text,
//                                   context,
//                                 );
//                               },
//                               loading: quotationProvider.editLoading,
//                               formKey: formKey,
//                             );
//                           },
//                         ),
//                         const SizedBox(height: 15),
//                         const ExitCustomButton(text: "Exit")
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/models/data-models/addQuotation_model.dart';
import 'package:pokakbilling/viewmodels/customer_viewmodel.dart';
import 'package:pokakbilling/viewmodels/quotation/quotation_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/contract_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/terms&condition_viewmodel.dart';
import 'package:pokakbilling/views/Screens/quotation/edit/edit_quotation_items.dart';
import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/colored_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/exit_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_dropdown.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_textfield.dart';
import 'package:provider/provider.dart';

class EditQuotation extends StatefulWidget {
  final int quotationId;
  const EditQuotation({super.key, required this.quotationId});

  @override
  State<EditQuotation> createState() => _EditQuotationState();
}

class _EditQuotationState extends State<EditQuotation>
    with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();

  late TextEditingController quotationNumberController;
  late TextEditingController quotationDateController;
  late TextEditingController customerNameController;
  late TextEditingController termsTextController;
  late TextEditingController deliveryAddressTextController;
  late TextEditingController deliveryLocationTextController;
  late TextEditingController contractDetailsTextController;
  late TextEditingController projectNameController;

  late AnimationController _entryCtrl;
  late Animation<double> _fadeA;
  late Animation<Offset> _slideA;

  // ── Theme-aware getters — identical to ProductScreen ──────────────────────
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _bg => Theme.of(context).scaffoldBackgroundColor;
  Color get _fg => _isDark ? Colors.white : const Color(0xFF1E1B4B);
  Color get _fgMuted => _isDark
      ? Colors.white.withValues(alpha: 0.55)
      : const Color(0xFF1E1B4B).withValues(alpha: 0.5);
  Color get _cardBg => _isDark ? Colors.white.withValues(alpha: 0.07) : Colors.white;
  Color get _cardBorder => _isDark
      ? Colors.white.withValues(alpha: 0.12)
      : const Color(0xFF6366F1).withValues(alpha: 0.15);
  Color get _iconBg => _isDark
      ? Colors.white.withValues(alpha: 0.12)
      : const Color(0xFF6366F1).withValues(alpha: 0.10);
  Color get _iconColor => _isDark ? Colors.white : const Color(0xFF4338CA);
  Color get _divider => _isDark
      ? Colors.white.withValues(alpha: 0.08)
      : const Color(0xFF6366F1).withValues(alpha: 0.08);
  Color get _sectionTitleColor =>
      _isDark ? Colors.white.withValues(alpha: 0.85) : const Color(0xFF6366F1);
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    quotationNumberController = TextEditingController();
    quotationDateController = TextEditingController();
    customerNameController = TextEditingController();
    termsTextController = TextEditingController();
    deliveryAddressTextController = TextEditingController();
    deliveryLocationTextController = TextEditingController();
    contractDetailsTextController = TextEditingController();
    projectNameController = TextEditingController();

    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeA = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideA = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));
    _entryCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadQuotationDetails();
    });
  }

  Future<void> loadQuotationDetails() async {
    final quotationProvider =
        Provider.of<QuotationViewmodel>(context, listen: false);
    quotationProvider.removeAll();

    final items = quotationProvider.singleQuotationList;
    if (items.isNotEmpty) {
      final quotationItems = items[0];

      quotationNumberController.text = quotationItems.quotationNumber;
      quotationDateController.text = quotationItems.quotationDate;
      customerNameController.text = quotationItems.clientName;
      termsTextController.text = quotationItems.termsAndConditionsTitle;
      deliveryAddressTextController.text = quotationItems.address;
      deliveryLocationTextController.text = quotationItems.deliveryLocation;
      contractDetailsTextController.text = quotationItems.contractTitle;
      projectNameController.text = quotationItems.projectName;

      quotationProvider.updateSalesPersonName(quotationItems.salespersonName);
      quotationProvider.addGrandTotal(quotationItems.grandTotal.toString());
      quotationProvider.updateClientId(quotationItems.clientId);
      quotationProvider
          .updateSelectedTermsId(quotationItems.termsAndConditionsId);
      quotationProvider.updateContractId(quotationItems.contractId);

      for (int i = 0; i < quotationItems.items.length; i++) {
        final item = quotationItems.items[i];
        quotationProvider.addEditItem(
          AddQuotationModel(
            itemNumber: i,
            tabId: item.id,
            productId: item.productId,
            selectedProduct: item.name,
            quantity: item.quantity.toString(),
            unitPrice: item.unitPrice.toString(),
            total: item.total.toString(),
            cgst: item.cgstPercentage.toString(),
            sgst: item.sgstPercentage.toString(),
            subTotal: item.subTotal.toString(),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    quotationNumberController.dispose();
    quotationDateController.dispose();
    customerNameController.dispose();
    termsTextController.dispose();
    deliveryAddressTextController.dispose();
    deliveryLocationTextController.dispose();
    contractDetailsTextController.dispose();
    projectNameController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: FadeTransition(
          opacity: _fadeA,
          child: SlideTransition(
            position: _slideA,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(),
                Divider(color: _divider, height: 1, thickness: 0.5),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 40),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Basic Info Card ──────────────────────────
                          _sectionCard(
                            label: 'Quotation Info',
                            icon: Icons.receipt_long_outlined,
                            child: Consumer<QuotationViewmodel>(
                              builder: (context, quotationProvider, child) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomTextfield(
                                      label: "Quotation Number",
                                      hintText: "",
                                      screenWidth: 14,
                                      textController: quotationNumberController,
                                      isMandatory: false,
                                      isEnabled: false,
                                    ),
                                    const SizedBox(height: 14),
                                    CustomTextfield(
                                      label: "Quotation Date",
                                      hintText: "",
                                      screenWidth: 14,
                                      textController: quotationDateController,
                                      isMandatory: false,
                                      isEnabled: true,
                                    ),
                                    const SizedBox(height: 14),
                                    Consumer2<CustomerViewmodel,
                                        QuotationViewmodel>(
                                      builder: (context, provider,
                                          quotationProvider, child) {
                                        final dropdownItems = provider
                                            .customerList
                                            .map((c) =>
                                                "${c.firstName} ${c.lastName}")
                                            .toSet()
                                            .toList();
                                        final selectedValue =
                                            dropdownItems.contains(
                                                    customerNameController.text)
                                                ? customerNameController.text
                                                : null;
                                        return CustomDropdown(
                                          selectedValue: selectedValue,
                                          hint: "Client Name",
                                          dropdownItems: dropdownItems,
                                          onChanged: (String? newValue) async {
                                            if (newValue != null) {
                                              newValue.split(" ");
                                              final selectedCustomer = provider
                                                  .customerList
                                                  .firstWhere(
                                                (c) =>
                                                    "${c.firstName} ${c.lastName}" ==
                                                    newValue,
                                              );
                                              await provider.getCustomerById(
                                                  selectedCustomer.customerId);
                                              final customer = provider
                                                      .singleCustomerList
                                                      .isNotEmpty
                                                  ? provider
                                                      .singleCustomerList[0]
                                                  : null;
                                              if (customer != null) {
                                                quotationProvider
                                                    .updateSalesPersonId(
                                                        customer.salesPersonId);
                                                quotationProvider
                                                    .updateSalesPersonName(
                                                        customer
                                                            .salesPersonName);
                                              }
                                              quotationProvider.updateClientId(
                                                  selectedCustomer.customerId);
                                              quotationProvider.updateClientName(
                                                  "${selectedCustomer.firstName} ${selectedCustomer.lastName}");
                                              customerNameController.text =
                                                  "${selectedCustomer.firstName} ${selectedCustomer.lastName}";
                                            }
                                          },
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 14),
                                    CustomTextfield(
                                      label: "Project Name",
                                      hintText: "",
                                      screenWidth: 14,
                                      textController: projectNameController,
                                      isMandatory: false,
                                      isEnabled: true,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 14),

                          // ── Products Card ────────────────────────────
                          _sectionCard(
                            label: 'Products',
                            icon: Icons.inventory_2_outlined,
                            child: Consumer<QuotationViewmodel>(
                              builder: (context, provider, child) {
                                if (provider.singleQuotationList.isEmpty) {
                                  return const SizedBox();
                                }
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(
                                    provider
                                        .singleQuotationList[0].items.length,
                                    (index) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: EditQuotationItems(
                                        itemNumber: index,
                                        quotationId: widget.quotationId,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 14),

                          // ── Grand Total Card ─────────────────────────
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                            decoration: BoxDecoration(
                              color: _isDark
                                  ? const Color(0xFF6366F1).withValues(alpha: 0.18)
                                  : const Color(0xFF6366F1).withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6366F1)
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.summarize_outlined,
                                        size: 16, color: Color(0xFF6366F1)),
                                  ),
                                  const SizedBox(width: 12),
                                  Text('Grand Total',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: _fg)),
                                ]),
                                Consumer<QuotationViewmodel>(
                                  builder: (context, provider, child) => Text(
                                    '₹ ${provider.grandTotal}',
                                    style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF6366F1)),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // ── Terms & Conditions Card ──────────────────
                          _sectionCard(
                            label: 'Terms & Conditions',
                            icon: Icons.gavel_outlined,
                            child:
                                Consumer2<TermsViewmodel, QuotationViewmodel>(
                              builder: (context, provider, quotationProvider,
                                  child) {
                                return CustomDropdown(
                                  selectedValue: provider.termsTitleList.any(
                                          (c) =>
                                              c.title ==
                                              termsTextController.text)
                                      ? termsTextController.text
                                      : null,
                                  hint: "Select Terms and Condition",
                                  dropdownItems: provider.termsTitleList
                                      .map((c) => c.title)
                                      .toSet()
                                      .toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      String selectedName =
                                          newValue.split(" (")[0];
                                      var selectedSalesPerson =
                                          provider.termsTitleList.firstWhere(
                                        (c) => c.title == selectedName,
                                      );
                                      quotationProvider.updateSelectedTermsId(
                                        selectedSalesPerson.titleId,
                                      );
                                      quotationProvider.selectTermsTitle(
                                          selectedSalesPerson.title);
                                      termsTextController.text =
                                          selectedSalesPerson.title.toString();
                                    }
                                  },
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 14),

                          // ── Address Card ─────────────────────────────
                          _sectionCard(
                            label: 'Address',
                            icon: Icons.location_on_outlined,
                            child: Column(
                              children: [
                                CustomTextfield(
                                  label: "Delivery Address",
                                  hintText: "",
                                  screenWidth: 14,
                                  textController: deliveryAddressTextController,
                                  isMandatory: false,
                                  isValidationRequired: true,
                                ),
                                const SizedBox(height: 12),
                                CustomTextfield(
                                  label: "Delivery Location",
                                  hintText: "",
                                  screenWidth: 14,
                                  textController:
                                      deliveryLocationTextController,
                                  isMandatory: false,
                                  isValidationRequired: true,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // ── Sales Person + Contract Card ──────────────
                          _sectionCard(
                            label: 'Sales & Contract',
                            icon: Icons.handshake_outlined,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Sales person display
                                Text(
                                  'Sales Person',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _fgMuted,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Consumer<QuotationViewmodel>(
                                  builder: (context, provider, child) {
                                    return Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _isDark
                                            ? Colors.white.withValues(alpha: 0.05)
                                            : const Color(0xFF6366F1)
                                                .withValues(alpha: 0.04),
                                        borderRadius: BorderRadius.circular(9),
                                        border: Border.all(
                                            color: _cardBorder, width: 0.8),
                                      ),
                                      child: Text(
                                        provider.selectedSalesPersonName
                                                .isNotEmpty
                                            ? provider.selectedSalesPersonName
                                            : '—',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: _fg),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 14),
                                Divider(
                                    color: _divider, height: 1, thickness: 0.5),
                                const SizedBox(height: 14),
                                // Contract dropdown
                                Consumer2<ContractViewmodel,
                                    QuotationViewmodel>(
                                  builder: (context, provider,
                                      quotationProvider, child) {
                                    return CustomDropdown(
                                      selectedValue: provider
                                              .contractHeadingList
                                              .any((c) =>
                                                  c.contractHeading ==
                                                  contractDetailsTextController
                                                      .text)
                                          ? contractDetailsTextController.text
                                          : null,
                                      hint: "Select Contract Details",
                                      dropdownItems: provider
                                          .contractHeadingList
                                          .map((c) => c.contractHeading)
                                          .toSet()
                                          .toList(),
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          String selectedName =
                                              newValue.split(" (")[0];
                                          var selectedContractDetails = provider
                                              .contractHeadingList
                                              .firstWhere(
                                            (c) =>
                                                c.contractHeading ==
                                                selectedName,
                                          );
                                          quotationProvider.updateContractId(
                                            selectedContractDetails.contractId,
                                          );
                                          quotationProvider.updateContractName(
                                              selectedContractDetails
                                                  .contractHeading);
                                          contractDetailsTextController.text =
                                              selectedContractDetails
                                                  .contractHeading
                                                  .toString();
                                        }
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ── Save button ──────────────────────────────
                          Consumer2<QuotationViewmodel, TermsViewmodel>(
                            builder: (context, quotationProvider,
                                termsQuotation, child) {
                              return ColoredCustomButton(
                                text: "Save",
                                onPressed: () {
                                  quotationProvider.editQuotation(
                                    widget.quotationId,
                                    quotationNumberController.text,
                                    quotationDateController.text,
                                    quotationProvider.selectedClientId,
                                    quotationProvider.selectedTermsId,
                                    deliveryAddressTextController.text,
                                    deliveryLocationTextController.text,
                                    quotationProvider.selectedContractId,
                                    projectNameController.text,
                                    context,
                                  );
                                },
                                loading: quotationProvider.editLoading,
                                formKey: formKey,
                              );
                            },
                          ),

                          const SizedBox(height: 12),
                          const ExitCustomButton(text: "Exit"),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── APP BAR ───────────────────────────────────────────────────────────────
  Widget _buildAppBar() => Container(
        color: _bg,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(children: [
          GestureDetector(
            onTap: () => pushReplacementNavigation(
              context,
              const ErpBottomBar(index: 0),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: _iconBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.home_outlined, color: _iconColor, size: 16),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Edit Quotation',
                  style: TextStyle(
                      color: _fg, fontSize: 16, fontWeight: FontWeight.w800)),
              Text('Update quotation details',
                  style: TextStyle(color: _fgMuted, fontSize: 10.5)),
            ],
          ),
        ]),
      );

  // ── SECTION CARD ──────────────────────────────────────────────────────────
  Widget _sectionCard({
    required String label,
    required IconData icon,
    required Widget child,
  }) =>
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _cardBorder, width: 1),
          boxShadow: _isDark
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Accent strip
            Container(
              height: 3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              ),
            ),
            // Section header
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Row(children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 14, color: _iconColor),
                ),
                const SizedBox(width: 10),
                Text(label,
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700, color: _fg)),
              ]),
            ),
            Divider(
              color: _divider,
              height: 18,
              thickness: 0.5,
              indent: 14,
              endIndent: 14,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: child,
            ),
          ],
        ),
      );
}
