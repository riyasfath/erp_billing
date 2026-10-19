// import 'package:pokakbilling/core/api/api_constants.dart';
// import 'package:pokakbilling/core/api/dio_client.dart';
// import 'package:pokakbilling/models/data-models/terms-and-condition/terms_model.dart';

// class TermsService {
//   // ================= GET ALL TERMS =================
//   static Future<List<TermsModel>> getTermsTitle() async {
//     final dio = await DioClient().getAuthorizedDio();

//     final response = await dio.get(ApiConstants.termsEndpoint);

//     if (response.statusCode == 200) {
//       List<dynamic> jsonList = response.data;
//       return jsonList.map((e) => TermsModel.fromJson(e)).toList();
//     } else {
//       throw Exception("Failed to fetch terms");
//     }
//   }

// // ================= GET TERMS BY ID =================
// static Future<TermsModel> getTermsTitleById(int id) async {
//   final dio = await DioClient().getAuthorizedDio();

//   final response = await dio.get(ApiConstants.termsByIdEndPoint(id));

//   if (response.statusCode == 200) {
//     return TermsModel.fromJson(response.data);
//   } else {
//     throw Exception("Failed to fetch terms by id");
//   }
// }
// }
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/terms-and-condition/terms_model.dart';

class TermsService {
  static Future<List<TermsModel>> getTermsTitle() async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(ApiConstants.termsEndpoint);

    if (response.statusCode == 200) {
      final data = response.data;

      List<dynamic> jsonList;

      if (data is List) {
        jsonList = data;
      } else if (data is Map && data.containsKey('results')) {
        jsonList = data['results'];
      } else {
        throw Exception("Unexpected API response format");
      }

      return jsonList.map((e) => TermsModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch terms");
    }
  }

  // ================= GET TERMS BY ID =================
  static Future<TermsModel> getTermsTitleById(int id) async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(ApiConstants.termsByIdEndPoint(id));

    if (response.statusCode == 200) {
      return TermsModel.fromJson(response.data);
    } else {
      throw Exception("Failed to fetch terms by id");
    }
  }
}
