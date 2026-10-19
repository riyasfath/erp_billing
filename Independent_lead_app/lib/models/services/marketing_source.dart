import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/marketing_model/source.dart';

class SourceServices {
  // GET all sources
  static Future<List<Source>> getSources() async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.get(ApiConstants.sourceEndpoint);

      if (response.statusCode == 200) {
        List<dynamic> sourcesJson = response.data;
        return sourcesJson.map((json) => Source.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load sources');
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

  // CREATE - add a new source
  static Future<String?> createSource(String name) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.post(ApiConstants.sourceEndpoint, data: {
        "name": name,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        return null; // success
      } else {
        return "Failed to create source";
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        return e.response!.data.toString();
      }
      return e.message;
    }
  }

  // UPDATE - edit existing source
  static Future<String?> updateSource(int sourceId, String name) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.patch(
        '${ApiConstants.sourceEndpoint}$sourceId/',
        data: {
          "name": name,
        },
      );

      if (response.statusCode == 200) {
        return null; // success
      } else {
        return "Failed to update source";
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        return e.response!.data.toString();
      }
      return e.message;
    }
  }

  // DELETE - remove source
  static Future<String?> deleteSource(int sourceId) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response =
          await dio.delete('${ApiConstants.sourceEndpoint}$sourceId/');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return null; // success
      } else {
        return response.data.toString();
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        return e.response!.data.toString();
      }
      return e.message;
    }
  }
}
