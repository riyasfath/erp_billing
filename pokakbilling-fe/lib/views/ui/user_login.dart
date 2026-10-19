import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/user_log_state.dart';
import 'package:pokakbilling/views/bottom_bar/settings_screen.dart';
import 'package:provider/provider.dart';

class UserLogin extends StatelessWidget {
  const UserLogin({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height;
    final width = mediaQuery.size.width;

    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        toolbarHeight: height * 0.02,
        backgroundColor: AppColors.violetblue,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height * 0.05),
                Text(
                  "Owner Mobile Number *",
                  style: TextStyle(fontSize: height * 0.02),
                ),
                SizedBox(height: height * 0.01),
                Consumer<UserLoginProvider>(
                  builder: (context, provider, child) {
                    return TextField(
                      controller: provider.mobileNumberController,
                      decoration: InputDecoration(
                        hintText: "+91",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: height * 0.02),
                Text(
                  "User Name *",
                  style: TextStyle(fontSize: height * 0.02),
                ),
                SizedBox(height: height * 0.01),
                Consumer<UserLoginProvider>(
                  builder: (context, provider, child) {
                    return TextField(
                      controller: provider.usernameController,
                      decoration: InputDecoration(
                        hintText: "abcd",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: height * 0.02),
                Text(
                  "Password *",
                  style: TextStyle(fontSize: height * 0.02),
                ),
                SizedBox(height: height * 0.01),
                Consumer<UserLoginProvider>(
                  builder: (context, provider, child) {
                    return TextField(
                      controller: provider.passwordController,
                      obscureText: !provider.isPasswordVisible,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            provider.isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: provider.togglePasswordVisibility,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: height * 0.07),
                Center(
                  child: SizedBox(
                    width: width * 0.8,
                    child: Consumer<UserLoginProvider>(
                      builder: (context, provider, child) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.violetblue,
                            padding:
                                EdgeInsets.symmetric(vertical: height * 0.02),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          onPressed: provider.isButtonEnabled
                              ? () {
                                  print(
                                      "Mobile Number: ${provider.mobileNumberController.text}");
                                  print(
                                      "Username: ${provider.usernameController.text}");
                                  print(
                                      "Password: ${provider.passwordController.text}");
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const SettingsScreen()),
                                  );
                                }
                              : null,
                          child: Text(
                            "CONTINUE",
                            style: TextStyle(
                                fontSize: height * 0.02, color: Colors.white),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
