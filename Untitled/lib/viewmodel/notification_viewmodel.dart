import 'package:flutter/foundation.dart';

import 'package:ecommerce_app/core/api_exception.dart';
import 'package:ecommerce_app/core/view_status.dart';
import 'package:ecommerce_app/models/notification_model.dart';
import 'package:ecommerce_app/service/notification_service.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationService _notificationService;

  NotificationViewModel({NotificationService? notificationService})
      : _notificationService = notificationService ?? NotificationService();

  ViewStatus status = ViewStatus.idle;
  String? error;
  List<NotificationModel> notifications = [];
  int unreadCount = 0;

  final Set<String> _markingReadIds = {};
  bool isMarkingAllRead = false;

  bool get isLoading => status == ViewStatus.loading;
  bool isMarkingRead(String id) => _markingReadIds.contains(id);

  Future<void> fetchNotifications() async {
    status = ViewStatus.loading;
    error = null;
    notifyListeners();

    try {
      notifications = await _notificationService.getNotifications();
      status = ViewStatus.success;
    } on ApiException catch (e) {
      status = ViewStatus.error;
      error = e.message;
    } catch (_) {
      status = ViewStatus.error;
      error = 'Something went wrong. Please try again.';
    }

    notifyListeners();
  }

  /// Silent on failure — a stale badge count isn't worth surfacing an
  /// error banner for; it'll correct itself next time this is called.
  Future<void> fetchUnreadCount() async {
    try {
      unreadCount = await _notificationService.getUnreadCount();
      notifyListeners();
    } catch (_) {
      // ignore
    }
  }

  Future<void> markAsRead(String id) async {
    if (_markingReadIds.contains(id)) return;
    final index = notifications.indexWhere((n) => n.id == id);
    if (index == -1 || notifications[index].isRead) return;

    _markingReadIds.add(id);
    notifyListeners();

    try {
      await _notificationService.markAsRead(id);
      notifications[index] = notifications[index].copyAsRead();
      if (unreadCount > 0) unreadCount--;
    } catch (_) {
      // Leave state unchanged — the tile just stays unread, safe to retry.
    }

    _markingReadIds.remove(id);
    notifyListeners();
  }

  Future<bool> markAllAsRead() async {
    isMarkingAllRead = true;
    notifyListeners();

    try {
      await _notificationService.markAllAsRead();
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

  /// Called on logout so a new login on this device starts with no
  /// leftover notifications from the previous user.
  void reset() {
    notifications = [];
    unreadCount = 0;
    status = ViewStatus.idle;
    error = null;
    notifyListeners();
  }
}