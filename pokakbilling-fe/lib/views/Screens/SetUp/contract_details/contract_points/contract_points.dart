import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/setup/contract_viewmodel.dart';
import 'package:pokakbilling/views/Screens/SetUp/contract_details/contract_points/single_contract_points.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/colored_custom_button.dart';
import 'package:provider/provider.dart';

class ContractDetailsPointScreen extends StatefulWidget {
  final int contractId;
  final int sectionId;
  final String contractHeading;
  const ContractDetailsPointScreen(
      {super.key,
      required this.contractId,
      required this.contractHeading,
      required this.sectionId});

  @override
  State<ContractDetailsPointScreen> createState() =>
      _ContractDetailsPointScreenState();
}

class _ContractDetailsPointScreenState
    extends State<ContractDetailsPointScreen> {
  late TextEditingController pointController;

  @override
  void initState() {
    super.initState();
    pointController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ContractViewmodel>(context, listen: false)
          .getAllContractPoints(widget.contractId, widget.sectionId);
    });
  }

  @override
  void dispose() {
    super.dispose();
    pointController.dispose();
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
              "Enter the contract points",
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
                controller: pointController,
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
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      await provider.createContractPoint(
                        widget.contractId,
                        widget.sectionId,
                        pointController.text.trim(),
                        context,
                      );
                    }
                    pointController.clear();
                  },
                  formKey: formKey,
                  loading: provider.createPointLoading,
                );
              },
            ),
            const SizedBox(height: 10),
            Consumer<ContractViewmodel>(
              builder: (context, provider, child) {
                if (provider.getPointsLoading) {
                  return const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (provider.contractPointsList.isEmpty) {
                  return const Expanded(
                    child: Center(
                      child: Text("No points found"),
                    ),
                  );
                } else {
                  return Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.only(top: 20),
                      itemBuilder: (context, index) {
                        return SingleContractDetailsPointsCard(
                          index: index,
                          contractId: widget.contractId,
                          sectionId: widget.sectionId,
                        );
                      },
                      separatorBuilder: (context, index) => const SizedBox(
                        height: 20,
                      ),
                      itemCount: provider.contractPointsList.length,
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
