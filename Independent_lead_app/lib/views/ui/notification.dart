import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: height * 0.027,
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.violetblue,
        elevation: 0,
        toolbarHeight: height * 0.08,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_outlined,
                  size: height * 0.08,
                  color: Colors.grey,
                ),
                SizedBox(height: height * 0.02),
                Text(
                  'Coming Soon!',
                  style: TextStyle(
                    fontSize: height * 0.028,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: height * 0.01),
                Text(
                  'Notifications feature will be available soon. Stay tuned!',
                  style: TextStyle(
                    fontSize: height * 0.02,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
