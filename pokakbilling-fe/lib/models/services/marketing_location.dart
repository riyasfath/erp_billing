import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/marketing_model/location.dart';

class LocationServices {
  // GET - Fetch all locations
  static Future<List<Location>> getLocations() async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.get(ApiConstants.locationEndpoint);

      if (response.statusCode == 200) {
        List<dynamic> locationsJson = response.data;
        return locationsJson.map((json) => Location.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load locations');
      }
    } on DioException catch (e) {
      String? errorMsg = 'Unknown error';
      if (e.response?.data != null) {
        errorMsg = e.response!.data.toString();
      } else {
        errorMsg = e.message;
      }
      throw Exception(errorMsg);
    }
  }

  // POST - Create new location
  static Future<String?> createLocation(String name) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      var data = {
        'name': name,
      };

      final response = await dio.post(
        ApiConstants.locationEndpoint,
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return null; // Success
      } else {
        return 'Error: ${response.data}';
      }
    } on DioException catch (e) {
      if (e.response != null) {
        try {
          final errors = e.response?.data['Errors'];
          if (errors != null && errors.containsKey('name')) {
            return errors['name'][0];
          }
        } catch (_) {
          return 'Validation failed.';
        }
      }
      return 'Request failed: ${e.message}';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // PUT/PATCH - Update location
  static Future<String?> updateLocation(int locationId, String name) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      var data = {
        'name': name,
      };

      final response = await dio.patch(
        '${ApiConstants.locationEndpoint}$locationId/',
        data: data,
      );

      if (response.statusCode == 200) {
        return null; // Success
      } else {
        return 'Error: ${response.data}';
      }
    } on DioException catch (e) {
      if (e.response != null) {
        try {
          final errors = e.response?.data['Errors'];
          if (errors != null && errors.containsKey('name')) {
            return errors['name'][0];
          }
        } catch (_) {
          return 'Validation failed.';
        }
      }
      return 'Request failed: ${e.message}';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // DELETE - Delete location
  static Future<String?> deleteLocation(int locationId) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final response = await dio.delete(
        '${ApiConstants.locationEndpoint}$locationId/',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return null; // Success
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
}
