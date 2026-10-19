import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/services.dart';
import 'package:pokakbilling/viewmodels/access_viewmodel.dart';
import 'package:pokakbilling/viewmodels/login_viewmodel.dart';
import 'package:provider/provider.dart';

class AuthServices {
  static Future<String?> signupUser(
    String firstName,
    String lastName,
    String emailId,
    String password,
  ) async {
    try {
      final dio = Dio();
      var data = {
        'first_name': firstName,
        'last_name': lastName,
        'email': emailId,
        'password': password,
      };
      print('Request Body: $data');

      final response = await dio.post(ApiConstants.signupEndPoint, data: data);

      if (response.statusCode == 201) {
        return null;
      } else {
        return response.data.toString();
      }
    } on DioException catch (e) {
      print("DioException caught: $e");

      if (e.response?.data != null &&
          e.response?.data is Map<String, dynamic>) {
        final errorData = e.response?.data as Map<String, dynamic>;

        String? errorMessage;
        errorData.forEach((key, value) {
          if (value is List && value.isNotEmpty) {
            errorMessage ??= value.first.toString();
          } else if (value is String) {
            errorMessage ??= value;
          }
        });

        return errorMessage ?? "Something went wrong. Please try again.";
      }

      return "Something went wrong. Please try again.";
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  static Future<String?> addOtp(email, otpNumber) async {
    try {
      final dio = Dio();
      var data = {
        'email': email,
        'otp': otpNumber,
      };
      final response = await dio.post(
        ApiConstants.verifyOtpEndPoint,
        data: data,
      );

      if (response.statusCode == 200) {
        return null;
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
      print("catch error - $e");
    }
    return '';
  }

  static Future<String?> addOrganization(
    email,
    organizationName,
    locationName,
    stateName,
  ) async {
    try {
      final dio = Dio();
      var data = {
        'email': email,
        'organization_name': organizationName,
        'business_location': locationName,
        'state_province': stateName,
      };
      final response = await dio.post(
        ApiConstants.getStartedEndPoint,
        data: data,
      );

      if (response.statusCode == 200) {
        return null;
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
      print("catch error - $e");
    }
    return '';
  }

  static Future<String?> userLogin(
    String emailId,
    String password,
    BuildContext context,
  ) async {
    try {
      final dio = Dio();
      final response = await dio.post(
        ApiConstants.loginEndPoint,
        data: {'email': emailId, 'password': password},
      );

      if (response.statusCode == 200) {
        final SecureStorageService secureStorage = SecureStorageService();
        final Map<String, dynamic>? responseData = response.data;

        if (responseData != null) {
          final String accessToken = responseData['access'] ?? '';
          await secureStorage.storeToken(accessToken);

          final String username = responseData['username'] ?? '';
          final String email = responseData['email'] ?? emailId;
          final bool isVerified = responseData['is_verified'] ?? false;
          final String role =
              (responseData['role'] ?? '').toString().toUpperCase();
          final int? userId = responseData['id'] != null
              ? int.tryParse(responseData['id'].toString())
              : null;
          final String? userType = responseData['user_type']?.toString();
          final bool hasSub = responseData['has_active_subscription'] ?? false;

          if (context.mounted) {
            Provider.of<LoginViewModel>(context, listen: false).setUserData(
              username: username,
              email: email,
              isVerified: isVerified,
              role: role,
              userId: userId,
              userType: userType,
              hasSubscription: hasSub,
            );

            Provider.of<AccessViewModel>(context, listen: false).isLogin();
          }
        }
        return null;
      } else {
        return response.data.toString();
      }
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData != null && errorData is Map<String, dynamic>) {
        String? msg;
        errorData.forEach((key, value) {
          if (value is List && value.isNotEmpty)
            msg ??= value.first.toString();
          else if (value is String) msg ??= value;
        });
        return msg ?? 'Something went wrong. Please try again.';
      }
      return 'Something went wrong. Please try again.';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }
}
