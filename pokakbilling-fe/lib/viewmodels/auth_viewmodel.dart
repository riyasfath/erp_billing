import 'package:flutter/material.dart';
import 'package:pokakbilling/models/services/auth_services.dart';
import 'package:pokakbilling/views/Screens/auth/add_organization.dart';
import 'package:pokakbilling/views/Screens/auth/otp_screen.dart';
import 'package:pokakbilling/views/Screens/auth/success_screen.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';

class AuthViewModel extends ChangeNotifier {
  bool isLoading = false;
  bool otpLoading = false;
  bool organizationLoading = false;

  Future<void> signupUser(
    String firstName,
    String lastName,
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      isLoading = true;
      notifyListeners();

      String? response =
          await AuthServices.signupUser(firstName, lastName, email, password);

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "You're almost there! Enter the OTP we sent to complete your registration",
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(
              enteredEmail: email,
            ),
          ),
        );
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addOtp(
    email,
    otpNumber,
    BuildContext context,
  ) async {
    try {
      otpLoading = true;
      notifyListeners();
      String? response = await AuthServices.addOtp(email, otpNumber);

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "OTP verified successfully! Now, let's set up your organization details to get started.",
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddOrganizationPage(
              enteredEmail: email,
            ),
          ),
        );
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      otpLoading = false;
      notifyListeners();
    }
  }

  Future<void> addOrganization(
    email,
    organizationName,
    locationName,
    stateName,
    countryName,
    pincode,
    BuildContext context,
  ) async {
    try {
      organizationLoading = true;
      notifyListeners();
      String? response = await AuthServices.addOrganization(
        email,
        organizationName,
        locationName,
        stateName,
      );

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "Setup complete! Your account and organization are now ready. Welcome aboard!",
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SuccessScreen(),
          ),
        );
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      organizationLoading = false;
      notifyListeners();
    }
  }
}
