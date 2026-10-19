import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/sales_person_viewmodel.dart';
import 'package:pokakbilling/views/Screens/sales_person/add_sales_person.dart';
import 'package:pokakbilling/views/Screens/sales_person/view_sales_person.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/action_button.dart';
import 'package:pokakbilling/views/commonWidgets/popups/delete_popup.dart';
import 'package:provider/provider.dart';

class SingleSalePersonCard extends StatelessWidget {
  final int index;
  const SingleSalePersonCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final salesPersonProvider = Provider.of<SalesPersonViewmodel>(context);
    var salesPerson = salesPersonProvider.salesPersonList[index];

    return Container(
      height: screenHeight * 0.09,
      // fix: use screenWidth (not screenWidth * screenWidth) to avoid huge unconstrained width
      width: screenWidth,
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 5.0,
          left: 10.0,
          right: 12.0,
          bottom: 5.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top row: index, name (truncated), designation (truncated)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("${(index + 1).toString()}."),
                const SizedBox(width: 5),

                // Name: take available space and truncate with ellipsis
                Expanded(
                  child: Text(
                    "${salesPerson.firstName ?? ''} ${salesPerson.lastName ?? ''}"
                        .trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),

                const SizedBox(width: 8),

                // Designation: keep a constrained width so it won't push the row
                SizedBox(
                  // give the designation up to ~35% of screen width (adjust if needed)
                  width: screenWidth * 0.35,
                  child: Text(
                    salesPerson.designation ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),

            // Bottom row: action buttons (kept unchanged)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Consumer<SalesPersonViewmodel>(
                  builder: (context, provider, child) {
                    return ActionButton(
                      text: "VIEW",
                      loading: false,
                      onPressed: () {
                        pushNavigation(context,
                            ViewSalesPersonScreen(salesPerson: salesPerson));
                      },
                      isColored: true,
                    );
                  },
                ),
                SizedBox(
                  width: screenWidth * 0.03,
                ),
                ActionButton(
                  text: "DELETE",
                  loading: false,
                  onPressed: () async {
                    showDeleteDialog(
                      context,
                      "Sales Person",
                      () => salesPersonProvider.deleteSalesPerson(
                        salesPerson.salesPersonId,
                        context,
                      ),
                    );
                  },
                  isColored: false,
                ),
                SizedBox(
                  width: screenWidth * 0.03,
                ),
                ActionButton(
                  text: "EDIT",
                  loading: false,
                  onPressed: () {
                    pushNavigation(context,
                        AddSalesPerson(isEdit: true, salesPerson: salesPerson));
                  },
                  isColored: false,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
