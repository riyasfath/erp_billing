import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/activity_leads/activity.dart';

class ActivityService {
  /// GET /leads/activity/{filter}/
  /// filter: 'today' | 'completed' | 'overdue'
  static Future<ActivityResponse> fetchActivities(
      {String filter = 'today'}) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      // Build URL: e.g. /leads/activity/today/
      final url = '${ApiConstants.serverUrl}/leads/activity/$filter/';

      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final json = response.data as Map<String, dynamic>;
        // API returns status == "1" on success
        if (json['status']?.toString() == '1' ||
            json['status']?.toString() == 'success' ||
            response.statusCode == 200) {
          return ActivityResponse.fromJson(json);
        } else {
          return ActivityResponse.empty();
        }
      } else {
        return ActivityResponse.empty();
      }
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Network error';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
