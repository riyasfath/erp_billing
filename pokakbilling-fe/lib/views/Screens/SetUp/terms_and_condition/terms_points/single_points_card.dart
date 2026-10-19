import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/setup/terms&condition_viewmodel.dart';
import 'package:pokakbilling/views/Screens/SetUp/terms_and_condition/terms_edit/terms_edit_popup.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/action_button.dart';
import 'package:pokakbilling/views/commonWidgets/popups/delete_popup.dart';
import 'package:provider/provider.dart';

class SingleTermsPointsCard extends StatelessWidget {
  final int index;
  final int termsId;
  final String heading;
  const SingleTermsPointsCard({
    super.key,
    required this.index,
    required this.termsId,
    required this.heading,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final termsProvider = Provider.of<TermsViewmodel>(context);
    var termsPoint = termsProvider.termsPointsList[index];

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
                    termsPoint.point,
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
                Consumer<TermsViewmodel>(
                  builder: (context, provider, child) {
                    return ActionButton(
                      text: "EDIT",
                      loading: false,
                      onPressed: () async {
                        if (!context.mounted) return;
                        showEditDialog(
                          context: context,
                          initialText: termsPoint.point,
                          onEdit: (newText) async {
                            await provider.editTermsPoint(
                              termsPoint.pointId,
                              termsPoint.titleId,
                              newText,
                              termsPoint.title,
                              context,
                            );
                            await provider.getAllTermsPoints(termsPoint.titleId);
                          },
                        );
                      },
                      isColored: false,
                    );
                  },
                ),
                SizedBox(width: screenWidth * 0.03),
                Consumer<TermsViewmodel>(
                  builder: (context, provider, child) {
                    return ActionButton(
                      text: "DELETE",
                      loading: false,
                      onPressed: () async {
                        showDeleteDialog(
                          context,
                          "terms & condition point",
                          () => provider.deleteTermsPoint(
                            termsId,
                            heading,
                            termsPoint.pointId,
                            context,
                          ),
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
}
