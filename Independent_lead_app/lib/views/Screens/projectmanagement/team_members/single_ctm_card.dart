import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/project_management/team_member_viewmodel.dart';
import 'package:pokakbilling/views/Screens/projectmanagement/team_members/create_team_member.dart';
import 'package:pokakbilling/views/Screens/projectmanagement/team_members/task_list/task_list.dart';
import 'package:pokakbilling/views/Screens/projectmanagement/team_members/view_single_tm.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/action_button.dart';
import 'package:pokakbilling/views/commonWidgets/popups/delete_popup.dart';
import 'package:provider/provider.dart';

class SingleTeamMemberCard extends StatelessWidget {
  final int index;
  const SingleTeamMemberCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final teamMemberProvider = Provider.of<TeamMemberViewmodel>(context);
    var teamMember = teamMemberProvider.teamMemberList[index];
    return Container(
      height: screenHeight * 0.1,
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
          top: 8.0,
          left: 10.0,
          right: 12.0,
          bottom: 8.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(teamMember.name),
                Text(teamMember.roleDisplay),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Consumer<TeamMemberViewmodel>(
                    builder: (context, provider, child) {
                  return ActionButton(
                    text: "Members",
                    loading: false,
                    onPressed: () async {
                      await provider.getTaskMemberById(teamMember.tmId);
                      if (!provider.taskByIdLoading && context.mounted) {
                        pushNavigation(
                            context,
                            TaskList(
                              projectTeamId: teamMember.tmId,
                            ));
                      }
                    },
                    isColored: true,
                  );
                }),
                SizedBox(width: screenWidth * 0.015),
                Consumer<TeamMemberViewmodel>(
                    builder: (context, provider, child) {
                  return ActionButton(
                    text: "VIEW",
                    loading: false,
                    onPressed: () async {
                      await provider.getTeamMemberById(teamMember.tmId);
                      if (!provider.singleTeamMemberLoading &&
                          context.mounted) {
                        pushNavigation(context, const ViewTeamMember());
                      }
                    },
                    isColored: true,
                  );
                }),
                SizedBox(width: screenWidth * 0.015),
                Consumer<TeamMemberViewmodel>(
                    builder: (context, provider, child) {
                  return ActionButton(
                    text: "DELETE",
                    loading: false,
                    onPressed: () async {
                      showDeleteDialog(
                        context,
                        "Team Member",
                        () => provider.deleteMember(
                          teamMember.tmId,
                          context,
                        ),
                      );
                    },
                    isColored: false,
                  );
                }),
                SizedBox(width: screenWidth * 0.015),
                Consumer<TeamMemberViewmodel>(
                    builder: (context, provider, child) {
                  return ActionButton(
                    text: "EDIT",
                    loading: false,
                    onPressed: () async {
                      await provider.getTeamMemberById(teamMember.tmId);
                      if (provider.singleTeamMemberLoading) {
                        const CircularProgressIndicator();
                      } else {
                        if (!context.mounted) return;
                        var teamMember = provider.singleTeamMemberList[0];
                        pushNavigation(
                          context,
                          CreateTeamMember(
                            isEdit: true,
                            teamMember: teamMember,
                          ),
                        );
                      }
                    },
                    isColored: false,
                  );
                }),
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
