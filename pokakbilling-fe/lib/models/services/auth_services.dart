import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/services.dart';
import 'package:pokakbilling/viewmodels/access_viewmodel.dart';
import 'package:provider/provider.dart';

class AuthServices {
  static Future<String?> signupUser(
    String firstName,
    String lastName,
    String emailId,
    String password,
  ) async {
    return null;
  
    // ... keep your existing signupUser implementation (no change needed)
  }

  static Future<String?> addOtp(email, otpNumber) async {
    return null;
  
    // ... keep existing addOtp (no change needed)
  }

  static Future<String?> addOrganization(
    email,
    organizationName,
    locationName,
    stateName,
  ) async {
    return null;
  
    // ... keep existing addOrganization (no change needed)
  }

  // 👉 unified login that tries user first, then admin
  static Future<String?> universalLogin(
    String emailId,
    String password,
    String turnstileToken, // ← NEW
    BuildContext context,
  ) async {
    final SecureStorageService secureStorage = SecureStorageService();

    // 1. Try normal user login
    try {
      final dio = Dio();
      final response = await dio.post(
        ApiConstants.loginEndPoint,
        data: {
          'email': emailId,
          'password': password,
          'turnstile_token': turnstileToken, // ← NEW
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final String? accessToken = data["access"];
        if (accessToken != null) {
          await secureStorage.storeToken(accessToken);
          if (context.mounted) {
            final accessProvider =
                Provider.of<AccessViewModel>(context, listen: false);
            accessProvider.isLogin();
          }
        }
        return null; // success
      }
    } on DioException catch (e) {
      // ── NEW: don't silently swallow Turnstile failures.
      // A 400 "Verification is required/failed" means the token itself
      // is the problem — retrying against the admin endpoint with the
      // same (already-consumed or invalid) token will fail too, so
      // surface it immediately instead of falling through.
      final data = e.response?.data;
      if (data is Map &&
          data['detail'] is String &&
          (data['detail'] as String).toLowerCase().contains('verification')) {
        return data['detail'] as String;
      }
      // otherwise ignore and try admin, as before
    }

    // 2. If user login failed, try admin
    try {
      final dio = Dio();
      final response = await dio.post(
        ApiConstants.adminLoginEndPoint,
        data: {
          'email': emailId,
          'password': password,
          'turnstile_token': turnstileToken, // ← NEW
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final String? accessToken = data["access"];
        final bool isSuperuser = data["is_superuser"] == true;

        if (accessToken == null) {
          return "Token missing from response.";
        }
        if (!isSuperuser) {
          return "Access denied: not an admin.";
        }

        await secureStorage.storeToken(accessToken);
        if (context.mounted) {
          final accessProvider =
              Provider.of<AccessViewModel>(context, listen: false);
          accessProvider
            ..isLogin()
            ..markAsAdmin();
        }
        return null; // admin success
      } else {
        return response.data.toString();
      }
    } on DioException catch (e) {
      Map<String, dynamic>? errorData = e.response?.data;

      if (errorData != null) {
        String? errorMessage = errorData.values.firstWhere(
          (value) => value is String,
          orElse: () => "Unknown error occurred",
        );
        return errorMessage;
      }
      return "Something went wrong. Please try again.";
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  // legacy userLogin (delegates to universalLogin)
  static Future<String?> userLogin(
    String emailId,
    String password,
    String turnstileToken, // ← NEW
    BuildContext context,
  ) async {
    return await universalLogin(emailId, password, turnstileToken, context);
  }
}
