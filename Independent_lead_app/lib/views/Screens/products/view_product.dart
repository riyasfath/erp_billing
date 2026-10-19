import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/core/utils/text_utils.dart';
import 'package:pokakbilling/models/data-models/product_model.dart';

class ViewProduct extends StatefulWidget {
  final ProductModel product;
  const ViewProduct({super.key, required this.product});

  @override
  State<ViewProduct> createState() => _ViewProductState();
}

class _ViewProductState extends State<ViewProduct>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final topPad = MediaQuery.of(context).padding.top;
    final product = widget.product;
    final initial = product.productName.isNotEmpty
        ? product.productName[0].toUpperCase()
        : '';
    final bool inStock = product.stock > 0;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          _buildHeader(context, sw, topPad, product, initial, inStock),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  child: Column(
                    children: [
                      _buildInfoCard(
                        icon: Icons.inventory_2_outlined,
                        title: 'Product Details',
                        rows: [
                          _InfoRow(Icons.label_outline, 'Product Name',
                              product.productName),
                          _InfoRow(Icons.description_outlined, 'Description',
                              product.productdescription),
                          _InfoRow(Icons.category_outlined, 'Category',
                              product.category),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        icon: Icons.attach_money_outlined,
                        title: 'Pricing',
                        rows: [
                          _InfoRow(Icons.straighten, 'Unit', product.unitName),
                          _InfoRow(Icons.currency_rupee, 'Unit Price',
                              product.unitPrice),
                          _InfoRow(Icons.inventory_outlined, 'Stock',
                              product.stock.toString()),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        icon: Icons.receipt_long_outlined,
                        title: 'Tax Details',
                        rows: [
                          _InfoRow(
                              Icons.percent, 'CGST', product.cgst.toString()),
                          _InfoRow(
                              Icons.percent, 'SGST', product.sgst.toString()),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildExitButton(context),
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
  Widget _buildHeader(
    BuildContext context,
    double sw,
    double topPad,
    ProductModel product,
    String initial,
    bool inStock,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: topPad + 8,
        bottom: 16,
        left: sw * 0.045,
        right: sw * 0.045,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.cborder, width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: back + title + ID badge ──────────────────────────
          Row(
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
              const Expanded(
                child: Text(
                  'Product View',
                  style: TextStyle(
                    color: AppColors.cdark,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.cxl,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cborder),
                ),
                child: Text(
                  'ID #${product.productId}',
                  style: const TextStyle(
                    color: AppColors.c1,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Product avatar + name + stock badge ───────────────────────
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.cxl,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.cborder, width: 2),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: AppColors.c1,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.cdark,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.category_outlined,
                            size: 13, color: AppColors.ctext),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            product.category[0].toUpperCase() +
                                product.category.substring(1),
                            style: const TextStyle(
                              color: AppColors.ctext,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: inStock ? AppColors.tagGreenBg : AppColors.tagRedBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: inStock
                        ? AppColors.tagGreen.withOpacity(0.30)
                        : AppColors.tagRed.withOpacity(0.30),
                  ),
                ),
                child: Text(
                  inStock ? 'IN STOCK' : 'OUT OF STOCK',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: inStock ? AppColors.tagGreen : AppColors.tagRed,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Info card ─────────────────────────────────────────────────────────────
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required List<_InfoRow> rows,
  }) {
    final visibleRows = rows.where((r) => r.value.isNotEmpty).toList();
    if (visibleRows.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cborder),
        boxShadow: [
          BoxShadow(
            color: AppColors.c1.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
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
                Text(
                  capitalizeWords(title),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cdark,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.cborder),

          // Field rows
          ...visibleRows.asMap().entries.map((entry) {
            final i = entry.key;
            final row = entry.value;
            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.cxl,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.cborder),
                        ),
                        child: Icon(row.icon, size: 14, color: AppColors.c1),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              row.label,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.ctext,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              row.value[0].toUpperCase() +
                                  row.value.substring(1),
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.cdark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < visibleRows.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.cborder,
                    indent: 56,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ── Go back button ────────────────────────────────────────────────────────
  Widget _buildExitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.c1,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: AppColors.c1.withOpacity(0.25),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.white, size: 14),
              SizedBox(width: 8),
              Text(
                'Go Back',
                style: TextStyle(
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
    );
  }
}

class _InfoRow {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);
}
