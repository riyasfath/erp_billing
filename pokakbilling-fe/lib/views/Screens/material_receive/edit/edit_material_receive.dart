import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_assets.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/addQuotation_model.dart';
import 'package:pokakbilling/viewmodels/material_receive_viewmodel.dart';
import 'package:pokakbilling/viewmodels/purchase_viewmodel.dart';
import 'package:pokakbilling/viewmodels/supplier_viewmodel.dart';
import 'package:pokakbilling/views/Screens/material_receive/edit/edit_single_product.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/colored_custom_button.dart';
import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/exit_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_dropdown.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_textfield.dart';
import 'package:provider/provider.dart';

class EditMaterialReceive extends StatefulWidget {
  final int mrId;
  const EditMaterialReceive({super.key, required this.mrId});

  @override
  State<EditMaterialReceive> createState() => _EditMaterialReceiveState();
}

class _EditMaterialReceiveState extends State<EditMaterialReceive> {
  late TextEditingController mrNumberTextcontroller;
  late TextEditingController mrDateTextController;
  late TextEditingController supplierTextController;
  late TextEditingController purchaseOrderTextController;
  late TextEditingController remarkTextController;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MaterialReceiveViewmodel>(context, listen: false).removeAll();
    });

    mrNumberTextcontroller = TextEditingController();
    mrDateTextController = TextEditingController();
    supplierTextController = TextEditingController();
    purchaseOrderTextController = TextEditingController();
    remarkTextController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadMRDetails();
    });
  }

  Future<void> loadMRDetails() async {
    final materialReceiveProvider =
        Provider.of<MaterialReceiveViewmodel>(context, listen: false);
    materialReceiveProvider.removeAll();
    final items = materialReceiveProvider.singleMaterialReceiveList;

    if (items.isNotEmpty) {
      final mrItems = items[0];
      mrNumberTextcontroller.text = mrItems.materialReceiveNumber;
      mrDateTextController.text = mrItems.receivedDate;
      supplierTextController.text = mrItems.supplierName;
      purchaseOrderTextController.text = mrItems.purchaseOrderNumber;
      remarkTextController.text = mrItems.remark;

      materialReceiveProvider.addGrandTotal(mrItems.grandTotal.toString());
      materialReceiveProvider.updateSupplierId(mrItems.supplierId);
      materialReceiveProvider.updatePurchaseId(mrItems.purchaseOrderId);

      for (int i = 0; i < mrItems.items.length; i++) {
        final item = mrItems.items[i];

        materialReceiveProvider.addEditItem(
          AddQuotationModel(
            itemNumber: i,
            tabId: item.materialid,
            productId: item.product,
            selectedProduct: "product Name",
            quantity: item.quantity.toString(),
            unitPrice: item.unitPrice.toString(),
            total: item.total.toString(),
            cgst: item.cgst.toString(),
            sgst: item.sgst.toString(),
            subTotal: item.subTotal.toString(),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    mrNumberTextcontroller.dispose();
    mrDateTextController.dispose();
    supplierTextController.dispose();
    purchaseOrderTextController.dispose();
    remarkTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<MaterialReceiveViewmodel>(context);
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
                      'Edit Material Receive',
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
                        Consumer<MaterialReceiveViewmodel>(
                          builder: (context, materialreceiveProvider, child) {
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
                                      label: "Material Receive No",
                                      hintText: "",
                                      screenWidth: screenWidth * 0.045,
                                      textController: mrNumberTextcontroller,
                                      isMandatory: false,
                                      isEnabled: false,
                                    ),
                                    SizedBox(height: screenHeight * 0.015),
                                    CustomTextfield(
                                      label: "Date",
                                      hintText: "",
                                      screenWidth: 5,
                                      textController: mrDateTextController,
                                      isMandatory: false,
                                      isEnabled: true,
                                    ),
                                    SizedBox(height: screenHeight * 0.02),
                                    Consumer2<SupplierViewmodel,
                                        MaterialReceiveViewmodel>(
                                      builder: (context, provider,
                                          materialreceiveProvider, child) {
                                        final dropdownItems = provider
                                            .supplierList
                                            .map((c) => c.firstName)
                                            .toSet()
                                            .toList();

                                        final selectedValue =
                                            dropdownItems.contains(
                                                    supplierTextController.text)
                                                ? supplierTextController.text
                                                : null;

                                        return CustomDropdown(
                                          selectedValue: selectedValue,
                                          hint: "Supplier",
                                          dropdownItems: dropdownItems,
                                          onChanged: (String? newValue) async {
                                            if (newValue != null) {
                                              final selectedPurchaseOrder =
                                                  provider.supplierList
                                                      .firstWhere(
                                                (c) => c.firstName == newValue,
                                              );

                                              materialreceiveProvider
                                                  .updateSupplierId(
                                                      selectedPurchaseOrder
                                                          .supplierId);

                                              supplierTextController.text =
                                                  selectedPurchaseOrder
                                                      .firstName;
                                            }
                                          },
                                        );
                                      },
                                    ),
                                    SizedBox(height: screenHeight * 0.02),
                                    Consumer2<PurchaseViewmodel,
                                        MaterialReceiveViewmodel>(
                                      builder: (context, provider,
                                          materialreceiveProvider, child) {
                                        final dropdownItems = provider
                                            .purchaseOrderList
                                            .map((c) => c.purchaseOrderNumber)
                                            .toSet()
                                            .toList();

                                        final selectedValue = dropdownItems
                                                .contains(
                                                    purchaseOrderTextController
                                                        .text)
                                            ? purchaseOrderTextController.text
                                            : null;

                                        return CustomDropdown(
                                          selectedValue: selectedValue,
                                          hint: "Purchase Order",
                                          dropdownItems: dropdownItems,
                                          onChanged: (String? newValue) async {
                                            if (newValue != null) {
                                              final matches =
                                                  provider.purchaseOrderList
                                                      .where(
                                                        (c) =>
                                                            c.purchaseOrderNumber ==
                                                            newValue,
                                                      )
                                                      .toList();

                                              if (matches.isNotEmpty) {
                                                final selectedPurchaseOrder =
                                                    matches.first;
                                                materialreceiveProvider
                                                    .updatePurchaseId(
                                                        selectedPurchaseOrder
                                                            .purchaseOrderId);
                                                purchaseOrderTextController
                                                        .text =
                                                    selectedPurchaseOrder
                                                        .purchaseOrderNumber;
                                              }
                                            }
                                          },
                                        );
                                      },
                                    ),
                                    SizedBox(height: screenHeight * 0.02),
                                    const Text(
                                      "Add Product",
                                      style: TextStyle(
                                        color: AppColors.violetblue,
                                        fontSize: 17,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Consumer<MaterialReceiveViewmodel>(
                                      builder: (context, provider, child) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: List.generate(
                                            provider
                                                .singleMaterialReceiveList[0]
                                                .items
                                                .length,
                                            (index) => Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 8),
                                              child: EditMrItems(
                                                itemNumber: index,
                                                mrId: widget.mrId,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
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
                                      child: Consumer<MaterialReceiveViewmodel>(
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
                                CustomTextfield(
                                  label: "Remark",
                                  hintText: "Remarks",
                                  screenWidth: screenWidth * 0.045,
                                  textController: remarkTextController,
                                  isMandatory: false,
                                  isValidationRequired: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.05),
                        Consumer<MaterialReceiveViewmodel>(
                          builder: (context, provider, child) {
                            return ColoredCustomButton(
                              text: "Save",
                              onPressed: () {
                                provider.editMaterialReceive(
                                  widget.mrId,
                                  mrNumberTextcontroller.text,
                                  mrDateTextController.text,
                                  provider.selectedSupplierId,
                                  provider.selectedPurchaseId,
                                  provider.grandTotal,
                                  remarkTextController.text,
                                  context,
                                );
                              },
                              loading: provider.editMrLoader,
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
