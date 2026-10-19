import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/sales_order_viewmodel.dart';
import 'package:pokakbilling/views/Screens/sales_order/edit/edit_sales_order.dart';
import 'package:pokakbilling/views/Screens/sales_order/view/view_sales_order.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/action_button.dart';
import 'package:pokakbilling/views/commonWidgets/popups/delete_popup.dart';
import 'package:provider/provider.dart';

class SingleSalesorderCard extends StatelessWidget {
  final int index;
  const SingleSalesorderCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final salesOrderProvider = Provider.of<SalesOrderViewmodel>(context);
    var salesOrder = salesOrderProvider.salesOrderList[index];
    return Container(
      height: screenHeight * 0.08,
      width: screenWidth * screenWidth,
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
          top: 4.0,
          left: 10.0,
          right: 12.0,
          bottom: 4.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${(index + 1).toString()}."),
                Text(salesOrder.salesDate),
                Text(salesOrder.salesOrderNumber),
                Text(salesOrder.clientName),
                Text(salesOrder.purchaseOrderNumber),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ActionButton(
                  text: "VIEW",
                  loading: false,
                  onPressed: () async {
                    await salesOrderProvider
                        .getSalesOrderById(salesOrder.salesOrderId);

                    if (salesOrderProvider.singleSalesOrderLoading) {
                      const CircularProgressIndicator();
                    } else {
                      if (!context.mounted) return;
                      pushNavigation(context, const ViewSalesOrder());
                    }
                  },
                  isColored: true,
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
                      "Sales Order",
                      () => salesOrderProvider.deleteSalesOrder(
                        salesOrder.salesOrderId,
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
                  onPressed: () async {
                    await salesOrderProvider
                        .getSalesOrderById(salesOrder.salesOrderId);

                    if (salesOrderProvider.singleSalesOrderLoading) {
                      const CircularProgressIndicator();
                    } else {
                      if (!context.mounted) return;
                      pushNavigation(
                          context,
                          EditSalesOrder(
                            salesOrderId: salesOrder.salesOrderId,
                          ));
                    }
                  },
                  isColored: false,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
