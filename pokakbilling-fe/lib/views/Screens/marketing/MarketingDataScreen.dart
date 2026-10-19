// lib/views/Screens/marketing/marketing_data_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/views/Screens/marketing/categoryList/categoryListScreen.dart';
import 'package:pokakbilling/views/Screens/marketing/location/locationScreen.dart';
import 'package:pokakbilling/views/Screens/marketing/source/sourceScreen.dart';

class MarketingDataScreen extends StatefulWidget {
  const MarketingDataScreen({super.key});

  @override
  State<MarketingDataScreen> createState() => _MarketingDataScreenState();
}

class _MarketingDataScreenState extends State<MarketingDataScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: AppColors.violetblue,
        title: const Text(
          'Marketing Data',
          style: TextStyle(color: AppColors.white, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.arrow_left, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _setUpTile('Location', () {
              pushNavigation(context, const LocationScreen());
            }),
            _setUpTile('Sources', () {
              pushNavigation(context, const SourceScreen());
            }),
            _setUpTile('Categories', () {
              pushNavigation(context, const CategoryMarketingScreen());
            }),
          ],
        ),
      ),
    );
  }
}

Widget _setUpTile(String title, VoidCallback onTap) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.violetblue, width: 1.5),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2F2E41),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: AppColors.violetblue,
            ),
          ],
        ),
      ),
    ),
  );
}
