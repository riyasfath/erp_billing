import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/terms_item.dart';

class PrivacyPolicyViewmodel extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  List<TermsItem> terms = [];

  Future<void> fetchTerms() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.get(ApiConstants.termsEndpoint);

      if (response.statusCode == 200) {
        final body = response.data;

        // Supports both:
        // { "status":"1", "data":[ ... ] }  OR  [ ... ]
        final List<dynamic> list = (body is Map && body['data'] is List)
            ? body['data'] as List
            : (body is List)
                ? body
                : <dynamic>[];

        terms = list
            .whereType<Map<String, dynamic>>()
            .map((e) => TermsItem.fromJson(e))
            .toList();

        // If you ONLY want items that are Privacy policies:
        // terms = terms.where((t) => t.title.toLowerCase().contains('privacy')).toList();
      } else {
        errorMessage = 'Failed to load terms (${response.statusCode})';
      }
    } on DioException catch (e) {
      errorMessage =
          e.response?.data?.toString() ?? e.message ?? 'Unknown error';
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
