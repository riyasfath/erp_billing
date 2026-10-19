import 'package:ecommerce_app/admin/admin_api_client.dart';
import 'package:ecommerce_app/admin/admin_model/admin_notifcation_model.dart';
import 'package:ecommerce_app/service/admin_notification_service.dart';
import 'package:flutter/foundation.dart';


class AdminNotificationViewModel extends ChangeNotifier {
  final AdminNotificationService _service;

  AdminNotificationViewModel({AdminNotificationService? service}) : _service = service ?? AdminNotificationService();

  bool isLoading = false;
  String? error;
  List<AdminNotificationModel> notifications = [];
  int unreadCount = 0;

  final Set<int> _markingReadIds = {};
  bool isMarkingAllRead = false;

  bool isMarkingRead(int id) => _markingReadIds.contains(id);

  Future<void> fetchNotifications() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      notifications = await _service.getNotifications();
      // Derive the count from the list itself (confirmed shape) rather
      // than relying only on the separate unread-count endpoint —
      // self-corrects the badge even if that endpoint has issues.
      unreadCount = notifications.where((n) => !n.isRead).length;
      isLoading = false;
    } on AdminApiException catch (e) {
      isLoading = false;
      error = e.message;
    } catch (_) {
      isLoading = false;
      error = 'Something went wrong. Please try again.';
    }
    notifyListeners();
  }

  /// Silent on failure — a stale badge count isn't worth an error banner.
  Future<void> fetchUnreadCount() async {
    try {
      unreadCount = await _service.getUnreadCount();
      notifyListeners();
    } catch (_) {
      // ignore
    }
  }

  Future<void> markAsRead(int id) async {
    if (_markingReadIds.contains(id)) return;
    final index = notifications.indexWhere((n) => n.id == id);
    if (index == -1 || notifications[index].isRead) return;

    _markingReadIds.add(id);
    notifyListeners();
    try {
      await _service.markAsRead(id);
      notifications[index] = notifications[index].copyAsRead();
      if (unreadCount > 0) unreadCount--;
    } catch (_) {
      // leave state unchanged — safe to retry
    }
    _markingReadIds.remove(id);
    notifyListeners();
  }

  Future<bool> markAllAsRead() async {
    isMarkingAllRead = true;
    notifyListeners();
    try {
      await _service.markAllAsRead();
      notifications = notifications.map((n) => n.copyAsRead()).toList();
      unreadCount = 0;
      isMarkingAllRead = false;
      notifyListeners();
      return true;
    } catch (_) {
      isMarkingAllRead = false;
      notifyListeners();
      return false;
    }
  }
}