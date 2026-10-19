import 'package:erp_academy/models/recording_item_model.dart';
import 'package:flutter/material.dart';
  import '../services/live_service.dart';

class LiveViewModel extends ChangeNotifier {
  final LiveService _service;
  LiveViewModel(this._service) {
    load();
  }

  List<RecordingItem> recordings = [];
  int tabIndex = 0; // Live Now / Upcoming / Past

  Future<void> load() async {
    recordings = await _service.getRecordings();
    notifyListeners();
  }

  void setTab(int i) {
    tabIndex = i;
    notifyListeners();
  }
}