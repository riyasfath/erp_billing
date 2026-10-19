import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/core/themes/app_assets.dart';
import 'package:pokakbilling/views/Screens/user/checkbox_demo.dart';
import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController fistNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    fistNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    fistNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.violetblue,
        title: const Text(
          'Create User',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: Image.asset(AppAssets.homeIcon),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ErpBottomBar(index: 0),
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                textfieldText("First Name"),
                const SizedBox(height: 5),
                TextFormField(
                  controller: fistNameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'First name is required';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "First Name",
                    hintStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                textfieldText("Last Name"),
                const SizedBox(height: 5),
                TextFormField(
                  controller: lastNameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Last name is required';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Last Name",
                    hintStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                textfieldText("Email ID"),
                const SizedBox(height: 5),
                TextFormField(
                  controller: emailController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email Id is required';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Email ID",
                    hintStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                textfieldText("Password"),
                const SizedBox(height: 5),
                TextFormField(
                  controller: passwordController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Password",
                    hintStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (formKey.currentState!.validate()) {
                          pushNavigation(
                            context,
                            AllocateAccessCheckbox(
                              firstName: fistNameController.text,
                              lastName: lastNameController.text,
                              emailId: emailController.text,
                              password: passwordController.text,
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "Allocate Access",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.violetblue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (formKey.currentState!.validate()) {
                          pushNavigation(
                            context,
                            AllocateAccessCheckbox(
                              firstName: fistNameController.text,
                              lastName: lastNameController.text,
                              emailId: emailController.text,
                              password: passwordController.text,
                            ),
                          );
                        }
                      },
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget textfieldText(text) {
  return Text(
    text,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
  );
}
