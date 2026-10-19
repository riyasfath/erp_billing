import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/setup/contract_viewmodel.dart';
import 'package:pokakbilling/views/Screens/SetUp/contract_details/contract_sub_header/single_contract_header.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/colored_custom_button.dart';
import 'package:provider/provider.dart';

class ContractDetailsSubheadingScreen extends StatefulWidget {
  final int contractId;
  final String contractHeading;
  const ContractDetailsSubheadingScreen(
      {super.key, required this.contractId, required this.contractHeading});

  @override
  State<ContractDetailsSubheadingScreen> createState() =>
      _ContractDetailsSubheadingScreenState();
}

class _ContractDetailsSubheadingScreenState
    extends State<ContractDetailsSubheadingScreen> {
  late TextEditingController contractsubHeaderController;

  @override
  void initState() {
    super.initState();
    contractsubHeaderController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    contractsubHeaderController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
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
          widget.contractHeading,
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
              "Enter the contract deatils",
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
                controller: contractsubHeaderController,
                maxLines: 2,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter the contract deatils",
                  hintStyle: TextStyle(
                    color: AppColors.grey,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Contract details are required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            Consumer<ContractViewmodel>(
              builder: (context, provider, child) {
                return ColoredCustomButton(
                  text: "Save",
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      provider.createContractSubHeading(
                        widget.contractId,
                        contractsubHeaderController.text,
                        context,
                      );
                    }
                    contractsubHeaderController.clear();
                  },
                  formKey: formKey,
                  loading: provider.createSubHeadingLoading,
                );
              },
            ),
            const SizedBox(height: 10),
            Consumer<ContractViewmodel>(
              builder: (context, provider, child) {
                if (provider.getSubHeadingLoading) {
                  return const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (provider.contractSubHeadingList.isEmpty) {
                  return const Expanded(
                    child: Center(
                      child: Text("No subheadings found"),
                    ),
                  );
                } else {
                  return Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.only(top: 20),
                      itemBuilder: (context, index) {
                        return SingleContractDetailsSubHeadingCard(
                          index: index,
                        );
                      },
                      separatorBuilder: (context, index) => const SizedBox(
                        height: 20,
                      ),
                      itemCount: provider.contractSubHeadingList.length,
                    ),
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
