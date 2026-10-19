import 'package:flutter/material.dart';
import 'package:pokakbilling/ERP_UI_KIT.dart';
import 'package:pokakbilling/viewmodels/product_viewmodel.dart';
import 'package:provider/provider.dart';

// ── Utility ───────────────────────────────────────────────────────────────────
String _capitalizeWords(String text) => text
    .split(' ')
    .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : w)
    .join(' ');

class ViewStockProduct extends StatefulWidget {
  const ViewStockProduct({super.key});

  @override
  State<ViewStockProduct> createState() => _ViewStockProductState();
}

class _ViewStockProductState extends State<ViewStockProduct>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

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
    final productProvider = Provider.of<ProductViewModel>(context);

    if (productProvider.singleProductLoading ||
        productProvider.singleProductList.isEmpty) {
      return _loadingOrEmpty(
          context, sw, topPad, productProvider.singleProductLoading);
    }

    final product = productProvider.singleProductList[0];
    final initial = product.productName.isNotEmpty
        ? product.productName[0].toUpperCase()
        : 'P';
    final bool inStock = product.stock > 0;

    return Scaffold(
      backgroundColor: ErpColors.pageBg,
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
                  padding: EdgeInsets.fromLTRB(sw * 0.04, 18, sw * 0.04,
                      MediaQuery.of(context).padding.bottom + 28),
                  child: Column(
                    children: [
                      // ── Quick stat tiles ──────────────────────────────
                      ErpFadeIn(
                        index: 0,
                        child: Row(
                          children: [
                            _statTile(
                              icon: Icons.currency_rupee_rounded,
                              label: 'Unit Price',
                              value: product.unitPrice.isNotEmpty
                                  ? '₹${product.unitPrice}'
                                  : '—',
                              color: ErpColors.green,
                            ),
                            const SizedBox(width: 10),
                            _statTile(
                              icon: Icons.inventory_rounded,
                              label: 'Stock',
                              value: product.stock.toString(),
                              color: inStock ? ErpColors.blue : ErpColors.red,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      ErpFadeIn(
                        index: 1,
                        child: _buildInfoCard(
                          icon: Icons.inventory_2_rounded,
                          color: ErpColors.cyan,
                          title: 'Product Details',
                          rows: [
                            _InfoRow(Icons.label_rounded, 'Product Name',
                                product.productName),
                            _InfoRow(Icons.description_rounded, 'Description',
                                product.productDescription),
                            _InfoRow(Icons.category_rounded, 'Category',
                                product.categoryName),
                            _InfoRow(Icons.straighten_rounded, 'Unit',
                                product.unitName),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      ErpFadeIn(
                        index: 2,
                        child: _buildInfoCard(
                          icon: Icons.currency_rupee_rounded,
                          color: ErpColors.green,
                          title: 'Pricing & Stock',
                          rows: [
                            _InfoRow(Icons.currency_rupee_rounded,
                                'Unit Price', product.unitPrice),
                            _InfoRow(Icons.inventory_rounded, 'Stock',
                                product.stock.toString()),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      ErpFadeIn(
                        index: 3,
                        child: _buildInfoCard(
                          icon: Icons.receipt_long_rounded,
                          color: ErpColors.violet,
                          title: 'Tax Details',
                          rows: [
                            _InfoRow(
                                Icons.percent_rounded, 'CGST', product.cgst),
                            _InfoRow(
                                Icons.percent_rounded, 'SGST', product.sgst),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      ErpFadeIn(index: 4, child: _buildExitButton(context)),
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
  Widget _headerShell({
    required double topPad,
    required double sw,
    required Widget child,
  }) {
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
              bottom: 22,
              left: sw * 0.045,
              right: sw * 0.045,
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    double sw,
    double topPad,
    dynamic product,
    String initial,
    bool inStock,
  ) {
    final String category = product.categoryName as String;
    final Color stockColor = inStock ? ErpColors.green : ErpColors.red;

    return _headerShell(
      topPad: topPad,
      sw: sw,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: back + title + ID badge ──────────────────────────
          Row(
            children: [
              ErpPressable(
                onTap: () => Navigator.pop(context),
                child: const ErpGlassCircle(
                    icon: Icons.arrow_back_ios_new_rounded, iconSize: 19),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Product View',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.40)),
                ),
                child: Text(
                  'ID #${product.productId}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ── Product card in header ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: ErpColors.cyanDeep.withValues(alpha: 0.22),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: ErpColors.headerGradient,
                    borderRadius: BorderRadius.circular(17),
                    boxShadow: [
                      BoxShadow(
                        color: ErpColors.cyan.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
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
                        (product.productName as String).toUpperCase(),
                        style: const TextStyle(
                          color: ErpColors.ink,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (category.isNotEmpty)
                        ErpMetaChip(
                          icon: Icons.category_rounded,
                          text: category[0].toUpperCase() +
                              category.substring(1),
                          color: ErpColors.cyanDeep,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ErpStatusChip(
                  label: inStock ? 'IN STOCK' : 'OUT OF STOCK',
                  color: stockColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Stat tile ─────────────────────────────────────────────────────────────
  Widget _statTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ErpColors.line),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.10),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            ErpGradientTile(icon: icon, color: color, size: 40),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: ErpColors.slate)),
                  const SizedBox(height: 2),
                  Text(value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: ErpColors.shade(color, 0.15))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Info card ─────────────────────────────────────────────────────────────
  Widget _buildInfoCard({
    required IconData icon,
    required Color color,
    required String title,
    required List<_InfoRow> rows,
  }) {
    final visibleRows = rows.where((r) => r.value.isNotEmpty).toList();
    if (visibleRows.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
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
          // Card header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              children: [
                ErpGradientTile(icon: icon, color: color, size: 38),
                const SizedBox(width: 11),
                Text(
                  _capitalizeWords(title),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: ErpColors.ink,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: ErpColors.line),

          // Field rows
          ...visibleRows.asMap().entries.map((entry) {
            final i = entry.key;
            final row = entry.value;
            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(row.icon,
                            size: 16, color: ErpColors.shade(color, 0.15)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              row.label,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: ErpColors.slate,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              row.value.isNotEmpty
                                  ? row.value[0].toUpperCase() +
                                      row.value.substring(1)
                                  : '—',
                              style: const TextStyle(
                                fontSize: 14,
                                color: ErpColors.ink,
                                fontWeight: FontWeight.w700,
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
                    color: ErpColors.line,
                    indent: 58,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ── Go Back button ────────────────────────────────────────────────────────
  Widget _buildExitButton(BuildContext context) {
    return ErpPrimaryButton(
      text: 'Go Back',
      icon: Icons.arrow_back_rounded,
      onTap: () => Navigator.pop(context),
    );
  }

  // ── Loading / Empty state ─────────────────────────────────────────────────
  Widget _loadingOrEmpty(
      BuildContext context, double sw, double topPad, bool isLoading) {
    return Scaffold(
      backgroundColor: ErpColors.pageBg,
      body: Column(
        children: [
          _headerShell(
            topPad: topPad,
            sw: sw,
            child: Row(
              children: [
                ErpPressable(
                  onTap: () => Navigator.pop(context),
                  child: const ErpGlassCircle(
                      icon: Icons.arrow_back_ios_new_rounded, iconSize: 19),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Product View',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        color: ErpColors.cyan,
                        strokeWidth: 2.5,
                      ),
                    )
                  : ErpEmptyState(
                      icon: Icons.inventory_2_rounded,
                      title: 'Product not found.',
                      subtitle: 'Please try again.',
                      actionLabel: 'Go Back',
                      actionIcon: Icons.arrow_back_rounded,
                      onAction: () => Navigator.pop(context),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Data class for info rows ─────────────────────────────────────────────────
class _InfoRow {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);
}