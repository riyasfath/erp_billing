import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/sales_order_viewmodel.dart';
import 'package:provider/provider.dart';

class SalesOrderItems extends StatelessWidget {
  final int index;
  const SalesOrderItems({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final salesOrderProvider = Provider.of<SalesOrderViewmodel>(context);
    var salesOrderItems =
        salesOrderProvider.singleSalesOrderList[0].items[index];
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
                  salesOrderItems.name,
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
                  salesOrderItems.quantity.toString(),
                ),
                customContainer(
                  screenHeight,
                  screenWidth,
                  "Unit Price",
                  salesOrderItems.unitPrice.toString(),
                ),
                customContainer(
                  screenHeight,
                  screenWidth,
                  "Total",
                  salesOrderItems.total.toString(),
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
                  salesOrderItems.sgst.toString(),
                ),
                customContainer(
                  screenHeight,
                  screenWidth,
                  "Tax(State)",
                  salesOrderItems.cgst.toString(),
                ),
                customContainer(
                  screenHeight,
                  screenWidth,
                  "Sub Total",
                  salesOrderItems.subTotal.toString(),
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
