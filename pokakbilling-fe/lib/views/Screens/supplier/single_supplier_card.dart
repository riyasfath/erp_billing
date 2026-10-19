import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/supplier_viewmodel.dart';
import 'package:pokakbilling/views/Screens/supplier/supplier_form.dart';
import 'package:pokakbilling/views/Screens/supplier/view_supplier.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/action_button.dart';
import 'package:pokakbilling/views/commonWidgets/popups/delete_popup.dart';
import 'package:provider/provider.dart';

class SingleSupplierCard extends StatelessWidget {
  final int index;
  const SingleSupplierCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final supplierProvider = Provider.of<SupplierViewmodel>(context);
    var supplier = supplierProvider.supplierList[index];
    return Container(
      height: screenHeight * 0.11,
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
                Text("${supplier.firstName} ${supplier.lastName}"),
                const SizedBox(width: 20),
                Text(supplier.supplierNumber),
                Text(supplier.date),
              ],
            ),
            Row(
              children: [
                const SizedBox(width: 20),
                Text(supplier.supplierType),
                const Spacer(),
                Text(supplier.currency),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Consumer<SupplierViewmodel>(
                  builder: (context, provider, child) {
                    return ActionButton(
                      text: "VIEW",
                      loading: false,
                      onPressed: () async {
                        await provider.getSupplierById(supplier.supplierId);

                        if (provider.supplierDetailLoading) {
                          const CircularProgressIndicator();
                        } else {
                          if (!context.mounted) return;
                          pushNavigation(context, const ViewSupplierScreen());
                        }
                      },
                      isColored: true,
                    );
                  },
                ),
                SizedBox(
                  width: screenWidth * 0.03,
                ),
                Consumer<SupplierViewmodel>(
                    builder: (context, provider, child) {
                  return ActionButton(
                    text: "EDIT",
                    loading: false,
                    onPressed: () async {
                      await provider.getSupplierById(supplier.supplierId);

                      if (provider.supplierDetailLoading) {
                        const CircularProgressIndicator();
                      } else {
                        if (!context.mounted) return;
                        pushNavigation(
                          context,
                          AddSupplier(
                            isEdit: true,
                            supplier: provider.singleSupplierList[0],
                          ),
                        );
                      }
                    },
                    isColored: false,
                  );
                }),
                SizedBox(
                  width: screenWidth * 0.03,
                ),
                Consumer<SupplierViewmodel>(
                  builder: (context, provider, child) {
                    return ActionButton(
                      text: "DELETE",
                      loading: false,
                      onPressed: () async {
                        showDeleteDialog(
                          context,
                          "Customer",
                          () => provider.deleteSupplier(
                              supplier.supplierId, context),
                        );
                      },
                      isColored: false,
                    );
                  },
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
