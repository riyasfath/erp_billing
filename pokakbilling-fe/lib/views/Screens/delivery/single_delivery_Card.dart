import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/delivery_viewmodel.dart';
import 'package:pokakbilling/views/Screens/delivery/view_delivery/view_delivery.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/action_button.dart';
import 'package:pokakbilling/views/commonWidgets/popups/delete_popup.dart';
import 'package:provider/provider.dart';

class SingleDeliveryCard extends StatelessWidget {
  final int index;
  const SingleDeliveryCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final deliveryProvider = Provider.of<DeliveryViewmodel>(context);
    var delivery = deliveryProvider.deliveryOrderList[index];
    return Container(
      height: screenHeight * 0.09,
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
                Text(delivery.deliveryDate),
                Text(delivery.deliveryNumber),
                Text(delivery.clientFirstName),
                Text("₹ ${delivery.grandTotal}"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ActionButton(
                  text: "VIEW",
                  loading: false,
                  onPressed: () async {
                    await deliveryProvider
                        .getDeliveryOrderById(delivery.deliveryId);

                    if (deliveryProvider.singleDeliveryOrderLoading) {
                      const CircularProgressIndicator();
                    } else {
                      if (!context.mounted) return;
                      pushNavigation(context, const ViewDelivery());
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
                      "Delivery Order",
                      () => deliveryProvider.deleteDeliveryOrder(
                        delivery.deliveryId,
                        context,
                      ),
                    );
                  },
                  isColored: false,
                ),
                // SizedBox(
                //   width: screenWidth * 0.03,
                // ),
                // ActionButton(
                //   text: "EDIT",
                //   loading: false,
                //   onPressed: () async {
                //     await deliveryProvider
                //         .getDeliveryOrderById(delivery.deliveryId);

                //     if (deliveryProvider.singleDeliveryOrderLoading) {
                //       const CircularProgressIndicator();
                //     } else {
                //       if (!context.mounted) return;
                //       pushNavigation(context,
                //           EditDelivery(deliveryId: delivery.deliveryId));
                //     }
                //   },
                //   isColored: false,
                // ),
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
