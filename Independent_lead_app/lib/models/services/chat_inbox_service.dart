
import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/chat/chat_data.dart';

class ChatService {
  // ── Current user ───────────────────────────────────────────────────────────

  /// GET /accounts/profile/ — extracts the logged-in user's ID.
  /// Handles flat {"id":1}, nested {"user":{"id":1}}, and {"profile":{"id":1}}.
  static Future<int> currentUserId() async {
    final dio = await DioClient().getAuthorizedDio();
    final res = await dio.get(ApiConstants.meEndpoint);
    _assertOk(res, 'current user');

    final raw = res.data;

    int? extractId(Map<String, dynamic> map) {
      final id = map['id'] ?? map['user_id'] ?? map['pk'];
      if (id is int) return id;
      if (id is String) return int.tryParse(id);
      return null;
    }

    if (raw is Map<String, dynamic>) {
      // Try flat first: { "id": 1, ... }
      final flat = extractId(raw);
      if (flat != null) return flat;

      // Try nested: { "user": {"id":1} } / { "profile": {...} } / { "data": {...} }
      for (final key in ['user', 'profile', 'data', 'account']) {
        final nested = raw[key];
        if (nested is Map<String, dynamic>) {
          final id = extractId(nested);
          if (id != null) return id;
        }
      }
    }

    throw Exception('ChatService [current user]: cannot extract id from: $raw');
  }

  // ── Users ──────────────────────────────────────────────────────────────────

  static Future<List<ChatUser>> fetchUsers({
    String? search,
    String? department,
  }) async {
    final dio = await DioClient().getAuthorizedDio();
    final params = <String, dynamic>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (department != null && department.isNotEmpty) {
      params['department'] = department;
    }
    final res = await dio.get(ApiConstants.chatUsersEndpoint,
        queryParameters: params.isEmpty ? null : params);
    _assertOk(res, 'fetch users');
    return (res.data as List)
        .cast<Map<String, dynamic>>()
        .map(ChatUser.fromJson)
        .toList();
  }

  // ── Conversations ──────────────────────────────────────────────────────────

  static Future<List<ChatConversation>> fetchConversations({
    String? search,
    bool? isGroup,
  }) async {
    final dio = await DioClient().getAuthorizedDio();
    final params = <String, dynamic>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (isGroup != null) params['is_group'] = isGroup.toString();
    final res = await dio.get(ApiConstants.chatConversationsEndpoint,
        queryParameters: params.isEmpty ? null : params);
    _assertOk(res, 'fetch conversations');
    return (res.data as List)
        .cast<Map<String, dynamic>>()
        .map(ChatConversation.fromJson)
        .toList();
  }

  static Future<ChatConversation> createDm(int userId) async {
    final dio = await DioClient().getAuthorizedDio();
    final res = await dio.post(ApiConstants.chatConversationsEndpoint,
        data: {'user_id': userId});
    _assertCreated(res, 'create DM');
    return ChatConversation.fromJson(res.data as Map<String, dynamic>);
  }

  static Future<ChatConversation> createGroup({
    required String name,
    required List<int> userIds,
  }) async {
    final dio = await DioClient().getAuthorizedDio();
    final res = await dio.post(ApiConstants.chatConversationsEndpoint,
        data: {'is_group': 'true', 'name': name, 'user_ids': userIds});
    _assertCreated(res, 'create group');
    return ChatConversation.fromJson(res.data as Map<String, dynamic>);
  }

  static Future<ChatConversation> fetchConversation(int id) async {
    final dio = await DioClient().getAuthorizedDio();
    final res = await dio.get(ApiConstants.chatConversationByIdEndpoint(id));
    _assertOk(res, 'fetch conversation $id');
    return ChatConversation.fromJson(res.data as Map<String, dynamic>);
  }

  static Future<ChatConversation> updateGroup(
      int id, String name, String? imagePath) async {
    final dio = await DioClient().getAuthorizedDio();
    final formData = FormData.fromMap({
      'name': name,
      if (imagePath != null) 'image': await MultipartFile.fromFile(imagePath),
    });
    final res = await dio.patch(ApiConstants.chatConversationByIdEndpoint(id),
        data: formData);
    _assertOk(res, 'update group $id');
    return ChatConversation.fromJson(res.data as Map<String, dynamic>);
  }

  // ── Messages ───────────────────────────────────────────────────────────────

  static Future<List<ChatMessageModel>> fetchMessages(
      int conversationId) async {
    final dio = await DioClient().getAuthorizedDio();
    final res = await dio
        .get(ApiConstants.chatConversationMessagesEndpoint(conversationId));
    _assertOk(res, 'fetch messages');
    return (res.data as List)
        .cast<Map<String, dynamic>>()
        .map(ChatMessageModel.fromJson)
        .toList();
  }

  static Future<ChatMessageModel> sendMessage({
    required int conversationId,
    String? text,
    String? attachmentPath,
  }) async {
    assert(text != null || attachmentPath != null,
        'Either text or attachment must be provided');
    final dio = await DioClient().getAuthorizedDio();
    final formData = FormData.fromMap({
      if (text != null && text.isNotEmpty) 'text': text,
      if (attachmentPath != null)
        'attachment': await MultipartFile.fromFile(attachmentPath),
    });
    final res = await dio.post(
        ApiConstants.chatConversationMessagesEndpoint(conversationId),
        data: formData);
    _assertCreated(res, 'send message');
    return ChatMessageModel.fromJson(res.data as Map<String, dynamic>);
  }

  // ── Group management ───────────────────────────────────────────────────────

  static Future<void> addMember(int conversationId, int userId) async {
    final dio = await DioClient().getAuthorizedDio();
    await dio.post(ApiConstants.chatAddMemberEndpoint(conversationId),
        data: {'user_id': userId});
  }

  static Future<void> removeMember(int conversationId, int userId) async {
    final dio = await DioClient().getAuthorizedDio();
    await dio.post(ApiConstants.chatRemoveMemberEndpoint(conversationId),
        data: {'user_id': userId});
  }

  // ── Pin / Mute ─────────────────────────────────────────────────────────────

  static Future<bool> togglePin(int conversationId) async {
    final dio = await DioClient().getAuthorizedDio();
    final res = await dio.post(ApiConstants.chatPinEndpoint(conversationId));
    return res.data['is_pinned'] == true;
  }

  static Future<bool> toggleMute(int conversationId) async {
    final dio = await DioClient().getAuthorizedDio();
    final res = await dio.post(ApiConstants.chatMuteEndpoint(conversationId));
    return res.data['is_muted'] == true;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  static void _assertOk(Response res, String ctx) {
    if (res.statusCode != 200) {
      throw Exception('ChatService [$ctx] failed: ${res.statusCode}');
    }
  }

  static void _assertCreated(Response res, String ctx) {
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('ChatService [$ctx] failed: ${res.statusCode}');
    }
  }
}
