import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/supplier_model.dart';
import 'package:pokakbilling/viewmodels/setup/terms&condition_viewmodel.dart';
import 'package:pokakbilling/viewmodels/supplier_viewmodel.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/colored_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/print_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_dropdown.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_text.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_textfield.dart';
import 'package:provider/provider.dart';

class AddSupplier extends StatefulWidget {
  final bool isEdit;
  final String? supplierNumber;
  final SupplierDetailModel? supplier;
  const AddSupplier({
    super.key,
    required this.isEdit,
    this.supplierNumber,
    this.supplier,
  });

  @override
  State<AddSupplier> createState() => _AddSupplierState();
}

class _AddSupplierState extends State<AddSupplier> {
  late String selectedCustomerType;

  late TextEditingController supplierNumberTextcontroller;
  late TextEditingController dateTextcontroller;
  late TextEditingController firstNameTextController;
  late TextEditingController lastNameTextController;
  late TextEditingController companyNameTextController;
  late TextEditingController contactPersonTextController;
  late TextEditingController contactPersonNumberTextController;
  late TextEditingController stateTextController;
  late TextEditingController countryTextController;
  late TextEditingController addressTextController;
  late TextEditingController emailIdTextController;
  late TextEditingController phoneTextController;
  late TextEditingController mobileTextController;
  late TextEditingController termsTextController;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    selectedCustomerType = widget.isEdit
        ? widget.supplier?.supplierType ?? 'Business'
        : 'Business';

    supplierNumberTextcontroller = TextEditingController(
      text: widget.isEdit
          ? widget.supplier?.supplierNumber ?? ''
          : widget.supplierNumber ?? '',
    );
    dateTextcontroller = TextEditingController();
    firstNameTextController =
        TextEditingController(text: widget.supplier?.firstName ?? '');
    lastNameTextController =
        TextEditingController(text: widget.supplier?.lastName ?? '');
    companyNameTextController =
        TextEditingController(text: widget.supplier?.companyName ?? '');
    contactPersonTextController =
        TextEditingController(text: widget.supplier?.contactPersonName ?? '');
    contactPersonNumberTextController =
        TextEditingController(text: widget.supplier?.contactPersonNumber ?? '');
    stateTextController =
        TextEditingController(text: widget.supplier?.state ?? '');
    countryTextController =
        TextEditingController(text: widget.supplier?.country ?? '');
    addressTextController =
        TextEditingController(text: widget.supplier?.address ?? '');
    emailIdTextController =
        TextEditingController(text: widget.supplier?.email ?? '');
    phoneTextController =
        TextEditingController(text: widget.supplier?.phone ?? '');
    mobileTextController =
        TextEditingController(text: widget.supplier?.mobile ?? '');
    termsTextController =
        TextEditingController(text: widget.supplier?.termsTitle ?? '');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final supplierProvider =
          Provider.of<SupplierViewmodel>(context, listen: false);
      supplierProvider.updateCurrency(widget.supplier?.currency ?? '');
      supplierProvider
          .updateSelectedTermsId(widget.supplier?.paymentTermsId ?? 0);
    });

    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    dateTextcontroller.text =
        widget.isEdit ? widget.supplier?.date ?? '' : formattedDate;
  }

  @override
  void dispose() {
    supplierNumberTextcontroller.dispose();
    dateTextcontroller.dispose();
    firstNameTextController.dispose();
    lastNameTextController.dispose();
    companyNameTextController.dispose();
    contactPersonTextController.dispose();
    contactPersonNumberTextController.dispose();
    stateTextController.dispose();
    countryTextController.dispose();
    addressTextController.dispose();
    emailIdTextController.dispose();
    phoneTextController.dispose();
    mobileTextController.dispose();
    termsTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
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
                      'Supplier',
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
          Form(
            key: formKey,
            child: Positioned(
              top: screenHeight * 0.15,
              left: screenWidth * 0.04,
              right: screenWidth * 0.04,
              bottom: screenWidth * 0.04,
              child: Container(
                height: screenHeight - screenHeight * 0.18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Supplier Information',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Text(
                                'Supplier Type',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  color: AppColors.violetblue,
                                ),
                              ),
                              Row(
                                children: [
                                  Radio(
                                    value: 'Business',
                                    groupValue: selectedCustomerType,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedCustomerType = value.toString();
                                      });
                                    },
                                  ),
                                  Text(
                                    'Business',
                                    style:
                                        TextStyle(fontSize: screenWidth * 0.04),
                                  ),
                                  Radio(
                                    value: 'Individual',
                                    groupValue: selectedCustomerType,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedCustomerType = value.toString();
                                      });
                                    },
                                  ),
                                  Text(
                                    'Individual',
                                    style:
                                        TextStyle(fontSize: screenWidth * 0.04),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextfield(
                                      label: "Supplier Number",
                                      hintText: "",
                                      screenWidth: 5,
                                      textController:
                                          supplierNumberTextcontroller,
                                      isMandatory: false,
                                      isEnabled: false,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: CustomTextfield(
                                      label: "Date",
                                      hintText: "",
                                      screenWidth: 5,
                                      textController: dateTextcontroller,
                                      isMandatory: false,
                                      isEnabled: true,
                                    ),
                                  ),
                                ],
                              ),
                              CustomTextfield(
                                label: "First Name",
                                hintText: "nowshad",
                                screenWidth: screenWidth,
                                textController: firstNameTextController,
                                isMandatory: false,
                              ),
                              SizedBox(height: screenHeight * 0.015),
                              CustomTextfield(
                                label: "Last Name",
                                hintText: "nowshad",
                                screenWidth: screenWidth,
                                textController: lastNameTextController,
                                isMandatory: false,
                              ),
                              SizedBox(height: screenHeight * 0.015),
                              CustomTextfield(
                                label: "Company Name",
                                hintText: "company name",
                                screenWidth: screenWidth,
                                textController: companyNameTextController,
                                isMandatory: false,
                              ),
                              SizedBox(height: screenHeight * 0.015),
                              CustomTextfield(
                                label: "Contact Person",
                                hintText: "nowshad",
                                screenWidth: screenWidth,
                                textController: contactPersonTextController,
                                isMandatory: false,
                              ),
                              SizedBox(height: screenHeight * 0.015),
                              CustomTextfield(
                                label: "Contact Person Number",
                                hintText: "nowshad",
                                screenWidth: screenWidth,
                                textController:
                                    contactPersonNumberTextController,
                                isMandatory: false,
                              ),
                              SizedBox(height: screenHeight * 0.015),
                              CustomTextfield(
                                label: "State",
                                hintText: "kerala",
                                screenWidth: screenWidth,
                                textController: stateTextController,
                                isMandatory: false,
                              ),
                              SizedBox(height: screenHeight * 0.015),
                              CustomTextfield(
                                label: "Country",
                                hintText: "india",
                                screenWidth: screenWidth,
                                textController: countryTextController,
                                isMandatory: false,
                              ),
                              SizedBox(height: screenHeight * 0.015),
                              CustomTextfield(
                                label: "Address",
                                hintText: "no:12, new street",
                                screenWidth: screenWidth,
                                textController: addressTextController,
                                isMandatory: false,
                              ),
                              SizedBox(height: screenHeight * 0.015),
                              CustomTextfield(
                                label: "Email",
                                hintText: "abc@gmail.com",
                                screenWidth: screenWidth,
                                textController: emailIdTextController,
                                isMandatory: true,
                              ),
                              SizedBox(height: screenHeight * 0.015),
                              CustomTextfield(
                                label: "Phone",
                                hintText: "9998887452",
                                screenWidth: screenWidth,
                                textController: phoneTextController,
                                isMandatory: true,
                              ),
                              SizedBox(height: screenHeight * 0.015),
                              CustomTextfield(
                                label: "Mobile",
                                hintText: "55555223200",
                                screenWidth: screenWidth,
                                textController: mobileTextController,
                                isMandatory: true,
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
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Other Details',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.015),
                              Consumer<SupplierViewmodel>(
                                builder: (context, provider, child) {
                                  return DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                      label: CustomText(
                                        text: 'Select Currency',
                                        isMandatory: false,
                                      ),
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 8),
                                    ),
                                    initialValue: provider.selectedCurrency.isEmpty
                                        ? null
                                        : provider.selectedCurrency,
                                    items: provider.currencyList.map((status) {
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
                                        provider.updateCurrency(status);
                                      }
                                    },
                                    dropdownColor: AppColors.white,
                                  );
                                },
                              ),
                              SizedBox(height: screenHeight * 0.015),
                              // Consumer2<TermsViewmodel, SupplierViewmodel>(
                              //   builder: (context, provider, supplierProvider,
                              //       child) {
                              //     return CustomDropdown(
                              //       selectedValue: provider.termsTitleList.any(
                              //               (c) =>
                              //                   c.title ==
                              //                   termsTextController.text)
                              //           ? termsTextController.text
                              //           : null,
                              //       hint: "Select Terms and Condition",
                              //       dropdownItems: provider.termsTitleList
                              //           .map((c) => c.title)
                              //           .toSet()
                              //           .toList(),
                              //       onChanged: (String? newValue) {
                              //         if (newValue != null) {
                              //           String selectedName =
                              //               newValue.split(" (")[0];
                              //           var selectedSalesPerson =
                              //               provider.termsTitleList.firstWhere(
                              //             (c) => c.title == selectedName,
                              //           );

                              //           supplierProvider.updateSelectedTermsId(
                              //             selectedSalesPerson.titleId,
                              //           );
                              //           provider.selectTermsTitle(
                              //               selectedSalesPerson.title);
                              //           termsTextController.text =
                              //               selectedSalesPerson.title
                              //                   .toString();
                              //         }
                              //       },
                              //     );
                              //   },
                              // ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.05),
                      Consumer<SupplierViewmodel>(
                        builder: (context, provider, child) {
                          return ColoredCustomButton(
                            text: "Save",
                            onPressed: () {
                              widget.isEdit
                                  ? provider.editSupplier(
                                      widget.supplier?.supplierId,
                                      selectedCustomerType,
                                      supplierNumberTextcontroller.text,
                                      dateTextcontroller.text,
                                      firstNameTextController.text,
                                      lastNameTextController.text,
                                      companyNameTextController.text,
                                      contactPersonTextController.text,
                                      contactPersonNumberTextController.text,
                                      stateTextController.text,
                                      countryTextController.text,
                                      addressTextController.text,
                                      emailIdTextController.text,
                                      phoneTextController.text,
                                      mobileTextController.text,
                                      provider.selectedCurrency,
                                      provider.selectedTermsId,
                                      context,
                                    )
                                  : provider.createSupplier(
                                      selectedCustomerType,
                                      supplierNumberTextcontroller.text,
                                      dateTextcontroller.text,
                                      firstNameTextController.text,
                                      lastNameTextController.text,
                                      companyNameTextController.text,
                                      contactPersonTextController.text,
                                      contactPersonNumberTextController.text,
                                      stateTextController.text,
                                      countryTextController.text,
                                      addressTextController.text,
                                      emailIdTextController.text,
                                      phoneTextController.text,
                                      mobileTextController.text,
                                      provider.selectedCurrency,
                                      provider.selectedTermsId,
                                      context,
                                    );
                            },
                            loading: widget.isEdit
                                ? provider.editSupplierLoading
                                : provider.createSupplierLoading,
                            formKey: formKey,
                          );
                        },
                      ),
                      SizedBox(
                        height: screenHeight * 0.03,
                      ),
                      const PrintCustomButton(
                        text: "Print",
                      )
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
