import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

class ViewBuildfield extends StatelessWidget {
  final String label;
  final String value;

  const ViewBuildfield({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.violetblue,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              alignment: Alignment.centerLeft,
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.grey,
                  ),
                ),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
                softWrap: true,
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
