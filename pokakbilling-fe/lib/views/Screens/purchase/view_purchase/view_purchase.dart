import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/pdf_viewmodel.dart';
import 'package:pokakbilling/viewmodels/purchase_viewmodel.dart';
import 'package:pokakbilling/views/Screens/purchase/view_purchase/purchase_items.dart';
import 'package:pokakbilling/views/Screens/purchase/view_purchase/view_terms_and_condition.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/pdf_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/print_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/pdf/purchase_order_pdf.dart';
import 'package:pokakbilling/views/commonWidgets/view_widget/view_buildfield.dart';
import 'package:pokakbilling/views/commonWidgets/view_widget/view_namecontainer.dart';
import 'package:provider/provider.dart';

class ViewPurchase extends StatelessWidget {
  const ViewPurchase({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final purchaseOrderProvider = Provider.of<PurchaseViewmodel>(context);
    var purchaseOrder = purchaseOrderProvider.singlePurchaseOrderList[0];

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
                      'Purchase Order View',
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
                      id: purchaseOrder.purchaseOrderId,
                      name: purchaseOrder.supplierName,
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
                            label: "Purchase Order Number",
                            value: purchaseOrder.purchaseOrderNumber,
                          ),
                          const SizedBox(height: 5),
                          ViewBuildfield(
                            label: "Quotation Number",
                            value: purchaseOrder.quotationNumber,
                          ),
                          const SizedBox(height: 5),
                          ViewBuildfield(
                            label: "Purchase Order Date",
                            value: purchaseOrder.purchaseOrderDate,
                          ),
                          const SizedBox(height: 5),
                          ViewBuildfield(
                            label: "Grand Total Amount",
                            value: purchaseOrder.grandTotal.toString(),
                          ),
                          const SizedBox(height: 5),
                          ViewBuildfield(
                            label: "Remark",
                            value: purchaseOrder.remark,
                          ),
                          const SizedBox(height: 5),
                          ViewBuildfield(
                            label: "Contact Person Name",
                            value: purchaseOrder.contactPersonName,
                          ),
                          const SizedBox(height: 5),
                          ViewBuildfield(
                            label: "Contact Person Number",
                            value: purchaseOrder.contactPersonNumber,
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
                              purchaseOrder.items.length,
                              (index) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: PurchaseItems(index: index),
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
                    SizedBox(height: screenHeight * 0.03),
                    PdfCustomButton(
                      text: "PDF File",
                      onTap: () async {
                        final pdfProvider =
                            Provider.of<PdfViewmodel>(context, listen: false);

                        await pdfProvider.fetchPurchaseOrderPdf(
                            purchaseOrder.purchaseOrderId);

                        if (pdfProvider.purchaseOrderList.isNotEmpty) {
                          final purchaseorderPdf =
                              pdfProvider.purchaseOrderList[0];
                          await createPurchaseOrderPDF(purchaseorderPdf);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Failed to generate PDF.')),
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
