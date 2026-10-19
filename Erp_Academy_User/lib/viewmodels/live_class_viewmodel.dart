import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/live_class_service.dart';

class LiveClassViewModel extends ChangeNotifier {
  final LiveClassService _service;
  LiveClassViewModel(this._service) {
    load();
  }

  final String title = 'Design Systems in Figma';
  int watching = 248;
  bool loading = true;
  bool handRaised = false;
  List<ChatMessage> messages = [];

  List<String> get participants =>
      {'You', ...messages.map((m) => m.name)}.toList();

  Future<void> load() async {
    messages = await _service.getMessages();
    loading = false;
    notifyListeners();
  }

  void toggleHand() {
    handRaised = !handRaised;
    notifyListeners();
  }

  void send(String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    final now = DateTime.now();
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    messages = [
      ...messages,
      ChatMessage('You', t, time, const Color(0xFF4F46E5)),
    ];
    notifyListeners();
  }
}