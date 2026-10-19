import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/core/themes/app_assets.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/customer_viewmodel.dart';
import 'package:pokakbilling/viewmodels/delivery_viewmodel.dart';
import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_dropdown.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_textfield.dart';
import 'package:provider/provider.dart';

class EditDelivery extends StatefulWidget {
  final int deliveryId;
  const EditDelivery({super.key, required this.deliveryId});

  @override
  State<EditDelivery> createState() => _EditDeliveryState();
}

class _EditDeliveryState extends State<EditDelivery> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController deliveryNumbercontroller;
  late TextEditingController deliveryDateController;
  late TextEditingController clientNameTextController;
  late TextEditingController salesOrderTextController;

  @override
  void initState() {
    super.initState();
    deliveryNumbercontroller = TextEditingController();
    deliveryDateController = TextEditingController();
    clientNameTextController = TextEditingController();
    salesOrderTextController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final customerProvider =
          Provider.of<CustomerViewmodel>(context, listen: false);
      final deliveryProvider =
          Provider.of<DeliveryViewmodel>(context, listen: false);

      loadDeliveryDetails();

      final clientId = deliveryProvider.singleDeliveryOrderList[0].clientId;
      final salesOrderId =
          deliveryProvider.singleDeliveryOrderList[0].salesOrderId;

      await customerProvider.getCustomerById(clientId);
      await deliveryProvider.getSalesOrderByClientId(clientId);
      // await deliveryProvider.getItemsBySalesOrderId(salesOrderId);
    });
  }

  Future<void> loadDeliveryDetails() async {
    final deliveryProvider =
        Provider.of<DeliveryViewmodel>(context, listen: false);

    // deliveryProvider.removeAll();

    final items = deliveryProvider.singleDeliveryOrderList;
    if (items.isNotEmpty) {
      final deliveryItems = items[0];

      deliveryNumbercontroller.text = deliveryItems.deliveryNumber;
      deliveryDateController.text = deliveryItems.deliveryDate;
      setState(() {
        clientNameTextController.text = deliveryItems.clientFirstName;
        salesOrderTextController.text = deliveryItems.salesOrderNumber;
      });

      deliveryProvider.updateClientId(deliveryItems.clientId);
      deliveryProvider.updateSalesOrderId(deliveryItems.salesOrderId);
    }
  }

  @override
  void dispose() {
    super.dispose();
    deliveryNumbercontroller.dispose();
    deliveryDateController.dispose();
    clientNameTextController.dispose();
    salesOrderTextController.dispose();
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
                        pushReplacementNavigation(
                          context,
                          const ErpBottomBar(index: 0),
                        );
                      },
                    ),
                    title: Text(
                      'Edit Delivery',
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
                                      textController: deliveryNumbercontroller,
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
                                      textController: deliveryDateController,
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
                                      (index) => const Padding(
                                        padding: EdgeInsets.only(bottom: 8),
                                        child: Text("hiaii"),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
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
