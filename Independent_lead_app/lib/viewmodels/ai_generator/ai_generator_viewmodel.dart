// lib/viewmodels/ai_generator_viewmodel.dart  (NEW)

import 'package:flutter/material.dart';
import 'package:pokakbilling/models/data-models/ai_followup_model.dart';
import 'package:pokakbilling/models/services/ai_generator_service.dart';

class AiGeneratorViewModel extends ChangeNotifier {
  final Map<String, List<AiFollowup>> _items = {'email': [], 'whatsapp': []};
  final Map<String, bool> _loading = {'email': false, 'whatsapp': false};
  final Map<String, String?> _loadError = {'email': null, 'whatsapp': null};

  bool generating = false;
  String? lastError;

  List<AiFollowup> itemsFor(String channel) => _items[channel] ?? const [];
  bool isLoading(String channel) => _loading[channel] ?? false;
  String? loadErrorFor(String channel) => _loadError[channel];

  AiFollowup? byId(int id) {
    for (final list in _items.values) {
      for (final i in list) {
        if (i.id == id) return i;
      }
    }
    return null;
  }

  void _sort(String channel) {
    _items[channel]?.sort((a, b) {
      final da = a.created ?? DateTime.fromMillisecondsSinceEpoch(0);
      final db = b.created ?? DateTime.fromMillisecondsSinceEpoch(0);
      return db.compareTo(da);
    });
  }

  void _replace(AiFollowup n) {
    final list = _items[n.channel];
    if (list == null) return;
    final idx = list.indexWhere((e) => e.id == n.id);
    if (idx >= 0) list[idx] = n;
  }

  Future<void> load(String channel) async {
    _loading[channel] = true;
    _loadError[channel] = null;
    notifyListeners();
    try {
      _items[channel] = await AiGeneratorService.list(channel);
      _sort(channel);
    } catch (e) {
      _loadError[channel] = AiGeneratorService.errorMessage(e);
    } finally {
      _loading[channel] = false;
      notifyListeners();
    }
  }

  Future<AiFollowup?> generate({
    required int leadId,
    required String channel,
    String? tone,
    String? length,
    String? language,
    String? purpose,
    String? additionalContext,
  }) async {
    generating = true;
    lastError = null;
    notifyListeners();
    try {
      final item = await AiGeneratorService.generate(
        leadId: leadId,
        channel: channel,
        tone: tone,
        length: length,
        language: language,
        purpose: purpose,
        additionalContext: additionalContext,
      );
      _items.putIfAbsent(channel, () => []).insert(0, item);
      _sort(channel);
      return item;
    } catch (e) {
      lastError = AiGeneratorService.errorMessage(e);
      return null;
    } finally {
      generating = false;
      notifyListeners();
    }
  }

  Future<bool> saveMessage(int id, String message) async {
    lastError = null;
    try {
      await AiGeneratorService.updateMessage(id, message);
      final cur = byId(id);
      if (cur != null) _replace(cur.copyWith(message: message));
      notifyListeners();
      return true;
    } catch (e) {
      lastError = AiGeneratorService.errorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> send(int id) async {
    lastError = null;
    try {
      await AiGeneratorService.sendAction(id);
      final cur = byId(id);
      if (cur != null) {
        _replace(cur.copyWith(
            status: 'SENT', sentAt: DateTime.now().toIso8601String()));
      }
      notifyListeners();
      return true;
    } catch (e) {
      lastError = AiGeneratorService.errorMessage(e);
      final cur = byId(id);
      if (cur != null && cur.channel == 'email') {
        // backend sets FAILED when SMTP fails – refresh to reflect it
        load('email');
      }
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(int id) async {
    lastError = null;
    try {
      await AiGeneratorService.delete(id);
      for (final list in _items.values) {
        list.removeWhere((e) => e.id == id);
      }
      notifyListeners();
      return true;
    } catch (e) {
      lastError = AiGeneratorService.errorMessage(e);
      notifyListeners();
      return false;
    }
  }
}