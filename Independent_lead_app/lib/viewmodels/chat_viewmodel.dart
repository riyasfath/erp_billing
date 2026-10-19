import 'package:flutter/material.dart';
import 'package:pokakbilling/models/data-models/chat/chat_data.dart';
import 'package:pokakbilling/models/services/chat_inbox_service.dart';

class ChatViewModel extends ChangeNotifier {
  List<ChatConversation> _conversations = [];
  List<ChatUser> _users = [];
  bool _loadingConversations = false;
  bool _loadingUsers = false;
  String? _error;
  bool _disposed = false;
  int? _currentUserId;

  final Map<int, List<ChatMessageModel>> _messages = {};
  final Map<int, bool> _loadingMessages = {};
  final Map<int, bool> _sendingMessage = {};

  String _search = '';
  int _tab = 0;

  bool get loadingConversations => _loadingConversations;
  bool get loadingUsers => _loadingUsers;
  String? get error => _error;
  String get search => _search;
  int get tab => _tab;
  int? get currentUserId => _currentUserId;
  List<ChatUser> get users => List.unmodifiable(_users);

  List<ChatConversation> get conversations {
    var list = List<ChatConversation>.from(_conversations);
    if (_tab == 1) list = list.where((c) => !c.isGroup).toList();
    if (_tab == 2) list = list.where((c) => c.isGroup).toList();
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((c) => c.name.toLowerCase().contains(q)).toList();
    }
    list.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      final au = a.unreadCount > 0 ? 1 : 0;
      final bu = b.unreadCount > 0 ? 1 : 0;
      if (au != bu) return bu.compareTo(au);
      final at = a.lastMessage?.timestamp ?? DateTime(2000);
      final bt = b.lastMessage?.timestamp ?? DateTime(2000);
      return bt.compareTo(at);
    });
    return list;
  }

  int get totalUnread => _conversations.fold(0, (s, c) => s + c.unreadCount);

  List<ChatMessageModel> messagesFor(int conversationId) =>
      List.unmodifiable(_messages[conversationId] ?? []);

  bool isLoadingMessages(int conversationId) =>
      _loadingMessages[conversationId] == true;

  bool isSendingMessage(int conversationId) =>
      _sendingMessage[conversationId] == true;

  void setSearch(String q) {
    _search = q;
    _notify();
  }

  void setTab(int t) {
    _tab = t;
    _notify();
  }

  // ── NEW: Seed user identity from LoginViewModel so names resolve immediately
  // Call this as early as possible (e.g. in initState of InboxScreen).
  void seedCurrentUser({required int? userId, required String? username}) {
    bool changed = false;
    if (userId != null && userId != -1 && _currentUserId != userId) {
      _currentUserId = userId;
      ChatConversation.currentUserId = userId;
      changed = true;
    }
    if (username != null && username.isNotEmpty) {
      final trimmed = username.toLowerCase().trim();
      if (ChatConversation.currentUsername != trimmed) {
        ChatConversation.currentUsername = trimmed;
        changed = true;
      }
    }
    if (changed && !_disposed) _notify();
  }

  void reset() {
    _conversations = [];
    _users = [];
    _messages.clear();
    _loadingMessages.clear();
    _sendingMessage.clear();
    _loadingConversations = false;
    _loadingUsers = false;
    _error = null;
    _currentUserId = null;
    _search = '';
    _tab = 0;
    _notify();
  }

  Future<void> ensureCurrentUser() async {
    if (_currentUserId != null && _currentUserId != -1) return;
    try {
      final uid = await ChatService.currentUserId();
      if (!_disposed) {
        _currentUserId = uid != -1 ? uid : -1;
        if (uid != -1) ChatConversation.currentUserId = uid;
        _notify();
      }
    } catch (_) {
      if (!_disposed) {
        _currentUserId = -1;
        _notify();
      }
    }
  }

  Future<void> fetchConversations() async {
    if (_loadingConversations) return;
    _loadingConversations = true;
    _error = null;
    _notify();
    try {
      final results = await Future.wait([
        ChatService.fetchConversations(),
        ChatService.currentUserId().catchError((_) => -1),
      ]);
      if (!_disposed) {
        _conversations = results[0] as List<ChatConversation>;
        final uid = results[1] as int;
        if (uid != -1) {
          _currentUserId = uid;
          ChatConversation.currentUserId = uid;
        }
      }
    } catch (e) {
      if (!_disposed) _error = e.toString();
    } finally {
      if (!_disposed) {
        _loadingConversations = false;
        _notify();
      }
    }
  }

  Future<void> fetchUsers({String? search}) async {
    if (_loadingUsers) return;
    _loadingUsers = true;
    _notify();
    try {
      final result = await ChatService.fetchUsers(search: search);
      if (!_disposed) _users = result;
    } catch (e) {
      if (!_disposed) _error = e.toString();
    } finally {
      if (!_disposed) {
        _loadingUsers = false;
        _notify();
      }
    }
  }

  Future<void> fetchMessages(int conversationId) async {
    if (_loadingMessages[conversationId] == true) return;
    await ensureCurrentUser();
    _loadingMessages[conversationId] = true;
    _notify();
    try {
      final msgs = await ChatService.fetchMessages(conversationId);
      if (!_disposed) {
        _messages[conversationId] = msgs;
        final idx = _conversations.indexWhere((c) => c.id == conversationId);
        if (idx != -1) _conversations[idx].unreadCount = 0;
      }
    } catch (e) {
      if (!_disposed) _error = e.toString();
    } finally {
      if (!_disposed) {
        _loadingMessages[conversationId] = false;
        _notify();
      }
    }
  }

  Future<void> refreshMessages(int conversationId) async {
    if (_loadingMessages[conversationId] == true) return;
    try {
      final msgs = await ChatService.fetchMessages(conversationId);
      if (!_disposed) {
        final current = _messages[conversationId] ?? [];
        if (msgs.length != current.length ||
            (msgs.isNotEmpty &&
                current.isNotEmpty &&
                msgs.last.id != current.last.id)) {
          _messages[conversationId] = msgs;
          final idx = _conversations.indexWhere((c) => c.id == conversationId);
          if (idx != -1) _conversations[idx].unreadCount = 0;
          _notify();
        }
      }
    } catch (_) {}
  }

  Future<void> sendMessage(int conversationId, String text) async {
    if (text.trim().isEmpty) return;
    _sendingMessage[conversationId] = true;
    _notify();
    try {
      final msg = await ChatService.sendMessage(
          conversationId: conversationId, text: text.trim());

      if (!_disposed) {
        await ensureCurrentUser();

        final myId = _currentUserId ?? -1;
        final patchedSender = myId != -1 && msg.sender.id == 0
            ? ChatParticipant(
                id: myId,
                username: msg.sender.username,
                firstName: msg.sender.firstName,
                lastName: msg.sender.lastName,
                profilePicture: msg.sender.profilePicture,
              )
            : msg.sender;

        final patchedMsg = ChatMessageModel(
          id: msg.id,
          sender: patchedSender,
          text: msg.text,
          attachment: msg.attachment,
          isRead: msg.isRead,
          timestamp: msg.timestamp,
        );

        _messages.putIfAbsent(conversationId, () => []).add(patchedMsg);

        final idx = _conversations.indexWhere((c) => c.id == conversationId);
        if (idx != -1) {
          final old = _conversations[idx];
          _conversations[idx] = ChatConversation(
            id: old.id,
            name: old.rawName,
            image: old.image,
            isGroup: old.isGroup,
            isPinned: old.isPinned,
            isMuted: old.isMuted,
            unreadCount: 0,
            lastMessage: patchedMsg,
            participants: old.participants,
          );
        }
        _notify();
      }
    } catch (e) {
      if (!_disposed) _error = e.toString();
    } finally {
      if (!_disposed) {
        _sendingMessage[conversationId] = false;
        _notify();
      }
    }
  }

  Future<ChatConversation?> createDm(int userId) async {
    try {
      final existing = _conversations
          .where((c) => !c.isGroup && c.participants.any((p) => p.id == userId))
          .toList();
      if (existing.isNotEmpty) return existing.first;
      final conv = await ChatService.createDm(userId);
      if (!_disposed) {
        _conversations.insert(0, conv);
        _notify();
      }
      return conv;
    } catch (e) {
      if (!_disposed) _error = e.toString();
      return null;
    }
  }

  Future<ChatConversation?> createGroup({
    required String name,
    required List<int> userIds,
  }) async {
    try {
      final conv = await ChatService.createGroup(name: name, userIds: userIds);
      if (!_disposed) {
        _conversations.insert(0, conv);
        _notify();
      }
      return conv;
    } catch (e) {
      if (!_disposed) _error = e.toString();
      return null;
    }
  }

  Future<void> togglePin(int conversationId) async {
    try {
      final isPinned = await ChatService.togglePin(conversationId);
      if (!_disposed) {
        final idx = _conversations.indexWhere((c) => c.id == conversationId);
        if (idx != -1) {
          final old = _conversations[idx];
          _conversations[idx] = ChatConversation(
            id: old.id,
            name: old.rawName,
            image: old.image,
            isGroup: old.isGroup,
            isPinned: isPinned,
            isMuted: old.isMuted,
            unreadCount: old.unreadCount,
            lastMessage: old.lastMessage,
            participants: old.participants,
          );
          _notify();
        }
      }
    } catch (e) {
      if (!_disposed) _error = e.toString();
    }
  }

  Future<void> toggleMute(int conversationId) async {
    try {
      final isMuted = await ChatService.toggleMute(conversationId);
      if (!_disposed) {
        final idx = _conversations.indexWhere((c) => c.id == conversationId);
        if (idx != -1) {
          final old = _conversations[idx];
          _conversations[idx] = ChatConversation(
            id: old.id,
            name: old.rawName,
            image: old.image,
            isGroup: old.isGroup,
            isPinned: old.isPinned,
            isMuted: isMuted,
            unreadCount: old.unreadCount,
            lastMessage: old.lastMessage,
            participants: old.participants,
          );
          _notify();
        }
      }
    } catch (e) {
      if (!_disposed) _error = e.toString();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
