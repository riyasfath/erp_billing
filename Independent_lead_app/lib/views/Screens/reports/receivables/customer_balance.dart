import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

class CustomerBalanceScreen extends StatelessWidget {
  const CustomerBalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Customer Balance',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 19,
            color: AppColors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 15,
              ),
            ),
          ),
        ],
        backgroundColor: AppColors.violetblue,
      ),
      body: Column(
        children: [
          SizedBox(height: height * 0.08),
          Center(
            child: Column(
              children: [
                Text(
                  'Alan',
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: height * 0.03,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Customer Balances',
                  style: TextStyle(
                    fontSize: height * 0.02,
                    color: AppColors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'As On 00/00/0000',
                  style: TextStyle(
                    fontSize: height * 0.02,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: height * 0.1),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xffF0F0F0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.25),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: height * 0.07,
            width: double.infinity,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Name',
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Balance',
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
