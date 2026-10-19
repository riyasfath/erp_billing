// import 'package:flutter/material.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/models/data-models/addQuotation_model.dart';
// import 'package:pokakbilling/viewmodels/product_viewmodel.dart';
// import 'package:pokakbilling/viewmodels/quotation/quotation_viewmodel.dart';
// import 'package:pokakbilling/views/commonWidgets/textfields/custom_dropdown.dart';
// import 'package:provider/provider.dart';

// class QuotationItem extends StatefulWidget {
//   final int itemNumber;
//   final bool isEditMode;

//   const QuotationItem({
//     super.key,
//     required this.itemNumber,
//     this.isEditMode = false,
//   });

//   @override
//   State<QuotationItem> createState() => _QuotationItemState();
// }

// class _QuotationItemState extends State<QuotationItem> {
//   final Map<String, TextEditingController> _controllers = {};

//   @override
//   void dispose() {
//     for (var controller in _controllers.values) {
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer2<QuotationViewmodel, ProductViewModel>(
//       builder: (context, quotationProvider, productProvider, child) {
//         final list = widget.isEditMode
//             ? quotationProvider.editItemList
//             : quotationProvider.itemList;

//         final item = list.firstWhere(
//           (element) => element.itemNumber == widget.itemNumber,
//           orElse: () => AddProductQuotationModel(itemNumber: widget.itemNumber),
//         );

//         dynamic selectedProduct;
//         try {
//           selectedProduct = productProvider.productList.firstWhere(
//             (p) => p.productId.toString() == item.selectedProduct,
//           );
//         } catch (_) {
//           selectedProduct = null;
//         }

//         return Container(
//           margin: const EdgeInsets.symmetric(vertical: 5),
//           width: double.infinity,
//           padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
//           decoration: BoxDecoration(
//             color: AppColors.white,
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: AppColors.cborder),
//             boxShadow: [
//               BoxShadow(
//                 color: AppColors.c1.withOpacity(0.06),
//                 blurRadius: 14,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildHeader(context, quotationProvider),
//               const SizedBox(height: 10),
//               CustomDropdown(
//                 selectedValue: selectedProduct?.productName,
//                 hint: "Select Product",
//                 dropdownItems: productProvider.productList
//                     .map((c) => c.productName)
//                     .toSet()
//                     .toList(),
//                 onChanged: (String? newValue) {
//                   if (newValue != null) {
//                     final selected = productProvider.productList.firstWhere(
//                       (c) => c.productName == newValue,
//                     );

//                     _updateField(quotationProvider, item.itemNumber,
//                         "selectedProduct", selected.productId.toString());
//                     _updateField(
//                         quotationProvider, item.itemNumber, "quantity", "1");
//                     _updateField(quotationProvider, item.itemNumber,
//                         "unitPrice", selected.unitPrice.toString());
//                     _updateField(quotationProvider, item.itemNumber, "cgst",
//                         selected.cgst.toString());
//                     _updateField(quotationProvider, item.itemNumber, "sgst",
//                         selected.sgst.toString());

//                     _calculateAndUpdateTotals(
//                       quotationProvider,
//                       item.itemNumber,
//                       1,
//                       double.tryParse(selected.unitPrice) ?? 0,
//                       double.tryParse(selected.cgst) ?? 0,
//                       double.tryParse(selected.sgst) ?? 0,
//                     );

//                     productProvider.getProductById(selected.productId);
//                   }
//                 },
//               ),
//               const SizedBox(height: 8),
//               _buildTextFields(context, item),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _updateField(
//       QuotationViewmodel provider, int itemNumber, String field, String value) {
//     if (widget.isEditMode) {
//       provider.updateEditItem(itemNumber, field, value);
//     } else {
//       provider.updateItem(itemNumber, field, value);
//     }
//   }

//   Widget _buildHeader(
//       BuildContext context, QuotationViewmodel quotationProvider) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           "Item No : ${widget.itemNumber}",
//           style: const TextStyle(
//             color: AppColors.cdark,
//             fontSize: 13,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         InkWell(
//           onTap: () => widget.isEditMode
//               ? quotationProvider.removeEditItem(widget.itemNumber)
//               : quotationProvider.removeItem(widget.itemNumber),
//           child: const Icon(Icons.highlight_remove_sharp, color: AppColors.c1),
//         ),
//       ],
//     );
//   }

//   Widget _buildTextFields(BuildContext context, AddProductQuotationModel item) {
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children:
//               _buildFieldSet(context, item, ["quantity", "unitPrice", "total"]),
//         ),
//         const SizedBox(height: 8),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: _buildFieldSet(context, item, ["sgst", "cgst", "subTotal"]),
//         ),
//       ],
//     );
//   }

//   List<Widget> _buildFieldSet(BuildContext context,
//       AddProductQuotationModel item, List<String> fields) {
//     return fields.map((field) {
//       final value = _getFieldValue(item, field);
//       // _controllers[field] ??= TextEditingController(text: value);
//       // _controllers[field]!.text = value;
//       if (!_controllers.containsKey(field)) {
//         _controllers[field] = TextEditingController(text: value);
//       } else if (_controllers[field]!.text != value) {
//         _controllers[field]!.text = value;
//       }

//       // ✅ unitPrice removed — auto-filled from product, not user-editable
//       final isEditable =
//           field == "quantity" || field == "sgst" || field == "cgst";

//       return Column(
//         children: [
//           Text(
//             field.toUpperCase(),
//             style: const TextStyle(
//               color: AppColors.cdark,
//               fontSize: 13,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 5),
//           SizedBox(
//             height: 30,
//             width: 60,
//             child: TextField(
//               controller: _controllers[field],
//               onChanged: isEditable
//                   ? (value) {
//                       final provider = Provider.of<QuotationViewmodel>(context,
//                           listen: false);

//                       _updateField(provider, item.itemNumber, field, value);

//                       final quantity = double.tryParse(
//                               field == "quantity" ? value : item.quantity) ??
//                           0;
//                       final unitPrice = double.tryParse(item.unitPrice) ?? 0;
//                       final cgst = double.tryParse(
//                               field == "cgst" ? value : item.cgst) ??
//                           0;
//                       final sgst = double.tryParse(
//                               field == "sgst" ? value : item.sgst) ??
//                           0;

//                       // ✅ unitPrice removed from trigger — totals still recalculate correctly
//                       if (field == "quantity" ||
//                           field == "cgst" ||
//                           field == "sgst") {
//                         _calculateAndUpdateTotals(provider, item.itemNumber,
//                             quantity, unitPrice, cgst, sgst);
//                       }
//                     }
//                   : null,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                   fontSize: 12,
//                   color: AppColors.ctext,
//                   fontWeight: FontWeight.w400),
//               readOnly: !isEditable,
//               // ✅ Grey background for read-only fields so user knows they can't edit
//               decoration: InputDecoration(
//                 contentPadding:
//                     const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                 isDense: true,
//                 filled: true,
//                 fillColor: AppColors.cxl,
//                 border: const OutlineInputBorder(
//                   borderSide: BorderSide(color: AppColors.cborder),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(color: AppColors.cborder),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(color: AppColors.c1, width: 1.5),
//                 ),
//                 errorBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide:
//                       BorderSide(color: AppColors.tagRed.withOpacity(0.6)),
//                 ),
//                 focusedErrorBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide:
//                       const BorderSide(color: AppColors.tagRed, width: 1.5),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       );
//     }).toList();
//   }

//   void _calculateAndUpdateTotals(
//     QuotationViewmodel provider,
//     int itemNumber,
//     double quantity,
//     double unitPrice,
//     double cgstPercent,
//     double sgstPercent,
//   ) {
//     final total = quantity * unitPrice;
//     final cgstAmount = (total * cgstPercent) / 100.0;
//     final sgstAmount = (total * sgstPercent) / 100.0;
//     final subTotal = total + cgstAmount + sgstAmount;

//     _updateField(provider, itemNumber, "total", total.toStringAsFixed(2));
//     _updateField(provider, itemNumber, "subTotal", subTotal.toStringAsFixed(2));
//   }

//   String _getFieldValue(AddProductQuotationModel item, String field) {
//     switch (field) {
//       case "quantity":
//         return item.quantity;
//       case "unitPrice":
//         return item.unitPrice;
//       case "total":
//         return item.total;
//       case "sgst":
//         return item.sgst;
//       case "cgst":
//         return item.cgst;
//       case "subTotal":
//         return item.subTotal;
//       default:
//         return '';
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/addQuotation_model.dart';
import 'package:pokakbilling/viewmodels/product_viewmodel.dart';
import 'package:pokakbilling/viewmodels/quotation/quotation_viewmodel.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_dropdown.dart';
import 'package:provider/provider.dart';

class QuotationItem extends StatefulWidget {
  final int itemNumber;
  final bool isEditMode;

  const QuotationItem({
    super.key,
    required this.itemNumber,
    this.isEditMode = false,
  });

  @override
  State<QuotationItem> createState() => _QuotationItemState();
}

class _QuotationItemState extends State<QuotationItem> {
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
    return Consumer2<QuotationViewmodel, ProductViewModel>(
      builder: (context, quotationProvider, productProvider, child) {
        final list = widget.isEditMode
            ? quotationProvider.editItemList
            : quotationProvider.itemList;

        final item = list.firstWhere(
          (element) => element.itemNumber == widget.itemNumber,
          orElse: () => AddProductQuotationModel(itemNumber: widget.itemNumber),
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
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cborder),
            boxShadow: [
              BoxShadow(
                color: AppColors.c1.withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, quotationProvider),
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

                    _updateField(quotationProvider, item.itemNumber,
                        "selectedProduct", selected.productId.toString());
                    _updateField(
                        quotationProvider, item.itemNumber, "quantity", "1");
                    _updateField(quotationProvider, item.itemNumber,
                        "unitPrice", selected.unitPrice.toString());
                    _updateField(quotationProvider, item.itemNumber, "cgst",
                        selected.cgst.toString());
                    _updateField(quotationProvider, item.itemNumber, "sgst",
                        selected.sgst.toString());

                    _calculateAndUpdateTotals(
                      quotationProvider,
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

  void _updateField(
      QuotationViewmodel provider, int itemNumber, String field, String value) {
    if (widget.isEditMode) {
      provider.updateEditItem(itemNumber, field, value);
    } else {
      provider.updateItem(itemNumber, field, value);
    }
  }

  Widget _buildHeader(
      BuildContext context, QuotationViewmodel quotationProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Item No : ${widget.itemNumber}",
          style: const TextStyle(
            color: AppColors.cdark,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        InkWell(
          onTap: () => widget.isEditMode
              ? quotationProvider.removeEditItem(widget.itemNumber)
              : quotationProvider.removeItem(widget.itemNumber),
          child: const Icon(Icons.highlight_remove_sharp, color: AppColors.c1),
        ),
      ],
    );
  }

  Widget _buildTextFields(BuildContext context, AddProductQuotationModel item) {
    return Column(
      children: [
        Row(
          children:
              _buildFieldSet(context, item, ["quantity", "unitPrice", "total"]),
        ),
        const SizedBox(height: 8),
        Row(
          children: _buildFieldSet(context, item, ["sgst", "cgst", "subTotal"]),
        ),
      ],
    );
  }

  List<Widget> _buildFieldSet(BuildContext context,
      AddProductQuotationModel item, List<String> fields) {
    return fields.map((field) {
      final value = _getFieldValue(item, field);

      if (!_controllers.containsKey(field)) {
        _controllers[field] = TextEditingController(text: value);
      } else if (_controllers[field]!.text != value) {
        _controllers[field]!.text = value;
      }

      final isEditable =
          field == "quantity" || field == "sgst" || field == "cgst";

      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Column(
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  field.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.cdark,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: 36,
                child: TextField(
                  controller: _controllers[field],
                  onChanged: isEditable
                      ? (value) {
                          final provider = Provider.of<QuotationViewmodel>(
                              context,
                              listen: false);

                          _updateField(provider, item.itemNumber, field, value);

                          final quantity = double.tryParse(field == "quantity"
                                  ? value
                                  : item.quantity) ??
                              0;
                          final unitPrice =
                              double.tryParse(item.unitPrice) ?? 0;
                          final cgst = double.tryParse(
                                  field == "cgst" ? value : item.cgst) ??
                              0;
                          final sgst = double.tryParse(
                                  field == "sgst" ? value : item.sgst) ??
                              0;

                          if (field == "quantity" ||
                              field == "cgst" ||
                              field == "sgst") {
                            _calculateAndUpdateTotals(provider, item.itemNumber,
                                quantity, unitPrice, cgst, sgst);
                          }
                        }
                      : null,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.ctext,
                    fontWeight: FontWeight.w400,
                  ),
                  readOnly: !isEditable,
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.cxl,
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.cborder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.cborder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppColors.c1, width: 1.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: AppColors.tagRed.withOpacity(0.6)),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppColors.tagRed, width: 1.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  void _calculateAndUpdateTotals(
    QuotationViewmodel provider,
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

    _updateField(provider, itemNumber, "total", total.toStringAsFixed(2));
    _updateField(provider, itemNumber, "subTotal", subTotal.toStringAsFixed(2));
  }

  String _getFieldValue(AddProductQuotationModel item, String field) {
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
