import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/project_management/project_viewmodel.dart';
import 'package:pokakbilling/viewmodels/project_management/stack_viewmodel.dart';
import 'package:pokakbilling/viewmodels/project_management/team_member_viewmodel.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/colored_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_dropdown.dart';
import 'package:provider/provider.dart';

class AddMembers extends StatefulWidget {
  final int projectId;
  const AddMembers({super.key, required this.projectId});

  @override
  State<AddMembers> createState() => _AddMembersState();
}

class _AddMembersState extends State<AddMembers> {
  late TextEditingController memberNameTextController;
  late TextEditingController stackNameTextController;

  @override
  void initState() {
    super.initState();

    memberNameTextController = TextEditingController();
    stackNameTextController = TextEditingController();

    final projectProvider =
        Provider.of<ProjectViewmodel>(context, listen: false);
    projectProvider.selectedStatus = "";
    projectProvider.selectedStatusKey = "";
  }

  @override
  void dispose() {
    memberNameTextController.dispose();
    stackNameTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final projectProvider = Provider.of<ProjectViewmodel>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 150,
                decoration: const BoxDecoration(
                  color: AppColors.violetblue,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
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
                    title: const Text(
                      "Add Project Team",
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
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
            top: 120,
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Card(
                      color: AppColors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Form(
                        key: formKey,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Consumer<TeamMemberViewmodel>(
                                builder: (context, provider, child) {
                                  return CustomDropdown(
                                    selectedValue: provider.teamMemberList.any(
                                            (c) =>
                                                c.name ==
                                                memberNameTextController.text)
                                        ? memberNameTextController.text
                                        : null,
                                    hint: "Select Team Member",
                                    dropdownItems: provider.teamMemberList
                                        .map((c) => c.name)
                                        .toSet()
                                        .toList(),
                                    onChanged: (String? newValue) async {
                                      if (newValue != null) {
                                        String selectedName =
                                            newValue.split(" (")[0];
                                        memberNameTextController.text =
                                            selectedName;

                                        var selectedMember =
                                            provider.teamMemberList.firstWhere(
                                          (c) => c.name == selectedName,
                                        );

                                        projectProvider.updateMemberId(
                                            selectedMember.tmId);
                                      }
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 15),
                              Consumer<StackViewmodel>(
                                builder: (context, provider, child) {
                                  return CustomDropdown(
                                    selectedValue: provider.stackList.any((c) =>
                                            c.stackName ==
                                            stackNameTextController.text)
                                        ? stackNameTextController.text
                                        : null,
                                    hint: "Stack",
                                    dropdownItems: provider.stackList
                                        .map((c) => c.stackName)
                                        .toSet()
                                        .toList(),
                                    onChanged: (String? newValue) async {
                                      if (newValue != null) {
                                        String selectedName =
                                            newValue.split(" (")[0];
                                        stackNameTextController.text =
                                            selectedName;

                                        var selectedStack =
                                            provider.stackList.firstWhere(
                                          (c) => c.stackName == selectedName,
                                        );

                                        projectProvider.updateStackId(
                                            selectedStack.stackId);
                                      }
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Consumer<ProjectViewmodel>(
                        builder: (context, provider, child) {
                      return Card(
                        color: AppColors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.03),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Current Project Teammembers',
                                style: TextStyle(
                                  color: AppColors.violetblue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Column(
                                children: List.generate(
                                  provider.projectMemberByProjectIdList.length,
                                  (index) {
                                    final member = provider
                                        .projectMemberByProjectIdList[index];
                                    return Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              member.memberName,
                                              style: const TextStyle(
                                                fontSize: 15.5,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Text(
                                              member.stackName,
                                              style: const TextStyle(
                                                fontSize: 15.5,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Divider(
                                          color: AppColors.grey,
                                          thickness: 1.0,
                                        ),
                                        const SizedBox(height: 7),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15),
        child: Consumer<ProjectViewmodel>(
          builder: (context, provider, child) {
            return ColoredCustomButton(
              text: "Save",
              onPressed: () async {
                if (!mounted) return;
                await provider.addTeamMember(
                  widget.projectId,
                  provider.selectedMemberId,
                  provider.selectedStackId,
                  context,
                );
              },
              loading: provider.addTeamMemberLoader,
              formKey: formKey,
            );
          },
        ),
      ),
    );
  }
}
