import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/purchase_viewmodel.dart';
import 'package:pokakbilling/views/Screens/purchase/edit/edit_purchase.dart';
import 'package:pokakbilling/views/Screens/purchase/view_purchase/view_purchase.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/action_button.dart';
import 'package:pokakbilling/views/commonWidgets/popups/delete_popup.dart';
import 'package:provider/provider.dart';

class SinglePurchaseCard extends StatelessWidget {
  final int index;
  const SinglePurchaseCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final purchaseProvider = Provider.of<PurchaseViewmodel>(context);
    var purchase = purchaseProvider.purchaseOrderList[index];
    return Container(
      height: screenHeight * 0.12,
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
          top: 5.0,
          left: 10.0,
          right: 12.0,
          bottom: 5.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${(index + 1).toString()}."),
                Text(purchase.purchaseOrderNumber),
                const SizedBox(width: 10),
                Text(purchase.totalItems.toString()),
                const SizedBox(width: 10),
                Text(purchase.supplierName),
                const SizedBox(width: 10),
                Text(purchase.purchaseOrderDate),
              ],
            ),
            Row(
              children: [
                const SizedBox(width: 25),
                Text(purchase.contactPersonNumber),
                const Spacer(),
                Text("₹ ${purchase.grandTotal}"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ActionButton(
                  text: "VIEW",
                  loading: false,
                  onPressed: () async {
                    await purchaseProvider
                        .getPurchaseOrderById(purchase.purchaseOrderId);

                    if (purchaseProvider.singlePurchaseOrderLoading) {
                      const CircularProgressIndicator();
                    } else {
                      if (!context.mounted) return;
                      pushNavigation(context, const ViewPurchase());
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
                      "Purchase Order",
                      () => purchaseProvider.deletePurchaseOrder(
                        purchase.purchaseOrderId,
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
                    await purchaseProvider
                        .getPurchaseOrderById(purchase.purchaseOrderId);

                    if (purchaseProvider.singlePurchaseOrderLoading) {
                      const CircularProgressIndicator();
                    } else {
                      if (!context.mounted) return;
                      pushNavigation(
                          context,
                          EditPurchase(
                            purchaseOrderId: purchase.purchaseOrderId,
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

  Widget getButtons(
    text,
    loading,
    final VoidCallback onPressed,
    isColored,
  ) {
    return GestureDetector(
      onTap: loading
          ? null
          : () {
              onPressed();
            },
      child: Container(
        height: 30,
        width: 60,
        decoration: BoxDecoration(
          color: isColored ? AppColors.violetblue : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: isColored
              ? null
              : Border.all(
                  color: AppColors.grey,
                ),
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  height: 8,
                  width: 8,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  text,
                  style: TextStyle(
                    color: isColored ? AppColors.white : AppColors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
        ),
      ),
    );
  }
}
