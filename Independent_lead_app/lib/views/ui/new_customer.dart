import 'package:flutter/material.dart';
import 'package:pokakbilling/viewmodels/customer_viewmodel.dart';
import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:provider/provider.dart';

class NewCustomer extends StatefulWidget {
  const NewCustomer({super.key});

  @override
  State<NewCustomer> createState() => _NewCustomerState();
}

class _NewCustomerState extends State<NewCustomer> {
  Widget buildLabel(String text) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: text,
            style: const TextStyle(
              color: AppColors.violetblue,
              fontSize: 16,
            ),
          ),
          const TextSpan(
            text: ' *',
            style: TextStyle(
              color: AppColors.red,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _selectedCustomerType = 'business';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final customerViewmodel = Provider.of<CustomerViewmodel>(context);

    return SafeArea(
      child: Scaffold(
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
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenHeight * 0.05,
                    ),
                    child: AppBar(
                      leading: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColors.white,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const BottomBar(index: 0),
                            ),
                          );
                        },
                      ),
                      title: Text(
                        'Welcon New Customer',
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: screenWidth * 0.05,
                        ),
                      ),
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      actions: [
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            "Save",
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: AppColors.white,
                            ),
                          ),
                        ),
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
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Customer Information',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Text(
                                'Customer Type',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  color: AppColors.violetblue,
                                ),
                              ),
                              Row(
                                children: [
                                  Radio(
                                    value: 'business',
                                    groupValue: _selectedCustomerType,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedCustomerType =
                                            value.toString();
                                      });
                                    },
                                  ),
                                  Text(
                                    'Business',
                                    style:
                                        TextStyle(fontSize: screenWidth * 0.04),
                                  ),
                                  Radio(
                                    value: 'individual',
                                    groupValue: _selectedCustomerType,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedCustomerType =
                                            value.toString();
                                      });
                                    },
                                  ),
                                  Text(
                                    'Individual',
                                    style:
                                        TextStyle(fontSize: screenWidth * 0.04),
                                  ),
                                ],
                              ),
                              TextField(
                                decoration: InputDecoration(
                                  labelText: 'First Name',
                                  labelStyle: TextStyle(
                                    color: AppColors.violetblue,
                                    fontSize: screenWidth * 0.04,
                                  ),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.015),
                              TextField(
                                decoration: InputDecoration(
                                  labelText: 'Last Name',
                                  labelStyle: TextStyle(
                                    color: AppColors.violetblue,
                                    fontSize: screenWidth * 0.04,
                                  ),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.015),
                              TextField(
                                decoration: InputDecoration(
                                  labelText: 'Company Name',
                                  labelStyle: TextStyle(
                                    color: AppColors.violetblue,
                                    fontSize: screenWidth * 0.04,
                                  ),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.015),
                              TextField(
                                decoration: InputDecoration(
                                  label: buildLabel('Customer Display Name'),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.015),
                              TextField(
                                decoration: InputDecoration(
                                  label: buildLabel('Email'),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.015),
                              TextField(
                                decoration: InputDecoration(
                                  label: buildLabel('Phone'),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.015),
                              TextField(
                                decoration: InputDecoration(
                                  label: buildLabel('Mobile'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Other Details',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.015),
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  label: buildLabel('Currency'),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'INR- Indian Rupee',
                                    child: Text('INR- Indian Rupee'),
                                  ),
                                  // Add more currency options here
                                ],
                                onChanged: (value) {},
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  label: buildLabel('Payment Terms'),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Due on Receipt',
                                    child: Text('Due on Receipt'),
                                  ),
                                ],
                                onChanged: (value) {},
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
