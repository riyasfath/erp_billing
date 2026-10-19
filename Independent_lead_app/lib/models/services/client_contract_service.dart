import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/client_contract_model.dart';

class ContractServices {
  // ================= CREATE =================
  static Future<String?> createContract(ContractModel contract) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final response = await dio.post(
        ApiConstants.clientContractEndpoint,
        data: contract.toJson(),
      );

      if (response.statusCode == 201) {
        return null;
      }
      return response.data.toString();
    } on DioException catch (e) {
      return e.response?.data.toString() ?? "Something went wrong";
    }
  }

  // ================= GET ALL =================
  static Future<List<ContractModel>> getContracts() async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(ApiConstants.getClientContractEndpoint);

    if (response.statusCode == 200) {
      return (response.data as List)
          .map((e) => ContractModel.fromJson(e))
          .toList();
    }
    throw Exception("Failed to load contracts");
  }

  // ================= UPDATE =================
  static Future<String?> updateContract(int id, ContractModel contract) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final response = await dio.put(
        ApiConstants.clientContractByIdEndpoint(id),
        data: contract.toJson(),
      );

      if (response.statusCode == 200) {
        return null;
      }
      return response.data.toString();
    } catch (e) {
      return "Update failed";
    }
  }

  // ================= DELETE =================
  static Future<String?> deleteContract(int id) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final response = await dio.delete(
        ApiConstants.clientContractByIdEndpoint(id),
      );

      if (response.statusCode == 204) {
        return null;
      }
      return response.data.toString();
    } catch (e) {
      return "Delete failed";
    }
  }

  // ================= BY ID =================
  static Future<ContractModel?> getContractById(int id) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final response = await dio.get(
        ApiConstants.clientContractByIdEndpoint(id),
      );

      if (response.statusCode == 200) {
        return ContractModel.fromJson(response.data);
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
