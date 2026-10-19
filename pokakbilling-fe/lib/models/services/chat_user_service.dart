import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/chat/chat_user.dart';

class ChatUsersService {
  static Future<List<ChatUser>> fetchUsers({String? search}) async {
    final dio = await DioClient().getAuthorizedDio();
    final url = (search == null || search.trim().isEmpty)
        ? ApiConstants.chatUsersEndpoint
        : Uri.parse(ApiConstants.chatUsersEndpoint)
            .replace(queryParameters: {'search': search.trim()}).toString();

    final res = await dio.get(url);
    if (res.statusCode == 200) {
      final data = res.data as List<dynamic>;
      return data
          .map((e) => ChatUser.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load chat users: ${res.statusCode}');
  }
}
