// import 'package:flutter/material.dart';
// import 'package:pokakbilling/core/navigations.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/viewmodels/product_viewmodel.dart';
// import 'package:pokakbilling/views/Screens/products/create_product.dart';
// import 'package:pokakbilling/views/Screens/stock/view_stock_product.dart';
// import 'package:pokakbilling/views/commonWidgets/popups/delete_popup.dart';
// import 'package:provider/provider.dart';

// class SingleProductTile extends StatelessWidget {
//   final int index;
//   const SingleProductTile({super.key, required this.index});

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<ProductViewModel>(context);
//     final product = provider.productList[index];

//     final bool inStock = product.stock > 0;

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ── Top section ────────────────────────────────────────────────
//           Padding(
//             padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Avatar circle (CRM style with ERP _kAccent)
//                 Container(
//                   width: 44,
//                   height: 44,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF818CF8).withOpacity(0.18),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Center(
//                     child: Text(
//                       _initial(product.productName),
//                       style: const TextStyle(
//                         fontSize: 17,
//                         fontWeight: FontWeight.w700,
//                         color: const Color(0xFF818CF8),
//                       ),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(width: 12),

//                 // Product details (CRM layout)
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Serial + Product name row (ERP style)
//                       Row(
//                         children: [
//                           Text(
//                             '${index + 1}. ',
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w700,
//                               color: Theme.of(context).brightness ==
//                                       Brightness.dark
//                                   ? Colors.white.withOpacity(0.50)
//                                   : const Color(0xFF1E1B4B).withOpacity(0.50),
//                             ),
//                           ),
//                           Expanded(
//                             child: Text(
//                               product.productName,
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w700,
//                                 color: Theme.of(context).brightness ==
//                                         Brightness.dark
//                                     ? Colors.white
//                                     : const Color(0xFF1E1B4B),
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 4),

//                       // Stock badge (ERP style with icon)
//                       Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 7, vertical: 3),
//                             decoration: BoxDecoration(
//                               color: Theme.of(context).brightness ==
//                                       Brightness.dark
//                                   ? Colors.white.withOpacity(0.12)
//                                   : const Color(0xFF6366F1).withOpacity(0.10),
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(
//                                   Icons.inventory_2_outlined,
//                                   size: 11,
//                                   color: Theme.of(context).brightness ==
//                                           Brightness.dark
//                                       ? const Color(0xFF818CF8)
//                                       : const Color(0xFF4338CA),
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   'Stock: ${product.stock}',
//                                   style: TextStyle(
//                                     fontSize: 11,
//                                     fontWeight: FontWeight.w600,
//                                     color: Theme.of(context).brightness ==
//                                             Brightness.dark
//                                         ? const Color(0xFF818CF8)
//                                         : const Color(0xFF4338CA),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(width: 10),

//                 // Price (ERP style)
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Text(
//                       '₹ ${product.unitPrice}',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w800,
//                         color: Theme.of(context).brightness == Brightness.dark
//                             ? Colors.white
//                             : const Color(0xFF1E1B4B),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           // Divider (CRM feature)
//           const Divider(
//             height: 1,
//             thickness: 1,
//             color: AppColors.cborder,
//           ),

//           // ── Action buttons (CRM style with ERP functionality) ─────────────────────────────────────────────
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             padding: const EdgeInsets.fromLTRB(12, 10, 24, 12),
//             child: Row(
//               children: [
//                 // VIEW (ERP functionality with CRM UI)
//                 Consumer<ProductViewModel>(
//                   builder: (context, provider, _) {
//                     return _ActionBtn(
//                       label: 'View',
//                       icon: Icons.visibility_outlined,
//                       color: AppColors.c1,
//                       filled: true,
//                       onTap: () async {
//                         final bool success =
//                             await provider.getProductById(product.productId);
//                         if (!context.mounted) return;
//                         if (success) {
//                           pushNavigation(context, const ViewStockProduct());
//                         } else {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text(
//                                   'Failed to load product details. Please try again.'),
//                               backgroundColor: Colors.red,
//                             ),
//                           );
//                         }
//                       },
//                     );
//                   },
//                 ),

//                 const SizedBox(width: 8),

//                 // EDIT (CRM feature)
//                 _ActionBtn(
//                   label: 'Edit',
//                   icon: Icons.edit_outlined,
//                   color: AppColors.c3,
//                   filled: false,
//                   onTap: () => pushNavigation(
//                     context,
//                     AddProduct(isEdit: true, product: product),
//                   ),
//                 ),

//                 const SizedBox(width: 8),

//                 // DELETE (CRM feature with ERP delete)
//                 Consumer<ProductViewModel>(
//                   builder: (context, provider, _) => _ActionBtn(
//                     label: 'Delete',
//                     icon: Icons.delete_outline_rounded,
//                     color: AppColors.tagRed,
//                     filled: false,
//                     onTap: () => showDeleteDialog(
//                       context,
//                       'Product',
//                       () => provider.deleteProduct(product.productId, context),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _initial(String name) => name.isNotEmpty ? name[0].toUpperCase() : 'P';
// }

// // ─── Action Button (CRM style) ────────────────────────────────────────────────────────────
// class _ActionBtn extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final Color color;
//   final bool filled;
//   final VoidCallback onTap;

//   const _ActionBtn({
//     required this.label,
//     required this.icon,
//     required this.color,
//     required this.filled,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
//         decoration: BoxDecoration(
//           color: filled ? color : color.withOpacity(0.08),
//           borderRadius: BorderRadius.circular(20),
//           border: filled ? null : Border.all(color: color.withOpacity(0.35)),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, size: 13, color: filled ? AppColors.white : color),
//             const SizedBox(width: 5),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w600,
//                 color: filled ? AppColors.white : color,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/product_viewmodel.dart';
import 'package:pokakbilling/views/Screens/products/create_product.dart';
import 'package:pokakbilling/views/Screens/stock/view_stock_product.dart';
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
          // ── Top row: avatar + name/stock + price ───────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar circle with initial
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
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.c1,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Product name + stock badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${index + 1}. ',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ctext,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              product.productName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.cdark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.c1.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.inventory_2_outlined,
                                  size: 11,
                                  color: AppColors.c1,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Stock: ${product.stock}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.c1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Price + stock status badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹ ${product.unitPrice}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.cdark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (inStock ? AppColors.green : AppColors.tagRed)
                            .withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: (inStock ? AppColors.green : AppColors.tagRed)
                              .withValues(alpha: 0.30),
                        ),
                      ),
                      child: Text(
                        inStock ? 'In Stock' : 'Out of Stock',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: inStock ? AppColors.green : AppColors.tagRed,
                        ),
                      ),
                    ),
                  ],
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

          // ── Action buttons ──────────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 10, 24, 12),
            child: Row(
              children: [
                // VIEW
                Consumer<ProductViewModel>(
                  builder: (context, provider, _) {
                    return _ActionBtn(
                      label: 'View',
                      icon: Icons.visibility_outlined,
                      color: AppColors.c1,
                      filled: true,
                      onTap: () async {
                        final bool success =
                            await provider.getProductById(product.productId);
                        if (!context.mounted) return;
                        if (success) {
                          pushNavigation(context, const ViewStockProduct());
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Failed to load product details. Please try again.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    );
                  },
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

  String _initial(String name) => name.isNotEmpty ? name[0].toUpperCase() : 'P';
}

// ─── Pill action button ─────────────────────────────────────────────────────
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
          color: filled ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: filled ? null : Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: filled ? Colors.white : color,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: filled ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
