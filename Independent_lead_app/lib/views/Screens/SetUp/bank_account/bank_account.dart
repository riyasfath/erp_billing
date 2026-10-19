import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/core/themes/app_assets.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/viewmodels/setup/bankaccount_viewmodel.dart';
import 'package:pokakbilling/viewmodels/product_viewmodel.dart';
import 'package:pokakbilling/views/Screens/SetUp/bank_account/create_account.dart';
import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/action_button.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/cancel_custom_button.dart';
import 'package:provider/provider.dart';

class BankAccountMain extends StatelessWidget {
  const BankAccountMain({super.key});

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
            pushNavigation(context, const BottomBar(index: 0));
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Bank Account',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
                fontSize: screenWidth * 0.05,
              ),
            ),
            InkWell(
              onTap: () {
                pushNavigation(context, const CreateAccount(isEdit: false));
              },
              child: Container(
                height: screenHeight * 0.032,
                width: screenWidth * 0.33,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Create Bank Account',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: screenWidth * 0.029,
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
            Consumer<BankaccountViewmodel>(
              builder: (context, provider, child) {
                return provider.getAccountLoader
                    ? const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : provider.accountList.isEmpty
                        ? const Expanded(
                            child: Center(
                              child: Text(
                                "No Bank Accounts Available !!",
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
                                                provider.accountList[index]
                                                    .bankName,
                                                style: const TextStyle(
                                                  color: AppColors.black,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            provider
                                                .accountList[index].holderName,
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
                                                // await provider.getCategoryById(
                                                //     provider.categoryList[index]
                                                //         .categoryId);

                                                // if (provider
                                                //     .singleCategoryLoader) {
                                                //   const CircularProgressIndicator();
                                                // } else {
                                                //   if (!context.mounted) return;
                                                //   Navigator.of(context).push(
                                                //     MaterialPageRoute(
                                                //       builder: (context) =>
                                                //           const ViewCategory(),
                                                //     ),
                                                //   );
                                                // }
                                              },
                                              isColored: true,
                                            ),
                                            const SizedBox(width: 10),
                                            ActionButton(
                                              text: "DELETE",
                                              loading: false,
                                              onPressed: () async {
                                                // showDeleteDialog(
                                                //   context,
                                                //   "Category",
                                                //   () => provider.deleteCategory(
                                                //     provider.categoryList[index]
                                                //         .categoryId,
                                                //     context,
                                                //   ),
                                                // );
                                              },
                                              isColored: false,
                                            ),
                                            const SizedBox(width: 10),
                                            ActionButton(
                                              text: "EDIT",
                                              loading: false,
                                              onPressed: () async {
                                                // await provider.getCategoryById(
                                                //     provider.categoryList[index]
                                                //         .categoryId);

                                                // if (provider.editLoading) {
                                                //   const CircularProgressIndicator();
                                                // } else {
                                                //   if (!context.mounted) return;
                                                //   var category = provider
                                                //       .singleCategoryList[0];
                                                //   homeNavigation(
                                                //       context,
                                                //       const CreateCategory(
                                                //         isEdit: false,
                                                //       ));

                                                // }
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
                              itemCount: provider.accountList.length,
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
