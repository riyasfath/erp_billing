import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/setup/contract_info_model.dart';
import 'package:pokakbilling/models/data-models/setup/contract_model.dart';

class ContractService {
  static Future<String?> createContractHeading(String contractHeading) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      var data = {
        'title': contractHeading,
      };

      final response =
          await dio.post(ApiConstants.contractEndpoint, data: data);

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

  static Future<List<ContractHeadingModel>> getAllContractHeading() async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.contractEndpoint,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> contractJson = jsonData["data"];

      if (jsonData["status"] == "1") {
        List<ContractHeadingModel> contractList = contractJson
            .map((json) => ContractHeadingModel.fromJson(json))
            .toList();

        return contractList;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to Contract Heading');
    }
  }

  static Future<String?> deleteContractHeading(int contractId) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final response = await dio.delete(
        ApiConstants.contractByIdEndPoint(contractId),
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

  static Future<String?> editContractHeading(
    int contractId,
    String heading,
  ) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      var data = {
        'title': heading,
      };

      final response = await dio
          .patch(ApiConstants.contractByIdEndPoint(contractId), data: data);

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

  static Future<String?> createContractSubHeading(
      int contractId, String subHeading) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      var data = {
        'title': subHeading,
      };

      print("Sending data: $data");

      final response = await dio.post(
        ApiConstants.contractSectionEndPoint(contractId),
        data: data,
      );

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

  static Future<List<ContractSubHeadingModel>> getAllContractSubHeadings(
      int contractId) async {
    final dio = await DioClient().getAuthorizedDio();
    final response =
        await dio.get(ApiConstants.contractSectionEndPoint(contractId));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> subheadingJson = jsonData["data"];

      if (jsonData["status"] == "1") {
        List<ContractSubHeadingModel> subheadings = subheadingJson
            .map((json) => ContractSubHeadingModel.fromJson(json))
            .toList();
        return subheadings;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load contract subheadings');
    }
  }

  static Future<String?> editContractSubHeading(
      int contractId, int sectionId, String newTitle) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.patch(
        ApiConstants.contractSectionByIdEndPoint(contractId, sectionId),
        data: {"title": newTitle},
      );
      return response.statusCode == 200 ? null : response.data.toString();
    } catch (e) {
      return "Edit failed: $e";
    }
  }

  static Future<String?> deleteContractSubHeading(
      int contractId, int sectionId) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.delete(
        ApiConstants.contractSectionByIdEndPoint(contractId, sectionId),
      );
      return response.statusCode == 204 ? null : response.data.toString();
    } catch (e) {
      return "Delete failed: $e";
    }
  }

//------------------POINTS---------------------
  static Future<String?> createContractPoint(
    int contractId,
    int sectionId,
    String points,
  ) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      var data = {
        'points': points,
        'section': sectionId,
      };

      final response = await dio.post(
        ApiConstants.contractSectionPointEndPoint(contractId, sectionId),
        data: data,
      );
      print('Create Point Response Status: ${response.statusCode}');
      print('Create Point Response Data: ${response.data}');

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

  static Future<List<ContractPointsModel>> getAllContractPoints(
    int contractId,
    int sectionId,
  ) async {
    final dio = await DioClient().getAuthorizedDio();
    final response = await dio.get(
      ApiConstants.contractSectionPointEndPoint(contractId, sectionId),
    );
    print('Get Points Response Status: ${response.statusCode}');
    print('Get Points Response Data: ${response.data}');
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> pointsJson = jsonData["data"];

      if (jsonData["status"] == "1") {
        List<ContractPointsModel> pointsList = pointsJson
            .map((json) => ContractPointsModel.fromJson(json))
            .toList();
        return pointsList;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load contract points');
    }
  }

  static Future<String?> editContractPoint(
    int contractId,
    int sectionId,
    int pointId,
    String updatedPoints,
  ) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.patch(
        ApiConstants.contractSectionPointByIdEndPoint(
            contractId, sectionId, pointId),
        data: {
          'points': updatedPoints,
        },
      );
      return response.statusCode == 200 ? null : response.data.toString();
    } catch (e) {
      return "Edit failed: $e";
    }
  }

  static Future<String?> deleteContractPoint(
    int contractId,
    int sectionId,
    int pointId,
  ) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.delete(
        ApiConstants.contractSectionPointByIdEndPoint(
            contractId, sectionId, pointId),
      );
      return response.statusCode == 204 ? null : response.data.toString();
    } catch (e) {
      return "Delete failed: $e";
    }
  }

  static Future<List<ContractInfoModel>> getAllContractInfo(
    int contractId,
  ) async {
    final dio = await DioClient().getAuthorizedDio();
    final response =
        await dio.get(ApiConstants.contractInfoEndPoint(contractId));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> contractInfoJson = jsonData["data"];

      if (jsonData["status"] == "1") {
        List<ContractInfoModel> contractInfo = contractInfoJson
            .map((json) => ContractInfoModel.fromJson(json))
            .toList();
        return contractInfo;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load contract Info');
    }
  }
}
