import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_assets.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/addQuotation_model.dart';
import 'package:pokakbilling/viewmodels/customer_viewmodel.dart';
import 'package:pokakbilling/viewmodels/sales_order_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/terms&condition_viewmodel.dart';
import 'package:pokakbilling/views/Screens/sales_order/edit/edit_sales_items.dart';
import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/colored_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/exit_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_dropdown.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_textfield.dart';
import 'package:provider/provider.dart';

class EditSalesOrder extends StatefulWidget {
  final int salesOrderId;
  const EditSalesOrder({super.key, required this.salesOrderId});

  @override
  State<EditSalesOrder> createState() => _EditSalesOrderState();
}

class _EditSalesOrderState extends State<EditSalesOrder> {
  late TextEditingController salesOrderNumberController;
  late TextEditingController salesDateController;
  late TextEditingController customerNameController;
  late TextEditingController purchaseOrderNumberController;
  late TextEditingController termsandConditionController;
  late TextEditingController deliveryLocationController;
  late TextEditingController deliveryAddressController;
  late TextEditingController mobileNumberController;
  late TextEditingController salesPersonNameController;
  late TextEditingController remarksController;

  final formKey = GlobalKey<FormState>();
  final dropdownController = SingleValueDropDownController();

  @override
  void initState() {
    super.initState();
    salesOrderNumberController = TextEditingController();
    salesDateController = TextEditingController();
    customerNameController = TextEditingController();
    purchaseOrderNumberController = TextEditingController();
    termsandConditionController = TextEditingController();
    deliveryLocationController = TextEditingController();
    deliveryAddressController = TextEditingController();
    mobileNumberController = TextEditingController();
    salesPersonNameController = TextEditingController();
    remarksController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSalesOrderDetails();
    });
  }

  Future<void> _loadSalesOrderDetails() async {
    final salesOrderProvider =
        Provider.of<SalesOrderViewmodel>(context, listen: false);

    final items = salesOrderProvider.singleSalesOrderList;
    if (items.isNotEmpty) {
      final salesOrderItems = items[0];

      salesOrderNumberController.text = salesOrderItems.salesOrderNumber;
      salesDateController.text = salesOrderItems.salesDate;
      customerNameController.text = salesOrderItems.clientName;
      purchaseOrderNumberController.text = salesOrderItems.purchaseOrderNumber;
      termsandConditionController.text = salesOrderItems.termsTitle;
      deliveryLocationController.text = salesOrderItems.deliveryLocation;
      deliveryAddressController.text = salesOrderItems.deliveryAddress;
      mobileNumberController.text = salesOrderItems.mobileNumber;
      salesPersonNameController.text = salesOrderItems.salesPersonName;
      remarksController.text = salesOrderItems.remark;

      salesOrderProvider.addGrandTotal(salesOrderItems.grandTotal.toString());
      salesOrderProvider.updateSalesPersonName(salesOrderItems.salesPersonName);
      salesOrderProvider.updateClientId(salesOrderItems.clientId);
      salesOrderProvider.updateTermsId(salesOrderItems.termsId);

      for (int i = 0; i < salesOrderItems.items.length; i++) {
        final item = salesOrderItems.items[i];

        salesOrderProvider.addEditItem(
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
    salesOrderNumberController.dispose();
    salesDateController.dispose();
    customerNameController.dispose();
    purchaseOrderNumberController.dispose();
    termsandConditionController.dispose();
    deliveryLocationController.dispose();
    deliveryAddressController.dispose();
    mobileNumberController.dispose();
    salesPersonNameController.dispose();
    remarksController.dispose();
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
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ErpBottomBar(index: 0),
                          ),
                        );
                      },
                    ),
                    title: Text(
                      'Edit Sales Order',
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
                        Consumer<SalesOrderViewmodel>(
                          builder: (context, salesOrderProvider, child) {
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(screenWidth * 0.03),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomTextfield(
                                      label: "Sales Order ID",
                                      hintText: "",
                                      screenWidth: screenWidth * 0.045,
                                      textController:
                                          salesOrderNumberController,
                                      isMandatory: false,
                                      isEnabled: false,
                                    ),
                                    SizedBox(height: screenHeight * 0.015),
                                    CustomTextfield(
                                      label: "Quotation Date",
                                      hintText: "",
                                      screenWidth: 5,
                                      textController: salesDateController,
                                      isMandatory: false,
                                      isEnabled: true,
                                    ),
                                    SizedBox(height: screenHeight * 0.02),
                                    Consumer2<CustomerViewmodel,
                                        SalesOrderViewmodel>(
                                      builder: (context, provider,
                                          salesOrderProvider, child) {
                                        return CustomDropdown(
                                          selectedValue: provider.customerList
                                                  .any((c) =>
                                                      c.firstName ==
                                                      customerNameController
                                                          .text)
                                              ? customerNameController.text
                                              : null,
                                          hint: "Client Name",
                                          dropdownItems: provider.customerList
                                              .map((c) => c.firstName)
                                              .toSet()
                                              .toList(),
                                          onChanged: (String? newValue) async {
                                            if (newValue != null) {
                                              String selectedName =
                                                  newValue.split(" (")[0];
                                              var selectedCustomer = provider
                                                  .customerList
                                                  .firstWhere(
                                                (c) =>
                                                    c.firstName == selectedName,
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
                                                salesOrderProvider
                                                    .updateSalesPersonId(
                                                        customer.salesPersonId);
                                                salesOrderProvider
                                                    .updateSalesPersonName(
                                                        customer
                                                            .salesPersonName);
                                              }

                                              salesOrderProvider.updateClientId(
                                                  selectedCustomer.customerId);
                                              salesOrderProvider
                                                  .updateClientName(
                                                      selectedCustomer
                                                          .firstName);
                                              customerNameController.text =
                                                  selectedCustomer.firstName;
                                            }
                                          },
                                        );
                                      },
                                    ),
                                    SizedBox(height: screenHeight * 0.02),
                                    CustomTextfield(
                                      label: "Purchase Order Number",
                                      hintText: "",
                                      screenWidth: screenWidth * 0.045,
                                      textController:
                                          purchaseOrderNumberController,
                                      isMandatory: false,
                                    ),
                                    SizedBox(height: screenHeight * 0.02),
                                    const Text(
                                      "Product",
                                      style: TextStyle(
                                        color: AppColors.violetblue,
                                        fontSize: 17,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Consumer<SalesOrderViewmodel>(
                                        builder: (context, provider, child) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: List.generate(
                                          provider.singleSalesOrderList[0].items
                                              .length,
                                          (index) => Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8),
                                            child: EditSalesOrderItems(
                                              itemNumber: index,
                                              salesOrderId: widget.salesOrderId,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            );
                          },
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
                                      child: Consumer<SalesOrderViewmodel>(
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
                                                    color: AppColors
                                                        .textfieldGrey),
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
                                Consumer2<TermsViewmodel, SalesOrderViewmodel>(
                                  builder: (context, provider,
                                      salesOrderProvider, child) {
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
                                          var selectedSalesPerson = provider
                                              .termsTitleList
                                              .firstWhere(
                                            (c) => c.title == selectedName,
                                          );

                                          salesOrderProvider.updateTermsId(
                                            selectedSalesPerson.titleId,
                                          );
                                          salesOrderProvider.updateTermsName(
                                              selectedSalesPerson.title);
                                          termsandConditionController.text =
                                              selectedSalesPerson.title
                                                  .toString();
                                        }
                                      },
                                    );
                                  },
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                CustomTextfield(
                                  label: "Delivery Location",
                                  hintText: "Location",
                                  screenWidth: screenWidth * 0.045,
                                  textController: deliveryLocationController,
                                  isMandatory: false,
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                CustomTextfield(
                                  label: "Delivery Address",
                                  hintText: "Address",
                                  screenWidth: screenWidth * 0.045,
                                  textController: deliveryAddressController,
                                  isMandatory: false,
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                CustomTextfield(
                                  label: "Mobile Number",
                                  hintText: "Number",
                                  screenWidth: screenWidth * 0.045,
                                  textController: mobileNumberController,
                                  isMandatory: false,
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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Sales Person",
                                      style: TextStyle(
                                        color: AppColors.violetblue,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Consumer<SalesOrderViewmodel>(
                                      builder: (context, provider, child) {
                                        return Container(
                                          width: double.infinity,
                                          padding:
                                              const EdgeInsets.only(bottom: 6),
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: AppColors.grey,
                                                width: 1.5,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            provider.selectedSalesPersonName,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                CustomTextfield(
                                  label: "Remark",
                                  hintText: "Remarks",
                                  screenWidth: screenWidth * 0.045,
                                  textController: remarksController,
                                  isMandatory: false,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.05),
                        Consumer2<SalesOrderViewmodel, TermsViewmodel>(
                          builder: (context, provider, termsProvider, child) {
                            return ColoredCustomButton(
                              text: "Save",
                              onPressed: () {
                                if (!formKey.currentState!.validate()) return;

                                provider.updateSalesOrder(
                                  widget.salesOrderId,
                                  salesOrderNumberController.text,
                                  salesDateController.text,
                                  provider.selectedClientId,
                                  purchaseOrderNumberController.text,
                                  deliveryLocationController.text,
                                  deliveryAddressController.text,
                                  provider.selectedTermsId,
                                  remarksController.text,
                                  context,
                                );
                              },
                              loading: provider.editSalesOrderLoading,
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
          ),
        ],
      ),
    );
  }
}
