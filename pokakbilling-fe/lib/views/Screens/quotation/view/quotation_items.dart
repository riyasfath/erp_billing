// import 'package:flutter/material.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/viewmodels/quotation/quotation_viewmodel.dart';
// import 'package:provider/provider.dart';

// class QuotationItems extends StatelessWidget {
//   final int index;
//   const QuotationItems({super.key, required this.index});

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final quotationProvider = Provider.of<QuotationViewmodel>(context);
//     var quotationItems = quotationProvider.singleQuotationList[0].items[index];
//     return Container(
//       width: screenWidth * screenWidth,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: AppColors.grey),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.only(
//           left: 12,
//           right: 12,
//           top: 15,
//           bottom: 15,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Item No: ${index + 1}",
//               style: const TextStyle(
//                 color: AppColors.violetblue,
//                 fontSize: 13,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             SizedBox(height: screenHeight * 0.01),
//             Container(
//               height: screenHeight * 0.05,
//               width: screenWidth * screenWidth,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(5),
//                 border: Border.all(color: AppColors.grey),
//               ),
//               child: Center(
//                 child: Text(
//                   quotationItems.name,
//                   style: const TextStyle(
//                     color: AppColors.violetblue,
//                     fontSize: 13,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: screenHeight * 0.025),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 customContainer(
//                   screenHeight,
//                   screenWidth,
//                   "Quantity",
//                   quotationItems.quantity.toString(),
//                 ),
//                 customContainer(
//                   screenHeight,
//                   screenWidth,
//                   "Unit Price",
//                   quotationItems.unitPrice.toString(),
//                 ),
//                 customContainer(
//                   screenHeight,
//                   screenWidth,
//                   "Total",
//                   quotationItems.total.toString(),
//                 )
//               ],
//             ),
//             SizedBox(height: screenHeight * 0.025),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 customContainer(
//                   screenHeight,
//                   screenWidth,
//                   "GST",
//                   quotationItems.sgst.toString(),
//                 ),
//                 customContainer(
//                   screenHeight,
//                   screenWidth,
//                   "Tax(State)",
//                   quotationItems.cgst.toString(),
//                 ),
//                 customContainer(
//                   screenHeight,
//                   screenWidth,
//                   "Sub Total",
//                   quotationItems.subTotal.toString(),
//                 )
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget customContainer(
//     screenHeight,
//     screenWidth,
//     text,
//     value,
//   ) {
//     return Column(
//       children: [
//         Text(
//           text,
//           style: const TextStyle(
//             color: AppColors.violetblue,
//             fontSize: 13,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         SizedBox(height: screenHeight * 0.005),
//         Container(
//           height: screenHeight * 0.045,
//           width: screenWidth * 0.18,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(5),
//             border: Border.all(color: AppColors.grey),
//           ),
//           child: Center(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 color: AppColors.violetblue,
//                 fontSize: 13,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/quotation/quotation_viewmodel.dart';
import 'package:provider/provider.dart';

class QuotationItemsSection extends StatelessWidget {
  const QuotationItemsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final quotationProvider = Provider.of<QuotationViewmodel>(context);
    final items = quotationProvider.singleQuotationList[0].items;

    if (items.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.cyan.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.cyan,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "Products",
                style: TextStyle(
                  color: AppColors.cdark,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        ...List.generate(
          items.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: QuotationItems(index: index),
          ),
        ),
      ],
    );
  }
}

class QuotationItems extends StatelessWidget {
  final int index;
  const QuotationItems({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final quotationProvider = Provider.of<QuotationViewmodel>(context);
    final item = quotationProvider.singleQuotationList[0].items[index];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cyan.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.c1.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── ITEM BADGE ──────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.c1.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Item ${index + 1}",
                style: const TextStyle(
                  color: AppColors.c1,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          // ── PRODUCT NAME ─────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.c1.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.c1.withValues(alpha: 0.20)),
              ),
              child: Center(
                child: Text(
                  item.name,
                  style: const TextStyle(
                    color: AppColors.cdark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          // ── VALUES GRID ──────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildField("Quantity", item.quantity.toString()),
                    _buildField("Unit Price", item.unitPrice.toString()),
                    _buildField("Total", item.total.toString()),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildField("GST", item.sgst.toString()),
                    _buildField("Tax (State)", item.cgst.toString()),
                    _buildField("Sub Total", item.subTotal.toString()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.c1.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.c1.withValues(alpha: 0.20)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.cdark.withValues(alpha: 0.55),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.cdark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
