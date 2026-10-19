import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/delivery_viewmodel.dart';
import 'package:provider/provider.dart';

class ViewTermsAndConditions extends StatelessWidget {
  const ViewTermsAndConditions({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final deliveryProvider = Provider.of<DeliveryViewmodel>(context);
    var deliveryItems = deliveryProvider.singleDeliveryOrderList[0];
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
          children: [
            Text(
              deliveryItems.termsTitle,
              style: const TextStyle(
                color: AppColors.violetblue,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                deliveryItems.termsCondition.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "• ",
                          style: TextStyle(
                            color: AppColors.violetblue,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            deliveryItems.termsCondition[index].point,
                            style: const TextStyle(
                              color: AppColors.violetblue,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
