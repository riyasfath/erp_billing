import 'dart:async';
import 'package:flutter/material.dart';
import '../models/upcoming_class.dart';
import '../models/continue_item.dart';
import '../models/course_item.dart';
import '../models/activity_item.dart';
import '../services/home_service.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeService _service;
  HomeViewModel(this._service);

  bool loading = true;
  String userName = 'Rahul';
  UpcomingClass? upcoming;
  ContinueItem? continueItem;
  List<CourseItem> courses = [];
  List<ActivityItem> activity = [];

  int _seconds = 0;
  Timer? _timer;

  Future<void> load() async {
    upcoming = await _service.getUpcoming();
    continueItem = await _service.getContinue();
    courses = await _service.getCourses();
    activity = await _service.getActivity();
    _seconds = upcoming!.startsInSeconds;
    loading = false;
    notifyListeners();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_seconds > 0) {
        _seconds--;
        notifyListeners();
      }
    });
  }

  String get countdown {
    final h = (_seconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((_seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}