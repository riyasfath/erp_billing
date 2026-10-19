import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pokakbilling/core/themes/app_assets.dart';
import 'package:pokakbilling/viewmodels/customer_viewmodel.dart';
import 'package:pokakbilling/viewmodels/delivery_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/terms&condition_viewmodel.dart';
import 'package:pokakbilling/views/Screens/delivery/add_delivery/single_item.dart';
import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/colored_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/exit_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_dropdown.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_textfield.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:provider/provider.dart';

class AddDelivery extends StatefulWidget {
  final String deliveryNumber;
  const AddDelivery({super.key, required this.deliveryNumber});

  @override
  State<AddDelivery> createState() => _AddDeliveryState();
}

class _AddDeliveryState extends State<AddDelivery> {
  late TextEditingController deliveryNumberTextcontroller;
  late TextEditingController deliveryDateTextController;
  late TextEditingController clientNameTextController;
  late TextEditingController salesOrderTextController;
  late TextEditingController termsandConditionTextController;
  late TextEditingController contactPersonTextController;
  late TextEditingController deliveryLocationTextController;
  late TextEditingController deliveryAddressTextController;
  late TextEditingController mobileNumberTextController;
  late TextEditingController timeTextController;
  late TextEditingController dateTextController;

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    deliveryNumberTextcontroller =
        TextEditingController(text: widget.deliveryNumber);
    deliveryDateTextController = TextEditingController();
    clientNameTextController = TextEditingController();
    salesOrderTextController = TextEditingController();
    termsandConditionTextController = TextEditingController();
    contactPersonTextController = TextEditingController();
    deliveryLocationTextController = TextEditingController();
    deliveryAddressTextController = TextEditingController();
    mobileNumberTextController = TextEditingController();
    timeTextController = TextEditingController();
    dateTextController = TextEditingController();

    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    deliveryDateTextController.text = formattedDate;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DeliveryViewmodel>(context, listen: false)
          .resetSelectedValues();
    });
  }

  @override
  void dispose() {
    deliveryNumberTextcontroller.dispose();
    deliveryDateTextController.dispose();
    clientNameTextController.dispose();
    salesOrderTextController.dispose();
    termsandConditionTextController.dispose();
    contactPersonTextController.dispose();
    deliveryLocationTextController.dispose();
    deliveryAddressTextController.dispose();
    mobileNumberTextController.dispose();
    timeTextController.dispose();
    dateTextController.dispose();
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
                      'Delivery',
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
                                      label: "Delivery Number",
                                      hintText: "",
                                      screenWidth: 5,
                                      textController:
                                          deliveryNumberTextcontroller,
                                      isMandatory: false,
                                      isEnabled: false,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: CustomTextfield(
                                      label: "Delivery Date",
                                      hintText: "",
                                      screenWidth: 5,
                                      textController:
                                          deliveryDateTextController,
                                      isMandatory: false,
                                      isEnabled: true,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Consumer2<CustomerViewmodel, DeliveryViewmodel>(
                                builder: (context, customerProvider,
                                    deliveryProvider, child) {
                                  return CustomDropdown(
                                    selectedValue: customerProvider.customerList
                                            .any((c) =>
                                                c.firstName ==
                                                clientNameTextController.text)
                                        ? clientNameTextController.text
                                        : null,
                                    hint: "Client Name",
                                    dropdownItems: customerProvider.customerList
                                        .map((c) => c.firstName)
                                        .toSet()
                                        .toList(),
                                    onChanged: (String? newValue) async {
                                      if (newValue != null) {
                                        deliveryProvider.dropDownStatus();
                                        String selectedName =
                                            newValue.split(" (")[0];
                                        var selectedCustomer = customerProvider
                                            .customerList
                                            .firstWhere(
                                          (c) => c.firstName == selectedName,
                                        );

                                        deliveryProvider.clearLists();
                                        salesOrderTextController.text = "";

                                        await customerProvider.getCustomerById(
                                            selectedCustomer.customerId);
                                        await deliveryProvider
                                            .getSalesOrderByClientId(
                                                selectedCustomer.customerId);

                                        final customer = customerProvider
                                                .singleCustomerList.isNotEmpty
                                            ? customerProvider
                                                .singleCustomerList[0]
                                            : null;

                                        if (customer != null) {
                                          deliveryProvider.updateSalesPersonId(
                                              customer.salesPersonId);
                                          deliveryProvider
                                              .updateSalesPersonName(
                                                  customer.salesPersonName);
                                        }

                                        deliveryProvider.updateClientId(
                                            selectedCustomer.customerId);
                                        deliveryProvider.updateClientName(
                                            selectedCustomer.firstName);
                                        clientNameTextController.text =
                                            selectedCustomer.firstName;
                                      }
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 15),
                              Consumer<DeliveryViewmodel>(
                                builder: (context, provider, child) {
                                  return Column(
                                    children: [
                                      CustomDropdown(
                                        selectedValue: provider
                                                .salesOrderClientList
                                                .any((c) =>
                                                    c.salesOrderNumber ==
                                                    salesOrderTextController
                                                        .text)
                                            ? salesOrderTextController.text
                                            : null,
                                        hint: "Sales Order",
                                        dropdownItems: provider
                                            .salesOrderClientList
                                            .map((c) => c.salesOrderNumber)
                                            .toSet()
                                            .toList(),
                                        onChanged: (String? newValue) async {
                                          if (newValue != null) {
                                            String selectedName =
                                                newValue.split(" (")[0];
                                            var selectedSalesOrder = provider
                                                .salesOrderClientList
                                                .firstWhere(
                                              (c) =>
                                                  c.salesOrderNumber ==
                                                  selectedName,
                                            );

                                            await provider
                                                .getItemsBySalesOrderId(
                                                    selectedSalesOrder
                                                        .salesOrderId);

                                            provider.updateSalesOrderId(
                                                selectedSalesOrder
                                                    .salesOrderId);
                                            salesOrderTextController.text =
                                                selectedSalesOrder
                                                    .salesOrderNumber;
                                          }
                                        },
                                      ),
                                      if (provider
                                              .salesOrderClientList.isEmpty &&
                                          provider.hasClientDropdownBeenTouched)
                                        const Padding(
                                          padding: EdgeInsets.only(
                                              bottom: 8.0, top: 8.0),
                                          child: Text(
                                            "No Sales Order found for the selected Client",
                                            style:
                                                TextStyle(color: AppColors.red),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 15),
                              Consumer<DeliveryViewmodel>(
                                builder: (context, provider, child) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(
                                      provider.salesOrderItemsList.length,
                                      (index) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8),
                                        child: SingleItem(index: index),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
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
                              const Text(
                                "Terms & Condition",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                              Consumer2<TermsViewmodel, DeliveryViewmodel>(
                                builder: (context, provider, salesOrderProvider,
                                    child) {
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
                              SizedBox(height: screenHeight * 0.01),
                              CustomTextfield(
                                label: "Contact Person",
                                hintText: "Contact Person",
                                screenWidth: screenWidth * 0.045,
                                textController: contactPersonTextController,
                                isMandatory: true,
                                isValidationRequired: true,
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              CustomTextfield(
                                label: "Delivery Location",
                                hintText: "Location",
                                screenWidth: screenWidth * 0.045,
                                textController: deliveryLocationTextController,
                                isMandatory: true,
                                isValidationRequired: true,
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              CustomTextfield(
                                label: "Delivery Address",
                                hintText: "Address",
                                screenWidth: screenWidth * 0.045,
                                textController: deliveryAddressTextController,
                                isMandatory: true,
                                isValidationRequired: true,
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              CustomTextfield(
                                label: "Mobile Number",
                                hintText: "Number",
                                screenWidth: screenWidth * 0.045,
                                textController: mobileNumberTextController,
                                isMandatory: true,
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
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      pickTime(context, timeTextController),
                                  child: AbsorbPointer(
                                    child: CustomTextfield(
                                      label: "Time",
                                      hintText: "",
                                      screenWidth: 5,
                                      textController: timeTextController,
                                      isMandatory: false,
                                      isEnabled: true,
                                      suffixIcon: const Icon(Icons.access_time),
                                      isValidationRequired: true,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      pickDate(context, dateTextController),
                                  child: AbsorbPointer(
                                    child: CustomTextfield(
                                      label: "Date",
                                      hintText: "",
                                      screenWidth: 5,
                                      textController: dateTextController,
                                      isMandatory: false,
                                      isEnabled: true,
                                      suffixIcon:
                                          const Icon(Icons.calendar_today),
                                      isValidationRequired: true,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Consumer<DeliveryViewmodel>(
                        builder: (context, provider, child) {
                          return ColoredCustomButton(
                            text: "Save",
                            onPressed: () {
                              bool hasChecked =
                                  provider.checkboxStates.contains(true);

                              if (!hasChecked) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "Please select at least one item before saving."),
                                  ),
                                );
                                return;
                              }

                              for (int i = 0;
                                  i < provider.checkboxStates.length;
                                  i++) {
                                if (provider.checkboxStates[i]) {
                                  String qtyText = provider
                                      .deliveryQuantityControllers[i].text
                                      .trim();
                                  if (qtyText.isEmpty ||
                                      double.tryParse(qtyText) == null ||
                                      double.parse(qtyText) <= 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Please enter valid delivery quantity for item ${i + 1}."),
                                      ),
                                    );
                                    return;
                                  }
                                }
                              }

                              provider.createDeliveryOrder(
                                provider.selectedClientId,
                                deliveryNumberTextcontroller.text,
                                deliveryDateTextController.text,
                                provider.selectedSalesOrderId,
                                deliveryLocationTextController.text,
                                deliveryAddressTextController.text,
                                contactPersonTextController.text,
                                mobileNumberTextController.text,
                                provider.selectedTermsId,
                                timeTextController.text,
                                dateTextController.text,
                                context,
                              );
                            },
                            loading: provider.addDeliveryOrderLoading,
                            formKey: formKey,
                          );
                        },
                      ),
                      SizedBox(
                        height: screenHeight * 0.02,
                      ),
                      const ExitCustomButton(text: "Print")
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

Future<void> pickTime(
  BuildContext context,
  TextEditingController controller,
) async {
  final TimeOfDay? pickedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );

  if (pickedTime != null) {
    // Format as "HH:mm"
    final formattedTime =
        "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";

    controller.text = formattedTime;
  }
}

Future<void> pickDate(
  BuildContext context,
  TextEditingController controller,
) async {
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );

  if (pickedDate != null) {
    final formattedDate = "${pickedDate.year.toString().padLeft(4, '0')}-"
        "${pickedDate.month.toString().padLeft(2, '0')}-"
        "${pickedDate.day.toString().padLeft(2, '0')}";
    controller.text = formattedDate;
  }
}
