import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/views/Screens/payments/add_payment.dart';
import 'package:pokakbilling/views/Screens/payments/view_payment.dart';

class SinglePaymentCard extends StatelessWidget {
  const SinglePaymentCard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.14,
      width: screenWidth * screenWidth,
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 4,
            offset: Offset(2, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 15.0,
          left: 10.0,
          right: 12.0,
          bottom: 15.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Supplier"),
                SizedBox(
                  width: 20,
                ),
                Text("#000001"),
                Text("00/00/0000"),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("\$20.00"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                getButtons(
                  "VIEW",
                  false,
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ViewPaymentScreen(),
                      ),
                    );
                  },
                  true,
                ),
                SizedBox(
                  width: screenWidth * 0.03,
                ),
                // getButtons(
                //   "DELETE",
                //   false,
                //   () {
                //     showDeleteDialog(context, "Payments");
                //   },
                //   false,
                // ),
                SizedBox(
                  width: screenWidth * 0.03,
                ),
                getButtons(
                  "EDIT",
                  false,
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AddPayment(),
                      ),
                    );
                  },
                  false,
                )
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
