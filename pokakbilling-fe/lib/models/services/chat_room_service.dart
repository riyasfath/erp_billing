import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/chat/chat_room.dart';

class ChatRoomService {
  /// Create (or get existing) 1:1 room between current user and peer.
  static Future<ChatRoom> createOrGetOneToOne({
    required int currentUserId,
    required int peerUserId,
  }) async {
    if (currentUserId == 0) {
      throw ArgumentError('currentUserId is 0. Resolve first.');
    }
    if (peerUserId == 0) throw ArgumentError('peerUserId is 0 — invalid peer.');
    if (currentUserId == peerUserId) {
      throw ArgumentError('Cannot create a 1:1 room with yourself.');
    }

    final dio = await DioClient().getAuthorizedDio();

    final a = currentUserId < peerUserId ? currentUserId : peerUserId;
    final b = currentUserId < peerUserId ? peerUserId : currentUserId;

    final payload = {
      "type": "one_to_one",
      "participants": [a, b]
    };

    try {
      final res = await dio.post(ApiConstants.chatChatsEndpoint, data: payload);
      if (res.statusCode == 200 || res.statusCode == 201) {
        return ChatRoom.fromJson(res.data as Map<String, dynamic>);
      }
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        error: 'Unexpected status ${res.statusCode}',
        type: DioExceptionType.badResponse,
      );
    } on DioException catch (e) {
      // Helpful log from server, if any
      // ignore: avoid_print
      print(
          '⚠️ chat/chats failed — status=${e.response?.statusCode} body=${e.response?.data}');
      rethrow;
    }
  }
}
