import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokakbilling/ERP_UI_KIT.dart';
import 'package:pokakbilling/models/data-models/addQuotation_model.dart';
import 'package:pokakbilling/viewmodels/product_viewmodel.dart';
import 'package:pokakbilling/viewmodels/quotation/quotation_viewmodel.dart';
import 'package:provider/provider.dart';

class QuotationItem extends StatefulWidget {
  final int itemNumber;

  const QuotationItem({super.key, required this.itemNumber});

  @override
  State<QuotationItem> createState() => _QuotationItemState();
}

class _QuotationItemState extends State<QuotationItem> {
  final Map<String, TextEditingController> _controllers = {};

  /// The max stock available for the currently selected product.
  /// -1 means no product selected yet (quantity field stays disabled).
  int _maxStock = -1;

  /// The last valid quantity the user committed.
  int _lastCommittedQty = 0;

  /// Currently selected product id — used for stock restore on qty change.
  int? _selectedProductId;

  /// Inline error message shown below the fields.
  String? _stockError;

  static const Color _accent = ErpColors.blue;

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
        final item = quotationProvider.itemList.firstWhere(
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

        final productNames = productProvider.productList
            .map((c) => c.productName)
            .toSet()
            .toList();
        final String? selectedName = selectedProduct?.productName;

        return ErpFadeIn(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _stockError != null
                    ? ErpColors.red.withValues(alpha: 0.45)
                    : _accent.withValues(alpha: 0.22),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _accent.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Accent strip
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [ErpColors.tint(_accent, 0.35), _accent],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, quotationProvider, productProvider,
                          selectedName),
                      const SizedBox(height: 12),

                      // ── Product Dropdown ──────────────────────────────────
                      DropdownButtonFormField<String>(
                        // Key forces a rebuild when the selected product
                        // changes from outside (e.g. items re-ordered).
                        key: ValueKey(
                            'prod_${widget.itemNumber}_${selectedName ?? ''}'),
                        initialValue: productNames.contains(selectedName)
                            ? selectedName
                            : null,
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        icon: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: _accent.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.keyboard_arrow_down_rounded,
                              size: 20, color: ErpColors.shade(_accent, 0.1)),
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: ErpColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                        hint: Text(
                          'Select Product',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: ErpColors.slate.withValues(alpha: 0.7),
                          ),
                        ),
                        decoration: erpInputDecoration(
                          hint: '',
                          icon: Icons.shopping_bag_rounded,
                          color: _accent,
                        ),
                        items: productNames
                            .map((e) => DropdownMenuItem<String>(
                                  value: e,
                                  child: Text(
                                    e,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: ErpColors.ink,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (String? newValue) {
                          if (newValue == null) return;

                          final selected =
                              productProvider.productList.firstWhere(
                            (c) => c.productName == newValue,
                          );

                          // Restore stock for previously selected product
                          if (_selectedProductId != null &&
                              _lastCommittedQty > 0) {
                            productProvider.restoreStock(
                                _selectedProductId!, _lastCommittedQty);
                          }

                          setState(() {
                            _selectedProductId = selected.productId;
                            _maxStock = selected.stock;
                            _stockError = null;
                            _lastCommittedQty = 0;
                          });

                          if (_controllers["quantity"] != null) {
                            _controllers["quantity"]!.text = "1";
                          }

                          quotationProvider.updateItem(item.itemNumber,
                              "selectedProduct", selected.productId.toString());
                          quotationProvider.updateItem(
                              item.itemNumber, "quantity", "1");
                          quotationProvider.updateItem(item.itemNumber,
                              "unitPrice", selected.unitPrice.toString());
                          quotationProvider.updateItem(item.itemNumber, "cgst",
                              selected.cgst.toString());
                          quotationProvider.updateItem(item.itemNumber, "sgst",
                              selected.sgst.toString());

                          _calculateAndUpdateTotals(
                            quotationProvider,
                            item.itemNumber,
                            1,
                            double.tryParse(selected.unitPrice) ?? 0,
                            double.tryParse(selected.cgst) ?? 0,
                            double.tryParse(selected.sgst) ?? 0,
                          );

                          setState(() => _lastCommittedQty = 1);
                        },
                      ),

                      // ── Hint / stock badge ────────────────────────────────
                      const SizedBox(height: 8),
                      if (_maxStock == -1)
                        _infoChip(
                          Icons.info_outline_rounded,
                          'Select a product to enter quantity',
                          _accent,
                        )
                      else
                        _infoChip(
                          Icons.inventory_2_rounded,
                          'Available stock: $_maxStock',
                          _maxStock == 0 ? ErpColors.red : ErpColors.green,
                        ),

                      const SizedBox(height: 12),
                      _buildTextFields(context, item, quotationProvider),

                      // ── Stock error ───────────────────────────────────────
                      if (_stockError != null) ErpErrorText(_stockError!),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: ErpColors.shade(color, 0.1)),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: ErpColors.shade(color, 0.15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    QuotationViewmodel quotationProvider,
    ProductViewModel productProvider,
    String? selectedName,
  ) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [ErpColors.tint(_accent, 0.2), _accent],
            ),
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(
                color: _accent.withValues(alpha: 0.30),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '${widget.itemNumber}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Item No : ${widget.itemNumber}',
                style: const TextStyle(
                  color: ErpColors.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                selectedName ?? 'No product selected',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: ErpColors.slate,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        ErpPressable(
          onTap: () {
            if (_selectedProductId != null && _lastCommittedQty > 0) {
              productProvider.restoreStock(
                  _selectedProductId!, _lastCommittedQty);
            }
            quotationProvider.removeItem(widget.itemNumber);
          },
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: ErpColors.red.withValues(alpha: 0.10),
              shape: BoxShape.circle,
              border: Border.all(color: ErpColors.red.withValues(alpha: 0.25)),
            ),
            child: const Icon(Icons.close_rounded,
                size: 18, color: ErpColors.red),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFields(
    BuildContext context,
    AddQuotationModel item,
    QuotationViewmodel quotationProvider,
  ) {
    return Column(
      children: [
        Row(
          children: _buildFieldSet(
            context,
            item,
            quotationProvider,
            ["quantity", "unitPrice", "total"],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: _buildFieldSet(
            context,
            item,
            quotationProvider,
            ["sgst", "cgst", "subTotal"],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFieldSet(
    BuildContext context,
    AddQuotationModel item,
    QuotationViewmodel quotationProvider,
    List<String> fields,
  ) {
    return fields.map((field) {
      final value = _getFieldValue(item, field);

      if (_controllers[field] == null) {
        _controllers[field] = TextEditingController(text: value);
      }
      if (_controllers[field]!.text != value) {
        _controllers[field]!.text = value;
      }

      final bool productSelected = _maxStock >= 0;

      final isEditable = (field == "quantity" && productSelected) ||
          field == "unitPrice" ||
          field == "sgst" ||
          field == "cgst";

      final bool isQuantityLocked = field == "quantity" && !productSelected;
      final bool isComputed = field == "total" || field == "subTotal";

      List<TextInputFormatter> formatters = [];
      if (field == "quantity") {
        formatters = [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(6),
        ];
      } else if (field == "unitPrice" || field == "sgst" || field == "cgst") {
        formatters = [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          LengthLimitingTextInputFormatter(10),
        ];
      }

      final bool showStockBorderError =
          field == "quantity" && _stockError != null;

      // Colours per field type
      final Color fieldColor = showStockBorderError
          ? ErpColors.red
          : (isComputed ? ErpColors.green : _accent);
      final Color fill = isQuantityLocked
          ? ErpColors.line.withValues(alpha: 0.6)
          : (isComputed
              ? ErpColors.green.withValues(alpha: 0.08)
              : (showStockBorderError
                  ? ErpColors.red.withValues(alpha: 0.05)
                  : ErpColors.pageBg));
      final Color borderC = showStockBorderError
          ? ErpColors.red.withValues(alpha: 0.7)
          : (isComputed
              ? ErpColors.green.withValues(alpha: 0.30)
              : ErpColors.line);

      OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: c, width: w),
          );

      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Column(
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isComputed) ...[
                      const Icon(Icons.auto_awesome_rounded,
                          size: 11, color: ErpColors.green),
                      const SizedBox(width: 3),
                    ],
                    Text(
                      _getFieldLabel(field),
                      style: TextStyle(
                        color: isComputed
                            ? ErpColors.shade(ErpColors.green, 0.1)
                            : ErpColors.slate,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: 40,
                child: TextField(
                  controller: _controllers[field],
                  inputFormatters: formatters,
                  cursorColor: fieldColor,
                  onChanged: isEditable
                      ? (value) {
                          if (field == "quantity") {
                            final enteredQty = int.tryParse(value) ?? 0;
                            if (enteredQty > _maxStock) {
                              setState(() {
                                _stockError =
                                    'Only $_maxStock units available in stock';
                              });
                            } else {
                              setState(() => _stockError = null);
                            }
                          }

                          quotationProvider.updateItem(
                              item.itemNumber, field, value);

                          final quantity = double.tryParse(
                                field == "quantity" ? value : item.quantity,
                              ) ??
                              0;
                          final unitPrice = double.tryParse(
                                field == "unitPrice" ? value : item.unitPrice,
                              ) ??
                              0;
                          final cgst = double.tryParse(
                                field == "cgst" ? value : item.cgst,
                              ) ??
                              0;
                          final sgst = double.tryParse(
                                field == "sgst" ? value : item.sgst,
                              ) ??
                              0;

                          _calculateAndUpdateTotals(
                            quotationProvider,
                            item.itemNumber,
                            quantity,
                            unitPrice,
                            cgst,
                            sgst,
                          );
                        }
                      : null,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isQuantityLocked
                        ? ErpColors.slate.withValues(alpha: 0.5)
                        : (isComputed
                            ? ErpColors.shade(ErpColors.green, 0.15)
                            : ErpColors.ink),
                    fontWeight: isComputed ? FontWeight.w900 : FontWeight.w700,
                  ),
                  readOnly: !isEditable,
                  keyboardType: isEditable
                      ? (field == "quantity"
                          ? TextInputType.number
                          : const TextInputType.numberWithOptions(
                              decimal: true))
                      : TextInputType.none,
                  decoration: InputDecoration(
                    hintText: isQuantityLocked ? "—" : null,
                    hintStyle: TextStyle(
                        color: ErpColors.slate.withValues(alpha: 0.5)),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 6,
                    ),
                    isDense: true,
                    filled: true,
                    fillColor: fill,
                    border: border(borderC),
                    enabledBorder: border(borderC),
                    focusedBorder: border(
                        isEditable ? fieldColor : borderC,
                        isEditable ? 1.6 : 1),
                    errorBorder:
                        border(ErpColors.red.withValues(alpha: 0.6)),
                    focusedErrorBorder: border(ErpColors.red, 1.6),
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
    const double maxSafeValue = 99999999.99;

    final rawTotal = quantity * unitPrice;
    final total = rawTotal.clamp(0.0, maxSafeValue);

    final cgstAmount = (total * cgstPercent) / 100.0;
    final sgstAmount = (total * sgstPercent) / 100.0;
    final rawSubTotal = total + cgstAmount + sgstAmount;
    final subTotal = rawSubTotal.clamp(0.0, maxSafeValue);

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

  String _getFieldLabel(String field) {
    switch (field) {
      case "quantity":
        return "QTY";
      case "unitPrice":
        return "PRICE";
      case "total":
        return "TOTAL";
      case "sgst":
        return "SGST%";
      case "cgst":
        return "CGST%";
      case "subTotal":
        return "SUB TOTAL";
      default:
        return field.toUpperCase();
    }
  }
}