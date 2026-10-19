import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/core/themes/app_assets.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/purchase_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/terms&condition_viewmodel.dart';
import 'package:pokakbilling/viewmodels/supplier_viewmodel.dart';
import 'package:pokakbilling/views/Screens/purchase/add/single_purchase_card.dart';
import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/colored_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/exit_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_dropdown.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_textfield.dart';
import 'package:provider/provider.dart';

class AddPurchase extends StatefulWidget {
  final String purchaseOrderNumber;
  const AddPurchase({super.key, required this.purchaseOrderNumber});

  @override
  State<AddPurchase> createState() => _AddPurchaseState();
}

class _AddPurchaseState extends State<AddPurchase> {
  late TextEditingController purchaseNumbercontroller;
  late TextEditingController purchaseDateController;
  late TextEditingController supplierController;
  late TextEditingController contactPersonNameController;
  late TextEditingController contactPersonNumberController;
  late TextEditingController remarkController;
  late TextEditingController termsandConditionController;
  late TextEditingController quotationNumberController;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    purchaseNumbercontroller =
        TextEditingController(text: widget.purchaseOrderNumber);
    purchaseDateController = TextEditingController();
    supplierController = TextEditingController();
    contactPersonNameController = TextEditingController();
    contactPersonNumberController = TextEditingController();
    remarkController = TextEditingController();
    termsandConditionController = TextEditingController();
    quotationNumberController = TextEditingController();

    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    purchaseDateController.text = formattedDate;
  }

  @override
  void dispose() {
    purchaseNumbercontroller.dispose();
    purchaseDateController.dispose();
    supplierController.dispose();
    contactPersonNameController.dispose();
    contactPersonNumberController.dispose();
    remarkController.dispose();
    termsandConditionController.dispose();
    quotationNumberController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: screenHeight * 0.18,
                decoration: const BoxDecoration(
                  color: AppColors.violetblue,
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: screenWidth * 0.02,
                    right: screenWidth * 0.03,
                  ),
                  child: AppBar(
                    leading: IconButton(
                      icon: Image.asset(AppAssets.homeIcon),
                      onPressed: () {
                        pushNavigation(context, const ErpBottomBar(index: 0));
                      },
                    ),
                    title: Text(
                      'New Purchase',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: screenWidth * 0.05,
                      ),
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: screenHeight * 0.15,
            left: screenWidth * 0.04,
            right: screenWidth * 0.04,
            bottom: screenWidth * 0.04,
            child: Container(
              height: screenHeight - screenHeight * 0.18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(screenWidth * 0.03),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomTextfield(
                                        label: "Purchase Number",
                                        hintText: "",
                                        screenWidth: 5,
                                        textController:
                                            purchaseNumbercontroller,
                                        isMandatory: false,
                                        isEnabled: false,
                                        isValidationRequired: true,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: CustomTextfield(
                                        label: "Purchase Date",
                                        hintText: "",
                                        screenWidth: 5,
                                        textController: purchaseDateController,
                                        isMandatory: false,
                                        isEnabled: true,
                                        isValidationRequired: true,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Consumer2<SupplierViewmodel, PurchaseViewmodel>(
                                  builder: (context, provider, purchaseProvider,
                                      child) {
                                    final dropdownItems = provider.supplierList
                                        .map((c) =>
                                            "${c.firstName} ${c.lastName}")
                                        .toSet()
                                        .toList();

                                    final selectedValue = dropdownItems
                                            .contains(supplierController.text)
                                        ? supplierController.text
                                        : null;

                                    return CustomDropdown(
                                      selectedValue: selectedValue,
                                      hint: "Supplier Name",
                                      dropdownItems: dropdownItems,
                                      onChanged: (String? newValue) async {
                                        if (newValue != null) {
                                          final selectedSupplier =
                                              provider.supplierList.firstWhere(
                                            (c) =>
                                                "${c.firstName} ${c.lastName}" ==
                                                newValue,
                                          );

                                          purchaseProvider.updateSupplierId(
                                              selectedSupplier.supplierId);
                                          purchaseProvider.updateSuppliertName(
                                            "${selectedSupplier.firstName} ${selectedSupplier.lastName}",
                                          );
                                          supplierController.text =
                                              "${selectedSupplier.firstName} ${selectedSupplier.lastName}";
                                        }
                                      },
                                    );
                                  },
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                Consumer<PurchaseViewmodel>(
                                  builder: (context, purchaseProvider, _) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              "Add Product",
                                              style: TextStyle(
                                                color: AppColors.violetblue,
                                                fontSize: 17,
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                WidgetsBinding.instance
                                                    .addPostFrameCallback((_) {
                                                  purchaseProvider.addItem();
                                                });
                                              },
                                              child: Image.asset(
                                                AppAssets.addProductIcon,
                                                color: AppColors.black,
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: purchaseProvider.itemList
                                              .map(
                                                (item) => PurchaseOrderItems(
                                                    itemNumber:
                                                        item.itemNumber),
                                              )
                                              .toList(),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Column(
                                  children: [
                                    const Text(
                                      "Grand Total Amount",
                                      style: TextStyle(
                                        color: AppColors.violetblue,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    SizedBox(
                                      height: 30,
                                      width: 120,
                                      child: Consumer<PurchaseViewmodel>(
                                        builder: (context, provider, child) {
                                          return TextFormField(
                                            enabled: false,
                                            controller: TextEditingController(
                                                text: provider.grandTotal),
                                            onChanged: (value) {},
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.black,
                                            ),
                                            decoration: const InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                vertical: 5,
                                                horizontal: 10,
                                              ),
                                              isDense: true,
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color:
                                                      AppColors.textfieldGrey,
                                                ),
                                              ),
                                              disabledBorder:
                                                  OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: AppColors.grey),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(screenWidth * 0.03),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: screenHeight * 0.02),
                                CustomTextfield(
                                  label: "Quotation Number",
                                  hintText: "Quotation Number",
                                  screenWidth: screenWidth * 0.045,
                                  textController: quotationNumberController,
                                  isMandatory: false,
                                  isValidationRequired: true,
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                CustomTextfield(
                                  label: "Contact Person Name",
                                  hintText: "Name",
                                  screenWidth: screenWidth * 0.045,
                                  textController: contactPersonNameController,
                                  isMandatory: false,
                                  isValidationRequired: true,
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                CustomTextfield(
                                  label: "Contact Person Number",
                                  hintText: "Number",
                                  screenWidth: screenWidth * 0.045,
                                  textController: contactPersonNumberController,
                                  isMandatory: false,
                                  isValidationRequired: true,
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                CustomTextfield(
                                  label: "Remark",
                                  hintText: "remark",
                                  screenWidth: screenWidth * 0.045,
                                  textController: remarkController,
                                  isMandatory: false,
                                  isValidationRequired: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(screenWidth * 0.03),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: screenHeight * 0.02),
                                Consumer2<TermsViewmodel, PurchaseViewmodel>(
                                  builder: (context, provider, purchaseProvider,
                                      child) {
                                    return CustomDropdown(
                                      selectedValue: provider.termsTitleList
                                              .any((c) =>
                                                  c.title ==
                                                  termsandConditionController
                                                      .text)
                                          ? termsandConditionController.text
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
                                          var selectedTermsCondition = provider
                                              .termsTitleList
                                              .firstWhere(
                                            (c) => c.title == selectedName,
                                          );

                                          purchaseProvider.updateTermsId(
                                            selectedTermsCondition.titleId,
                                          );

                                          termsandConditionController.text =
                                              selectedTermsCondition.title
                                                  .toString();
                                        }
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.05),
                        Consumer<PurchaseViewmodel>(
                          builder: (context, provider, child) {
                            return ColoredCustomButton(
                              text: "Save",
                              onPressed: () {
                                double updatedGrandTotal =
                                    double.parse(provider.grandTotal);
                                provider.createPurchaseOrder(
                                  purchaseNumbercontroller.text,
                                  purchaseDateController.text,
                                  provider.selectedSupplierId,
                                  quotationNumberController.text,
                                  contactPersonNameController.text,
                                  contactPersonNumberController.text,
                                  updatedGrandTotal,
                                  remarkController.text,
                                  provider.selectedTermsId,
                                  context,
                                );
                              },
                              loading: provider.addPurchaseOrderLoader,
                              formKey: formKey,
                            );
                          },
                        ),
                        SizedBox(
                          height: screenHeight * 0.02,
                        ),
                        const ExitCustomButton(text: "Exit"),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
