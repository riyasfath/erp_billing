import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/receipt_viewmodel.dart';
import 'package:pokakbilling/views/Screens/receipt/edit_receipt.dart';
import 'package:pokakbilling/views/Screens/receipt/view/view_receipt.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/action_button.dart';
import 'package:provider/provider.dart';

class SingleReceiptCard extends StatelessWidget {
  final int index;
  const SingleReceiptCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final receiptProvider = Provider.of<ReceiptViewmodel>(context);
    var receipt = receiptProvider.receiptList[index];
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
          top: 5,
          left: 10.0,
          right: 12.0,
          bottom: 5,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(receipt.receiptDate),
                Text(receipt.receiptNumber),
                Text(receipt.clientName),
                Text(receipt.invoiceNumber),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ActionButton(
                  text: "VIEW",
                  loading: false,
                  onPressed: () async {
                    await receiptProvider.getReceiptById(receipt.receiptId);

                    if (receiptProvider.singleReceiptLoading) {
                      const CircularProgressIndicator();
                    } else {
                      if (!context.mounted) return;
                      pushNavigation(context, const ViewReceipt());
                    }
                  },
                  isColored: true,
                ),
                SizedBox(width: screenWidth * 0.03),
                ActionButton(
                  text: "EDIT",
                  loading: false,
                  onPressed: () async {
                    await receiptProvider.getReceiptById(receipt.receiptId);

                    if (receiptProvider.singleReceiptLoading) {
                      const CircularProgressIndicator();
                    } else {
                      if (!context.mounted) return;
                      pushNavigation(context,
                          EditReceipt(receiptId: receipt.receiptId));
                    }
                  },  
                  isColored: false,
                ),
                SizedBox(width: screenWidth * 0.03),
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
