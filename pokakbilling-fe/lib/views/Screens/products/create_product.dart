import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokakbilling/ERP_UI_KIT.dart';
import 'package:pokakbilling/models/data-models/product_model.dart';
import 'package:pokakbilling/viewmodels/product_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/category_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/unit_viewmodel.dart';
import 'package:provider/provider.dart';

class AddProduct extends StatefulWidget {
  final bool isEdit;
  final ProductModel? product;

  const AddProduct({
    super.key,
    required this.isEdit,
    this.product,
  });

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController categoryController;
  late TextEditingController unitController;
  late TextEditingController unitPriceController;
  late TextEditingController stockController;
  late TextEditingController sgstController;
  late TextEditingController cgstController;

  // ── Manual field errors ───────────────────────────────────────────────────
  String? _errName;
  String? _errDescription;
  String? _errCategory;
  String? _errUnit;
  String? _errUnitPrice;
  String? _errStock;
  String? _errSgst;
  String? _errCgst;

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();

    nameController =
        TextEditingController(text: widget.product?.productName ?? '');
    descriptionController =
        TextEditingController(text: widget.product?.productDescription ?? '');
    categoryController =
        TextEditingController(text: widget.product?.categoryName ?? '');
    unitController =
        TextEditingController(text: widget.product?.unitName ?? '');
    unitPriceController =
        TextEditingController(text: widget.product?.unitPrice ?? '');
    stockController =
        TextEditingController(text: widget.product?.stock.toString() ?? '');
    sgstController = TextEditingController(text: widget.product?.sgst ?? '');
    cgstController = TextEditingController(text: widget.product?.cgst ?? '');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final categoryProvider =
          Provider.of<CategoryViewmodel>(context, listen: false);
      if (widget.isEdit && widget.product != null) {
        categoryProvider.updateSelectedCategoryId(widget.product!.categoryId);
      }
      if (categoryProvider.categoryList.isEmpty) {
        categoryProvider.getAllCategory();
      }
      final unitProvider = Provider.of<UnitViewmodel>(context, listen: false);
      if (unitProvider.unitList.isEmpty) {
        unitProvider.getAllUnits();
      }
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    nameController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    unitController.dispose();
    unitPriceController.dispose();
    stockController.dispose();
    sgstController.dispose();
    cgstController.dispose();
    super.dispose();
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  void _handleSubmit(
    ProductViewModel productVM,
    CategoryViewmodel categoryVM,
  ) {
    FocusScope.of(context).unfocus();

    final nameErr =
        nameController.text.trim().isEmpty ? 'Product name is required' : null;
    final descErr = descriptionController.text.trim().isEmpty
        ? 'Description is required'
        : null;
    final catErr =
        categoryController.text.trim().isEmpty ? 'Category is required' : null;
    final unitErr =
        unitController.text.trim().isEmpty ? 'Unit is required' : null;

    String? priceErr;
    if (unitPriceController.text.trim().isEmpty) {
      priceErr = 'Unit price is required';
    } else {
      final price = double.tryParse(unitPriceController.text.trim());
      if (price == null) {
        priceErr = 'Enter a valid unit price';
      } else if (price <= 0) {
        priceErr = 'Unit price must be greater than 0';
      }
    }

    String? stockErr;
    if (stockController.text.trim().isNotEmpty) {
      final stock = int.tryParse(stockController.text.trim());
      if (stock == null) {
        stockErr = 'Enter valid stock quantity';
      } else if (stock < 0) {
        stockErr = 'Stock cannot be negative';
      }
    }

    String? sgstErr;
    if (sgstController.text.trim().isEmpty) {
      sgstErr = 'SGST percentage is required';
    } else {
      final sgst = double.tryParse(sgstController.text.trim());
      if (sgst == null) {
        sgstErr = 'Enter valid SGST percentage';
      } else if (sgst < 0 || sgst > 100) {
        sgstErr = 'SGST must be between 0 and 100';
      }
    }

    String? cgstErr;
    if (cgstController.text.trim().isEmpty) {
      cgstErr = 'CGST percentage is required';
    } else {
      final cgst = double.tryParse(cgstController.text.trim());
      if (cgst == null) {
        cgstErr = 'Enter valid CGST percentage';
      } else if (cgst < 0 || cgst > 100) {
        cgstErr = 'CGST must be between 0 and 100';
      }
    }

    setState(() {
      _errName = nameErr;
      _errDescription = descErr;
      _errCategory = catErr;
      _errUnit = unitErr;
      _errUnitPrice = priceErr;
      _errStock = stockErr;
      _errSgst = sgstErr;
      _errCgst = cgstErr;
    });

    if (nameErr != null ||
        descErr != null ||
        catErr != null ||
        unitErr != null ||
        priceErr != null ||
        stockErr != null ||
        sgstErr != null ||
        cgstErr != null) {
      return;
    }

    final stock = int.tryParse(stockController.text.trim()) ?? 0;

    if (widget.isEdit) {
      productVM.editProduct(
        widget.product?.productId,
        nameController.text.trim(),
        descriptionController.text.trim(),
        unitController.text.trim(),
        unitPriceController.text.trim(),
        categoryVM.selectedCategoryId,
        stock,
        sgstController.text.trim(),
        cgstController.text.trim(),
        context,
      );
    } else {
      productVM.createProduct(
        nameController.text.trim(),
        descriptionController.text.trim(),
        unitController.text.trim(),
        unitPriceController.text.trim(),
        categoryVM.selectedCategoryId,
        stock,
        sgstController.text.trim(),
        cgstController.text.trim(),
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final topPad = MediaQuery.of(context).padding.top;

    final decimalFormatter = [
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
    ];

    return Scaffold(
      backgroundColor: ErpColors.pageBg,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          _buildHeader(context, sw, topPad),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(sw * 0.04, 18, sw * 0.04, 24),
                  child: Column(
                    children: [
                      // ── Product information ──────────────────────────────
                      ErpFadeIn(
                        index: 0,
                        child: _buildSection(
                          icon: Icons.inventory_2_rounded,
                          color: ErpColors.cyan,
                          title: 'Product Information',
                          subtitle: 'Name, description, category & unit',
                          children: [
                            _field(
                              nameController,
                              'Product Name',
                              Icons.shopping_bag_rounded,
                              hint: 'e.g. Wireless Mouse',
                              isRequired: true,
                              error: _errName,
                              onChanged: (_) {
                                if (_errName != null) {
                                  setState(() => _errName = null);
                                }
                              },
                            ),
                            _field(
                              descriptionController,
                              'Description',
                              Icons.description_rounded,
                              hint: 'Short description of the product',
                              isRequired: true,
                              maxLines: 3,
                              error: _errDescription,
                              onChanged: (_) {
                                if (_errDescription != null) {
                                  setState(() => _errDescription = null);
                                }
                              },
                            ),

                            // ── Category dropdown ─────────────────────────
                            Consumer<CategoryViewmodel>(
                              builder: (context, categoryVM, _) {
                                return _buildDropdownField(
                                  label: 'Category',
                                  icon: Icons.category_rounded,
                                  isRequired: true,
                                  error: _errCategory,
                                  isLoading: categoryVM.getCatogoryLoader,
                                  isEmpty: categoryVM.categoryList.isEmpty,
                                  emptyText: 'No categories available',
                                  value: categoryVM.categoryList.any((c) =>
                                          c.categoryName ==
                                          categoryController.text)
                                      ? categoryController.text
                                      : null,
                                  items: categoryVM.categoryList
                                      .map((c) => c.categoryName)
                                      .toSet()
                                      .toList(),
                                  onChanged: (v) {
                                    if (v == null) return;
                                    final selected =
                                        categoryVM.categoryList.firstWhere(
                                      (c) => c.categoryName == v,
                                    );
                                    categoryVM.updateSelectedCategoryId(
                                        selected.categoryId);
                                    categoryVM
                                        .selectCategory(selected.categoryName);
                                    categoryController.text =
                                        selected.categoryName;
                                    if (_errCategory != null) {
                                      setState(() => _errCategory = null);
                                    }
                                  },
                                );
                              },
                            ),

                            // ── Unit dropdown ─────────────────────────────
                            Consumer<UnitViewmodel>(
                              builder: (context, unitVM, _) {
                                return _buildDropdownField(
                                  label: 'Unit',
                                  icon: Icons.straighten_rounded,
                                  isRequired: true,
                                  error: _errUnit,
                                  isLoading: unitVM.getUnitLoader,
                                  isEmpty: unitVM.unitList.isEmpty,
                                  emptyText: 'No units available',
                                  value: unitVM.unitList
                                          .map((u) => u.unitName)
                                          .contains(unitController.text)
                                      ? unitController.text
                                      : null,
                                  items: unitVM.unitList
                                      .map((u) => u.unitName)
                                      .toSet()
                                      .toList(),
                                  onChanged: (v) {
                                    if (v == null) return;
                                    unitVM.selectUnit(v);
                                    unitController.text = v;
                                    if (_errUnit != null) {
                                      setState(() => _errUnit = null);
                                    }
                                  },
                                  bottomGap: 0,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ── Pricing & stock ──────────────────────────────────
                      ErpFadeIn(
                        index: 1,
                        child: _buildSection(
                          icon: Icons.currency_rupee_rounded,
                          color: ErpColors.green,
                          title: 'Pricing & Stock',
                          subtitle: 'Selling price and quantity in hand',
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _field(
                                    unitPriceController,
                                    'Unit Price',
                                    Icons.currency_rupee_rounded,
                                    hint: '0.00',
                                    color: ErpColors.green,
                                    isRequired: true,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    inputFormatters: decimalFormatter,
                                    error: _errUnitPrice,
                                    bottomGap: 0,
                                    onChanged: (_) {
                                      if (_errUnitPrice != null) {
                                        setState(() => _errUnitPrice = null);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _field(
                                    stockController,
                                    'Stock',
                                    Icons.inventory_rounded,
                                    hint: '0',
                                    color: ErpColors.green,
                                    isOptional: true,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    error: _errStock,
                                    bottomGap: 0,
                                    onChanged: (_) {
                                      if (_errStock != null) {
                                        setState(() => _errStock = null);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ── Tax details ──────────────────────────────────────
                      ErpFadeIn(
                        index: 2,
                        child: _buildSection(
                          icon: Icons.receipt_long_rounded,
                          color: ErpColors.violet,
                          title: 'Tax Details',
                          subtitle: 'GST split for this product',
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _field(
                                    sgstController,
                                    'SGST %',
                                    Icons.percent_rounded,
                                    hint: '0',
                                    color: ErpColors.violet,
                                    isRequired: true,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    inputFormatters: decimalFormatter,
                                    error: _errSgst,
                                    bottomGap: 0,
                                    onChanged: (_) {
                                      if (_errSgst != null) {
                                        setState(() => _errSgst = null);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _field(
                                    cgstController,
                                    'CGST %',
                                    Icons.percent_rounded,
                                    hint: '0',
                                    color: ErpColors.violet,
                                    isRequired: true,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    inputFormatters: decimalFormatter,
                                    error: _errCgst,
                                    bottomGap: 0,
                                    onChanged: (_) {
                                      if (_errCgst != null) {
                                        setState(() => _errCgst = null);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ErpFadeIn(
                        index: 3,
                        child: Consumer2<ProductViewModel, CategoryViewmodel>(
                          builder: (context, productVM, categoryVM, _) =>
                              _buildSaveBar(productVM, categoryVM),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 16,
                      ),
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

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, double sw, double topPad) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: ErpColors.headerGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: ErpColors.cyan.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -34,
            top: -44,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 24,
            top: topPad + 6,
            child: Transform.rotate(
              angle: -0.25,
              child: Icon(
                  widget.isEdit
                      ? Icons.edit_note_rounded
                      : Icons.add_box_rounded,
                  size: 86,
                  color: Colors.white.withValues(alpha: 0.13)),
            ),
          ),
          Positioned(
            left: -26,
            bottom: -34,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: topPad + 12,
              bottom: 26,
              left: sw * 0.045,
              right: sw * 0.045,
            ),
            child: Row(
              children: [
                ErpPressable(
                  onTap: () => Navigator.pop(context),
                  child: const ErpGlassCircle(
                      icon: Icons.arrow_back_ios_new_rounded, iconSize: 19),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isEdit ? 'Edit Product' : 'New Product',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.isEdit
                            ? 'Update product details'
                            : 'Enter product details',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section card ──────────────────────────────────────────────────────────
  Widget _buildSection({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ErpColors.line),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ErpGradientTile(icon: icon, color: color, size: 40),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                        color: ErpColors.ink,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: ErpColors.slate),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, thickness: 1, color: ErpColors.line),
          ),
          ...children,
        ],
      ),
    );
  }

  // ── Text field (label above, kit decoration) ──────────────────────────────
  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    String? hint,
    bool isRequired = false,
    bool isOptional = false,
    Color color = ErpColors.cyan,
    int maxLines = 1,
    double bottomGap = 14,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? error,
    void Function(String)? onChanged,
  }) {
    final hasError = error != null && error.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ErpFieldLabel(label, isRequired: isRequired, isOptional: isOptional),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            cursorColor: color,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            minLines: 1,
            maxLines: maxLines,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: hasError ? ErpColors.red : ErpColors.ink,
            ),
            decoration: erpInputDecoration(
              hint: hint ?? 'Enter ${label.toLowerCase()}',
              icon: icon,
              hasError: hasError,
              color: color,
            ),
          ),
          if (hasError) ErpErrorText(error),
        ],
      ),
    );
  }

  // ── Dropdown field (Category / Unit) ──────────────────────────────────────
  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    bool isRequired = false,
    String? error,
    required bool isLoading,
    required bool isEmpty,
    required String emptyText,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    double bottomGap = 14,
  }) {
    final hasError = error != null && error.isNotEmpty;

    Widget statusBox(Widget child) => Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: hasError
                ? ErpColors.red.withValues(alpha: 0.04)
                : ErpColors.pageBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError
                  ? ErpColors.red.withValues(alpha: 0.6)
                  : ErpColors.line,
            ),
          ),
          child: child,
        );

    return Padding(
      padding: EdgeInsets.only(bottom: bottomGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ErpFieldLabel(label, isRequired: isRequired),
          if (isLoading)
            statusBox(
              const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      color: ErpColors.cyan, strokeWidth: 2),
                ),
              ),
            )
          else if (isEmpty)
            statusBox(
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: (hasError ? ErpColors.red : ErpColors.slate)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(icon,
                        size: 16,
                        color: hasError ? ErpColors.red : ErpColors.slate),
                  ),
                  const SizedBox(width: 10),
                  Text(emptyText,
                      style: TextStyle(
                          color: hasError ? ErpColors.red : ErpColors.slate,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5)),
                ],
              ),
            )
          else
            DropdownButtonFormField<String>(
              initialValue: value,
              isExpanded: true,
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(16),
              icon: Container(
                width: 26,
                height: 26,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: (hasError ? ErpColors.red : ErpColors.cyan)
                      .withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.keyboard_arrow_down_rounded,
                    color: hasError ? ErpColors.red : ErpColors.cyanDeep,
                    size: 19),
              ),
              style: const TextStyle(
                  fontSize: 14.5,
                  color: ErpColors.ink,
                  fontWeight: FontWeight.w600),
              hint: Text(
                'Select ${label.toLowerCase()}',
                style: TextStyle(
                  fontSize: 13.5,
                  color: hasError
                      ? ErpColors.red.withValues(alpha: 0.7)
                      : ErpColors.slate.withValues(alpha: 0.7),
                ),
              ),
              items: items
                  .map((name) => DropdownMenuItem(
                        value: name,
                        child: Text(name,
                            style: const TextStyle(
                                color: ErpColors.ink,
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                      ))
                  .toList(),
              onChanged: onChanged,
              decoration: erpInputDecoration(
                hint: '',
                icon: icon,
                hasError: hasError,
              ),
            ),
          if (hasError) ErpErrorText(error),
        ],
      ),
    );
  }

  // ── Save bar ──────────────────────────────────────────────────────────────
  Widget _buildSaveBar(
      ProductViewModel productVM, CategoryViewmodel categoryVM) {
    final isLoading = productVM.addProductLoader;

    return SafeArea(
      top: false,
      child: Column(
        children: [
          ErpPrimaryButton(
            text: widget.isEdit ? 'Save Changes' : 'Save Product',
            icon: widget.isEdit
                ? Icons.check_rounded
                : Icons.inventory_2_rounded,
            loading: isLoading,
            onTap: () => _handleSubmit(productVM, categoryVM),
          ),
          const SizedBox(height: 12),
          ErpSecondaryButton(
            text: 'Cancel',
            onTap: isLoading ? null : () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}