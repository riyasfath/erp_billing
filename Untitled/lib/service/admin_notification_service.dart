
import 'package:ecommerce_app/admin/admin_api_client.dart';
import 'package:ecommerce_app/admin/admin_endpoints.dart';
import 'package:ecommerce_app/admin/admin_model/admin_notifcation_model.dart';

class AdminNotificationService {
  final AdminApiClient _apiClient;

  AdminNotificationService({AdminApiClient? apiClient}) : _apiClient = apiClient ?? AdminApiClient();

  /// Plain array response (not paginated), matching the sample given.
  Future<List<AdminNotificationModel>> getNotifications() async {
    final data = await _apiClient.get(AdminEndpoints.notifications);
    final list = (data['data'] as List?) ?? (data['results'] as List?) ?? [];
    return list.map((e) => AdminNotificationModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<int> getUnreadCount() async {
    final data = await _apiClient.get(AdminEndpoints.notificationsUnreadCount);
    return data['count'] is int ? data['count'] as int : int.tryParse(data['count']?.toString() ?? '') ?? 0;
  }

  Future<void> markAsRead(int id) async {
    await _apiClient.postJson(AdminEndpoints.notificationRead(id), {});
  }

  Future<String> markAllAsRead() async {
    final data = await _apiClient.postJson(AdminEndpoints.notificationsReadAll, {});
    return data['message']?.toString() ?? 'All notifications marked as read';
  }
}