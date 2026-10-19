import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/setup/terms&condition_viewmodel.dart';
import 'package:pokakbilling/views/Screens/SetUp/terms_and_condition/terms_main_header/single_header_card.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/colored_custom_button.dart';
import 'package:provider/provider.dart';

class TermsConditionHeaderScreen extends StatefulWidget {
  const TermsConditionHeaderScreen({super.key});

  @override
  State<TermsConditionHeaderScreen> createState() =>
      _TermsConditionHeaderScreenState();
}

class _TermsConditionHeaderScreenState
    extends State<TermsConditionHeaderScreen> {
  final TextEditingController termsController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Terms & Condition',
          style: TextStyle(
            fontSize: 18,
            color: AppColors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter the terms and condition",
              style: TextStyle(
                color: AppColors.grey,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Form(
              key: formKey,
              child: TextFormField(
                controller: termsController,
                maxLines: 2,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter the terms and condition",
                  hintStyle: TextStyle(
                    color: AppColors.grey,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Consumer<TermsViewmodel>(
              builder: (context, provider, child) {
                return ColoredCustomButton(
                  text: "Save",
                  onPressed: () {
                    provider.createTermsTitle(termsController.text, context);
                  },
                  loading: provider.createTermsTitleLoader,
                  formKey: formKey,
                );
              },
            ),
            const SizedBox(height: 10),
            Consumer<TermsViewmodel>(
              builder: (context, provider, child) {
                return Expanded(
                  child: Center(
                    child: ListView.separated(
                      padding: const EdgeInsets.only(
                        top: 20,
                      ),
                      itemBuilder: (context, index) {
                        return SingleTermsHeaderCard(
                          index: index,
                        );
                      },
                      separatorBuilder: (context, index) => const SizedBox(
                        height: 20,
                      ),
                      itemCount: provider.termsTitleList.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
