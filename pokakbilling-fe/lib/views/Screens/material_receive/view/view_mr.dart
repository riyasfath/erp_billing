import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/material_receive_viewmodel.dart';

import 'package:pokakbilling/views/Screens/material_receive/view/mr_items.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/exit_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/view_widget/view_buildfield.dart';
import 'package:pokakbilling/views/commonWidgets/view_widget/view_namecontainer.dart';
import 'package:provider/provider.dart';

class ViewMaterialReceive extends StatelessWidget {
  const ViewMaterialReceive({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final materialProvider = Provider.of<MaterialReceiveViewmodel>(context);
    var materialreceive = materialProvider.singleMaterialReceiveList[0];

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
                      'Material Receive View',
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
                      id: materialreceive.mrId,
                      name: materialreceive.supplierName,
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
                          const SizedBox(height: 10),
                          ViewBuildfield(
                            label: "Material Receive No",
                            value: materialreceive.materialReceiveNumber,
                          ),
                          const SizedBox(height: 10),
                          ViewBuildfield(
                            label: "Material Receive Date",
                            value: materialreceive.receivedDate,
                          ),
                          const SizedBox(height: 10),
                          ViewBuildfield(
                            label: "Supplier Name",
                            value: materialreceive.supplierName,
                          ),
                          const SizedBox(height: 10),
                          ViewBuildfield(
                            label: "Purchase Order",
                            value: materialreceive.purchaseOrderNumber,
                          ),
                          const SizedBox(height: 10),
                          ViewBuildfield(
                            label: "Grand Total Amount",
                            value: materialreceive.grandTotal,
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
                              materialreceive.items.length,
                              (index) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: MaterialReceiveItems(index: index),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ViewBuildfield(
                            label: "remark",
                            value: materialreceive.remark,
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.03,
                    ),
                    const ExitCustomButton(text: "Exit"),
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
