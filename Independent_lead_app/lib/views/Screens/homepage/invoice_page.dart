import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

class InvoicePage extends StatelessWidget {
  const InvoicePage({super.key});

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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: screenHeight * 0.15,
                  decoration: const BoxDecoration(
                    color: AppColors.violetblue,
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: screenHeight * 0.05,
                      left: screenWidth * 0.03,
                      right: screenWidth * 0.03,
                    ),
                    child: AppBar(
                      leading: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColors.white,
                        ),
                        onPressed: () {},
                      ),
                      title: Text(
                        'Sales',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: screenWidth * 0.05,
                        ),
                      ),
                      backgroundColor: AppColors.transparent,
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: screenHeight * 0.12,
              left: screenWidth * 0.04,
              right: screenWidth * 0.04,
              bottom:
                  0, // Ensure the container stretches to the bottom of the screen
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  // Add bottom padding to make sure "Confirm" button is visible
                  child: Column(
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.03),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                decoration: InputDecoration(
                                  label: buildLabel('Customer Name'),
                                  hintText: "Start typing to select a customer",
                                  suffixIcon: const Icon(Icons.add),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              TextField(
                                decoration: InputDecoration(
                                  label: buildLabel('Sales #'),
                                  hintText: '00001',
                                  suffixIcon: const Icon(
                                    Icons.settings,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              const TextField(
                                decoration: InputDecoration(
                                  labelText: 'Sales Number',
                                  labelStyle:
                                      TextStyle(color: AppColors.violetblue),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              TextField(
                                decoration: InputDecoration(
                                  label: buildLabel('Date'),
                                  hintText: '00/00/0000',
                                  suffixIcon: const Icon(
                                    Icons.calendar_today,
                                    color: AppColors.grey,
                                  ),
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
                          padding: EdgeInsets.all(screenWidth * 0.03),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Salesperson',
                                  labelStyle:
                                      TextStyle(color: AppColors.violetblue),
                                  hintText: "Select a Salesperson",
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Select a Salesperson',
                                    child: Text('Select a Salesperson'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'John Doe',
                                    child: Text('John Doe'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Jane Smith',
                                    child: Text('Jane Smith'),
                                  ),
                                ],
                                onChanged: (value) {},
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              const TextField(
                                decoration: InputDecoration(
                                  labelText: 'Subject',
                                  labelStyle:
                                      TextStyle(color: AppColors.violetblue),
                                  hintText: 'What is this sales for?',
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
                          padding: EdgeInsets.all(screenWidth * 0.03),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Sales Return',
                                  labelStyle:
                                      TextStyle(color: AppColors.violetblue),
                                  hintText: "Select a Sales Return",
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Select a Sales Return',
                                    child: Text('Select a Sales Return'),
                                  ),
                                ],
                                onChanged: (value) {},
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              const TextField(
                                decoration: InputDecoration(
                                  labelText: 'Subject',
                                  labelStyle:
                                      TextStyle(color: AppColors.violetblue),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(screenWidth * 0.03),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Attachments",
                                  style: TextStyle(
                                    color: AppColors.violetblue,
                                    fontSize: screenWidth * 0.04,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.note_add_rounded),
                                    label: const Text('Upload File'),
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      side: const BorderSide(
                                        color: AppColors.violetblue,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      SizedBox(
                        width: double.infinity,
                        height: screenHeight * 0.04,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.violetblue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Confirm",
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: screenWidth * 0.04,
                            ),
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
