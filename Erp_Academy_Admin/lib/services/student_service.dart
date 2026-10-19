import '../core/network/api_endpoints.dart';
import '../core/network/api_exception.dart';
import '../core/network/dio_client.dart';
import '../models/student_model.dart';
import '../models/student_profile_model.dart';

/// Student APIs. Throws [ApiException] on failure.
class StudentService {
  StudentService([DioClient? client]) : _client = client ?? DioClient.shared;

  final DioClient _client;

  /// GET /internship/students/
  Future<List<StudentListItem>> getStudents() async {
    final res = await _client.get<dynamic>(ApiEndpoints.students);
    final data = res.data;

    final list = data is List
        ? data
        : (data is Map && data['results'] is List
            ? data['results'] as List
            : null);

    if (list == null) {
      throw const ApiException('Invalid students response from server.');
    }

    return list
        .whereType<Map>()
        .map((e) => StudentListItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// GET /internship/students/{id}/profile/
  Future<StudentProfile> getProfile(int id) async {
    final res = await _client.get<dynamic>(ApiEndpoints.studentProfile(id));
    final data = res.data;
    if (data is! Map) {
      throw const ApiException('Invalid student profile response.');
    }
    return StudentProfile.fromJson(Map<String, dynamic>.from(data));
  }

  /// PATCH /internship/students/{id}/credentials/
  Future<void> updateCredentials(
    int id, {
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final res = await _client.patch<dynamic>(
      ApiEndpoints.studentCredentials(id),
      data: {
        'email': email.trim(),
        'password': password,
        'confirm_password': confirmPassword,
      },
    );
    final code = res.statusCode ?? 0;
    if (code < 200 || code >= 300) {
      throw ApiException('Failed to update credentials.', statusCode: code);
    }
  }
}