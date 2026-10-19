import '../core/utils/json_parse.dart';

class DashboardStats {
  final int activeStudents;
  final int activeCourses;
  final int facultyCount;
  final int pendingPayments;

  const DashboardStats({
    this.activeStudents = 0,
    this.activeCourses = 0,
    this.facultyCount = 0,
    this.pendingPayments = 0,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) => DashboardStats(
        activeStudents: JsonParse.toInt(json['active_students']),
        activeCourses: JsonParse.toInt(json['active_courses']),
        facultyCount: JsonParse.toInt(json['faculty_count']),
        pendingPayments: JsonParse.toInt(json['pending_payments']),
      );
}

class RevenuePoint {
  final String month;
  final double amount;
  const RevenuePoint(this.month, this.amount);

  factory RevenuePoint.fromJson(Map<String, dynamic> json) => RevenuePoint(
        JsonParse.toStr(json['month']),
        JsonParse.toDouble(json['amount']),
      );
}

class EnrollmentPoint {
  final String course;
  final int students;
  const EnrollmentPoint(this.course, this.students);

  factory EnrollmentPoint.fromJson(Map<String, dynamic> json) =>
      EnrollmentPoint(
        JsonParse.toStr(json['course']),
        JsonParse.toInt(json['students']),
      );
}

class RecentIntern {
  final String name;
  final String? course;
  final String status;
  const RecentIntern(this.name, this.course, this.status);

  factory RecentIntern.fromJson(Map<String, dynamic> json) {
    final c = json['course']?.toString().trim();
    return RecentIntern(
      JsonParse.toStr(json['name']),
      (c == null || c.isEmpty) ? null : c,
      JsonParse.toStr(json['status'], 'Active'),
    );
  }
}

class TopFaculty {
  final String name;
  final int students;
  const TopFaculty(this.name, this.students);

  factory TopFaculty.fromJson(Map<String, dynamic> json) => TopFaculty(
        JsonParse.toStr(json['name']),
        JsonParse.toInt(json['students']),
      );
}

/// GET /internship/dashboard/academic/
class AcademicDashboard {
  final DashboardStats stats;
  final List<RevenuePoint> revenue;
  final List<EnrollmentPoint> enrollments;
  final List<RecentIntern> recentInterns;
  final List<TopFaculty> topFaculty;

  const AcademicDashboard({
    required this.stats,
    required this.revenue,
    required this.enrollments,
    required this.recentInterns,
    required this.topFaculty,
  });

  double get totalRevenue => revenue.fold(0.0, (s, r) => s + r.amount);

  factory AcademicDashboard.fromJson(Map<String, dynamic> json) {
    final charts = json['charts'] is Map
        ? Map<String, dynamic>.from(json['charts'] as Map)
        : <String, dynamic>{};
    return AcademicDashboard(
      stats: json['stats'] is Map
          ? DashboardStats.fromJson(
              Map<String, dynamic>.from(json['stats'] as Map))
          : const DashboardStats(),
      revenue: JsonParse.toMapList(charts['revenue'])
          .map(RevenuePoint.fromJson)
          .toList(),
      enrollments: JsonParse.toMapList(charts['enrollments'])
          .map(EnrollmentPoint.fromJson)
          .toList(),
      recentInterns: JsonParse.toMapList(json['recent_interns'])
          .map(RecentIntern.fromJson)
          .toList(),
      topFaculty: JsonParse.toMapList(json['top_faculty'])
          .map(TopFaculty.fromJson)
          .toList(),
    );
  }
}