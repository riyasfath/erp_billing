import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/setup/contract_viewmodel.dart';
import 'package:pokakbilling/views/Screens/SetUp/contract_details/contract_header/single_cd_header.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/colored_custom_button.dart';
import 'package:provider/provider.dart';

class ContractDetailsHeaderScreen extends StatefulWidget {
  const ContractDetailsHeaderScreen({super.key});

  @override
  State<ContractDetailsHeaderScreen> createState() =>
      _ContractDetailsHeaderScreenState();
}

class _ContractDetailsHeaderScreenState
    extends State<ContractDetailsHeaderScreen> {
  late TextEditingController contractHeaderController;

  @override
  void initState() {
    super.initState();
    contractHeaderController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    contractHeaderController.dispose();
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
        title: const Text(
          'Contract Details',
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
                controller: contractHeaderController,
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
                    provider.createContractHeading(
                        contractHeaderController.text, context);
                  },
                  formKey: formKey,
                  loading: provider.createContractLoading,
                );
              },
            ),
            const SizedBox(height: 10),
            Consumer<ContractViewmodel>(
              builder: (context, provider, child) {
                if (provider.getContractLoading) {
                  return const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (provider.contractHeadingList.isEmpty) {
                  return const Expanded(
                    child: Center(
                      child: Text("No Contracts found"),
                    ),
                  );
                } else {
                  return Expanded(
                    child: Center(
                      child: ListView.separated(
                        padding: const EdgeInsets.only(
                          top: 20,
                        ),
                        itemBuilder: (context, index) {
                          return SingleContractDetailsHeaderCard(
                            index: index,
                          );
                        },
                        separatorBuilder: (context, index) => const SizedBox(
                          height: 20,
                        ),
                        itemCount: provider.contractHeadingList.length,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
