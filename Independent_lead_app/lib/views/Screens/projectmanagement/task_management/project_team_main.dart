import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/project_management/task_management_viewmodel.dart';
import 'package:pokakbilling/viewmodels/project_management/team_member_viewmodel.dart';
import 'package:pokakbilling/views/Screens/projectmanagement/task_management/single_team_member.dart';
import 'package:provider/provider.dart';

class ProjectTeamMain extends StatelessWidget {
  final int projectId;
  const ProjectTeamMain({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: screenHeight * 0.18,
                decoration: const BoxDecoration(
                  color: AppColors.violetblue,
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: screenWidth * 0.02,
                    right: screenWidth * 0.03,
                  ),
                  child: AppBar(
                    leading: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    title: Text(
                      'Project Team',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: screenWidth * 0.05,
                      ),
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: screenHeight * 0.15,
            left: screenWidth * 0.04,
            right: screenWidth * 0.04,
            child: Container(
              height: screenHeight - screenHeight * 0.18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _buildSearchCard(context),
                  Consumer<TaskManagementViewmodel>(
                    builder: (context, provider, child) {
                      return Expanded(
                        child: Center(
                          child: provider.getProjectMemberLoader
                              ? const CircularProgressIndicator()
                              : provider.projectMemberList.isEmpty
                                  ? const Text("No Team Members Available.")
                                  : ListView.separated(
                                      padding: const EdgeInsets.only(
                                        top: 20,
                                      ),
                                      itemBuilder: (context, index) {
                                        return SingleProjectTeamMemberCard(
                                          index: index,
                                          projectId: projectId,
                                        );
                                      },
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(height: 20),
                                      itemCount:
                                          provider.projectMemberList.length,
                                    ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSearchCard(
    BuildContext context,
  ) {
    return Consumer<TeamMemberViewmodel>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 4,
                offset: Offset(2, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              TextFormField(
                // controller: nameTextController,
                onChanged: (value) => provider.searchByName(value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'required';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: "",
                  labelStyle: TextStyle(
                    color: AppColors.violetblue,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Stack",
                style: TextStyle(
                  color: AppColors.violetblue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropdownButtonFormField<String>(
                items: ["Customer 1", "Customer 2", "Customer 3"]
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {},
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: AppColors.lightGrey,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
