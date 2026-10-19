import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/member_project_task_model.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/pdf_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/print_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/view_widget/view_buildfield.dart';
import 'package:pokakbilling/views/commonWidgets/view_widget/view_namecontainer.dart';

class ViewTask extends StatelessWidget {
  final MemberProjectTaskModel task;

  const ViewTask({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: Text(
                      ' Task View',
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
                      id: task.id,
                      name: task.projectName,
                    ),
                    SizedBox(height: screenHeight * 0.03),
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ViewBuildfield(
                            label: "Task Name",
                            value: task.taskName,
                          ),
                          const SizedBox(height: 10),
                          ViewBuildfield(
                            label: "Description",
                            value: task.taskDescription,
                          ),
                          const SizedBox(height: 10),
                          ViewBuildfield(
                            label: "Start Date",
                            value: task.startDate,
                          ),
                          const SizedBox(height: 10),
                          ViewBuildfield(
                            label: "End Date",
                            value: task.endDate,
                          ),
                          const SizedBox(height: 10),
                          ViewBuildfield(
                            label: "Status",
                            value: task.displayStatus,
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    PdfCustomButton(
                      text: "PDF File",
                      onTap: () async {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('PDF generation not implemented yet.'),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    const PrintCustomButton(text: "Print"),
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
