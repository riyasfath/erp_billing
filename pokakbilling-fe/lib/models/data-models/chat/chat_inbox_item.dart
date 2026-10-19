// class ChatInboxItem {
//   final int id; // room id
//   final String email; // the OTHER participant's email (for UI title)
//   final String? lastText; // optional preview
//   final DateTime? lastAt; // optional timestamp
//   final int unreadCount; // NEW: unread message count

//   ChatInboxItem({
//     required this.id,
//     required this.email,
//     this.lastText,
//     this.lastAt,
//     this.unreadCount = 0,
//   });

//   /// Returns a copy with updated unread count
//   ChatInboxItem copyWith({int? unreadCount}) {
//     return ChatInboxItem(
//       id: id,
//       email: email,
//       lastText: lastText,
//       lastAt: lastAt,
//       unreadCount: unreadCount ?? this.unreadCount,
//     );
//   }

//   static String _extractAnyEmail(Map<String, dynamic> j) {
//     if (j['email'] != null && j['email'].toString().contains('@')) {
//       return j['email'].toString();
//     }
//     for (final key in ['user', 'sender', 'receiver', 'from_user', 'to_user']) {
//       final v = j[key];
//       if (v is Map &&
//           v['email'] != null &&
//           v['email'].toString().contains('@')) {
//         return v['email'].toString();
//       }
//     }
//     if (j['participants'] is List) {
//       for (final e in (j['participants'] as List)) {
//         if (e is Map &&
//             e['email'] != null &&
//             e['email'].toString().contains('@')) {
//           return e['email'].toString();
//         }
//       }
//     }
//     if (j['last_message'] is Map) {
//       final m = j['last_message'] as Map<String, dynamic>;
//       for (final k in ['sender', 'receiver', 'user']) {
//         final v = m[k];
//         if (v is Map &&
//             v['email'] != null &&
//             v['email'].toString().contains('@')) {
//           return v['email'].toString();
//         }
//       }
//       for (final k in ['sender_email', 'receiver_email']) {
//         final v = m[k];
//         if (v != null && v.toString().contains('@')) return v.toString();
//       }
//     }
//     for (final k in ['sender_email', 'receiver_email', 'user_email']) {
//       final v = j[k];
//       if (v != null && v.toString().contains('@')) return v.toString();
//     }
//     return 'unknown@user';
//   }

//   factory ChatInboxItem.fromJson(Map<String, dynamic> json) {
//     final id =
//         json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0;
//     String? lastText;
//     DateTime? lastAt;

//     if (json['last_message'] is Map) {
//       final m = json['last_message'] as Map<String, dynamic>;
//       lastText = (m['content'] ?? m['message'])?.toString();
//       lastAt = DateTime.tryParse(m['created_at']?.toString() ?? '');
//     }

//     return ChatInboxItem(
//       id: id,
//       email: _extractAnyEmail(json),
//       lastText: lastText,
//       lastAt: lastAt,
//       unreadCount: 0,
//     );
//   }
// }
class ChatInboxItem {
  final int id; // room id
  final String email; // the OTHER participant's email (for UI title)
  final String? lastText; // optional preview
  final DateTime? lastAt; // optional timestamp
  final int unreadCount; // unread message count
  final int? lastSenderId; // NEW: who sent the last message (for unread logic)

  ChatInboxItem({
    required this.id,
    required this.email,
    this.lastText,
    this.lastAt,
    this.unreadCount = 0,
    this.lastSenderId,
  });

  /// Returns a copy with updated fields
  ChatInboxItem copyWith({
    int? unreadCount,
    String? lastText,
    DateTime? lastAt,
    int? lastSenderId,
  }) {
    return ChatInboxItem(
      id: id,
      email: email,
      lastText: lastText ?? this.lastText,
      lastAt: lastAt ?? this.lastAt,
      unreadCount: unreadCount ?? this.unreadCount,
      lastSenderId: lastSenderId ?? this.lastSenderId,
    );
  }

  static String _extractAnyEmail(Map<String, dynamic> j) {
    if (j['email'] != null && j['email'].toString().contains('@')) {
      return j['email'].toString();
    }
    for (final key in ['user', 'sender', 'receiver', 'from_user', 'to_user']) {
      final v = j[key];
      if (v is Map &&
          v['email'] != null &&
          v['email'].toString().contains('@')) {
        return v['email'].toString();
      }
    }
    if (j['participants'] is List) {
      for (final e in (j['participants'] as List)) {
        if (e is Map &&
            e['email'] != null &&
            e['email'].toString().contains('@')) {
          return e['email'].toString();
        }
      }
    }
    if (j['last_message'] is Map) {
      final m = j['last_message'] as Map<String, dynamic>;
      for (final k in ['sender', 'receiver', 'user']) {
        final v = m[k];
        if (v is Map &&
            v['email'] != null &&
            v['email'].toString().contains('@')) {
          return v['email'].toString();
        }
      }
      for (final k in ['sender_email', 'receiver_email']) {
        final v = m[k];
        if (v != null && v.toString().contains('@')) return v.toString();
      }
    }
    for (final k in ['sender_email', 'receiver_email', 'user_email']) {
      final v = j[k];
      if (v != null && v.toString().contains('@')) return v.toString();
    }
    return 'unknown@user';
  }

  /// Extracts the numeric id of whoever sent the last message, from
  /// `last_message.sender`. Handles both shapes: a raw int id, or a
  /// nested map like `{"id": 5, "email": "..."}`.
  static int? _extractLastSenderId(Map<String, dynamic> j) {
    final lm = j['last_message'];
    if (lm is! Map) return null;
    final sender = lm['sender'];
    if (sender is int) return sender;
    if (sender is String) return int.tryParse(sender);
    if (sender is Map) {
      final id = sender['id'];
      if (id is int) return id;
      if (id != null) return int.tryParse('$id');
    }
    return null;
  }

  factory ChatInboxItem.fromJson(Map<String, dynamic> json) {
    final id =
        json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0;
    String? lastText;
    DateTime? lastAt;

    if (json['last_message'] is Map) {
      final m = json['last_message'] as Map<String, dynamic>;
      lastText = (m['content'] ?? m['message'])?.toString();
      lastAt = DateTime.tryParse(m['created_at']?.toString() ?? '');
    }

    return ChatInboxItem(
      id: id,
      email: _extractAnyEmail(json),
      lastText: lastText,
      lastAt: lastAt,
      unreadCount: 0,
      lastSenderId: _extractLastSenderId(json),
    );
  }
}
