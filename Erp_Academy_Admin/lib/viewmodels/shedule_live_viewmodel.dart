import 'package:erp_academy/models/shedule_live_data.dart';
import 'package:flutter/material.dart';
import '../services/live_service.dart';

class ScheduleLiveViewModel extends ChangeNotifier {
  final LiveService _service;
  ScheduleLiveViewModel(this._service) {
    _loadMilestones();
  }

  static const durations = [45, 60, 90, 120];
  static const region = 'AWS US-East (Virginia)';
  static const _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December'
  ];

  List<String> milestones = ['Module 04: Convolutional Neural Networks & Vision'];
  String milestone = 'Module 04: Convolutional Neural Networks & Vision';
  int dayIndex = 1; // 0 Today, 1 Tomorrow, 2 Custom
  DateTime? customDate;
  TimeOfDay start = const TimeOfDay(hour: 10, minute: 0);
  int duration = 90;
  bool busy = false;

  Future<void> _loadMilestones() async {
    milestones = await _service.getMilestones();
    if (!milestones.contains(milestone)) milestone = milestones.last;
    notifyListeners();
  }

  void setMilestone(String? v) {
    if (v == null) return;
    milestone = v;
    notifyListeners();
  }

  void setDay(int i) {
    dayIndex = i;
    notifyListeners();
  }

  void setCustomDate(DateTime d) {
    customDate = d;
    dayIndex = 2;
    notifyListeners();
  }

  void setTime(TimeOfDay t) {
    start = t;
    notifyListeners();
  }

  void setDuration(int m) {
    duration = m;
    notifyListeners();
  }

  DateTime get date {
    final now = DateTime.now();
    if (dayIndex == 0) return now;
    if (dayIndex == 1) return now.add(const Duration(days: 1));
    return customDate ?? now;
  }

  String get dateTitle =>
      '${['Today', 'Tomorrow', 'Custom'][dayIndex]}, ${_days[date.weekday - 1]}';
  String get dateSub => '${_months[date.month - 1]} ${date.day}, ${date.year}';

  String get startLabel => _fmt(start);
  String get endLabel {
    final total = start.hour * 60 + start.minute + duration;
    return _fmt(TimeOfDay(hour: (total ~/ 60) % 24, minute: total % 60));
  }

  String _fmt(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m ${t.period == DayPeriod.am ? 'AM' : 'PM'}';
  }

  ScheduleLiveData _data(String title, String subtitle) => ScheduleLiveData(
        title: title,
        subtitle: subtitle,
        milestone: milestone,
        dateLabel: '$dateTitle, $dateSub',
        startTime: startLabel,
        durationMin: duration,
        region: region,
      );

  Future<bool> schedule(String title, String subtitle) =>
      _run(() => _service.scheduleLive(_data(title, subtitle)));

  Future<bool> saveDraft(String title, String subtitle) =>
      _run(() => _service.saveDraft(_data(title, subtitle)));

  Future<bool> _run(Future<bool> Function() job) async {
    busy = true;
    notifyListeners();
    final ok = await job();
    busy = false;
    notifyListeners();
    return ok;
  }
}