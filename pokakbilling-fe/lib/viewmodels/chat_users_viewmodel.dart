import 'package:flutter/material.dart';
import 'package:pokakbilling/models/data-models/chat/chat_user.dart';
import 'package:pokakbilling/models/services/chat_user_service.dart';

class ChatUsersViewModel extends ChangeNotifier {
  final List<ChatUser> _allUsers = [];

  bool _loading = false;
  String? _error;
  bool _disposed = false;

  String _query = '';
  String _lastApiQuery = '';

  List<ChatUser> get users {
    if (_query.trim().isEmpty) return List.unmodifiable(_allUsers);

    final q = _query.toLowerCase();

    return _allUsers.where((e) => e.email.toLowerCase().contains(q)).toList();
  }

  bool get loading => _loading;
  String? get error => _error;
  String get query => _query;
  String get lastQuery => _lastApiQuery;

  /// ✅ RESET (for session expiry)
  void reset() {
    _allUsers.clear();
    _loading = false;
    _error = null;
    _query = '';
    _lastApiQuery = '';
    notifyListeners();
  }

  /// (optional alias)
  void clearData() => reset();

  Future<void> fetch({String? search}) async {
    if (_loading) return;

    _loading = true;
    _error = null;

    if (search != null) _lastApiQuery = search;

    notifyListeners();

    try {
      final result = await ChatUsersService.fetchUsers(
        search: search ?? (_lastApiQuery.isEmpty ? null : _lastApiQuery),
      );

      if (!_disposed) {
        _allUsers
          ..clear()
          ..addAll(result);
      }
    } catch (e) {
      if (!_disposed) _error = e.toString();
    } finally {
      if (!_disposed) {
        _loading = false;
        notifyListeners();
      }
    }
  }

  void setQuery(String q) {
    _query = q;
    if (!_disposed) notifyListeners();
  }

  Future<void> clearAll() async {
    _query = '';
    _lastApiQuery = '';
    await fetch(search: '');
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
