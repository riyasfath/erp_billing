import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/models/data-models/setup/terms&condition_model.dart';

class TermsServices {
  static Future<String?> createTermsTitle(
    String title,
  ) async {
    try {
      final dio = Dio();
      var data = {
        'title': title,
      };

      final response = await dio.post(ApiConstants.termsEndpoint, data: data);

      if (response.statusCode == 201) {
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
      return "Unexpected error: $e";
    }
  }

  static Future<List<TermsTitleModel>> getTermsTitle() async {
    final dio = Dio();

    final response = await dio.get(
      ApiConstants.termsEndpoint,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> termsTitleJson = jsonData["data"];

      if (jsonData["status"] == "1") {
        List<TermsTitleModel> termsTitleList = termsTitleJson
            .map((json) => TermsTitleModel.fromJson(json))
            .toList();

        return termsTitleList;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load Terms Title');
    }
  }

  static Future<String?> deleteTermsTitle(int termsId) async {
    try {
      final dio = Dio();

      final response = await dio.delete(
        ApiConstants.termsByIdEndPoint(termsId),
      );

      if (response.statusCode == 204) {
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
      return "Unexpected error: $e";
    }
  }

  static Future<List<TermsTitleModel>> getTermsTitleById(int termsId) async {
    final dio = Dio();

    final response = await dio.get(
      ApiConstants.termsByIdEndPoint(termsId),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> termsTitleJson = jsonData["data"];

      if (jsonData["status"] == "1") {
        List<TermsTitleModel> termsTitleList = termsTitleJson
            .map((json) => TermsTitleModel.fromJson(json))
            .toList();

        return termsTitleList;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load Terms Title');
    }
  }

  static Future<String?> editTermsTitle(
    int termsId,
    String title,
  ) async {
    try {
      final dio = Dio();
      var data = {
        'title': title,
      };

      final response =
          await dio.put(ApiConstants.termsByIdEndPoint(termsId), data: data);

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
      return "Unexpected error: $e";
    }
  }

  static Future<List<TermsPointsModel>> getTermsPoints(int termsId) async {
    final dio = Dio();

    final response = await dio.get(
      ApiConstants.termsPointByTermsIdEndPoint(termsId),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> termsPointsJson = jsonData["data"];

      if (jsonData["status"] == "1") {
        List<TermsPointsModel> termsPointsList = termsPointsJson
            .map((json) => TermsPointsModel.fromJson(json))
            .toList();

        return termsPointsList;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load Terms Points');
    }
  }

  static Future<String?> createTermsPoints(
    int termsId,
    String points,
  ) async {
    try {
      final dio = Dio();
      var data = {
        'terms_and_conditions': termsId,
        'point': points,
      };

      final response =
          await dio.post(ApiConstants.termsPointsEndpoint, data: data);

      if (response.statusCode == 201) {
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
      return "Unexpected error: $e";
    }
  }

  static Future<String?> deleteTermsPoints(int pointId) async {
    try {
      final dio = Dio();

      final response = await dio.delete(
        ApiConstants.termsPointByIdEndPoint(pointId),
      );

      if (response.statusCode == 204) {
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
      return "Unexpected error: $e";
    }
  }

  static Future<String?> editTermsPoint(
    int pointId,
    int termsId,
    String point,
  ) async {
    try {
      final dio = Dio();
      var data = {
        "terms_and_conditions": termsId,
        "point": point,
      };

      final response = await dio.put(
        ApiConstants.termsPointByIdEndPoint(pointId),
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
      return "Unexpected error: $e";
    }
  }
}
