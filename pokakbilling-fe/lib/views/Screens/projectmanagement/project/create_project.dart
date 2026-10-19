import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/project_management/client_contract_viewmodel.dart';
import 'package:pokakbilling/viewmodels/project_management/project_viewmodel.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/exit_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/colored_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_dropdown.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_text.dart';
import 'package:provider/provider.dart';

class CreateProject extends StatefulWidget {
  const CreateProject({
    super.key,
  });

  @override
  State<CreateProject> createState() => _CreateProjectState();
}

class _CreateProjectState extends State<CreateProject> {
  late TextEditingController startDateTextController;
  late TextEditingController endDateTextController;
  late TextEditingController proDurationTextController;
  late TextEditingController proNameTextController;
  late TextEditingController descriptionTextController;
  late TextEditingController clientNameTextController;

  @override
  void initState() {
    super.initState();
    startDateTextController = TextEditingController();
    endDateTextController = TextEditingController();
    proDurationTextController = TextEditingController();
    proNameTextController = TextEditingController();
    descriptionTextController = TextEditingController();
    clientNameTextController = TextEditingController();

    final projectProvider =
        Provider.of<ProjectViewmodel>(context, listen: false);
    projectProvider.selectedStatus = "";
    projectProvider.selectedStatusKey = "";
  }

  @override
  void dispose() {
    startDateTextController.dispose();
    endDateTextController.dispose();
    proDurationTextController.dispose();
    proNameTextController.dispose();
    descriptionTextController.dispose();
    clientNameTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final projectProvider = Provider.of<ProjectViewmodel>(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 150,
                decoration: const BoxDecoration(
                  color: AppColors.violetblue,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
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
                    title: const Text(
                      "Create Project",
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
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
            top: 120,
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Card(
                      color: AppColors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Form(
                        key: formKey,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: startDateTextController,
                                      decoration: InputDecoration(
                                        label: const CustomText(
                                          text: "Start Date",
                                          isMandatory: false,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 2.0, horizontal: 1.0),
                                        suffixIcon: IconButton(
                                          icon: const Icon(
                                            Icons.calendar_month,
                                            color: AppColors.grey,
                                          ),
                                          onPressed: () => _selectDate(
                                            context,
                                            startDateTextController,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: TextField(
                                      controller: endDateTextController,
                                      decoration: InputDecoration(
                                        label: const CustomText(
                                          text: "End Date",
                                          isMandatory: false,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 2.0, horizontal: 1.0),
                                        suffixIcon: IconButton(
                                          icon: const Icon(
                                            Icons.calendar_month,
                                            color: AppColors.grey,
                                          ),
                                          onPressed: () => _selectDate(
                                            context,
                                            endDateTextController,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Consumer<ClientContractViewmodel>(
                                builder: (context, provider, child) {
                                  return CustomDropdown(
                                    selectedValue: provider.contractList.any(
                                            (c) =>
                                                c.contractName ==
                                                clientNameTextController.text)
                                        ? clientNameTextController.text
                                        : null,
                                    hint: "Client Name",
                                    dropdownItems: provider.contractList
                                        .map((c) => c.contractName)
                                        .toSet()
                                        .toList(),
                                    onChanged: (String? newValue) async {
                                      if (newValue != null) {
                                        String selectedName =
                                            newValue.split(" (")[0];
                                        clientNameTextController.text =
                                            selectedName;

                                        var selectedCustomer =
                                            provider.contractList.firstWhere(
                                          (c) => c.contractName == selectedName,
                                        );

                                        // await provider.getCustomerById(
                                        //     selectedCustomer.customerId);
                                        projectProvider.updateClientId(
                                            selectedCustomer.contractId);
                                      }
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: proDurationTextController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'required';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Project Duration',
                                  hintText: "",
                                  labelStyle: TextStyle(
                                    color: AppColors.violetblue,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: proNameTextController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'required';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Project Name',
                                  hintText: "",
                                  labelStyle: TextStyle(
                                    color: AppColors.violetblue,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: descriptionTextController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'required';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Description',
                                  hintText: "",
                                  labelStyle: TextStyle(
                                    color: AppColors.violetblue,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              Consumer<ProjectViewmodel>(
                                builder: (context, provider, child) {
                                  return DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                      label: CustomText(
                                        text: 'Status',
                                        isMandatory: false,
                                      ),
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 8),
                                    ),
                                    initialValue:
                                        provider.selectedStatus.isEmpty
                                            ? null
                                            : provider.selectedStatus,
                                    items: provider.statusList.map((status) {
                                      return DropdownMenuItem(
                                        value: status,
                                        child: Text(
                                          status,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (status) {
                                      if (status != null) {
                                        provider.selectStatus(status);
                                      }
                                    },
                                    dropdownColor: AppColors.white,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    Consumer<ProjectViewmodel>(
                        builder: (context, provider, child) {
                      return ColoredCustomButton(
                        text: "Next",
                        onPressed: () async {
                          provider.createProject(
                            provider.selectedClientId,
                            proNameTextController.text,
                            descriptionTextController.text,
                            startDateTextController.text,
                            endDateTextController.text,
                            provider.selectedStatusKey,
                            proDurationTextController.text,
                            context,
                          );
                        },
                        loading: provider.createProjectLoader,
                        formKey: formKey,
                      );
                    }),
                    const SizedBox(height: 20),
                    const ExitCustomButton(
                      text: "Exit",
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _selectDate(BuildContext context, fromTextController) async {
  DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );

  if (pickedDate != null) {
    fromTextController.text = "${pickedDate.toLocal()}".split(' ')[0];
  }
}
