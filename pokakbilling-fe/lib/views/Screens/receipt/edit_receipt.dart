import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_assets.dart';
import 'package:pokakbilling/viewmodels/customer_viewmodel.dart';
import 'package:pokakbilling/viewmodels/receipt_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/terms&condition_viewmodel.dart';
import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/colored_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/exit_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_dropdown.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_textfield.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:provider/provider.dart';

class EditReceipt extends StatefulWidget {
  final int receiptId;
  const EditReceipt({super.key, required this.receiptId});

  @override
  State<EditReceipt> createState() => _EditReceiptState();
}

class _EditReceiptState extends State<EditReceipt> {
  late TextEditingController receiptNumberTextcontroller;
  late TextEditingController receiptDateTextController;
  late TextEditingController customerNameTextController;
  late TextEditingController invoiceNumberTextController;
  late TextEditingController termsandConditionTextController;
  late TextEditingController remarkTextController;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    receiptNumberTextcontroller = TextEditingController();
    receiptDateTextController = TextEditingController();
    customerNameTextController = TextEditingController();
    invoiceNumberTextController = TextEditingController();
    termsandConditionTextController = TextEditingController();
    remarkTextController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadReceiptDetails();
    });
  }

  Future<void> loadReceiptDetails() async {
    final receiptProvider =
        Provider.of<ReceiptViewmodel>(context, listen: false);

    final items = receiptProvider.singleReceiptList;

    if (items.isNotEmpty) {
      final receiptItems = items[0];
      receiptNumberTextcontroller.text = receiptItems.receiptNumber;
      receiptDateTextController.text = receiptItems.receiptDate;
      customerNameTextController.text = receiptItems.clientName;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        invoiceNumberTextController.text = receiptItems.invoiceNumber.trim();
      });
      termsandConditionTextController.text = receiptItems.termsTitle;
      remarkTextController.text = receiptItems.remark;

      receiptProvider.updateClientId(receiptItems.clientId);
      receiptProvider.updateInvoiceId(receiptItems.invoiceId);
      receiptProvider.updateTermsId(receiptItems.termsId);
    }
  }

  @override
  void dispose() {
    receiptNumberTextcontroller.dispose();
    receiptDateTextController.dispose();
    customerNameTextController.dispose();
    invoiceNumberTextController.dispose();
    termsandConditionTextController.dispose();
    remarkTextController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final receiptProvider = Provider.of<ReceiptViewmodel>(context);
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
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ErpBottomBar(index: 0),
                          ),
                        );
                      },
                    ),
                    title: Text(
                      'Receipt',
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
            bottom: screenHeight * 0.04,
            child: Container(
              height: screenHeight - screenHeight * 0.18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
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
                                      label: "Receipt Number",
                                      hintText: "",
                                      screenWidth: 5,
                                      textController:
                                          receiptNumberTextcontroller,
                                      isMandatory: false,
                                      isEnabled: false,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: CustomTextfield(
                                      label: "Receipt Date",
                                      hintText: "",
                                      screenWidth: 5,
                                      textController: receiptDateTextController,
                                      isMandatory: false,
                                      isEnabled: true,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Consumer<CustomerViewmodel>(
                                builder: (context, provider, child) {
                                  // 👇 Create dropdown items with full names
                                  final dropdownItems = provider.customerList
                                      .map((c) => c.firstName)
                                      .toSet()
                                      .toList();

                                  // 👇 Set selected value based on controller text
                                  final selectedValue = dropdownItems.contains(
                                          customerNameTextController.text)
                                      ? customerNameTextController.text
                                      : null;

                                  return CustomDropdown(
                                    selectedValue: selectedValue,
                                    hint: "Client Name",
                                    dropdownItems: dropdownItems,
                                    onChanged: (String? newValue) async {
                                      if (newValue != null) {
                                        // 👇 Match the full name
                                        final selectedCustomer =
                                            provider.customerList.firstWhere(
                                          (c) => c.firstName == newValue,
                                        );

                                        receiptProvider.updateClientId(
                                            selectedCustomer.customerId);
                                        provider.selectCustomer(
                                            selectedCustomer.firstName);
                                        customerNameTextController.text =
                                            selectedCustomer.firstName;
                                      }
                                    },
                                  );
                                },
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Consumer<ReceiptViewmodel>(
                                builder: (context, provider, child) {
                                  final selectedInvoice =
                                      invoiceNumberTextController.text.trim();

                                  final isInvoiceInList = provider.invoiceList
                                      .any((c) =>
                                          c.invoiceNumber.trim() ==
                                          selectedInvoice);

                                  return CustomDropdown(
                                    selectedValue: isInvoiceInList
                                        ? selectedInvoice
                                        : null,
                                    hint: "Select Invoice Number",
                                    dropdownItems: provider.invoiceList
                                        .map((c) => c.invoiceNumber.trim())
                                        .toSet()
                                        .toList(),
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        // Fetch the selected invoice
                                        final selectedSalesPerson =
                                            provider.invoiceList.firstWhere(
                                          (c) =>
                                              c.invoiceNumber.trim() ==
                                              newValue.trim(),
                                        );

                                        // Update provider and controller
                                        provider.updateInvoiceId(
                                            selectedSalesPerson.invoiceId);
                                        invoiceNumberTextController.text =
                                            selectedSalesPerson.invoiceNumber
                                                .trim();
                                      }
                                    },
                                  );
                                },
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Consumer<TermsViewmodel>(
                                builder: (context, provider, child) {
                                  return CustomDropdown(
                                    selectedValue: provider.termsTitleList.any(
                                            (c) =>
                                                c.title ==
                                                termsandConditionTextController
                                                    .text)
                                        ? termsandConditionTextController.text
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

                                        receiptProvider.updateTermsId(
                                          selectedSalesPerson.titleId,
                                        );

                                        termsandConditionTextController.text =
                                            selectedSalesPerson.title
                                                .toString();
                                      }
                                    },
                                  );
                                },
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              CustomTextfield(
                                label: "Remark",
                                hintText: "Enter Remark",
                                screenWidth: screenWidth * 0.045,
                                textController: remarkTextController,
                                isMandatory: false,
                                isValidationRequired: true,
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              const SizedBox(height: 5),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Consumer<ReceiptViewmodel>(
                        builder: (context, provider, child) {
                          return ColoredCustomButton(
                            text: "Edit",
                            onPressed: () {
                              provider.updateReceipt(
                                widget.receiptId,
                                receiptNumberTextcontroller.text,
                                receiptDateTextController.text,
                                provider.selectedClientId,
                                provider.selectedInvoiceId,
                                provider.selectedTermsId,
                                remarkTextController.text,
                                context,
                              );
                            },
                            loading: provider.editReceiptLoading,
                            formKey: formKey,
                          );
                        },
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      const ExitCustomButton(text: "Exit")
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
