// import 'package:flutter/material.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/viewmodels/quotation/quotation_viewmodel.dart';
// import 'package:provider/provider.dart';

// class ViewContractDetails extends StatelessWidget {
//   const ViewContractDetails({super.key});

//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     var height = size.height;
//     var width = size.width;
//     final quotationProvider = Provider.of<QuotationViewmodel>(context);
//     var quotationItems = quotationProvider.singleQuotationList[0];
//     return Container(
//       // height: height * 0.01,
//       width: width * width,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: AppColors.grey),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: List.generate(
//           quotationItems.contract.sections.length,
//           (sectionIndex) {
//             final section = quotationItems.contract.sections[sectionIndex];
//             return Padding(
//               padding: const EdgeInsets.symmetric(vertical: 10),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 10),
//                     child: Text(
//                       section.title,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.w500,
//                         fontSize: 16,
//                         color: AppColors.violetblue,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: List.generate(
//                       section.points.length,
//                       (pointIndex) {
//                         final point = section.points[pointIndex];
//                         return Padding(
//                           padding:
//                               const EdgeInsets.only(left: 20.0, bottom: 4.0),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text(
//                                 '• ',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: AppColors.violetblue,
//                                 ),
//                               ),
//                               Expanded(
//                                 child: Text(
//                                   point.points,
//                                   style: const TextStyle(
//                                     fontSize: 14,
//                                     color: AppColors.violetblue,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   )
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/quotation/quotation_viewmodel.dart';
import 'package:provider/provider.dart';

class ViewContractDetails extends StatelessWidget {
  const ViewContractDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final quotationProvider = Provider.of<QuotationViewmodel>(context);
    final quotationItem = quotationProvider.singleQuotationList[0];
    final sections = quotationItem.contract.sections;

    // ── EMPTY STATE ────────────────────────────────
    if (sections.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(
              Icons.description_outlined,
              color: AppColors.c1.withValues(alpha: 0.35),
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              'No contract available',
              style: TextStyle(
                color: AppColors.ctext.withValues(alpha: 0.55),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // ── MAIN CONTENT ───────────────────────────────
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contract name row
          _contractNameRow(quotationItem.contract.title),

          const SizedBox(height: 10),
          Divider(
              height: 1, thickness: 1, color: AppColors.c1.withValues(alpha: 0.08)),
          const SizedBox(height: 10),

          // Sections
          ...sections.asMap().entries.map((entry) {
            final isLast = entry.key == sections.length - 1;
            return _buildSection(entry.value, isLast: isLast);
          }),
        ],
      ),
    );
  }

  Widget _contractNameRow(String name) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.c1.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.handshake_outlined,
            size: 14,
            color: AppColors.c1.withValues(alpha: 0.65),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contract Name',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.ctext.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
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
    );
  }

  Widget _buildSection(dynamic section, {required bool isLast}) {
    final points = section.points as List;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.c1.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.article_outlined,
                  size: 14,
                  color: AppColors.c1.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  section.title,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.ctext.withValues(alpha: 0.55),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),

          // Points
          if (points.isNotEmpty) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 42),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: points.map<Widget>((point) {
                  final raw = point.points as String;
                  final text = raw.isNotEmpty
                      ? raw[0].toUpperCase() + raw.substring(1).toLowerCase()
                      : '';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: AppColors.c1.withValues(alpha: 0.55),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            text,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.cdark,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
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
        ],
      ),
    );
  }
}
