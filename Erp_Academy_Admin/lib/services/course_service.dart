import '../core/network/api_endpoints.dart';
import '../core/network/api_exception.dart';
import '../core/network/dio_client.dart';
import '../models/course_item_model.dart';
import '../models/create_course_request_model.dart';
import '../models/video_upload_data_model.dart';

/// Course APIs. Throws [ApiException] on failure.
class CourseService {
  CourseService([DioClient? client]) : _client = client ?? DioClient.shared;

  final DioClient _client;

  /// GET /internship/course/
  Future<List<CourseItem>> getCourses() async {
    final res = await _client.get<dynamic>(ApiEndpoints.courses);
    final data = res.data;

    final list = data is List
        ? data
        : (data is Map && data['results'] is List
            ? data['results'] as List
            : null);

    if (list == null) {
      throw const ApiException('Invalid courses response from server.');
    }

    return list
        .whereType<Map>()
        .map((e) => CourseItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// POST /internship/course/
  Future<CourseItem?> createCourse(CreateCourseRequest request) async {
    final error = request.validate();
    if (error != null) throw ApiException(error, statusCode: 400);

    final res = await _client.post<dynamic>(
      ApiEndpoints.courses,
      data: request.toJson(),
    );

    final code = res.statusCode ?? 0;
    if (code < 200 || code >= 300) {
      throw ApiException('Failed to create course.', statusCode: code);
    }

    final data = res.data;
    if (data is Map && data['id'] != null) {
      return CourseItem.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  /// DELETE /internship/course/{id}/
  Future<void> deleteCourse(int id) async {
    final res = await _client.delete<dynamic>(ApiEndpoints.courseById(id));
    final code = res.statusCode ?? 0;
    if (code < 200 || code >= 300) {
      throw ApiException('Failed to delete course.', statusCode: code);
    }
  }

  /// Course titles from the API (used by dropdowns like the upload screen).
  Future<List<String>> getDomains() async {
    final courses = await getCourses();
    return courses
        .where((c) => c.isActive)
        .map((c) => c.title)
        .toSet()
        .toList();
  }

  // ---------- Still local (no API given yet) ----------

  Future<bool> uploadVideo(VideoUploadData data) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> saveDraft(VideoUploadData data) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }
}