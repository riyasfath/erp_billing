import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/setup/contract_viewmodel.dart';
import 'package:pokakbilling/views/Screens/SetUp/contract_details/contract_header/edit_header.dart';
import 'package:pokakbilling/views/Screens/SetUp/contract_details/contract_points/contract_points.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/action_button.dart';
import 'package:pokakbilling/views/commonWidgets/popups/delete_popup.dart';
import 'package:provider/provider.dart';

class SingleContractDetailsSubHeadingCard extends StatelessWidget {
  final int index;
  const SingleContractDetailsSubHeadingCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final contractProvider = Provider.of<ContractViewmodel>(context);
    var contractsubHeading = contractProvider.contractSubHeadingList[index];

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(contractsubHeading.title),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Consumer<ContractViewmodel>(
                  builder: (context, provider, child) {
                    return ActionButton(
                      text: "VIEW",
                      loading: false,
                      onPressed: () async {
                        await provider.getAllContractPoints(
                          contractsubHeading.contract,
                          contractsubHeading.id,
                        );

                        pushNavigation(
                          context,
                          ContractDetailsPointScreen(
                            contractId: contractsubHeading.contract,
                            sectionId: contractsubHeading.id,
                            contractHeading: contractsubHeading.title,
                          ),
                        );
                      },
                      isColored: true,
                    );
                  },
                ),
                SizedBox(width: screenWidth * 0.03),
                Consumer<ContractViewmodel>(
                  builder: (context, provider, child) {
                    return ActionButton(
                      text: "EDIT",
                      loading: false,
                      onPressed: () async {
                        showEditDialog(
                          context: context,
                          initialText: contractsubHeading.title,
                          onEdit: (newText) async {
                            await provider.editContractSubHeading(
                              contractsubHeading.contract,
                              contractsubHeading.id,
                              newText,
                              context,
                            );

                            await provider.getAllContractSubHeadings(
                              contractsubHeading.contract,
                            );
                          },
                        );
                      },
                      isColored: false,
                    );
                  },
                ),
                SizedBox(width: screenWidth * 0.03),
                Consumer<ContractViewmodel>(
                  builder: (context, provider, child) {
                    return ActionButton(
                      text: "DELETE",
                      loading: false,
                      onPressed: () async {
                        showDeleteDialog(
                          context,
                          "Contract Subheading",
                          () async {
                            await provider.deleteContractSubHeading(
                              contractsubHeading.contract,
                              contractsubHeading.id,
                              context,
                            );
                          },
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
