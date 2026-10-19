// // class ChatInboxItem {
// //   final int id; // room id
// //   final String email;

// //   ChatInboxItem({
// //     required this.id,
// //     required this.email,
// //   });

// //   static String _extractEmail(Map<String, dynamic> j) {
// //     if (j['email'] != null && j['email'].toString().contains('@')) {
// //       return j['email'].toString();
// //     }
// //     for (final key in ['user', 'sender', 'receiver', 'from_user', 'to_user']) {
// //       final v = j[key];
// //       if (v is Map &&
// //           v['email'] != null &&
// //           v['email'].toString().contains('@')) {
// //         return v['email'].toString();
// //       }
// //     }
// //     if (j['participants'] is List) {
// //       for (final e in (j['participants'] as List)) {
// //         if (e is Map &&
// //             e['email'] != null &&
// //             e['email'].toString().contains('@')) {
// //           return e['email'].toString();
// //         }
// //       }
// //     }
// //     if (j['last_message'] is Map) {
// //       final m = j['last_message'] as Map<String, dynamic>;
// //       for (final k in ['sender', 'receiver', 'user']) {
// //         final v = m[k];
// //         if (v is Map &&
// //             v['email'] != null &&
// //             v['email'].toString().contains('@')) {
// //           return v['email'].toString();
// //         }
// //       }
// //       for (final k in ['sender_email', 'receiver_email']) {
// //         final v = m[k];
// //         if (v != null && v.toString().contains('@')) return v.toString();
// //       }
// //     }
// //     for (final k in ['sender_email', 'receiver_email', 'user_email']) {
// //       final v = j[k];
// //       if (v != null && v.toString().contains('@')) return v.toString();
// //     }
// //     return 'unknown@user';
// //   }

// //   factory ChatInboxItem.fromJson(Map<String, dynamic> json) {
// //     final email = _extractEmail(json);
// //     final id = json['id'] is int
// //         ? json['id'] as int
// //         : int.tryParse('${json['id']}') ?? 0;
// //     return ChatInboxItem(id: id, email: email);
// //   }
// // }
// class ChatInboxItem {
//   final int id; // room id
//   final String email;

//   ChatInboxItem({required this.id, required this.email});

//   static String _extractEmail(Map<String, dynamic> j) {
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

//   factory ChatInboxItem.fromJson(Map<String, dynamic> json) => ChatInboxItem(
//         id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
//         email: _extractEmail(json),
//       );
// }
class ChatInboxItem {
  final int id; // room id
  final String email; // the OTHER participant's email (for UI title)
  final String? lastText; // optional preview
  final DateTime? lastAt; // optional timestamp

  ChatInboxItem({
    required this.id,
    required this.email,
    this.lastText,
    this.lastAt,
  });

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
    );
  }
}
