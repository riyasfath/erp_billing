import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pokakbilling/core/themes/app_assets.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/customer_viewmodel.dart';
import 'package:pokakbilling/viewmodels/sales_order_viewmodel.dart';
import 'package:pokakbilling/viewmodels/sales_person_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/terms&condition_viewmodel.dart';
import 'package:pokakbilling/views/Screens/sales_order/add/add_single_product.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/colored_custom_button.dart';
import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/exit_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_dropdown.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_textfield.dart';
import 'package:provider/provider.dart';

class AddSalesOrder extends StatefulWidget {
  final String salesOrderNumber;
  const AddSalesOrder({super.key, required this.salesOrderNumber});

  @override
  State<AddSalesOrder> createState() => _AddSalesOrderState();
}

class _AddSalesOrderState extends State<AddSalesOrder> {
  late TextEditingController salesNumberTextcontroller;
  late TextEditingController salesDateTextController;
  late TextEditingController purchaseOrderNumberTextController;
  late TextEditingController termsTextController;
  late TextEditingController deliveryLocationTextController;
  late TextEditingController deliveryAddressTextController;
  late TextEditingController contactPersonTextController;
  late TextEditingController mobileNumberTextController;
  late TextEditingController remarkTextController;
  late TextEditingController termsandConditionTextController;
  late TextEditingController customerNameTextController =
      TextEditingController();
  late TextEditingController totalAmountTextController =
      TextEditingController();
  late TextEditingController salesPersonTextController =
      TextEditingController();
  final dropdownController = SingleValueDropDownController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    salesNumberTextcontroller =
        TextEditingController(text: widget.salesOrderNumber);
    salesDateTextController = TextEditingController();
    purchaseOrderNumberTextController = TextEditingController();
    termsTextController = TextEditingController();
    deliveryLocationTextController = TextEditingController();
    deliveryAddressTextController = TextEditingController();
    contactPersonTextController = TextEditingController();
    mobileNumberTextController = TextEditingController();
    remarkTextController = TextEditingController();
    termsandConditionTextController = TextEditingController();

    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    salesDateTextController.text = formattedDate;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SalesOrderViewmodel>(context, listen: false)
          .resetSelectedValues();
    });
  }

  @override
  void dispose() {
    salesNumberTextcontroller.dispose();
    salesDateTextController.dispose();
    purchaseOrderNumberTextController.dispose();
    termsTextController.dispose();
    deliveryLocationTextController.dispose();
    deliveryAddressTextController.dispose();
    contactPersonTextController.dispose();
    mobileNumberTextController.dispose();
    remarkTextController.dispose();
    termsandConditionTextController.dispose();
    customerNameTextController.dispose();
    totalAmountTextController.dispose();
    salesPersonTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<SalesPersonViewmodel>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // final categoryProvider = Provider.of<CategoryViewmodel>(context);

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
                      'New Sales Order',
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
                                      textController: salesNumberTextcontroller,
                                      isMandatory: false,
                                      isEnabled: false,
                                    ),
                                    SizedBox(height: screenHeight * 0.015),
                                    CustomTextfield(
                                      label: "Quotation Date",
                                      hintText: "",
                                      screenWidth: 5,
                                      textController: salesDateTextController,
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
                                                      customerNameTextController
                                                          .text)
                                              ? customerNameTextController.text
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
                                              customerNameTextController.text =
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
                                          purchaseOrderNumberTextController,
                                      isMandatory: false,
                                    ),
                                    SizedBox(height: screenHeight * 0.02),
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
                                              salesOrderProvider.addItem();
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
                                      children: salesOrderProvider.itemList
                                          .map(
                                            (item) => SalesOrderItems(
                                                itemNumber: item.itemNumber),
                                          )
                                          .toList(),
                                    ),
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
                                  label: "Delivery Location",
                                  hintText: "Location",
                                  screenWidth: screenWidth * 0.045,
                                  textController:
                                      deliveryLocationTextController,
                                  isMandatory: false,
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                CustomTextfield(
                                  label: "Delivery Address",
                                  hintText: "Address",
                                  screenWidth: screenWidth * 0.045,
                                  textController: deliveryAddressTextController,
                                  isMandatory: false,
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                CustomTextfield(
                                  label: "Mobile Number",
                                  hintText: "Number",
                                  screenWidth: screenWidth * 0.045,
                                  textController: mobileNumberTextController,
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
                                  textController: remarkTextController,
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
                                provider.createSalesOrder(
                                  salesNumberTextcontroller.text,
                                  salesDateTextController.text,
                                  provider.selectedClientId,
                                  purchaseOrderNumberTextController.text,
                                  termsTextController.text,
                                  deliveryLocationTextController.text,
                                  deliveryAddressTextController.text,
                                  provider.selectedTermsId,
                                  remarkTextController.text,
                                  context,
                                );
                              },
                              loading: provider.addSalesOrderLoading,
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
