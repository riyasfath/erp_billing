import 'package:flutter/material.dart';
import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

class DateRangeScreen extends StatelessWidget {
  final List<String> dateRanges = [
    "Today",
    "This Week",
    "This Month",
    "This Quarter",
    "This Year",
    "Yesterday"
  ];

  DateRangeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.violetblue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => const ErpBottomBar(index: 0)),
            );
          },
        ),
        title: const Text(
          "Payment Received",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Save action
            },
            child: Text(
              "Save",
              style: TextStyle(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width *
                    0.05, // Use context for screen width
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: const Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Date Range",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.start,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: dateRanges.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      dateRanges[index],
                      style: TextStyle(
                          fontSize: screenHeight * 0.02, color: Colors.black),
                    ),
                    onTap: () {
                      // Handle tap
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
