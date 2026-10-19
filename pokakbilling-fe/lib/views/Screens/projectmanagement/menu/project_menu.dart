import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/project_management/project_viewmodel.dart';
import 'package:pokakbilling/viewmodels/project_management/task_management_viewmodel.dart';
import 'package:pokakbilling/views/Screens/projectmanagement/menu/project_details.dart';
import 'package:pokakbilling/views/Screens/projectmanagement/task_management/project_team_main.dart';
import 'package:pokakbilling/views/Screens/projectmanagement/project/edit_project.dart';
import 'package:pokakbilling/views/commonWidgets/popups/delete_popup.dart';
import 'package:provider/provider.dart';

class ProjectMenuScreen extends StatelessWidget {
  final int projectId;
  const ProjectMenuScreen({super.key, required this.projectId});
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    final projectProvider =
        Provider.of<ProjectViewmodel>(context, listen: false);
    final taskManagementProvider =
        Provider.of<TaskManagementViewmodel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.violetblue,
        title: const Text(
          'Menu',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SizedBox(
        height: height,
        width: width,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                _setUpTile('Projects Details', () async {
                  await projectProvider.getProjectById(projectId);
                  if (projectProvider.singleProjectLoading) {
                    const CircularProgressIndicator();
                  } else {
                    if (!context.mounted) return;
                    pushNavigation(context, const ProjectDetailsScreen());
                  }
                }),
                _setUpTile('Edit Project', () async {
                  await projectProvider.getProjectById(projectId);
                  if (projectProvider.singleProjectLoading) {
                    const CircularProgressIndicator();
                  } else {
                    if (!context.mounted) return;
                    pushNavigation(
                      context,
                      EditProjectScreen(
                          projectModel: projectProvider.singleProjectList[0]),
                    );
                  }
                }),
                _setUpTile('Project Team', () async {
                  await taskManagementProvider.getAllProjectMembers(projectId);

                  if (taskManagementProvider.getProjectMemberLoader) {
                    const CircularProgressIndicator();
                  } else {
                    if (!context.mounted) return;
                    pushNavigation(
                        context, ProjectTeamMain(projectId: projectId));
                  }
                }),
                _setUpTile('Delete Project', () {
                  showDeleteDialog(
                    context,
                    "Project",
                    () => projectProvider.deleteProject(
                      projectId,
                      context,
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _setUpTile(String title, VoidCallback onTap) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: ListTile(
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.grey, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.grey),
      onTap: onTap,
    ),
  );
}
