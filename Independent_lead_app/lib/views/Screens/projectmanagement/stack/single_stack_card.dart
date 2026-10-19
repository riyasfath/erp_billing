import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/views/Screens/projectmanagement/stack/stack_update.dart';
import 'package:pokakbilling/viewmodels/project_management/stack_viewmodel.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/action_button.dart';
import 'package:pokakbilling/views/commonWidgets/popups/delete_popup.dart';
import 'package:provider/provider.dart';

class SingleStackCard extends StatelessWidget {
  final int index;
  const SingleStackCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final stackProvider = Provider.of<StackViewmodel>(context);
    var stack = stackProvider.stackList[index];
    return Container(
      height: screenHeight * 0.10,
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
                Text(stack.stackName),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ActionButton(
                  text: "UPDATE",
                  loading: false,
                  onPressed: () async {
                    await showUpdateStackDialog(
                      context,
                      stackProvider,
                      stack.stackId,
                      stack.stackName,
                    );
                  },
                  isColored: true,
                ),
                SizedBox(width: screenWidth * 0.015),
                Consumer<StackViewmodel>(
                  builder: (context, provider, child) {
                    return ActionButton(
                      text: "DELETE",
                      loading: false,
                      onPressed: () async {
                        showDeleteDialog(
                          context,
                          "Stack",
                          () => provider.deleteStack(stack.stackId, context),
                        );
                      },
                      isColored: false,
                    );
                  },
                ),
                SizedBox(width: screenWidth * 0.015),
              ],
            ),
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
