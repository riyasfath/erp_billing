import 'package:flutter/material.dart';
import 'package:pokakbilling/views/Screens/homepage/new%20delivery%20challans.dart';
import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';
import 'package:pokakbilling/core/themes/app_assets.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

class ItemAdd extends StatelessWidget {
  const ItemAdd({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.violetblue,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.white,
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ErpBottomBar(index: 0)));
          },
        ),
        title: const Text(
          'Delivery Challans',
          style: TextStyle(color: AppColors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Save',
              style: TextStyle(color: AppColors.white),
            ),
          ),
          const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(
                Icons.search,
                color: AppColors.white,
              ))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(AppAssets.item),
            const SizedBox(height: 16),
            const Text(
              'There is no item',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: screenHeight * 0.06),
            ClipOval(
              child: Container(
                height: 100,
                width: 100,
                color: AppColors.violetblue,
                child: IconButton(
                  icon: const Icon(Icons.add, color: AppColors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NewDeliveryChallan()),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.05),
            const Text(
              'Add New item',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
