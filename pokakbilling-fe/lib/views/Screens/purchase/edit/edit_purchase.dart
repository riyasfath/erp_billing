import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/core/themes/app_assets.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/addQuotation_model.dart';
import 'package:pokakbilling/viewmodels/purchase_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/terms&condition_viewmodel.dart';
import 'package:pokakbilling/viewmodels/supplier_viewmodel.dart';
import 'package:pokakbilling/views/Screens/purchase/edit/edit_purchase_items.dart';
import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/colored_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/exit_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_dropdown.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_textfield.dart';
import 'package:provider/provider.dart';

class EditPurchase extends StatefulWidget {
  final int purchaseOrderId;
  const EditPurchase({super.key, required this.purchaseOrderId});

  @override
  State<EditPurchase> createState() => _EditPurchaseState();
}

class _EditPurchaseState extends State<EditPurchase> {
  late TextEditingController purchaseNumbercontroller;
  late TextEditingController purchaseDateController;
  late TextEditingController supplierController;
  late TextEditingController quotationNumberController;
  late TextEditingController contactPersonNameController;
  late TextEditingController contactPersonNumberController;
  late TextEditingController remarkController;
  late TextEditingController termsandConditionController;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    purchaseNumbercontroller = TextEditingController();
    purchaseDateController = TextEditingController();
    supplierController = TextEditingController();
    quotationNumberController = TextEditingController();
    contactPersonNameController = TextEditingController();
    contactPersonNumberController = TextEditingController();
    remarkController = TextEditingController();
    termsandConditionController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadPurchaseDetails();
    });
  }

  Future<void> loadPurchaseDetails() async {
    final purchaseProvider =
        Provider.of<PurchaseViewmodel>(context, listen: false);
    purchaseProvider.removeAll();

    final items = purchaseProvider.singlePurchaseOrderList;

    if (items.isNotEmpty) {
      final purchaseItems = items[0];
      purchaseNumbercontroller.text = purchaseItems.purchaseOrderNumber;
      purchaseDateController.text = purchaseItems.purchaseOrderDate;
      supplierController.text = purchaseItems.supplierName;
      quotationNumberController.text = purchaseItems.quotationNumber;
      contactPersonNameController.text = purchaseItems.contactPersonName;
      contactPersonNumberController.text = purchaseItems.contactPersonNumber;
      remarkController.text = purchaseItems.remark;
      termsandConditionController.text = purchaseItems.termsTitle;

      purchaseProvider.addGrandTotal(purchaseItems.grandTotal.toString());
      purchaseProvider.updateTermsId(purchaseItems.termsId);
      purchaseProvider.updateSupplierId(purchaseItems.supplierId);

      for (int i = 0; i < purchaseItems.items.length; i++) {
        final item = purchaseItems.items[i];

        purchaseProvider.addEditItem(
          AddQuotationModel(
            itemNumber: i,
            tabId: item.id,
            productId: item.productId,
            selectedProduct: item.productName,
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
    purchaseNumbercontroller.dispose();
    purchaseDateController.dispose();
    supplierController.dispose();
    quotationNumberController.dispose();
    contactPersonNameController.dispose();
    contactPersonNumberController.dispose();
    remarkController.dispose();
    termsandConditionController.dispose();
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
                      'Edit Purchase',
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
                                        .map((c) => c.firstName)
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
                                            (c) => c.firstName == newValue,
                                          );

                                          purchaseProvider.updateSupplierId(
                                              selectedSupplier.supplierId);

                                          supplierController.text =
                                              selectedSupplier.firstName;
                                        }
                                      },
                                    );
                                  },
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                const Text(
                                  "Product",
                                  style: TextStyle(
                                    color: AppColors.violetblue,
                                    fontSize: 17,
                                  ),
                                ),
                                Consumer<PurchaseViewmodel>(
                                    builder: (context, provider, child) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(
                                      provider.singlePurchaseOrderList[0].items
                                          .length,
                                      (index) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8),
                                        child: EditPurchaseItems(
                                          itemNumber: index,
                                          purchaseId: widget.purchaseOrderId,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
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
                                provider.editPurchaseOrder(
                                  widget.purchaseOrderId,
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
                              loading: provider.editPurchaseOrderLoader,
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
