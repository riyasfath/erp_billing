import 'package:flutter/material.dart';
import 'package:pokakbilling/views/ui/item.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

class NewDeliveryChallan extends StatelessWidget {
  const NewDeliveryChallan({super.key});

  Widget buildLabel(String text) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: text,
            style: const TextStyle(
              color: AppColors.violetblue,
              fontSize: 16,
            ),
          ),
          const TextSpan(
            text: ' *',
            style: TextStyle(
              color: AppColors.red,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.violetblue,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.white,
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const ItemAdd()));
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
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          label: buildLabel('Customer Name'),
                          hintText: "Start typing to select a customer",
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      TextField(
                        decoration: InputDecoration(
                          label: buildLabel('Delivery Challans'),
                          hintText: "challan",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Customer Note',
                          hintText: "Discribe",
                          labelStyle: TextStyle(color: AppColors.violetblue),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
