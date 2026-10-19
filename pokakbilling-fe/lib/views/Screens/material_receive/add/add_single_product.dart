import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/addQuotation_model.dart';
import 'package:pokakbilling/viewmodels/material_receive_viewmodel.dart';
import 'package:pokakbilling/viewmodels/product_viewmodel.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_dropdown.dart';
import 'package:provider/provider.dart';

class MRItems extends StatefulWidget {
  final int itemNumber;

  const MRItems({super.key, required this.itemNumber});

  @override
  State<MRItems> createState() => _MRItemsState();
}

class _MRItemsState extends State<MRItems> {
  final Map<String, TextEditingController> _controllers = {};

  TextEditingController _getController(String field, String value) {
    final key = '${widget.itemNumber}_$field';
    if (!_controllers.containsKey(key)) {
      _controllers[key] = TextEditingController(text: value);
    } else {
      _controllers[key]!.text = value;
    }
    return _controllers[key]!;
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<MaterialReceiveViewmodel, ProductViewModel>(
      builder: (context, materialreceiveProvider, productProvider, child) {
        final item = materialreceiveProvider.itemList.firstWhere(
          (e) => e.itemNumber == widget.itemNumber,
          orElse: () => AddQuotationModel(itemNumber: widget.itemNumber),
        );

        final selectedProduct = productProvider.productList
            .where((p) => p.productId.toString() == item.selectedProduct)
            .cast<dynamic>()
            .firstOrNull;

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
              _buildHeader(materialreceiveProvider),
              const SizedBox(height: 10),

              /// PRODUCT DROPDOWN (UI SAME)
              CustomDropdown(
                selectedValue: selectedProduct?.productName,
                hint: "Select Product",
                dropdownItems: productProvider.productList
                    .map((e) => e.productName)
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;

                  final product = productProvider.productList
                      .firstWhere((p) => p.productName == value);

                  materialreceiveProvider.updateItem(item.itemNumber,
                      "selectedProduct", product.productId.toString());
                  materialreceiveProvider.updateItem(
                      item.itemNumber, "quantity", "1");
                  materialreceiveProvider.updateItem(item.itemNumber,
                      "unitPrice", product.unitPrice.toString());
                  materialreceiveProvider.updateItem(
                      item.itemNumber, "cgst", product.cgst.toString());
                  materialreceiveProvider.updateItem(
                      item.itemNumber, "sgst", product.sgst.toString());

                  _calculateAndUpdateTotals(
                    materialreceiveProvider,
                    item.itemNumber,
                    1,
                    double.tryParse(product.unitPrice) ?? 0,
                    double.tryParse(product.cgst) ?? 0,
                    double.tryParse(product.sgst) ?? 0,
                  );
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

  Widget _buildHeader(MaterialReceiveViewmodel provider) {
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
          onTap: () => provider.removeItem(widget.itemNumber),
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
      final controller = _getController(field, value);

      final isEditable =
          ["quantity", "unitPrice", "cgst", "sgst"].contains(field);

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
              controller: controller,
              readOnly: !isEditable,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
              onChanged: isEditable
                  ? (val) {
                      final provider = Provider.of<MaterialReceiveViewmodel>(
                          context,
                          listen: false);
                      provider.updateItem(item.itemNumber, field, val);

                      final qty = double.tryParse(
                              field == "quantity" ? val : item.quantity) ??
                          0;
                      final price = double.tryParse(
                              field == "unitPrice" ? val : item.unitPrice) ??
                          0;
                      final cgst =
                          double.tryParse(field == "cgst" ? val : item.cgst) ??
                              0;
                      final sgst =
                          double.tryParse(field == "sgst" ? val : item.sgst) ??
                              0;

                      _calculateAndUpdateTotals(
                          provider, item.itemNumber, qty, price, cgst, sgst);
                    }
                  : null,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      );
    }).toList();
  }

  void _calculateAndUpdateTotals(
    MaterialReceiveViewmodel provider,
    int itemNumber,
    double quantity,
    double unitPrice,
    double cgstPercent,
    double sgstPercent,
  ) {
    final total = quantity * unitPrice;
    final cgstAmount = total * cgstPercent / 100;
    final sgstAmount = total * sgstPercent / 100;
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
