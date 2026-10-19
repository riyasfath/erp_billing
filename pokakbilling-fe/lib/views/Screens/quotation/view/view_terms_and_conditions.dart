// import 'package:flutter/material.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/viewmodels/quotation/quotation_viewmodel.dart';
// import 'package:provider/provider.dart';

// class ViewTermsAndConditions extends StatelessWidget {
//   const ViewTermsAndConditions({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final quotationProvider = Provider.of<QuotationViewmodel>(context);
//     var quotationItems = quotationProvider.singleQuotationList[0];
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
//               quotationItems.termsAndConditionsTitle,
//               style: const TextStyle(
//                 color: AppColors.violetblue,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             const SizedBox(height: 5),
//             Column(
//               children: List.generate(
//                 quotationItems.termsAndConditions.length,
//                 (index) => Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 10, vertical: 2.0),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         "• ",
//                         style: TextStyle(
//                           color: AppColors.violetblue,
//                           fontSize: 14,
//                         ),
//                       ),
//                       Expanded(
//                         child: Text(
//                           quotationItems.termsAndConditions[index].point,
//                           style: const TextStyle(
//                             color: AppColors.violetblue,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/quotation/quotation_viewmodel.dart';
import 'package:provider/provider.dart';

class ViewTermsAndConditions extends StatelessWidget {
  const ViewTermsAndConditions({super.key});

  @override
  Widget build(BuildContext context) {
    final quotationProvider = Provider.of<QuotationViewmodel>(context);
    final quotationItem = quotationProvider.singleQuotationList[0];

    final termsTitle = quotationItem.termsAndConditionsTitle;
    final termsList = quotationItem.termsAndConditions;

    // ── EMPTY STATE ────────────────────────────────
    if (termsList.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cborder),
          boxShadow: [
            BoxShadow(
              color: AppColors.c1.withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Text(
          "No Terms & Conditions Available",
          style: TextStyle(
            color: AppColors.ctext,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    // ── MAIN CARD ──────────────────────────────────
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cborder),
        boxShadow: [
          BoxShadow(
            color: AppColors.c1.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── HEADER ───────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.article,
                    color: AppColors.c1,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    "Terms & Conditions",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ctext,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: AppColors.cborder),

          // ── TITLE ────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    termsTitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cdark,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── TERMS LIST ───────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: termsList.map((term) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: AppColors.c1,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          term.point,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.ctext,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
