import '../core/network/api_endpoints.dart';
import '../core/network/api_exception.dart';
import '../core/network/dio_client.dart';
import '../models/class_model.dart';

class ClassService {
  ClassService([DioClient? client]) : _client = client ?? DioClient.shared;

  final DioClient _client;

  /// GET /internship/class/
  Future<List<ClassItem>> getClasses() async {
    final res = await _client.get<dynamic>(ApiEndpoints.classes);
    final data = res.data;
    final list = data is List
        ? data
        : (data is Map && data['results'] is List
            ? data['results'] as List
            : null);
    if (list == null) {
      throw const ApiException('Invalid classes response from server.');
    }
    return list
        .whereType<Map>()
        .map((e) => ClassItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// GET /internship/class/{id}/
  Future<ClassDetail> getClassDetail(int id) async {
    final res = await _client.get<dynamic>(ApiEndpoints.classById(id));
    final data = res.data;
    if (data is! Map) {
      throw const ApiException('Invalid class detail response.');
    }
    return ClassDetail.fromJson(Map<String, dynamic>.from(data));
  }
}