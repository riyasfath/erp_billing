import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/core/themes/app_assets.dart';
import 'package:pokakbilling/models/data-models/teamMember_model.dart';
import 'package:pokakbilling/viewmodels/project_management/team_member_viewmodel.dart';
import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/exit_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/colored_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_text.dart';
import 'package:provider/provider.dart';

class CreateTeamMember extends StatefulWidget {
  final bool isEdit;
  final TeamMemberModel? teamMember;
  const CreateTeamMember({super.key, required this.isEdit, this.teamMember});

  @override
  State<CreateTeamMember> createState() => _CreateTeamMemberState();
}

class _CreateTeamMemberState extends State<CreateTeamMember> {
  String? selectedStatus = 'Active';
  late TextEditingController nameTextController;
  late TextEditingController emailIdTextController;
  late TextEditingController phoneTextController;

  @override
  void initState() {
    super.initState();
    nameTextController =
        TextEditingController(text: widget.teamMember?.name ?? '');
    emailIdTextController =
        TextEditingController(text: widget.teamMember?.emailId ?? '');
    phoneTextController =
        TextEditingController(text: widget.teamMember?.phone ?? '');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.isEdit
          ? Provider.of<TeamMemberViewmodel>(context, listen: false)
              .setSelectedRoleStatus(widget.teamMember?.roleDisplay)
          : Provider.of<TeamMemberViewmodel>(context, listen: false)
              .setSelectedRoleStatus(null);
    });
  }

  @override
  void dispose() {
    nameTextController.dispose();
    emailIdTextController.dispose();
    phoneTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

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
                      icon: Image.asset(AppAssets.homeIcon),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const BottomBar(index: 0),
                          ),
                        );
                      },
                    ),
                    title: Text(
                      widget.isEdit ? "Edit Team Member" : "Create Team Member",
                      style: const TextStyle(
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
                              TextFormField(
                                controller: nameTextController,
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
                              const SizedBox(height: 15),
                              Consumer<TeamMemberViewmodel>(
                                builder: (context, provider, child) {
                                  return DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                      label: CustomText(
                                        text: 'Role',
                                        isMandatory: false,
                                      ),
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 8),
                                    ),
                                    initialValue: provider.selectedRoleStatus.isEmpty
                                        ? null
                                        : provider.selectedRoleStatus,
                                    items: provider.roleStatusList
                                        .map((leadStatus) {
                                      return DropdownMenuItem(
                                        value: leadStatus,
                                        child: Text(
                                          leadStatus,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (teamMember) {
                                      if (teamMember != null) {
                                        provider.selectRoleStatus(teamMember);
                                      }
                                    },
                                    dropdownColor: AppColors.white,
                                  );
                                },
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: emailIdTextController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'required';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Email ID',
                                  hintText: "",
                                  labelStyle: TextStyle(
                                    color: AppColors.violetblue,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: phoneTextController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'required';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Phone Number',
                                  hintText: "",
                                  labelStyle: TextStyle(
                                    color: AppColors.violetblue,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    Consumer<TeamMemberViewmodel>(
                        builder: (context, provider, child) {
                      return ColoredCustomButton(
                        text: widget.isEdit ? "Edit" : "Next",
                        onPressed: () async {
                          widget.isEdit
                              ? provider.editTeamMember(
                                  widget.teamMember?.tmId,
                                  nameTextController.text,
                                  provider.selectedRoleStatusKey,
                                  emailIdTextController.text,
                                  phoneTextController.text,
                                  context,
                                )
                              : provider.createTeamMember(
                                  nameTextController.text,
                                  provider.selectedRoleStatusKey,
                                  emailIdTextController.text,
                                  phoneTextController.text,
                                  context,
                                );
                        },
                        loading: widget.isEdit
                            ? provider.editLoading
                            : provider.addTeamLoader,
                        formKey: formKey,
                      );
                    }),
                    const SizedBox(height: 20),
                    const ExitCustomButton(text: "Exit"),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
