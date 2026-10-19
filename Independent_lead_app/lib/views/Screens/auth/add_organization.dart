import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/core/validators.dart';
import 'package:pokakbilling/viewmodels/auth_viewmodel.dart';
import 'package:pokakbilling/viewmodels/country_state_viewmodel.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/colored_custom_button.dart';
import 'package:provider/provider.dart';

// import shared validators

class AddOrganizationPage extends StatefulWidget {
  final String enteredEmail;
  const AddOrganizationPage({super.key, required this.enteredEmail});

  @override
  State<AddOrganizationPage> createState() => _AddOrganizationPage();
}

class _AddOrganizationPage extends State<AddOrganizationPage> {
  bool passwordVisible = false;
  final organizationController = TextEditingController();
  final countryController = TextEditingController();
  final stateController = TextEditingController();
  final locationController = TextEditingController();
  final pincodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    organizationController.dispose();
    countryController.dispose();
    stateController.dispose();
    locationController.dispose();
    pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthViewModel>(context);
    final provider = Provider.of<CountryStateProvider>(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    // If provider has selected values, prefill the text fields (only once)
    if (provider.selectedCountry != null && countryController.text.isEmpty) {
      countryController.text = provider.selectedCountry!;
    }
    if (provider.selectedState != null && stateController.text.isEmpty) {
      stateController.text = provider.selectedState!;
    }

    return Scaffold(
      backgroundColor: AppColors.violetblue,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
          const Positioned(
            top: 50,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 60,
                ),
                Text(
                  "Organization Details",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Set up your organization to streamline billing",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 11,
                  ),
                ),
                Text(
                  "and manage transactions efficiently.",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 11,
                  ),
                ),
                Text(
                  "Providing accurate details ensures a smooth invoicing experience.",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Form(
            key: _formKey,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                reverse: true,
                padding: EdgeInsets.only(bottom: bottomInset),
                child: Container(
                  width: double.infinity,
                  // keep visual height similar while allowing scroll when keyboard opens
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.9,
                  ),
                  padding: const EdgeInsets.all(24.0),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Organization Name ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            " *",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: organizationController,
                        validator: (value) => Validators.validateName(value,
                            fieldName: "Organization Name"),
                        style: const TextStyle(color: AppColors.grey),
                        decoration: InputDecoration(
                          errorStyle: const TextStyle(height: 0.9),
                          labelStyle: const TextStyle(color: AppColors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Country as TextFormField (replaces dropdown)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Country ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                  Text(
                                    "*",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.red,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              SizedBox(
                                width: 150,
                                height: 70,
                                child: TextFormField(
                                  controller: countryController,
                                  validator: (value) => Validators.validateName(
                                      value,
                                      fieldName: "Country"),
                                  style: const TextStyle(color: AppColors.grey),
                                  decoration: InputDecoration(
                                    errorStyle: const TextStyle(height: 0.9),
                                    labelStyle:
                                        const TextStyle(color: AppColors.black),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // State/Province as TextFormField (replaces dropdown)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "State/Province ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                  Text(
                                    "*",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.red,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              SizedBox(
                                width: 150,
                                height: 70,
                                child: TextFormField(
                                  controller: stateController,
                                  validator: (value) => Validators.validateName(
                                      value,
                                      fieldName: "State/Province"),
                                  style: const TextStyle(color: AppColors.grey),
                                  decoration: InputDecoration(
                                    errorStyle: const TextStyle(height: 0.9),
                                    labelStyle:
                                        const TextStyle(color: AppColors.black),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Location ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                  Text(
                                    "*",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.red,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              SizedBox(
                                width: 150,
                                height: 55,
                                child: TextFormField(
                                  controller: locationController,
                                  validator: (value) => Validators.validateName(
                                      value,
                                      fieldName: "Location"),
                                  style: const TextStyle(color: AppColors.grey),
                                  decoration: InputDecoration(
                                    errorStyle: const TextStyle(height: 0.9),
                                    labelStyle:
                                        const TextStyle(color: AppColors.black),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Pincode ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                  Text(
                                    "*",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.red,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              SizedBox(
                                width: 150,
                                height: 55,
                                child: TextFormField(
                                  controller: pincodeController,
                                  keyboardType: TextInputType.number,
                                  validator: (value) =>
                                      Validators.validateDigits(
                                    value,
                                    fieldName: "Pincode",
                                  ),
                                  style: const TextStyle(color: AppColors.grey),
                                  decoration: InputDecoration(
                                    errorStyle: const TextStyle(height: 0.9),
                                    labelStyle:
                                        const TextStyle(color: AppColors.black),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      ColoredCustomButton(
                        text: "CONTINUE",
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            authProvider.addOrganization(
                              widget.enteredEmail,
                              organizationController.text,
                              locationController.text,
                              stateController.text,
                              countryController.text,
                              pincodeController.text,
                              context,
                            );
                          }
                        },
                        loading: authProvider.organizationLoading,
                        formKey: _formKey,
                      ),
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
