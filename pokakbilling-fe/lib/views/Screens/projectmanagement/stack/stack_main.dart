import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/project_management/stack_viewmodel.dart';
import 'package:pokakbilling/views/Screens/projectmanagement/stack/single_stack_card.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/colored_custom_button.dart';
import 'package:provider/provider.dart';

class StackMain extends StatefulWidget {
  const StackMain({super.key});

  @override
  State<StackMain> createState() => _StackMainState();
}

class _StackMainState extends State<StackMain> {
  final TextEditingController stackNameTextController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    stackNameTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Form(
            key: formKey,
            child: Column(
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
                        'Stack',
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
              child: Column(
                children: [
                  _buildSearchCard(context, stackNameTextController),
                  Consumer<StackViewmodel>(
                    builder: (context, provider, child) {
                      return Expanded(
                        child: Center(
                          child: provider.getStackLoader
                              ? const CircularProgressIndicator()
                              : provider.stackList.isEmpty
                                  ? const Text("No Stacks Available")
                                  : ListView.separated(
                                      padding: const EdgeInsets.only(
                                        top: 20,
                                      ),
                                      itemBuilder: (context, index) {
                                        return SingleStackCard(
                                          index: index,
                                        );
                                      },
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(
                                        height: 20,
                                      ),
                                      itemCount: provider.stackList.length,
                                    ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  Consumer<StackViewmodel>(
                    builder: (context, provider, child) {
                      return ColoredCustomButton(
                        text: "Confirm",
                        onPressed: () async {
                          provider.createStack(stackNameTextController.text, context);
                        },
                        loading: provider.addStackLoader,
                        formKey: formKey,
                      );
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSearchCard(
    BuildContext context,
    TextEditingController controller,
  ) {
    return Container(
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
      child: TextFormField(
        controller: controller,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'required';
          }
          return null;
        },
        decoration: const InputDecoration(
          labelText: 'Name',
          labelStyle: TextStyle(
            color: AppColors.violetblue,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
