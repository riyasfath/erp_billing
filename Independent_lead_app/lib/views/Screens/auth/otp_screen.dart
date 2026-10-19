import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_assets.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/core/validators.dart';
import 'package:pokakbilling/viewmodels/auth_viewmodel.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/cancel_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/colored_custom_button.dart';
import 'package:provider/provider.dart';

// import the shared validators

class OtpScreen extends StatelessWidget {
  final String enteredEmail;
  const OtpScreen({super.key, required this.enteredEmail});

  @override
  Widget build(BuildContext context) {
    final otpController = TextEditingController();
    final authProvider = Provider.of<AuthViewModel>(context);
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: AppColors.violetblue,
      body: Stack(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: 50),
              ],
            ),
          ),
          Positioned(
            top: 100,
            left: 120,
            child: Image.asset(AppAssets.logo, width: 80, height: 100),
          ),
          Positioned(
            top: 100,
            left: 180,
            child:
                Image.asset("assets/images/google.png", width: 80, height: 100),
          ),
          Form(
            key: formKey,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: 520,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Verify your mobile number",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: otpController,
                        validator: Validators.validateOtp,
                        decoration: InputDecoration(
                          labelStyle: const TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 15,
                          ),
                        ),
                      ),
                      const Text(
                        "Resend OTP",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 15),
                      ColoredCustomButton(
                        text: "Verify",
                        onPressed: () {
                          if (formKey.currentState?.validate() ?? false) {
                            authProvider.addOtp(
                              enteredEmail,
                              otpController.text,
                              context,
                            );
                          }
                        },
                        loading: authProvider.otpLoading,
                        formKey: formKey,
                      ),
                      const SizedBox(height: 15),
                      const CancelCustomButton(text: "Cancel"),
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
