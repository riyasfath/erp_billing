import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/project_management/team_member_viewmodel.dart';
import 'package:pokakbilling/views/Screens/projectmanagement/team_members/create_team_member.dart';
import 'package:pokakbilling/views/Screens/projectmanagement/team_members/single_ctm_card.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/main_page_custom_button.dart';
import 'package:provider/provider.dart';

class CreateTeamMemberMain extends StatelessWidget {
  const CreateTeamMemberMain({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final formKey = GlobalKey<FormState>();
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
                      'Team Member',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: screenWidth * 0.05,
                      ),
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    actions: [
                      MainPageCustomButton(
                        text: "Create Team",
                        onPressed: () {
                          pushNavigation(
                              context, const CreateTeamMember(isEdit: false));
                        },
                      )
                    ],
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
                  Consumer<TeamMemberViewmodel>(
                    builder: (context, provider, child) {
                      return Expanded(
                        child: Center(
                          child: provider.getTeamMemberLoader
                              ? const CircularProgressIndicator()
                              : provider.teamMemberList.isEmpty
                                  ? const Text("No Team Members Available.")
                                  : ListView.separated(
                                      padding: const EdgeInsets.only(
                                        top: 20,
                                      ),
                                      itemBuilder: (context, index) {
                                        return SingleTeamMemberCard(
                                          index: index,
                                        );
                                      },
                                      separatorBuilder: (context, index) =>
                                          const Divider(
                                        color: AppColors.grey,
                                        thickness: 1.6,
                                      ),
                                      itemCount: provider.teamMemberList.length,
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
