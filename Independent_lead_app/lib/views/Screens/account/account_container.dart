import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

class AccountContainer extends StatelessWidget {
  final String title; // Added title parameter

  const AccountContainer({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.violetblue,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          const Row(
            children: [
              Text(
                "Sl/No : 1",
                style: TextStyle(
                  color: AppColors.violetblue,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 45),
              Text(
                "00/00/0000",
                style: TextStyle(
                  color: AppColors.violetblue,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 45),
              Text(
                "Doc No",
                style: TextStyle(
                  color: AppColors.violetblue,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: SizedBox(
                  height: 25,
                  width: 20,
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.textfieldGrey),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            "Description",
            style: TextStyle(
              color: AppColors.violetblue,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          const SizedBox(
            height: 45,
            width: double.infinity,
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.textfieldGrey),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildFieldWithLabel("Receipt No"),
              buildFieldWithLabel("Amount"),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildFieldWithLabel("Return No"),
              buildFieldWithLabel("Amount"),
            ],
          )
        ],
      ),
    );
  }

  Widget buildFieldWithLabel(String label) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.violetblue,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        const SizedBox(
          height: 30,
          width: 60,
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.textfieldGrey),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
