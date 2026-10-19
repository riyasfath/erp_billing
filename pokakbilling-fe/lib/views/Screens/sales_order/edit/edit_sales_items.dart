import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/addQuotation_model.dart';
import 'package:pokakbilling/viewmodels/product_viewmodel.dart';
import 'package:pokakbilling/viewmodels/sales_order_viewmodel.dart';
import 'package:pokakbilling/views/commonWidgets/popups/delete_popup.dart';
import 'package:provider/provider.dart';

class EditSalesOrderItems extends StatefulWidget {
  final int itemNumber;
  final int salesOrderId;

  const EditSalesOrderItems({
    super.key,
    required this.itemNumber,
    required this.salesOrderId,
  });

  @override
  State<EditSalesOrderItems> createState() => _EditSalesOrderItemsState();
}

class _EditSalesOrderItemsState extends State<EditSalesOrderItems> {
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
    return Consumer2<SalesOrderViewmodel, ProductViewModel>(
      builder: (context, salesOrderProvider, productProvider, child) {
        final item = salesOrderProvider.editItemList.firstWhere(
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
              _buildHeader(context, salesOrderProvider, item),
              const SizedBox(height: 10),
              _buildTextFields(context, item),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context,
      SalesOrderViewmodel salesOrderProvider, AddQuotationModel item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Item No : ${widget.itemNumber + 1}",
          style: const TextStyle(
            color: AppColors.violetblue,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        InkWell(
          onTap: () => showDeleteDialog(
            context,
            "Sales Order Item",
            () => salesOrderProvider.deleteSalesOrderItem(
              widget.salesOrderId,
              item.tabId,
              context,
            ),
          ),
          child: const Icon(Icons.highlight_remove_sharp),
        ),
      ],
    );
  }

  Widget _buildTextFields(BuildContext context, AddQuotationModel item) {
    return Column(
      children: [
        Container(
          height: 40,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: AppColors.grey),
          ),
          child: Center(
            child: Text(
              item.selectedProduct,
              style: const TextStyle(
                color: AppColors.violetblue,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
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
                      final provider = Provider.of<SalesOrderViewmodel>(context,
                          listen: false);
                      provider.updateEditItem(item.itemNumber, field, value);

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
    SalesOrderViewmodel provider,
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

    provider.updateEditItem(itemNumber, "total", total.toStringAsFixed(2));
    provider.updateEditItem(
        itemNumber, "subTotal", subTotal.toStringAsFixed(2));
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
