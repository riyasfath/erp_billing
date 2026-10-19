import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';

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
}
