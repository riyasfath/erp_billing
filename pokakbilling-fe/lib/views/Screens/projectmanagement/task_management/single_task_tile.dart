import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/project_management/task_management_viewmodel.dart';
import 'package:pokakbilling/views/Screens/projectmanagement/task_management/add_task.dart';
import 'package:pokakbilling/views/Screens/projectmanagement/task_management/view_task.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/action_button.dart';
import 'package:pokakbilling/views/commonWidgets/popups/delete_popup.dart';
import 'package:provider/provider.dart';

class SingleTaskTile extends StatelessWidget {
  final int index;
  final int? projectTeamId;
  const SingleTaskTile({
    super.key,
    required this.index,
    this.projectTeamId,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final taskManagementProvider =
        Provider.of<TaskManagementViewmodel>(context);
    var task = taskManagementProvider.taskList[index];
    return Container(
      height: screenHeight * 0.22,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Task Name",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        task.taskName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9BF6A1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    task.displayStatus,
                    style: const TextStyle(
                      color: AppColors.green,
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Start Date",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(task.startDate),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "End Date",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(task.endDate),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ActionButton(
                  text: "VIEW",
                  loading: false,
                  onPressed: () async {
                    pushNavigation(context, ViewTask(task: task));
                  },
                  isColored: true,
                ),
                const SizedBox(width: 10),
                ActionButton(
                  text: "EDIT",
                  loading: false,
                  isColored: false,
                  onPressed: () async {
                    await taskManagementProvider.getTaskById(task.id);
                    if (taskManagementProvider.getSingleTaskLoader) {
                      const CircularProgressIndicator();
                    } else {
                      if (!context.mounted) return;
                      var singleTask =
                          taskManagementProvider.selectedTaskDetail[0];
                      pushNavigation(
                        context,
                        AddTask(
                          projectTeamId: projectTeamId ?? 0,
                          isEdit: true,
                          taskId: task.id,
                          task: singleTask,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(width: 10),
                ActionButton(
                  text: "DELETE",
                  loading: taskManagementProvider.deleteTaskLoader,
                  onPressed: () async {
                    showDeleteDialog(
                      context,
                      "Task",
                      () async {
                        await taskManagementProvider.deleteTask(
                          task.id,
                          projectTeamId!,
                          context,
                        );
                      },
                    );
                  },
                  isColored: false,
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
