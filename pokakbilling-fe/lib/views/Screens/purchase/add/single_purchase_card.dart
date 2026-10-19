import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/addQuotation_model.dart';
import 'package:pokakbilling/viewmodels/product_viewmodel.dart';
import 'package:pokakbilling/viewmodels/purchase_viewmodel.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_dropdown.dart';
import 'package:provider/provider.dart';

class PurchaseOrderItems extends StatefulWidget {
  final int itemNumber;

  const PurchaseOrderItems({super.key, required this.itemNumber});

  @override
  State<PurchaseOrderItems> createState() => _PurchaseOrderItemsState();
}

class _PurchaseOrderItemsState extends State<PurchaseOrderItems> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PurchaseViewmodel, ProductViewModel>(
      builder: (context, purchaseProvider, productProvider, child) {
        final item = purchaseProvider.itemList.firstWhere(
          (element) => element.itemNumber == widget.itemNumber,
          orElse: () => AddQuotationModel(itemNumber: widget.itemNumber),
        );

        dynamic selectedProduct;
        try {
          selectedProduct = productProvider.productList.firstWhere(
            (p) => p.productId.toString() == item.selectedProduct,
          );
        } catch (_) {
          selectedProduct = null;
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, purchaseProvider),
              const SizedBox(height: 10),
              CustomDropdown(
                selectedValue: selectedProduct?.productName,
                hint: "Select Product",
                dropdownItems: productProvider.productList
                    .map((c) => c.productName)
                    .toSet()
                    .toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    final selected = productProvider.productList.firstWhere(
                      (c) => c.productName == newValue,
                    );

                    purchaseProvider.updateItem(item.itemNumber,
                        "selectedProduct", selected.productId.toString());
                    purchaseProvider.updateItem(
                        item.itemNumber, "quantity", "1");
                    purchaseProvider.updateItem(item.itemNumber, "unitPrice",
                        selected.unitPrice.toString());
                    purchaseProvider.updateItem(
                        item.itemNumber, "cgst", selected.cgst.toString());
                    purchaseProvider.updateItem(
                        item.itemNumber, "sgst", selected.sgst.toString());

                    _calculateAndUpdateTotals(
                      purchaseProvider,
                      item.itemNumber,
                      1,
                      double.tryParse(selected.unitPrice) ?? 0,
                      double.tryParse(selected.cgst) ?? 0,
                      double.tryParse(selected.sgst) ?? 0,
                    );

                    productProvider.getProductById(selected.productId);
                  }
                },
              ),
              const SizedBox(height: 8),
              _buildTextFields(context, item),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(
      BuildContext context, PurchaseViewmodel purchaseProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Item No : ${widget.itemNumber}",
          style: const TextStyle(
            color: AppColors.violetblue,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        InkWell(
          onTap: () => purchaseProvider.removeItem(widget.itemNumber),
          child: const Icon(Icons.highlight_remove_sharp),
        ),
      ],
    );
  }

  Widget _buildTextFields(BuildContext context, AddQuotationModel item) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:
              _buildFieldSet(context, item, ["quantity", "unitPrice", "total"]),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _buildFieldSet(context, item, ["sgst", "cgst", "subTotal"]),
        ),
      ],
    );
  }

  List<Widget> _buildFieldSet(
      BuildContext context, AddQuotationModel item, List<String> fields) {
    return fields.map((field) {
      final value = _getFieldValue(item, field);
      _controllers[field] ??= TextEditingController(text: value);
      _controllers[field]!.text = value;

      final isEditable = field == "quantity" ||
          field == "unitPrice" ||
          field == "sgst" ||
          field == "cgst";

      return Column(
        children: [
          Text(
            field.toUpperCase(),
            style: const TextStyle(
              color: AppColors.violetblue,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            height: 30,
            width: 60,
            child: TextField(
              controller: _controllers[field],
              onChanged: isEditable
                  ? (value) {
                      final provider = Provider.of<PurchaseViewmodel>(context,
                          listen: false);
                      provider.updateItem(item.itemNumber, field, value);

                      final quantity = double.tryParse(
                              field == "quantity" ? value : item.quantity) ??
                          0;
                      final unitPrice = double.tryParse(
                              field == "unitPrice" ? value : item.unitPrice) ??
                          0;
                      final cgst = double.tryParse(
                              field == "cgst" ? value : item.cgst) ??
                          0;
                      final sgst = double.tryParse(
                              field == "sgst" ? value : item.sgst) ??
                          0;

                      if (field == "quantity" ||
                          field == "unitPrice" ||
                          field == "cgst" ||
                          field == "sgst") {
                        _calculateAndUpdateTotals(provider, item.itemNumber,
                            quantity, unitPrice, cgst, sgst);
                      }
                    }
                  : null,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
              readOnly: !isEditable,
              decoration: const InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                isDense: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.textfieldGrey),
                ),
              ),
            ),
          ),
        ],
      );
    }).toList();
  }

  void _calculateAndUpdateTotals(
    PurchaseViewmodel provider,
    int itemNumber,
    double quantity,
    double unitPrice,
    double cgstPercent,
    double sgstPercent,
  ) {
    final total = quantity * unitPrice;
    final cgstAmount = (total * cgstPercent) / 100.0;
    final sgstAmount = (total * sgstPercent) / 100.0;
    final subTotal = total + cgstAmount + sgstAmount;

    provider.updateItem(itemNumber, "total", total.toStringAsFixed(2));
    provider.updateItem(itemNumber, "subTotal", subTotal.toStringAsFixed(2));
  }

  String _getFieldValue(AddQuotationModel item, String field) {
    switch (field) {
      case "quantity":
        return item.quantity;
      case "unitPrice":
        return item.unitPrice;
      case "total":
        return item.total;
      case "sgst":
        return item.sgst;
      case "cgst":
        return item.cgst;
      case "subTotal":
        return item.subTotal;
      default:
        return '';
    }
  }
}
