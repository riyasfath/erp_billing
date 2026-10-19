import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

class ViewNamecontainer extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;
  final int id;
  final String name;
  const ViewNamecontainer({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
    required this.id,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      padding: const EdgeInsets.all(16.0),
      height: screenHeight * 0.08,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: const [
          BoxShadow(
            color: AppColors.grey,
            blurRadius: 1,
            spreadRadius: 1,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.black,
            ),
          ),
          Text(
            id.toString(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
