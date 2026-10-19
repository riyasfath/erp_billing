import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';

class UserAccessServices {
  static Future<String?> allowUserAccess(
    String firstName,
    String lastName,
    String emailId,
    String password,
    List<String> modules,
  ) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      var data = {
        'first_name': firstName,
        'last_name': lastName,
        'email': emailId,
        'password': password,
        'modules': modules,
      };

      final response =
          await dio.post(ApiConstants.userAccessEndpoint, data: data);

      if (response.statusCode == 201) {
        return null;
      } else {
        return response.data.toString();
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data != null && data is Map<String, dynamic>) {
        for (var value in data.values) {
          if (value is String) {
            return value;
          } else if (value is List &&
              value.isNotEmpty &&
              value.first is String) {
            return value.first;
          }
        }
        return "Unknown error occurred.";
      }
      return "Something went wrong. Please try again.";
    } catch (e) {
      return "Unexpected error: $e";
    }
  }
}
