import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/delivery_viewmodel.dart';
import 'package:provider/provider.dart';

class SingleItem extends StatelessWidget {
  final int index;
  const SingleItem({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final deliveryProvider = Provider.of<DeliveryViewmodel>(context);
    var salesOrderItems = deliveryProvider.salesOrderItemsList[index];

    final deliveryQtyController =
        deliveryProvider.deliveryQuantityControllers[index];

    return Container(
      width: screenWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Item No: ${index + 1}",
                  style: const TextStyle(
                    color: AppColors.violetblue,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Checkbox(
                  value: deliveryProvider.getCheckboxState(index),
                  onChanged: (_) => deliveryProvider.toggleCheckbox(index),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.01),
            Container(
              height: screenHeight * 0.05,
              width: screenWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: AppColors.grey),
              ),
              child: Center(
                child: Text(
                  salesOrderItems.productName,
                  style: const TextStyle(
                    color: AppColors.violetblue,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.025),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                customContainer(
                  screenHeight,
                  screenWidth,
                  "Sales Order Quantity",
                  salesOrderItems.quantity.toString(),
                  false,
                  false,
                  null,
                ),
                customContainer(
                  screenHeight,
                  screenWidth,
                  "Delivery Quantity",
                  "",
                  false,
                  true,
                  deliveryQtyController,
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.025),
            Align(
              alignment: Alignment.centerRight,
              child: customContainer(
                screenHeight,
                screenWidth,
                "Unit Price",
                "1494",
                true,
                false,
                null,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
          ],
        ),
      ),
    );
  }

  Widget customContainer(
    double screenHeight,
    double screenWidth,
    String text,
    String value,
    bool isUnitPrice,
    bool isTextfield,
    TextEditingController? controller,
  ) {
    return Column(
      children: [
        Text(
          text,
          style: const TextStyle(
            color: AppColors.violetblue,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: screenHeight * 0.005),
        isTextfield
            ? SizedBox(
                height: screenHeight * 0.045,
                width: isUnitPrice ? screenWidth * 0.18 : screenWidth * 0.35,
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  style: const TextStyle(
                    color: AppColors.violetblue,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColors.violetblue),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              )
            : Container(
                height: screenHeight * 0.045,
                width: isUnitPrice ? screenWidth * 0.18 : screenWidth * 0.35,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: AppColors.grey),
                ),
                child: Center(
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: AppColors.violetblue,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}
