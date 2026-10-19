import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/views/Screens/account/account_container.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/exit_custom_button.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  String _selectedCustomerType = 'business';
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
                      'Accounts',
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
                    buildNameContainer(
                      screenHeight,
                      screenWidth,
                    ),
                    SizedBox(
                      height: screenHeight * 0.03,
                    ),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.grey,
                            blurRadius: 4,
                            offset: Offset(2, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          buildField(
                            "Date",
                            icon: Icons.calendar_month,
                          ),
                          buildField("From", icon: Icons.calendar_month),
                          buildField("To", icon: Icons.calendar_month),
                          buildField("Supplier", icon: Icons.arrow_drop_down),
                          buildField("Invoice Amount"),
                          buildField("Receipt"),
                          buildField("Sales Return"),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.03,
                    ),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.grey,
                            blurRadius: 4,
                            offset: Offset(2, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: screenHeight * 0.02),
                          const AccountContainer(
                              title: "Debit"), // For Debit Section
                          SizedBox(height: screenHeight * 0.02),
                          const AccountContainer(
                              title: "Credit"), // For Credit Section
                        ],
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.03,
                    ),
                    const ExitCustomButton(
                      text: "Exit",
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildNameContainer(screenHeight, screenWidth) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: screenHeight * 0.08,
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: const [
          BoxShadow(
            color: AppColors.grey,
            blurRadius: 6,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Radio(
            value: 'Customer',
            groupValue: _selectedCustomerType,
            onChanged: (value) {
              setState(() {
                _selectedCustomerType = value.toString();
              });
            },
          ),
          Text(
            'Customer',
            style: TextStyle(fontSize: screenWidth * 0.04),
          ),
          const SizedBox(
            width: 10,
          ),
          Radio(
            value: 'Supplier',
            groupValue: _selectedCustomerType,
            onChanged: (value) {
              setState(() {
                _selectedCustomerType = value.toString();
              });
            },
          ),
          Text(
            'Supplier',
            style: TextStyle(fontSize: screenWidth * 0.04),
          ),
        ],
      ),
    );
  }

  Widget buildField(String label, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                color: AppColors.violetblue,
                fontWeight: FontWeight.w500,
                fontSize: 14),
          ),
          Container(
              height: 30,
              decoration: const BoxDecoration(
                color: AppColors.lightGrey,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.grey,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      "",
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ),
                  if (icon != null)
                    Icon(
                      icon,
                      color: AppColors.grey,
                    ),
                ],
              )),
        ],
      ),
    );
  }
}
