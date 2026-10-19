import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/supplier_viewmodel.dart';
import 'package:provider/provider.dart';

class ViewTermsAndConditionsSupplier extends StatelessWidget {
  const ViewTermsAndConditionsSupplier({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final supplierProvider = Provider.of<SupplierViewmodel>(context);
    var supplier = supplierProvider.singleSupplierList[0];
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
              supplier.termsTitle,
              style: const TextStyle(
                color: AppColors.violetblue,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 5),
            Column(
              children: List.generate(
                supplier.termsCondition.length,
                (index) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 2.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "• ",
                        style: TextStyle(
                          color: AppColors.violetblue,
                          fontSize: 14,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          supplier.termsCondition[index].point,
                          style: const TextStyle(
                            color: AppColors.violetblue,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
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
