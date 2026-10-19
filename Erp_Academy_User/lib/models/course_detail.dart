import 'package:erp_user/models/module_session.dart';

import 'live_session_item.dart';

class CourseDetail {
  final int overviewPercent;
  final String overview, lessonsCount;
  final List<ModuleSection> modules;
  final List<LiveSessionItem> upcoming, completed;
  const CourseDetail({
    required this.overviewPercent,
    required this.overview,
    required this.lessonsCount,
    required this.modules,
    required this.upcoming,
    required this.completed,
  });
}