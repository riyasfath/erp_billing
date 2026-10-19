import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/material_receive_viewmodel.dart';
import 'package:provider/provider.dart';

class MaterialReceiveItems extends StatelessWidget {
  final int index;
  const MaterialReceiveItems({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final materialProvider = Provider.of<MaterialReceiveViewmodel>(context);
    var materialreceiveItem =
        materialProvider.singleMaterialReceiveList[0].items[index];

    return Container(
      width: screenWidth * screenWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 12,
          right: 12,
          top: 15,
          bottom: 15,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Item No: ${index + 1}",
              style: const TextStyle(
                color: AppColors.violetblue,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Container(
              height: screenHeight * 0.05,
              width: screenWidth * screenWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: AppColors.grey),
              ),
              child: Center(
                child: Text(
                  materialreceiveItem.productName,
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
                  "Quantity",
                  materialreceiveItem.quantity.toString(),
                ),
                customContainer(
                  screenHeight,
                  screenWidth,
                  "Unit Price",
                  materialreceiveItem.unitPrice.toString(),
                ),
                customContainer(
                  screenHeight,
                  screenWidth,
                  "Total",
                  materialreceiveItem.total.toString(),
                )
              ],
            ),
            SizedBox(height: screenHeight * 0.025),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                customContainer(
                  screenHeight,
                  screenWidth,
                  "GST",
                  materialreceiveItem.sgst.toString(),
                ),
                customContainer(
                  screenHeight,
                  screenWidth,
                  "Tax(State)",
                  materialreceiveItem.cgst.toString(),
                ),
                customContainer(
                  screenHeight,
                  screenWidth,
                  "Sub Total",
                  materialreceiveItem.subTotal.toString(),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget customContainer(
    screenHeight,
    screenWidth,
    text,
    value,
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
        Container(
          height: screenHeight * 0.045,
          width: screenWidth * 0.18,
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
