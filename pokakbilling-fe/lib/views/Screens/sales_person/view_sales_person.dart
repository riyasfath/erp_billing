import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/salesperson_model.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/exit_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/view_widget/view_buildfield.dart';
import 'package:pokakbilling/views/commonWidgets/view_widget/view_namecontainer.dart';

class ViewSalesPersonScreen extends StatelessWidget {
  final SalesPersonModel salesPerson;
  const ViewSalesPersonScreen({super.key, required this.salesPerson});

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
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    title: Text(
                      'Sales Person',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 67, 20, 20),
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
                      id: salesPerson.salesPersonId,
                      name: "${salesPerson.firstName} ${salesPerson.lastName}",
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
                            label: "First Name",
                            value: salesPerson.firstName,
                          ),
                          ViewBuildfield(
                            label: "Last Name",
                            value: salesPerson.lastName,
                          ),
                          ViewBuildfield(
                            label: "Designation",
                            value: salesPerson.designation,
                          ),
                          ViewBuildfield(
                            label: "Country",
                            value: salesPerson.country,
                          ),
                          ViewBuildfield(
                            label: "State",
                            value: salesPerson.state,
                          ),
                          ViewBuildfield(
                            label: "Address",
                            value: salesPerson.address,
                          ),
                          ViewBuildfield(
                            label: "Email",
                            value: salesPerson.email,
                          ),
                          ViewBuildfield(
                            label: "Phone",
                            value: salesPerson.phone,
                          ),
                          ViewBuildfield(
                            label: "Mobile",
                            value: salesPerson.mobile,
                          ),
                          ViewBuildfield(
                            label: "Incentive",
                            value: salesPerson.incentive,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.03,
                    ),
                    const ExitCustomButton(text: "Exit"),
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
