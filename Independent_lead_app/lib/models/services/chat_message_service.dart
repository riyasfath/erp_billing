// import 'package:pokakbilling/core/api/api_constants.dart';
// import 'package:pokakbilling/core/api/dio_client.dart';
// import 'package:pokakbilling/models/data-models/chat/chat_message.dart';

// class ChatMessageService {
//   static Future<List<ChatMessage>> fetchMessages(int roomId) async {
//     final dio = await DioClient().getAuthorizedDio();
//     final res = await dio.get(ApiConstants.chatMessages(roomId));
//     if (res.statusCode == 200) {
//       final data = res.data as List<dynamic>;
//       return data
//           .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
//           .toList();
//     }
//     throw Exception('Failed to load messages: ${res.statusCode}');
//   }

//   static Future<ChatMessage> sendMessage({
//     required int roomId,
//     required String content,
//   }) async {
//     final dio = await DioClient().getAuthorizedDio();
//     final res = await dio.post(
//       ApiConstants.chatMessages(roomId),
//       data: {'content': content},
//     );
//     if (res.statusCode == 200 || res.statusCode == 201) {
//       return ChatMessage.fromJson(res.data as Map<String, dynamic>);
//     }
//     throw Exception('Failed to send message: ${res.statusCode}');
//   }
// }
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/chat/chat_message.dart';

class ChatMessageService {
  static Future<List<ChatMessage>> fetchMessages(int roomId) async {
    final dio = await DioClient().getAuthorizedDio();
    final res = await dio.get(ApiConstants.chatMessages(roomId));
    if (res.statusCode == 200) {
      final data = res.data as List<dynamic>;
      return data
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load messages: ${res.statusCode}');
  }

  static Future<ChatMessage> sendMessage({
    required int roomId,
    required String content,
  }) async {
    final dio = await DioClient().getAuthorizedDio();
    final res = await dio
        .post(ApiConstants.chatMessages(roomId), data: {'content': content});
    if (res.statusCode == 200 || res.statusCode == 201) {
      return ChatMessage.fromJson(res.data as Map<String, dynamic>);
    }
    throw Exception('Failed to send message: ${res.statusCode}');
  }
}
