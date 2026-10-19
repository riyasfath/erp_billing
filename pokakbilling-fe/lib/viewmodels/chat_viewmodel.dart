// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:pokakbilling/models/data-models/chat/chat_inbox_item.dart';
// import 'package:pokakbilling/models/services/chat_inbox_service.dart';

// class ChatInboxViewModel extends ChangeNotifier {
//   final List<ChatInboxItem> _all = [];

//   bool _loading = false;
//   String? _error;
//   bool _disposed = false;

//   String _query = '';
//   int? _currentUserId;

//   final Map<int, int> _lastSeenCount = {};

//   Timer? _pollTimer;

//   // ── GETTERS ─────────────────────────────────────────

//   List<ChatInboxItem> get items {
//     List<ChatInboxItem> base = List<ChatInboxItem>.from(_all);

//     base.sort((a, b) {
//       if (a.lastAt == null && b.lastAt == null) return 0;
//       if (a.lastAt == null) return 1;
//       if (b.lastAt == null) return -1;
//       return b.lastAt!.compareTo(a.lastAt!);
//     });

//     if (_query.trim().isEmpty) return List.unmodifiable(base);

//     final q = _query.toLowerCase();
//     return List.unmodifiable(
//       base.where((e) => e.email.toLowerCase().contains(q)).toList(),
//     );
//   }

//   bool get loading => _loading;
//   String? get error => _error;
//   String get query => _query;
//   int? get currentUserId => _currentUserId;

//   /// ✅ RESET (for session expiry)
//   void reset() {
//     _all.clear();
//     _loading = false;
//     _error = null;
//     _query = '';
//     _currentUserId = null;
//     _lastSeenCount.clear();
//     _pollTimer?.cancel();
//     _pollTimer = null;
//     notifyListeners();
//   }

//   /// (optional alias)
//   void clearData() => reset();

//   // ── QUERY ───────────────────────────────────────────

//   void setQuery(String q) {
//     _query = q;
//     _safeNotify();
//   }

//   void clearQuery() => setQuery('');

//   // ── FETCH ───────────────────────────────────────────

//   Future<void> fetchFor(int currentUserId, {bool silent = false}) async {
//     if (_loading && !silent) return;

//     _currentUserId = currentUserId;

//     if (!silent) {
//       _loading = true;
//       _error = null;
//       _safeNotify();
//     }

//     try {
//       final result = await ChatInboxService.fetchInboxFor(currentUserId);

//       if (!_disposed) {
//         final updated = result.map((item) {
//           final prev = _all.cast<ChatInboxItem?>().firstWhere(
//                 (e) => e?.id == item.id,
//                 orElse: () => null,
//               );

//           int unread = 0;

//           if (prev != null) {
//             final prevAt = prev.lastAt;
//             final newAt = item.lastAt;

//             if (newAt != null && (prevAt == null || newAt.isAfter(prevAt))) {
//               unread = prev.unreadCount + 1;
//             } else {
//               unread = prev.unreadCount;
//             }
//           }

//           return item.copyWith(unreadCount: unread);
//         }).toList();

//         _all
//           ..clear()
//           ..addAll(updated);
//       }
//     } catch (e) {
//       if (!_disposed) _error = e.toString();
//     } finally {
//       if (!_disposed) {
//         _loading = false;
//         _safeNotify();
//       }
//     }
//   }

//   void markRoomAsRead(int roomId) {
//     final idx = _all.indexWhere((e) => e.id == roomId);

//     if (idx != -1) {
//       _all[idx] = _all[idx].copyWith(unreadCount: 0);
//       _safeNotify();
//     }
//   }

//   void updateRoomLastMessage({
//     required int roomId,
//     required String lastText,
//     required DateTime lastAt,
//   }) {
//     final idx = _all.indexWhere((e) => e.id == roomId);

//     if (idx != -1) {
//       _all[idx] = ChatInboxItem(
//         id: _all[idx].id,
//         email: _all[idx].email,
//         lastText: lastText,
//         lastAt: lastAt,
//         unreadCount: _all[idx].unreadCount,
//       );

//       _safeNotify();
//     }
//   }

//   // ── AUTO POLLING ────────────────────────────────────

//   void startPolling({int intervalSeconds = 10}) {
//     _pollTimer?.cancel();

//     _pollTimer = Timer.periodic(Duration(seconds: intervalSeconds), (_) {
//       if (_currentUserId != null && _currentUserId! != 0) {
//         fetchFor(_currentUserId!, silent: true);
//       }
//     });
//   }

//   void stopPolling() {
//     _pollTimer?.cancel();
//     _pollTimer = null;
//   }

//   // ── HELPERS ─────────────────────────────────────────

//   void _safeNotify() {
//     if (!_disposed) notifyListeners();
//   }

//   @override
//   void dispose() {
//     _disposed = true;
//     _pollTimer?.cancel();
//     super.dispose();
//   }
// }
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pokakbilling/models/data-models/chat/chat_inbox_item.dart';
import 'package:pokakbilling/models/services/chat_inbox_service.dart';

class ChatInboxViewModel extends ChangeNotifier {
  final List<ChatInboxItem> _all = [];

  bool _loading = false;
  String? _error;
  bool _disposed = false;

  String _query = '';
  int? _currentUserId;

  final Map<int, int> _lastSeenCount = {};

  Timer? _pollTimer;

  // ── GETTERS ─────────────────────────────────────────

  List<ChatInboxItem> get items {
    List<ChatInboxItem> base = List<ChatInboxItem>.from(_all);

    base.sort((a, b) {
      if (a.lastAt == null && b.lastAt == null) return 0;
      if (a.lastAt == null) return 1;
      if (b.lastAt == null) return -1;
      return b.lastAt!.compareTo(a.lastAt!);
    });

    if (_query.trim().isEmpty) return List.unmodifiable(base);

    final q = _query.toLowerCase();
    return List.unmodifiable(
      base.where((e) => e.email.toLowerCase().contains(q)).toList(),
    );
  }

  bool get loading => _loading;
  String? get error => _error;
  String get query => _query;
  int? get currentUserId => _currentUserId;

  /// ✅ RESET (for session expiry)
  void reset() {
    _all.clear();
    _loading = false;
    _error = null;
    _query = '';
    _currentUserId = null;
    _lastSeenCount.clear();
    _pollTimer?.cancel();
    _pollTimer = null;
    notifyListeners();
  }

  /// (optional alias)
  void clearData() => reset();

  // ── QUERY ───────────────────────────────────────────

  void setQuery(String q) {
    _query = q;
    _safeNotify();
  }

  void clearQuery() => setQuery('');

  // ── FETCH ───────────────────────────────────────────

  Future<void> fetchFor(int currentUserId, {bool silent = false}) async {
    if (_loading && !silent) return;

    _currentUserId = currentUserId;

    if (!silent) {
      _loading = true;
      _error = null;
      _safeNotify();
    }

    try {
      final result = await ChatInboxService.fetchInboxFor(currentUserId);

      if (!_disposed) {
        final updated = result.map((item) {
          final prev = _all.cast<ChatInboxItem?>().firstWhere(
                (e) => e?.id == item.id,
                orElse: () => null,
              );

          int unread = 0;

          if (prev != null) {
            final prevAt = prev.lastAt;
            final newAt = item.lastAt;
            final isNewMessage =
                newAt != null && (prevAt == null || newAt.isAfter(prevAt));

            // Only count as "unread" if there IS a newer message AND it
            // wasn't sent by me. Sending my own message must never bump
            // the badge on my own inbox.
            final sentByMe =
                item.lastSenderId != null && item.lastSenderId == currentUserId;

            if (isNewMessage && !sentByMe) {
              unread = prev.unreadCount + 1;
            } else if (isNewMessage && sentByMe) {
              // My own outgoing message updated lastAt — keep unread as-is
              // (should already be 0 from markRoomAsRead when I opened it).
              unread = prev.unreadCount;
            } else {
              unread = prev.unreadCount;
            }
          } else {
            // Brand-new room appearing for the first time.
            // If its last message wasn't from me, treat it as unread.
            final sentByMe =
                item.lastSenderId != null && item.lastSenderId == currentUserId;
            unread = (item.lastAt != null && !sentByMe) ? 1 : 0;
          }

          return item.copyWith(unreadCount: unread);
        }).toList();

        _all
          ..clear()
          ..addAll(updated);
      }
    } catch (e) {
      if (!_disposed) _error = e.toString();
    } finally {
      if (!_disposed) {
        _loading = false;
        _safeNotify();
      }
    }
  }

  void markRoomAsRead(int roomId) {
    final idx = _all.indexWhere((e) => e.id == roomId);

    if (idx != -1) {
      _all[idx] = _all[idx].copyWith(unreadCount: 0);
      _safeNotify();
    }
  }

  void updateRoomLastMessage({
    required int roomId,
    required String lastText,
    required DateTime lastAt,
    int? senderId,
  }) {
    final idx = _all.indexWhere((e) => e.id == roomId);

    if (idx != -1) {
      _all[idx] = _all[idx].copyWith(
        lastText: lastText,
        lastAt: lastAt,
        lastSenderId: senderId,
        // Sending a message yourself never creates unread on your own inbox.
        unreadCount: (senderId != null && senderId == _currentUserId)
            ? 0
            : _all[idx].unreadCount,
      );

      _safeNotify();
    }
  }

  // ── AUTO POLLING ────────────────────────────────────

  void startPolling({int intervalSeconds = 10}) {
    _pollTimer?.cancel();

    _pollTimer = Timer.periodic(Duration(seconds: intervalSeconds), (_) {
      if (_currentUserId != null && _currentUserId! != 0) {
        fetchFor(_currentUserId!, silent: true);
      }
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  // ── HELPERS ─────────────────────────────────────────

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _pollTimer?.cancel();
    super.dispose();
  }
}
