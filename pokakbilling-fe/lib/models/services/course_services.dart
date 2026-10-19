// lib/models/services/course_services.dart

import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/student/course_model.dart';

class CourseServices {
  /// Fetches the list of internship/student courses.
  ///
  /// NOTE: Add `courseEndpoint` to your `ApiConstants` file, pointing to the
  /// actual API path (e.g. '/internship/courses/').
  static Future<List<InternshipCourseModel>> getCourses() async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(ApiConstants.internshipCourseEndpoint);

    if (response.statusCode == 200) {
      final dynamic data = response.data;
      List<dynamic> courseJson;

      if (data is Map<String, dynamic>) {
        // Supports either {"data": [...]}, {"results": [...]}, or
        // {"status": "1", "data": [...]} style responses.
        courseJson = (data['data'] ?? data['results'] ?? []) as List<dynamic>;
      } else if (data is List) {
        courseJson = data;
      } else {
        courseJson = [];
      }

      return courseJson
          .map((json) =>
              InternshipCourseModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load courses. Status: ${response.statusCode}');
    }
  }
}
