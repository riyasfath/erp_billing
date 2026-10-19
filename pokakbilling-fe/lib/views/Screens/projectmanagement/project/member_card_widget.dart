import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/project_management/project_viewmodel.dart';
import 'package:pokakbilling/viewmodels/project_management/stack_viewmodel.dart';
import 'package:pokakbilling/viewmodels/project_management/team_member_viewmodel.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_dropdown.dart';

class MemberCardWidget extends StatefulWidget {
  final int index;
  final TextEditingController memberController;
  final TextEditingController stackController;
  final VoidCallback onRemove;
  final int memberIds;
  final int stackIds;

  const MemberCardWidget({
    super.key,
    required this.index,
    required this.memberController,
    required this.stackController,
    required this.onRemove,
    required this.memberIds,
    required this.stackIds,
  });

  @override
  State<MemberCardWidget> createState() => _MemberCardWidgetState();
}

class _MemberCardWidgetState extends State<MemberCardWidget> {
  late int memberIds;
  late int stackIds;

  @override
  void initState() {
    super.initState();
    memberIds = widget.memberIds;
    stackIds = widget.stackIds;
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider =
        Provider.of<ProjectViewmodel>(context, listen: false);

    return Card(
      color: AppColors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row with Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Team Member Details",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: widget.onRemove,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Consumer<TeamMemberViewmodel>(
              builder: (context, provider, child) {
                return CustomDropdown(
                  selectedValue: provider.teamMemberList
                      .firstWhereOrNull((c) => c.tmId == memberIds)
                      ?.name,
                  hint: "Select Team Member",
                  dropdownItems: provider.teamMemberList
                      .map((c) => c.name)
                      .toSet()
                      .toList(),
                  onChanged: (String? newValue) async {
                    if (newValue != null) {
                      String selectedName = newValue.split(" (")[0];
                      widget.memberController.text = selectedName;

                      var selectedMember = provider.teamMemberList.firstWhere(
                        (c) => c.name == selectedName,
                      );

                      setState(() {
                        memberIds = selectedMember.tmId;
                        widget.memberController.text = selectedMember.name;
                      });

                      projectProvider.updateMemberId(selectedMember.tmId);
                      // projectProvider.updateMemberIds(
                      //     widget.index, selectedMember.tmId);
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 15),
            Consumer<StackViewmodel>(builder: (context, provider, child) {
              return CustomDropdown(
                selectedValue: provider.stackList
                    .firstWhereOrNull((c) => c.stackId == stackIds)
                    ?.stackName,
                hint: "Stack",
                dropdownItems:
                    provider.stackList.map((c) => c.stackName).toSet().toList(),
                onChanged: (String? newValue) async {
                  if (newValue != null) {
                    String selectedName = newValue.split(" (")[0];
                    widget.stackController.text = selectedName;

                    var selectedStack = provider.stackList.firstWhere(
                      (c) => c.stackName == selectedName,
                    );

                    setState(() {
                      stackIds = selectedStack.stackId;
                      widget.stackController.text = selectedStack.stackName;
                    });

                    projectProvider.updateStackId(selectedStack.stackId);
                    // projectProvider.updateStackIds(
                    //     widget.index, selectedStack.stackId);
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
