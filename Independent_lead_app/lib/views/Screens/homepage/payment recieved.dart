import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_assets.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

class PaymentsReceivedScreen extends StatelessWidget {
  const PaymentsReceivedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.violetblue,
        title: const Text(
          'Payments Received',
          style: TextStyle(color: AppColors.white, fontSize: 16),
        ),
        leading: const Icon(
          CupertinoIcons.arrow_left,
          color: AppColors.white,
        ),
        actions: [
          const Text(
            "Save",
            style: TextStyle(color: AppColors.white, fontSize: 15),
          ),
          IconButton(
            icon: const Icon(
              Icons.search,
              color: AppColors.white,
            ),
            onPressed: () {
              // Search action
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 45, left: 20),
                child: Column(
                  children: [
                    const Text(
                      'All',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.violetblue,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4.0),
                      height: 2.0,
                      width: 24.0,
                      color: const Color(0xff643CB5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Image.asset(
                AppAssets.payment,
              ),
              const SizedBox(height: 20),
              const Text(
                'No Payments have been received',
                style: TextStyle(
                    fontSize: 16,
                    color: AppColors.black,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              FloatingActionButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                onPressed: () {},
                backgroundColor: AppColors.violetblue,
                child: const Icon(
                  Icons.add,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Record Payment",
                style: TextStyle(
                    fontSize: 16,
                    color: AppColors.black,
                    fontWeight: FontWeight.w500),
              )
            ],
          ),
        ],
      ),
    );
  }
}
