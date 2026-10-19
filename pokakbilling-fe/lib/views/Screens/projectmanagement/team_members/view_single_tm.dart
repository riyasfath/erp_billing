import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/project_management/team_member_viewmodel.dart';
import 'package:pokakbilling/views/commonWidgets/view_widget/view_buildfield.dart';
import 'package:pokakbilling/views/commonWidgets/view_widget/view_namecontainer.dart';
import 'package:provider/provider.dart';

class ViewTeamMember extends StatelessWidget {
  const ViewTeamMember({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final teamMemberProvider = Provider.of<TeamMemberViewmodel>(context);
    var teamMember = teamMemberProvider.singleTeamMemberList[0];
    return Scaffold(
      backgroundColor: AppColors.white,
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
                      'Team Member View',
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
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    ViewNamecontainer(
                      screenHeight: screenHeight,
                      screenWidth: screenWidth,
                      id: teamMember.tmId,
                      name: teamMember.name,
                    ),
                    SizedBox(
                      height: screenHeight * 0.03,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.grey,
                            blurRadius: 1,
                            spreadRadius: 1,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          ViewBuildfield(
                            label: "Role",
                            value: teamMember.roleDisplay,
                          ),
                          ViewBuildfield(
                            label: "Email Id",
                            value: teamMember.emailId,
                          ),
                          ViewBuildfield(
                            label: "Phone Number",
                            value: teamMember.phone,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
