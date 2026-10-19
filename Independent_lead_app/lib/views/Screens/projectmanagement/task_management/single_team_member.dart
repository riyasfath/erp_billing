import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/core/themes/app_assets.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/viewmodels/project_management/task_management_viewmodel.dart';
import 'package:pokakbilling/viewmodels/project_management/team_member_viewmodel.dart';
import 'package:pokakbilling/views/Screens/projectmanagement/task_management/task_list.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/action_button.dart';
import 'package:provider/provider.dart';

class SingleProjectTeamMemberCard extends StatelessWidget {
  final int index;
  final int projectId;
  const SingleProjectTeamMemberCard({
    super.key,
    required this.index,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final taskManagementProvider =
        Provider.of<TaskManagementViewmodel>(context);
    var projectTeam = taskManagementProvider.projectMemberList[index];
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
                Text(projectTeam.memberName),
                Text(projectTeam.stackName),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(AppAssets.projectTeamIcon),
                      Text("${projectTeam.taskCount} Tasks"),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Consumer<TaskManagementViewmodel>(
                      builder: (context, provider, child) {
                        return ActionButton(
                          text: "VIEW",
                          loading: false,
                          onPressed: () async {
                            await provider.getAllTask(projectTeam.id);
                            if (!context.mounted) return;

                            if (provider.getTaskLoader) {
                              const CircularProgressIndicator();
                            } else {
                              if (!context.mounted) return;
                              pushNavigation(context,
                                  TaskList(projectTeamId: projectTeam.id));
                            }
                          },
                          isColored: true,
                        );
                      },
                    ),
                    SizedBox(width: screenWidth * 0.015),
                    Consumer<TeamMemberViewmodel>(
                      builder: (context, provider, child) {
                        return ActionButton(
                          text: "DELETE",
                          loading: false,
                          onPressed: () async {
                            // showDeleteDialog(
                            //   context,
                            //   "Team Member",
                            //   () => provider.deleteMember(
                            //     teamMember.tmId,
                            //     context,
                            //   ),
                            // );
                          },
                          isColored: false,
                        );
                      },
                    ),
                  ],
                ),
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
