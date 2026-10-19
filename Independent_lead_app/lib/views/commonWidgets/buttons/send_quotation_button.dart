import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/global_viewmodel.dart';
import 'package:pokakbilling/views/Screens/quotation/add/add_quotation.dart';
import 'package:provider/provider.dart';

class SendQuotationButton extends StatelessWidget {
  const SendQuotationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalViewmodel>(
      builder: (context, provider, child) {
        return GestureDetector(
          onTap: () async {
            await provider.getAllLeads("QU");
            if (provider.getGeneratedNumberLoader) {
              const CircularProgressIndicator();
            } else {
              if (!context.mounted) return;
              pushNavigation(
                  context,
                  AddQuotation(
                    quotationNumber: provider.orderNumber,
                    isEdit: false,
                  ));
            }
          },
          child: Container(
            height: 30,
            width: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.grey,
              ),
            ),
            child: const Center(
              child: Text(
                "Send Quotation",
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
