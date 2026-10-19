import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/profile_model.dart';

class ProfileService {
  // ===========================
  // GET PROFILE
  // ===========================
  static Future<List<ProfileModel>> getUserProfile() async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.profileEndpoint,
    );

    if (response.statusCode == 200) {
      return [
        ProfileModel.fromJson(response.data),
      ];
    }

    throw Exception('Failed to load profile');
  }

  // ===========================
  // UPDATE PROFILE
  // ===========================
  static Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String gender,
    required String dob,
    required String address,
    String? imagePath,
  }) async {
    final dio = await DioClient().getAuthorizedDio();

    // Only send non-empty fields to avoid backend validation errors
    final Map<String, dynamic> fields = {
      "first_name": firstName,
      "last_name": lastName,
    };

    if (phoneNumber.isNotEmpty) fields["phone_number"] = phoneNumber;
    if (gender.isNotEmpty) fields["gender"] = gender;
    if (dob.isNotEmpty) fields["dob"] = dob;
    if (address.isNotEmpty) fields["address"] = address;

    FormData formData = FormData.fromMap(fields);

    if (imagePath != null && imagePath.isNotEmpty) {
      formData.files.add(
        MapEntry(
          "profile_picture",
          await MultipartFile.fromFile(imagePath),
        ),
      );
    }

    // ── Debug logs (remove after confirming it works) ──
    print('========== PROFILE UPDATE DEBUG ==========');
    print('FIELDS SENT  : $fields');
    print('IMAGE PATH   : $imagePath');
    print('==========================================');

    try {
      final response = await dio.patch(
        ApiConstants.profileEndpoint,
        data: formData,
      );

      print('RESPONSE STATUS : ${response.statusCode}');
      print('RESPONSE BODY   : ${response.data}');

      // Accept any 2xx as success
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return;
      }

      throw Exception("Failed to update profile");
    } on DioException catch (e) {
      // Prints the REAL backend rejection reason
      print('========== DIO ERROR ==========');
      print('STATUS CODE : ${e.response?.statusCode}');
      print('ERROR BODY  : ${e.response?.data}');
      print('===============================');
      rethrow;
    }
  }
}
