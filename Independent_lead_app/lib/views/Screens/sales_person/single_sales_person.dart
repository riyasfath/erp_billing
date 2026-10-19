// import 'package:flutter/material.dart';
// import 'package:pokakbilling/core/navigations.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/viewmodels/sales_person_viewmodel.dart';
// import 'package:pokakbilling/views/Screens/sales_person/add_sales_person.dart';
// import 'package:pokakbilling/views/Screens/sales_person/view_sales_person.dart';
// import 'package:pokakbilling/views/commonWidgets/buttons/action_button.dart';
// import 'package:pokakbilling/views/commonWidgets/popups/delete_popup.dart';
// import 'package:provider/provider.dart';

// class SingleSalePersonCard extends StatelessWidget {
//   final int index;
//   const SingleSalePersonCard({super.key, required this.index});

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final salesPersonProvider = Provider.of<SalesPersonViewmodel>(context);
//     var salesPerson = salesPersonProvider.salesPersonList[index];

//     return Container(
//       height: screenHeight * 0.09,
//       // fix: use screenWidth (not screenWidth * screenWidth) to avoid huge unconstrained width
//       width: screenWidth,
//       decoration: BoxDecoration(
//         color: AppColors.lightGrey,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: const [
//           BoxShadow(
//             color: Colors.grey,
//             blurRadius: 4,
//             offset: Offset(2, 2),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.only(
//           top: 5.0,
//           left: 10.0,
//           right: 12.0,
//           bottom: 5.0,
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             // Top row: index, name (truncated), designation (truncated)
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Text("${(index + 1).toString()}."),
//                 const SizedBox(width: 5),

//                 // Name: take available space and truncate with ellipsis
//                 Expanded(
//                   child: Text(
//                     "${salesPerson.firstName ?? ''} ${salesPerson.lastName ?? ''}"
//                         .trim(),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     softWrap: false,
//                     style: const TextStyle(fontSize: 14),
//                   ),
//                 ),

//                 const SizedBox(width: 8),

//                 // Designation: keep a constrained width so it won't push the row
//                 SizedBox(
//                   // give the designation up to ~35% of screen width (adjust if needed)
//                   width: screenWidth * 0.35,
//                   child: Text(
//                     salesPerson.designation ?? '',
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     softWrap: false,
//                     textAlign: TextAlign.right,
//                     style: const TextStyle(fontSize: 13),
//                   ),
//                 ),
//               ],
//             ),

//             // Bottom row: action buttons (kept unchanged)
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 Consumer<SalesPersonViewmodel>(
//                   builder: (context, provider, child) {
//                     return ActionButton(
//                       text: "VIEW",
//                       loading: false,
//                       onPressed: () {
//                         pushNavigation(context,
//                             ViewSalesPersonScreen(salesPerson: salesPerson));
//                       },
//                       isColored: true,
//                     );
//                   },
//                 ),
//                 SizedBox(
//                   width: screenWidth * 0.03,
//                 ),
//                 ActionButton(
//                   text: "DELETE",
//                   loading: false,
//                   onPressed: () async {
//                     showDeleteDialog(
//                       context,
//                       "Sales Person",
//                       () => salesPersonProvider.deleteSalesPerson(
//                         salesPerson.salesPersonId,
//                         context,
//                       ),
//                     );
//                   },
//                   isColored: false,
//                 ),
//                 SizedBox(
//                   width: screenWidth * 0.03,
//                 ),
//                 ActionButton(
//                   text: "EDIT",
//                   loading: false,
//                   onPressed: () {
//                     pushNavigation(context,
//                         AddSalesPerson(isEdit: true, salesPerson: salesPerson));
//                   },
//                   isColored: false,
//                 )
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/core/utils/text_utils.dart';
import 'package:pokakbilling/viewmodels/sales_person_viewmodel.dart';
import 'package:pokakbilling/views/Screens/sales_person/add_sales_person.dart';
import 'package:pokakbilling/views/Screens/sales_person/view_sales_person.dart';
import 'package:pokakbilling/views/commonWidgets/popups/delete_popup.dart';
import 'package:provider/provider.dart';

class _C {
  _C._();
  static Color get p => AppColors.violetblue;
  static Color get p1 => Color.lerp(p, Colors.white, 0.22)!;
  static Color get white => AppColors.white;
  static Color get red => AppColors.red;
  static Color get textDark => Color.lerp(p, Colors.black, 0.55)!;
  static Color get textMid => Color.lerp(p, Colors.black, 0.18)!;
  static Color get textMuted => Color.lerp(p, Colors.white, 0.20)!;
}

class SingleSalePersonCard extends StatelessWidget {
  final int index;

  const SingleSalePersonCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SalesPersonViewmodel>(context);
    final person = provider.salesPersonList[index];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ── Avatar + Name + Designation ─────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Avatar circle
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _C.p.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _initials(person.firstName ?? "", person.lastName ?? ""),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _C.p,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                /// Name + designation
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Name
                      Text(
                        "${person.firstName ?? ""} ${person.lastName ?? ""}"
                            .trim()
                            .toUpperCase(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _C.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 2),

                      /// Designation
                      Row(
                        children: [
                          Icon(
                            Icons.work_outline,
                            size: 12,
                            color: _C.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              capitalizeWords(person.designation ?? ""),
                              style: TextStyle(
                                fontSize: 11,
                                color: _C.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 12,
                            color: _C.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              capitalizeWords(person.email ?? ""),
                              style: TextStyle(
                                fontSize: 11,
                                color: _C.textMuted,
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
              ],
            ),
          ),

          /// Divider
          Divider(
            height: 1,
            thickness: 1,
            color: _C.p.withOpacity(0.07),
          ),

          /// ── Action Buttons ─────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 10, 24, 12),
            child: Row(
              children: [
                /// VIEW
                _ActionBtn(
                  label: 'View',
                  icon: Icons.visibility_outlined,
                  color: _C.p,
                  filled: true,
                  onTap: () {
                    pushNavigation(
                      context,
                      ViewSalesPersonScreen(salesPerson: person),
                    );
                  },
                ),

                const SizedBox(width: 8),

                /// EDIT
                _ActionBtn(
                  label: 'Edit',
                  icon: Icons.edit_outlined,
                  color: _C.p,
                  filled: false,
                  onTap: () {
                    pushNavigation(
                      context,
                      AddSalesPerson(isEdit: true, salesPerson: person),
                    );
                  },
                ),

                const SizedBox(width: 8),

                /// DELETE
                Consumer<SalesPersonViewmodel>(
                  builder: (context, provider, _) => _ActionBtn(
                    label: 'Delete',
                    icon: Icons.delete_outline,
                    color: _C.red,
                    filled: false,
                    onTap: () {
                      showDeleteDialog(
                        context,
                        "Sales Person",
                        () => provider.deleteSalesPerson(
                          person.salesPersonId,
                          context,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// initials
  String _initials(String first, String last) {
    final f = first.isNotEmpty ? first[0].toUpperCase() : '';
    final l = last.isNotEmpty ? last[0].toUpperCase() : '';
    return '$f$l';
  }

 
}

/// ─── Action Button ───────────────────────────────
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: filled ? AppColors.white : color,
            ),
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
