import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/invoice/invoice_model.dart';
import 'package:pokakbilling/views/Screens/invoice/invoice_pdf.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/pdf_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/print_custom_button.dart';

class ViewInvoiceScreen extends StatelessWidget {
  const ViewInvoiceScreen({super.key, required InvoiceModel invoice});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: screenHeight * 0.18,
                decoration: const BoxDecoration(
                  color: AppColors.violetblue,
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: screenWidth * 0.02,
                    right: screenWidth * 0.03,
                  ),
                  child: AppBar(
                    leading: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    title: Text(
                      'Invoice',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: screenWidth * 0.05,
                      ),
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: screenHeight * 0.15,
            left: screenWidth * 0.04,
            right: screenWidth * 0.04,
            child: Container(
              height: screenHeight - screenHeight * 0.18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    buildNameContainer(
                      screenHeight,
                      screenWidth,
                    ),
                    SizedBox(
                      height: screenHeight * 0.03,
                    ),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.grey,
                            blurRadius: 4,
                            offset: Offset(2, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          buildField("Invoice Date"),
                          buildField("Customer Name"),
                          buildField("Sales Order Number"),
                          buildField("Delivery Number"),
                          buildField("Product Name"),
                          buildField("Product Code"),
                          buildField("Description"),
                          buildField("Delivery Quantity"),
                          buildField("Unit Price"),
                          buildField("Total Amount"),
                          buildField("Terms"),
                          buildField("Due Date"),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.03,
                    ),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 4,
                            offset: Offset(2, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          buildField("Sales Person"),
                          buildField("Remark"),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.03,
                    ),
                    PdfCustomButton(
                      text: "PDF File",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const InvoicePDF()),
                        );
                      },
                    ),
                    SizedBox(
                      height: screenHeight * 0.03,
                    ),
                    const PrintCustomButton(
                      text: "Print",
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildNameContainer(screenHeight, screenWidth) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: screenHeight * 0.08,
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: const [
          BoxShadow(
            color: AppColors.grey,
            blurRadius: 6,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Alan Jhan",
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.black),
          ),
          Text(
            "#000001",
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.black),
          ),
        ],
      ),
    );
  }

  Widget buildField(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                color: AppColors.violetblue,
                fontWeight: FontWeight.w500,
                fontSize: 14),
          ),
          Container(
            height: 30,
            decoration: const BoxDecoration(
              color: AppColors.lightGrey,
              border: Border(
                bottom: BorderSide(
                  color: AppColors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
