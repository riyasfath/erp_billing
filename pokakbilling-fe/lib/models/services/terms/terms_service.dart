import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/terms_item.dart';

class TermsServices {
  /// GET /accounts/terms/
  /// Handles:
  ///   { "status": "1", "data": [ ... ] }  OR  [ ... ]
  static Future<List<TermsItem>> getTerms() async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.get(ApiConstants.termsEndpoint);

      if (response.statusCode == 200) {
        final body = response.data;

        final List<dynamic> list =
            (body is Map && body['data'] is List)
                ? body['data'] as List<dynamic>
                : (body is List)
                    ? body
                    : <dynamic>[];

        return list
            .whereType<Map<String, dynamic>>()
            .map((e) => TermsItem.fromJson(e))
            .toList();
      }

      throw Exception('Failed to load terms (${response.statusCode})');
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Unknown error';
      throw Exception('Terms fetch failed: $msg');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
