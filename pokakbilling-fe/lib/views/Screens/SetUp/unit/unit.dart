import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/core/themes/app_assets.dart';
import 'package:pokakbilling/viewmodels/product_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/unit_viewmodel.dart';
import 'package:pokakbilling/views/Screens/SetUp/unit/create_unit.dart';
import 'package:pokakbilling/views/Screens/SetUp/unit/view_unit.dart';
import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/action_button.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/cancel_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/popups/delete_popup.dart';
import 'package:provider/provider.dart';

class UnitMain extends StatelessWidget {
  const UnitMain({super.key});

  @override
  Widget build(BuildContext context) {
    final productViewModel = context.read<ProductViewModel>();
    Future.microtask(() => productViewModel.getAllProducts());
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.violetblue,
        leading: IconButton(
          icon: Image.asset(AppAssets.homeIcon),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ErpBottomBar(index: 0),
              ),
            );
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Unit',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
                fontSize: screenWidth * 0.05,
              ),
            ),
            InkWell(
              onTap: () {
                print("button pressed");
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateUnit(
                      isEdit: false,
                    ),
                  ),
                );
              },
              child: Container(
                height: screenHeight * 0.035,
                width: screenWidth * 0.32,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.white),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Create Unit',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: screenWidth * 0.035,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Consumer<UnitViewmodel>(
              builder: (context, provider, child) {
                return provider.getUnitLoader
                    ? const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : provider.unitList.isEmpty
                        ? const Expanded(
                            child: Center(
                              child: Text(
                                "No Units Available !!",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          )
                        : Expanded(
                            child: ListView.separated(
                              itemBuilder: (context, index) => Card(
                                color: AppColors.lightGrey,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(screenWidth * 0.04),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                "0${index + 1}",
                                                style: const TextStyle(
                                                  color: AppColors.black,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              SizedBox(
                                                  width: screenWidth * 0.025),
                                              Text(
                                                provider
                                                    .unitList[index].unitName,
                                                style: const TextStyle(
                                                  color: AppColors.black,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            provider.unitList[index].unitId
                                                .toString(),
                                            style: const TextStyle(
                                              color: AppColors.black,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16,
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ActionButton(
                                              text: "VIEW",
                                              loading: false,
                                              onPressed: () async {
                                                await provider.getUnitById(
                                                    provider.unitList[index]
                                                        .unitId);

                                                if (provider.singleUnitLoader) {
                                                  const CircularProgressIndicator();
                                                } else {
                                                  if (!context.mounted) return;
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const ViewUnit(),
                                                    ),
                                                  );
                                                }
                                              },
                                              isColored: true,
                                            ),
                                            const SizedBox(width: 10),
                                            ActionButton(
                                              text: "DELETE",
                                              loading: false,
                                              onPressed: () async {
                                                showDeleteDialog(
                                                  context,
                                                  "Unit",
                                                  () => provider.deleteUnit(
                                                    provider
                                                        .unitList[index].unitId,
                                                    context,
                                                  ),
                                                );
                                              },
                                              isColored: false,
                                            ),
                                            const SizedBox(width: 10),
                                            ActionButton(
                                              text: "EDIT",
                                              loading: false,
                                              onPressed: () async {
                                                await provider.getUnitById(
                                                    provider.unitList[index]
                                                        .unitId);

                                                if (provider.editLoading) {
                                                  const CircularProgressIndicator();
                                                } else {
                                                  if (!context.mounted) return;
                                                  var unit = provider
                                                      .singleUnitList[0];
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          CreateUnit(
                                                        isEdit: true,
                                                        unit: unit,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              isColored: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              separatorBuilder: (context, index) => SizedBox(
                                height: screenHeight * 0.01,
                              ),
                              itemCount: provider.unitList.length,
                            ),
                          );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: screenHeight * 0.03,
          left: screenWidth * 0.04,
          right: screenWidth * 0.04,
        ),
        child: const CancelCustomButton(
          text: "Back",
        ),
      ),
    );
  }
}
