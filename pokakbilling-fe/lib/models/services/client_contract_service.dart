import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/client_contract_model.dart';

class ClientContractServices {
  static Future<String?> createClientContract({
    required int clientId,
    required String contractName,
    required String description,
    required String contractDate,
    required String startDate,
    required String endDate,
    required int duration,
  }) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      var data = {
        "client": clientId,
        "contract_name": contractName,
        "description": description,
        "contract_date": contractDate,
        "start_date": startDate,
        "end_date": endDate,
        "duration": duration,
      };

      final response = await dio.post(
        ApiConstants.clientContractEndpoint,
        data: data,
      );

      if (response.statusCode == 201) {
        return null;
      } else {
        return 'Error: ${response.data}';
      }
    } on DioException catch (e) {
      return e.response?.data.toString() ?? 'Request failed: ${e.message}';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  static Future<List<ClientContractModel>> getAllClientContracts() async {
    final dio = await DioClient().getAuthorizedDio();
    final response = await dio.get(ApiConstants.clientContractEndpoint);

    if (response.statusCode == 200) {
      List<dynamic> contractJson = response.data["data"];
      return contractJson.map((e) => ClientContractModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load client contracts');
    }
  }

  static Future<String?> deleteClientContract(int contractId) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final response = await dio.delete(
        ApiConstants.clientContractByIdEndpoint(contractId),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return null;
      } else {
        return 'Error: ${response.data}';
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

  static Future<ClientContractModel?> getClientContractById(
      int contractId) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response =
          await dio.get(ApiConstants.clientContractByIdEndpoint(contractId));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ClientContractModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load client contract');
      }
    } catch (e) {
      throw Exception('Error fetching contract: $e');
    }
  }

  static Future<String?> updateClientContract({
    required int contractId,
    required int clientId,
    required String contractName,
    required String description,
    required String contractDate,
    required String startDate,
    required String endDate,
    required int duration,
  }) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      var data = {
        "client": clientId,
        "contract_name": contractName,
        "description": description,
        "contract_date": contractDate,
        "start_date": startDate,
        "end_date": endDate,
        "duration": duration,
      };

      final response = await dio.patch(
        ApiConstants.clientContractByIdEndpoint(contractId),
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return null;
      } else {
        return 'Error: ${response.data}';
      }
    } on DioException catch (e) {
      return e.response?.data.toString() ?? 'Request failed: ${e.message}';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }
}
