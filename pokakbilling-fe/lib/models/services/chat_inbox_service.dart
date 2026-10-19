// import 'package:pokakbilling/core/api/api_constants.dart';
// import 'package:pokakbilling/core/api/dio_client.dart';
// import 'package:pokakbilling/models/data-models/chat/chat_inbox_item.dart';

// class ChatInboxService {
//   /// Returns only rooms that include [currentUserId], and resolves the OTHER participant's email.
//   static Future<List<ChatInboxItem>> fetchInboxFor(int currentUserId) async {
//     final dio = await DioClient().getAuthorizedDio();
//     final res = await dio.get(ApiConstants.chatChatsEndpoint); // list rooms
//     if (res.statusCode != 200) {
//       throw Exception('Failed to load inbox chats: ${res.statusCode}');
//     }

//     final list = (res.data as List).cast<Map<String, dynamic>>();

//     String? otherEmail(Map<String, dynamic> room) {
//       final participants = room['participants'];
//       // 1) participants might be list of user maps
//       if (participants is List) {
//         for (final p in participants) {
//           if (p is Map) {
//             final id =
//                 p['id'] is int ? p['id'] : int.tryParse('${p['id']}') ?? -1;
//             final email = p['email']?.toString();
//             if (id != -1 &&
//                 id != currentUserId &&
//                 email != null &&
//                 email.contains('@')) {
//               return email;
//             }
//           }
//         }
//         // 2) or list of ids -> try last_message users
//         if (participants.every((e) => e is int || int.tryParse('$e') != null)) {
//           final lm = room['last_message'];
//           if (lm is Map) {
//             final sender = lm['sender'];
//             final recv = lm['receiver'];
//             String? sEmail, rEmail;
//             if (sender is Map && sender['email'] != null) {
//               sEmail = sender['email'].toString();
//             }
//             if (recv is Map && recv['email'] != null) {
//               rEmail = recv['email'].toString();
//             }
//             if (sEmail != null &&
//                 sEmail.contains('@') &&
//                 lm['sender'] != currentUserId) {
//               return sEmail;
//             }
//             if (rEmail != null &&
//                 rEmail.contains('@') &&
//                 lm['receiver'] != currentUserId) {
//               return rEmail;
//             }
//           }
//         }
//       }
//       // 3) fallback generic extraction
//       return ChatInboxItem.fromJson(room).email;
//     }

//     final filtered = <ChatInboxItem>[];

//     for (final room in list) {
//       // keep only rooms that include me
//       bool includesMe = false;
//       final participants = room['participants'];

//       if (participants is List) {
//         for (final p in participants) {
//           if (p is int && p == currentUserId) includesMe = true;
//           if (p is String && int.tryParse(p) == currentUserId) {
//             includesMe = true;
//           }
//           if (p is Map) {
//             final id = p['id'] is int ? p['id'] : int.tryParse('${p['id']}');
//             if (id == currentUserId) includesMe = true;
//           }
//         }
//       }

//       if (!includesMe) continue;

//       final email = otherEmail(room) ?? 'unknown@user';

//       String? lastText;
//       DateTime? lastAt;
//       if (room['last_message'] is Map) {
//         final m = room['last_message'] as Map<String, dynamic>;
//         lastText = (m['content'] ?? m['message'])?.toString();
//         lastAt = DateTime.tryParse(m['created_at']?.toString() ?? '');
//       }

//       final id =
//           room['id'] is int ? room['id'] : int.tryParse('${room['id']}') ?? 0;
//       filtered.add(ChatInboxItem(
//           id: id, email: email, lastText: lastText, lastAt: lastAt));
//     }

//     return filtered;
//   }

//   /// Creates a new 1:1 chat room with [otherUserId] and returns the new room's id.
//   ///
//   /// NOTE: The exact request body your backend expects for room creation is a
//   /// guess based on common DRF conventions (`user_id`). If this throws with a
//   /// 400 response, the error message below will include the raw response body
//   /// — send that back and the field name can be corrected in one line.
//   static Future<int> createRoom({
//     required int otherUserId,
//     String? otherUserEmail,
//   }) async {
//     final dio = await DioClient().getAuthorizedDio();

//     final body = <String, dynamic>{
//       'user_id': otherUserId,
//     };

//     final res = await dio.post(ApiConstants.chatChatsEndpoint, data: body);

//     if (res.statusCode == 200 || res.statusCode == 201) {
//       final data = res.data;
//       if (data is Map<String, dynamic>) {
//         final rawId = data['id'];
//         final id = rawId is int ? rawId : int.tryParse('$rawId');
//         if (id != null) return id;
//       }
//       throw Exception(
//           'Room created but response had no usable "id": ${res.data}');
//     }

//     throw Exception('Failed to create room (${res.statusCode}): ${res.data}');
//   }
// }
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/chat/chat_inbox_item.dart';

class ChatInboxService {
  /// Returns only rooms that include [currentUserId], and resolves the OTHER participant's email.
  static Future<List<ChatInboxItem>> fetchInboxFor(int currentUserId) async {
    final dio = await DioClient().getAuthorizedDio();
    final res = await dio.get(ApiConstants.chatChatsEndpoint); // list rooms
    if (res.statusCode != 200) {
      throw Exception('Failed to load inbox chats: ${res.statusCode}');
    }

    final list = (res.data as List).cast<Map<String, dynamic>>();

    String? otherEmail(Map<String, dynamic> room) {
      final participants = room['participants'];
      // 1) participants might be list of user maps
      if (participants is List) {
        for (final p in participants) {
          if (p is Map) {
            final id =
                p['id'] is int ? p['id'] : int.tryParse('${p['id']}') ?? -1;
            final email = p['email']?.toString();
            if (id != -1 &&
                id != currentUserId &&
                email != null &&
                email.contains('@')) {
              return email;
            }
          }
        }
        // 2) or list of ids -> try last_message users
        if (participants.every((e) => e is int || int.tryParse('$e') != null)) {
          final lm = room['last_message'];
          if (lm is Map) {
            final sender = lm['sender'];
            final recv = lm['receiver'];
            String? sEmail, rEmail;
            if (sender is Map && sender['email'] != null) {
              sEmail = sender['email'].toString();
            }
            if (recv is Map && recv['email'] != null) {
              rEmail = recv['email'].toString();
            }
            if (sEmail != null &&
                sEmail.contains('@') &&
                lm['sender'] != currentUserId) {
              return sEmail;
            }
            if (rEmail != null &&
                rEmail.contains('@') &&
                lm['receiver'] != currentUserId) {
              return rEmail;
            }
          }
        }
      }
      // 3) fallback generic extraction
      return ChatInboxItem.fromJson(room).email;
    }

    // Extracts the numeric id of whoever sent the last message.
    // Handles last_message.sender being a raw int id or a nested user map.
    int? lastSenderId(Map<String, dynamic> room) {
      final lm = room['last_message'];
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

    final filtered = <ChatInboxItem>[];

    for (final room in list) {
      // keep only rooms that include me
      bool includesMe = false;
      final participants = room['participants'];

      if (participants is List) {
        for (final p in participants) {
          if (p is int && p == currentUserId) includesMe = true;
          if (p is String && int.tryParse(p) == currentUserId) {
            includesMe = true;
          }
          if (p is Map) {
            final id = p['id'] is int ? p['id'] : int.tryParse('${p['id']}');
            if (id == currentUserId) includesMe = true;
          }
        }
      }

      if (!includesMe) continue;

      final email = otherEmail(room) ?? 'unknown@user';

      String? lastText;
      DateTime? lastAt;
      if (room['last_message'] is Map) {
        final m = room['last_message'] as Map<String, dynamic>;
        lastText = (m['content'] ?? m['message'])?.toString();
        lastAt = DateTime.tryParse(m['created_at']?.toString() ?? '');
      }

      final id =
          room['id'] is int ? room['id'] : int.tryParse('${room['id']}') ?? 0;
      filtered.add(ChatInboxItem(
        id: id,
        email: email,
        lastText: lastText,
        lastAt: lastAt,
        lastSenderId: lastSenderId(room),
      ));
    }

    return filtered;
  }

  /// Creates a new 1:1 chat room with [otherUserId] and returns the new room's id.
  ///
  /// NOTE: The exact request body your backend expects for room creation is a
  /// guess based on common DRF conventions (`user_id`). If this throws with a
  /// 400 response, the error message will include the raw response body —
  /// send that back and the field name can be corrected in one line.
  static Future<int> createRoom({
    required int otherUserId,
    String? otherUserEmail,
  }) async {
    final dio = await DioClient().getAuthorizedDio();

    final body = <String, dynamic>{
      'user_id': otherUserId,
    };

    final res = await dio.post(ApiConstants.chatChatsEndpoint, data: body);

    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final rawId = data['id'];
        final id = rawId is int ? rawId : int.tryParse('$rawId');
        if (id != null) return id;
      }
      throw Exception(
          'Room created but response had no usable "id": ${res.data}');
    }

    throw Exception('Failed to create room (${res.statusCode}): ${res.data}');
  }
}
