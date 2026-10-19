import 'package:flutter/foundation.dart';
import 'package:pokakbilling/core/authh/jwtutils.dart';

class AuthSession extends ChangeNotifier {
  String? _accessToken;
  int? _userId;

  String? get accessToken => _accessToken;
  int? get userId => _userId;

  void setAccessToken(String token) {
    _accessToken = token;
    _userId = userIdFromToken(token);
    notifyListeners();
  }

  void clear() {
    _accessToken = null;
    _userId = null;
    notifyListeners();
  }
}
