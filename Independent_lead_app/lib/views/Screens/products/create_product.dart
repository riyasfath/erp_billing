
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/product_model.dart';
import 'package:pokakbilling/viewmodels/product_viewmodel.dart';
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
        TextEditingController(text: widget.product?.productdescription ?? '');
    categoryController =
        TextEditingController(text: widget.product?.category ?? '');
    unitController =
        TextEditingController(text: widget.product?.unitName ?? '');
    unitPriceController =
        TextEditingController(text: widget.product?.unitPrice ?? '');
    stockController =
        TextEditingController(text: widget.product?.stock.toString() ?? '');
    sgstController = TextEditingController(text: widget.product?.sgst ?? '');
    cgstController = TextEditingController(text: widget.product?.cgst ?? '');
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

  void _handleSubmit(ProductViewModel provider) {
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
        cgstErr != null) return;

    final stock = int.tryParse(stockController.text.trim()) ?? 0;

    if (widget.isEdit) {
      provider.editProduct(
        widget.product?.productId,
        nameController.text.trim(),
        descriptionController.text.trim(),
        unitController.text.trim(),
        unitPriceController.text.trim(),
        categoryController.text.trim(),
        stock,
        sgstController.text.trim(),
        cgstController.text.trim(),
        context,
      );
    } else {
      provider.createProduct(
        nameController.text.trim(),
        descriptionController.text.trim(),
        unitController.text.trim(),
        unitPriceController.text.trim(),
        categoryController.text.trim(),
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

    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            _buildHeader(context, sw, topPad),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Column(
                      children: [
                        _buildSection(
                          icon: Icons.inventory_2_outlined,
                          title: 'Product Information',
                          children: [
                            _field(
                              nameController,
                              'Product Name',
                              Icons.shopping_bag_outlined,
                              isRequired: true,
                              error: _errName,
                              onChanged: (_) {
                                if (_errName != null)
                                  setState(() => _errName = null);
                              },
                            ),
                            _field(
                              descriptionController,
                              'Description',
                              Icons.description_outlined,
                              isRequired: true,
                              error: _errDescription,
                              onChanged: (_) {
                                if (_errDescription != null)
                                  setState(() => _errDescription = null);
                              },
                            ),
                            _field(
                              categoryController,
                              'Category',
                              Icons.category_outlined,
                              isRequired: true,
                              error: _errCategory,
                              onChanged: (_) {
                                if (_errCategory != null)
                                  setState(() => _errCategory = null);
                              },
                            ),
                            _field(
                              unitController,
                              'Unit',
                              Icons.straighten_outlined,
                              isRequired: true,
                              error: _errUnit,
                              onChanged: (_) {
                                if (_errUnit != null)
                                  setState(() => _errUnit = null);
                              },
                            ),
                            _field(
                              unitPriceController,
                              'Unit Price',
                              Icons.currency_rupee,
                              isRequired: true,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d{0,2}')),
                              ],
                              error: _errUnitPrice,
                              onChanged: (_) {
                                if (_errUnitPrice != null)
                                  setState(() => _errUnitPrice = null);
                              },
                            ),
                            _field(
                              stockController,
                              'Stock',
                              Icons.inventory_outlined,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              error: _errStock,
                              onChanged: (_) {
                                if (_errStock != null)
                                  setState(() => _errStock = null);
                              },
                            ),
                            _field(
                              sgstController,
                              'SGST %',
                              Icons.percent_outlined,
                              isRequired: true,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              error: _errSgst,
                              onChanged: (_) {
                                if (_errSgst != null)
                                  setState(() => _errSgst = null);
                              },
                            ),
                            _field(
                              cgstController,
                              'CGST %',
                              Icons.percent_outlined,
                              isRequired: true,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              error: _errCgst,
                              onChanged: (_) {
                                if (_errCgst != null)
                                  setState(() => _errCgst = null);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Consumer<ProductViewModel>(
                          builder: (context, vm, _) => _buildSaveBar(vm),
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double sw, double topPad) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: 8,
        bottom: 13,
        left: sw * 0.045,
        right: sw * 0.045,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.cborder, width: 1.5),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.cxl,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cborder),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.c3,
                size: 15,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isEdit ? 'Edit Product' : 'New Product',
                style: const TextStyle(
                  color: AppColors.cdark,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                widget.isEdit
                    ? 'Update product details'
                    : 'Enter product details',
                style: const TextStyle(
                  color: AppColors.ctext,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
    Widget? trailing,
  }) {
    return Container(
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
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.cxl,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cborder),
                ),
                child: Icon(icon, color: AppColors.c1, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cdark,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const Divider(height: 20, thickness: 1, color: AppColors.cborder),
          ...children,
        ],
      ),
    );
  }

  // ── Text field — label turns red on error ─────────────────────────────────
  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isRequired = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? error,
    void Function(String)? onChanged,
  }) {
    final hasError = error != null && error.isNotEmpty;

    // ── Label color: red when error, accent when focused, grey otherwise
    final labelColor =
        hasError ? AppColors.red : AppColors.ctext.withOpacity(0.75);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            cursorColor: AppColors.c1,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.cdark,
            ),
            decoration: InputDecoration(
              labelText: label,
              // ── FIX: drive label colour via labelStyle + floatingLabelStyle
              // so both the resting hint position AND the floated label
              // turn red when there is a validation error.
              labelStyle: TextStyle(
                fontSize: 13,
                color: labelColor,
              ),
              floatingLabelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                // Floated label: red on error, primary accent otherwise
                color: hasError ? AppColors.red : AppColors.c1,
              ),
              prefixIcon: Icon(
                icon,
                size: 18,
                color: hasError ? AppColors.red : AppColors.c1,
              ),
              suffixIcon: isRequired
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.circle,
                        size: 6,
                        color: AppColors.red,
                      ),
                    )
                  : null,
              suffixIconConstraints:
                  const BoxConstraints(minWidth: 32, minHeight: 32),
              filled: true,
              fillColor:
                  hasError ? AppColors.red.withOpacity(0.04) : AppColors.cxl,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: hasError
                        ? AppColors.red.withOpacity(0.60)
                        : AppColors.cborder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: hasError
                        ? AppColors.red.withOpacity(0.60)
                        : AppColors.cborder),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.cborder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: hasError ? AppColors.red : AppColors.c1, width: 1.5),
              ),
            ),
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 13, color: AppColors.red),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      error,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.red,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSaveBar(ProductViewModel vm) {
    return SafeArea(
      top: false,
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.c1,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppColors.c1.withOpacity(0.30),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: vm.addProductLoader ? null : () => _handleSubmit(vm),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: vm.addProductLoader
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: AppColors.white, strokeWidth: 2),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.isEdit
                            ? Icons.check_rounded
                            : Icons.inventory_2_outlined,
                        color: AppColors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.isEdit ? 'Save Changes' : 'Save Product',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
