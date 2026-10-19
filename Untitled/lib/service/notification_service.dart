import 'package:ecommerce_app/core/api_client.dart';
import 'package:ecommerce_app/core/providers.dart';
import 'package:ecommerce_app/models/notification_model.dart';

class NotificationService {
  final ApiClient _apiClient;

  NotificationService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Handles either a paginated {results: [...]} response or a plain
  /// array (which ApiClient.get() wraps as {'data': [...]}) — the
  /// real shape wasn't confirmed with a sample.
  Future<List<NotificationModel>> getNotifications() async {
    final data = await _apiClient.get(ApiEndpoints.notifications);
    final List<dynamic> list = (data['results'] as List?) ?? (data['data'] as List?) ?? [];
    return list.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<int> getUnreadCount() async {
    final data = await _apiClient.get(ApiEndpoints.notificationsUnreadCount);
    return data['count'] is int
        ? data['count'] as int
        : int.tryParse(data['count']?.toString() ?? '') ?? 0;
  }

  Future<void> markAsRead(String id) async {
    await _apiClient.post(ApiEndpoints.notificationRead(id), {});
  }

  Future<String> markAllAsRead() async {
    final data = await _apiClient.post(ApiEndpoints.notificationsReadAll, {});
    return data['message']?.toString() ?? 'All notifications marked as read';
  }
}