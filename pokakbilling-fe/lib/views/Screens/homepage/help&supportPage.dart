import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {

          },
        ),
        title: Text(
          'Help & Support',
          style: TextStyle(
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Help Links',
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            HelpLinkTile(
              icon: Icons.message,
              title: 'Help Document',
              onTap: () {

              },
            ),
            HelpLinkTile(
              icon: Icons.video_library,
              title: 'Help Videos',
              onTap: () {

              },
            ),
            HelpLinkTile(
              icon: Icons.mail,
              title: 'Mail Us',
              onTap: () {

              },
            ),
          ],
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: 0,
      //   items: const [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.shopping_cart),
      //       label: 'Products',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.settings),
      //       label: 'Settings',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.person),
      //       label: 'Profile',
      //     ),
      //   ],
      //   onTap: (index) {
      //     // Handle bottom navigation tap
      //   },
      // ),
    );
  }
}

class HelpLinkTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const HelpLinkTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.04), // Responsive margin
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.violetblue),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 0, // Optional: Remove elevation for a flat look
        child: ListTile(
          leading: Icon(icon, color: AppColors.violetblue, size: screenWidth * 0.07), // Responsive icon size
          title: Text(
            title,
            style: TextStyle(fontSize: screenWidth * 0.04), // Responsive font size
          ),
          trailing: const Icon(Icons.arrow_forward),
          onTap: onTap,
        ),
      ),
    );
  }
}
