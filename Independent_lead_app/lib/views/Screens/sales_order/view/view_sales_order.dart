import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/pdf_viewmodel.dart';
import 'package:pokakbilling/viewmodels/sales_order_viewmodel.dart';
import 'package:pokakbilling/views/Screens/sales_order/view/sales_order_items.dart';
import 'package:pokakbilling/views/Screens/sales_order/view/terms_and_conditions.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/pdf_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/print_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/pdf/salesorder_pdf.dart';
import 'package:pokakbilling/views/commonWidgets/view_widget/view_buildfield.dart';
import 'package:pokakbilling/views/commonWidgets/view_widget/view_namecontainer.dart';
import 'package:provider/provider.dart';

class ViewSalesOrder extends StatelessWidget {
  const ViewSalesOrder({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final salesOrderProvider = Provider.of<SalesOrderViewmodel>(context);
    var salesOrder = salesOrderProvider.singleSalesOrderList[0];

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
                      'Sales Order View',
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
                    ViewNamecontainer(
                      screenHeight: screenHeight,
                      screenWidth: screenWidth,
                      id: salesOrder.id,
                      name: salesOrder.clientName,
                    ),
                    SizedBox(
                      height: screenHeight * 0.03,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      padding: const EdgeInsets.all(16.0),
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ViewBuildfield(
                            label: "Sales Order Number",
                            value: salesOrder.salesOrderNumber,
                          ),
                          const SizedBox(height: 10),
                          ViewBuildfield(
                            label: "Sales Order Date",
                            value: salesOrder.salesDate,
                          ),
                          const SizedBox(height: 10),
                          ViewBuildfield(
                            label: "Grand Total Amount",
                            value: salesOrder.grandTotal.toString(),
                          ),
                          const SizedBox(height: 10),
                          ViewBuildfield(
                            label: "Purchase Order Number",
                            value: salesOrder.purchaseOrderNumber,
                          ),
                          const SizedBox(height: 10),
                          ViewBuildfield(
                            label: "Delivery Location",
                            value: salesOrder.deliveryLocation,
                          ),
                          const SizedBox(height: 10),
                          ViewBuildfield(
                            label: "Delivery Address",
                            value: salesOrder.deliveryAddress,
                          ),
                          const SizedBox(height: 10),
                          ViewBuildfield(
                            label: "remark",
                            value: salesOrder.remark,
                          ),
                          const SizedBox(height: 10),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Products",
                              style: TextStyle(
                                color: AppColors.violetblue,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              salesOrder.items.length,
                              (index) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: SalesOrderItems(index: index),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Terms and Conditions",
                              style: TextStyle(
                                color: AppColors.violetblue,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const ViewTermsAndConditions(),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.03,
                    ),
                    PdfCustomButton(
                      text: "PDF File",
                      onTap: () async {
                        final pdfProvider =
                            Provider.of<PdfViewmodel>(context, listen: false);
                        await pdfProvider.fetchSalesorderPdf(salesOrder.id);

                        if (pdfProvider.salesorderList.isNotEmpty) {
                          final salesorderPdf = pdfProvider.salesorderList[0];
                          await createSalesOrderPDF(salesorderPdf);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Failed to generate Sales Order PDF.')),
                          );
                        }
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
}
