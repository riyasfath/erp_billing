import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/core/themes/app_assets.dart';
import 'package:pokakbilling/core/validators.dart';
import 'package:pokakbilling/viewmodels/auth_viewmodel.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/colored_custom_button.dart';
import 'package:provider/provider.dart';

// import the validators

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool passwordVisible = false;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthViewModel>(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      backgroundColor: AppColors.violetblue,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned(
            top: 60,
            left: 120,
            child: Image.asset(AppAssets.logo, width: 80, height: 100),
          ),
          Positioned(
            top: 60,
            left: 180,
            child: Image.asset(AppAssets.google, width: 80, height: 100),
          ),
          Form(
            key: _formKey,
            child: Align(
              alignment: Alignment.bottomCenter,
              // Use a scrollable container that adjusts for the keyboard.
              child: SingleChildScrollView(
                // reverse:true brings focused field into view when keyboard opens
                reverse: true,
                padding: EdgeInsets.only(bottom: bottomInset),
                child: Container(
                  width: double.infinity,
                  // keep the visual height similar to original by limiting maxHeight
                  constraints: BoxConstraints(
                    // keep it flexible but don't exceed most of the screen
                    maxHeight: MediaQuery.of(context).size.height * 0.9,
                  ),
                  padding: const EdgeInsets.all(24.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    // allow column to size naturally and scroll when needed
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Enter your Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "We'll send you the code to your number to verify",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 15),
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "First Name",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
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
                      const SizedBox(height: 3),
                      TextFormField(
                        controller: firstNameController,
                        validator: (value) => Validators.validateName(value,
                            fieldName: "First Name"),
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
                      const SizedBox(height: 8),
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Last Name",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
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
                      const SizedBox(height: 3),
                      TextFormField(
                        controller: lastNameController,
                        validator: (value) => Validators.validateName(value,
                            fieldName: "Last Name"),
                        decoration: InputDecoration(
                          labelStyle: const TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Email ID",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
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
                      const SizedBox(height: 3),
                      TextFormField(
                        controller: emailController,
                        validator: Validators.validateGmail,
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
                      const SizedBox(height: 8),
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Password",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
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
                      const SizedBox(height: 3),
                      TextFormField(
                        obscureText: !passwordVisible,
                        controller: passwordController,
                        validator: Validators.validatePassword,
                        decoration: InputDecoration(
                          labelStyle: const TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 15,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                passwordVisible = !passwordVisible;
                              });
                            },
                            icon: Icon(
                              passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ColoredCustomButton(
                        text: "Get Otp",
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            authProvider.signupUser(
                              firstNameController.text,
                              lastNameController.text,
                              emailController.text,
                              passwordController.text,
                              context,
                            );
                          }
                        },
                        loading: authProvider.isLoading,
                        formKey: _formKey,
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
