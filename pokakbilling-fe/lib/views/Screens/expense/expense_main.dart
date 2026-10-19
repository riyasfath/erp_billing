import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_assets.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/expense_viewmodel.dart';
import 'package:pokakbilling/views/Screens/expense/add_photo.dart';
import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/colored_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/exit_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_textfield.dart';
import 'package:provider/provider.dart';

class ExpenseMain extends StatefulWidget {
  const ExpenseMain({super.key});

  @override
  State<ExpenseMain> createState() => _ExpenseMainState();
}

class _ExpenseMainState extends State<ExpenseMain> {
  late TextEditingController deliveryNumberTextController =
      TextEditingController();
  late TextEditingController customerNameTextController =
      TextEditingController();
  late TextEditingController salesOrderNumberTextController =
      TextEditingController();
  late TextEditingController amountTextController = TextEditingController();
  late TextEditingController invoiceTextController = TextEditingController();
  late TextEditingController notesTextController = TextEditingController();
  late TextEditingController customerTextController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    deliveryNumberTextController.dispose();
    customerNameTextController.dispose();
    salesOrderNumberTextController.dispose();
    amountTextController.dispose();
    invoiceTextController.dispose();
    notesTextController.dispose();
    customerTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
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
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ErpBottomBar(index: 0),
                          ),
                        );
                      },
                    ),
                    title: Text(
                      'Expense',
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
                child: Form(
                  key: formKey,
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
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextfield(
                                      label: "Date",
                                      hintText: "INV-00001",
                                      screenWidth: screenWidth * 0.045,
                                      textController:
                                          deliveryNumberTextController,
                                      isMandatory: false,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 50,
                                  ),
                                  const DashedBorderContainer(
                                    width: 90,
                                    height: 90,
                                    imagePath: AppAssets.logo,
                                  ),
                                ],
                              ),
                              CustomTextfield(
                                label: "Expense Account",
                                hintText: "INV-00001",
                                screenWidth: screenWidth * 0.045,
                                textController: customerNameTextController,
                                isMandatory: false,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
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
                              CustomTextfield(
                                label: "Amount",
                                hintText: "",
                                screenWidth: screenWidth * 0.045,
                                textController: amountTextController,
                                isMandatory: false,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
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
                              CustomTextfield(
                                label: "Invoice#",
                                hintText: "",
                                screenWidth: screenWidth * 0.045,
                                textController: invoiceTextController,
                                isMandatory: false,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              CustomTextfield(
                                label: "Notes",
                                hintText: "",
                                screenWidth: screenWidth * 0.045,
                                textController: notesTextController,
                                isMandatory: false,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              CustomTextfield(
                                label: "Customer",
                                hintText: "",
                                screenWidth: screenWidth * 0.045,
                                textController: customerNameTextController,
                                isMandatory: false,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Consumer<ExpenseViewmodel>(
                        builder: (context, notifier, child) {
                          return ColoredCustomButton(
                            text: "Save",
                            onPressed: () {},
                            loading: notifier.addExpenseLoader,
                            formKey: formKey,
                          );
                        },
                      ),
                      SizedBox(
                        height: screenHeight * 0.02,
                      ),
                      const ExitCustomButton(text: "Print")
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
