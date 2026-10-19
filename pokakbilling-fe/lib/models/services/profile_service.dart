import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/profile_model.dart';

class ProfileService {
  static Future<List<ProfileModel>> getUserProfile() async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.profileEndpoint,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> profileJson = jsonData["data"];

      if (jsonData["status"] == "1") {
        List<ProfileModel> profileList =
            profileJson.map((json) => ProfileModel.fromJson(json)).toList();

        return profileList;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load Profile');
    }
  }
}
