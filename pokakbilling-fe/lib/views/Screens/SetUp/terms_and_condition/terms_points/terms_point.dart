import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/setup/terms&condition_viewmodel.dart';
import 'package:pokakbilling/views/Screens/SetUp/terms_and_condition/terms_points/single_points_card.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/colored_custom_button.dart';
import 'package:provider/provider.dart';

class TermsConditionPointsScreen extends StatefulWidget {
  final int termsId;
  final String heading;
  const TermsConditionPointsScreen(
      {super.key, required this.heading, required this.termsId});

  @override
  State<TermsConditionPointsScreen> createState() =>
      _TermsConditionPointsScreenState();
}

class _TermsConditionPointsScreenState
    extends State<TermsConditionPointsScreen> {
  final TextEditingController termsController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final List<String> termsList = [
    "All the transaction should be under the company account other than..",
    "Payment should be done within 7 working days.",
    "Products once sold will not be taken back.",
    "Tax and GST will be applicable as per government norms.",
    "Invoice once generated cannot be changed.",
  ];
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
        title: Text(
          widget.heading,
          style: const TextStyle(
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
              "Enter the terms and condition points",
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
                  hintText: "Enter the terms and condition points",
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
                    provider.createTermsPoints(
                      widget.termsId,
                      termsController.text,
                      widget.heading,
                      context,
                    );
                  },
                  loading: provider.createTermsPointsLoader,
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
                      padding: const EdgeInsets.only(top: 20),
                      itemBuilder: (context, index) {
                        return SingleTermsPointsCard(
                          index: index,
                          termsId: widget.termsId,
                          heading: widget.heading,
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 20),
                      itemCount: provider.termsPointsList.length,
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
