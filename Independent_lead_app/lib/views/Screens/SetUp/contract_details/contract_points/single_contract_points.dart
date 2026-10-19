import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/setup/contract_viewmodel.dart';
import 'package:pokakbilling/views/Screens/SetUp/contract_details/contract_header/edit_header.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/action_button.dart';
import 'package:pokakbilling/views/commonWidgets/popups/delete_popup.dart';
import 'package:provider/provider.dart';

class SingleContractDetailsPointsCard extends StatelessWidget {
  final int index;
  final int contractId;
  final int sectionId;

  const SingleContractDetailsPointsCard({
    super.key,
    required this.index,
    required this.contractId,
    required this.sectionId,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final contractProvider = Provider.of<ContractViewmodel>(context);
    var contractpoint = contractProvider.contractPointsList[index];

    return Container(
      height: screenHeight * 0.14,
      width: screenWidth * 0.9,
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
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2.0),
                  child: Text(
                    '•',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    contractpoint.points,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Consumer<ContractViewmodel>(
                  builder: (context, provider, child) {
                    return ActionButton(
                      text: "EDIT",
                      loading: false,
                      onPressed: () async {
                        showEditDialog(
                          context: context,
                          initialText: contractpoint.points,
                          onEdit: (newText) async {
                            if (newText.trim().isNotEmpty) {
                              await contractProvider.editContractPoint(
                                contractId,
                                sectionId,
                                contractpoint.id,
                                newText.trim(),
                                context,
                              );
                            }
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
                          "Contract Point",
                          () async {
                            await contractProvider.deleteContractPoint(
                              contractId,
                              sectionId,
                              contractpoint.id,
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
            ),
          ],
        ),
      ),
    );
  }
}
