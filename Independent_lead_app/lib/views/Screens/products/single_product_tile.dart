import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/product_viewmodel.dart';
import 'package:pokakbilling/views/Screens/products/create_product.dart';
import 'package:pokakbilling/views/Screens/products/view_product.dart';
import 'package:pokakbilling/views/commonWidgets/popups/delete_popup.dart';
import 'package:provider/provider.dart';

class SingleProductTile extends StatelessWidget {
  final int index;
  const SingleProductTile({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductViewModel>(context);
    final product = provider.productList[index];

    final bool inStock = product.stock > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top section ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar circle
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.cxl,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.cborder,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _initial(product.productName),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.c1,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Product details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product name
                      Text(
                        product.productName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.cdark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 2),

                      // Category
                      Text(
                        product.category[0].toUpperCase() +
                            product.category.substring(1).toLowerCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.ctext,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Price + stock row
                      Row(
                        children: [
                          const Icon(Icons.currency_rupee,
                              size: 11, color: AppColors.tagGreen),
                          Text(
                            product.unitPrice,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.tagGreen,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Stock: ${product.stock}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.tagRed,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Stock badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                    inStock ? 'In Stock' : 'Out of Stock',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: inStock ? AppColors.tagGreen : AppColors.tagRed,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.cborder,
          ),

          // ── Action buttons ─────────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 10, 24, 12),
            child: Row(
              children: [
                // VIEW
                _ActionBtn(
                  label: 'View',
                  icon: Icons.visibility_outlined,
                  color: AppColors.c1,
                  filled: true,
                  onTap: () =>
                      pushNavigation(context, ViewProduct(product: product)),
                ),

                const SizedBox(width: 8),

                // EDIT
                _ActionBtn(
                  label: 'Edit',
                  icon: Icons.edit_outlined,
                  color: AppColors.c3,
                  filled: false,
                  onTap: () => pushNavigation(
                    context,
                    AddProduct(isEdit: true, product: product),
                  ),
                ),

                const SizedBox(width: 8),

                // DELETE
                Consumer<ProductViewModel>(
                  builder: (context, provider, _) => _ActionBtn(
                    label: 'Delete',
                    icon: Icons.delete_outline_rounded,
                    color: AppColors.tagRed,
                    filled: false,
                    onTap: () => showDeleteDialog(
                      context,
                      'Product',
                      () => provider.deleteProduct(product.productId, context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initial(String name) => name.isNotEmpty ? name[0].toUpperCase() : '';
}

// ─── Action Button ────────────────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: filled ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: filled ? null : Border.all(color: color.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 13, color: filled ? AppColors.white : color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: filled ? AppColors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
