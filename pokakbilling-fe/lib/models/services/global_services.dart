import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/module_permission/permission_module.dart';

class GlobalServices {
  static Future<String?> getGeneratedNumbers(String type) async {
    final dio = Dio();

    final response = await dio.get(
      ApiConstants.generateNumberEndPoint(type),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;

      if (jsonData["status"] == "1") {
        return jsonData["order_number"];
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load order number');
    }
  }

  // Kept as-is — unrelated existing usage, untouched.
  static Future<List<String>> getUserModules() async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(ApiConstants.userAccessModulesEndpoint);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      if (jsonData.containsKey("modules") && jsonData["modules"] is List) {
        return List<String>.from(jsonData["modules"]);
      } else {
        throw Exception("Invalid response format");
      }
    } else {
      throw Exception('Failed to load user modules');
    }
  }

  // NEW: fetches the full nested modules+submodules permission tree
  // from /accounts/user/modules/all/ and parses it into typed models.
  static Future<List<UserModuleModel>> getUserModulesAll() async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(ApiConstants.userAccessModulesAllEndpoint);

    if (response.statusCode == 200) {
      final jsonData = response.data;
      if (jsonData is Map<String, dynamic> && jsonData['modules'] is List) {
        return (jsonData['modules'] as List)
            .map((e) => UserModuleModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      throw Exception('Failed to load user modules');
    }
  }
}
