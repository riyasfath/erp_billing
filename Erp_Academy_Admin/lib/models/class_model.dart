import '../core/utils/json_parse.dart';

/// One class from GET /internship/class/
class ClassItem {
  final int id;
  final String name;
  final int? centerId;
  final String centerName;
  final int sectionsCount;
  final bool isActive;
  final DateTime? createdAt;

  const ClassItem({
    required this.id,
    required this.name,
    required this.centerId,
    required this.centerName,
    required this.sectionsCount,
    required this.isActive,
    required this.createdAt,
  });

  factory ClassItem.fromJson(Map<String, dynamic> json) => ClassItem(
        id: JsonParse.toInt(json['id']),
        name: JsonParse.toStr(json['name']).trim(),
        centerId:
            json['center'] == null ? null : JsonParse.toInt(json['center']),
        centerName: JsonParse.toStr(json['center_name']),
        sectionsCount: JsonParse.toInt(json['sections_count']),
        isActive: JsonParse.toBool(json['is_active'], true),
        createdAt: JsonParse.toDate(json['created_at']),
      );
}

/// A section inside a class. Parsed defensively because the API
/// sample had no sections yet.
class ClassSection {
  final int? id;
  final String time;
  final List<String> days;
  final String course;
  final String batch;
  final int students;
  final String duration;

  const ClassSection({
    required this.id,
    required this.time,
    required this.days,
    required this.course,
    required this.batch,
    required this.students,
    required this.duration,
  });

  bool runsOn(String shortDay) => days.any(
      (d) => d.toLowerCase().startsWith(shortDay.toLowerCase().substring(0, 3)));

  static String _fmtTime(String t) {
    final m = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(t.trim());
    if (m == null) return t.trim();
    var h = int.parse(m.group(1)!);
    final min = m.group(2)!;
    final ap = h >= 12 ? 'PM' : 'AM';
    h = h % 12;
    if (h == 0) h = 12;
    return '$h:$min $ap';
  }

  static String _nameOf(dynamic v, List<String> keys) {
    if (v == null) return '';
    if (v is Map) {
      for (final k in keys) {
        if (v[k] != null) return v[k].toString();
      }
      return '';
    }
    return v.toString();
  }

  factory ClassSection.fromJson(Map<String, dynamic> json) {
    // Time
    final start = JsonParse.toStr(json['start_time'] ?? json['from_time']);
    final end = JsonParse.toStr(json['end_time'] ?? json['to_time']);
    var time = JsonParse.toStr(json['time']);
    if (time.isEmpty && start.isNotEmpty) {
      time = end.isEmpty
          ? _fmtTime(start)
          : '${_fmtTime(start)} - ${_fmtTime(end)}';
    }

    // Days
    final rawDays = json['days'] ?? json['day'];
    List<String> days;
    if (rawDays is List) {
      days = rawDays
          .map((d) => _nameOf(d, const ['name', 'day', 'short_name']))
          .where((d) => d.isNotEmpty)
          .toList();
    } else if (rawDays is String && rawDays.trim().isNotEmpty) {
      days = rawDays.split(RegExp(r'[,/ ]+')).where((d) => d.isNotEmpty).toList();
    } else {
      days = const [];
    }

    // Course & batch (string, id or nested object)
    final course = JsonParse.toStr(json['course_name']).isNotEmpty
        ? JsonParse.toStr(json['course_name'])
        : _nameOf(json['course'], const ['title', 'name']);
    final batch = JsonParse.toStr(json['batch_number']).isNotEmpty
        ? JsonParse.toStr(json['batch_number'])
        : _nameOf(json['batch'], const ['batch_number', 'name']);

    // Students (count or list)
    final st = json['students_count'] ?? json['students'];
    final students = st is List ? st.length : JsonParse.toInt(st);

    return ClassSection(
      id: json['id'] == null ? null : JsonParse.toInt(json['id']),
      time: time,
      days: days,
      course: course,
      batch: batch,
      students: students,
      duration: JsonParse.toStr(json['duration']),
    );
  }
}

/// GET /internship/class/{id}/
class ClassDetail {
  final ClassItem info;
  final List<ClassSection> sections;

  const ClassDetail({required this.info, required this.sections});

  factory ClassDetail.fromJson(Map<String, dynamic> json) => ClassDetail(
        info: ClassItem.fromJson(json),
        sections: JsonParse.toMapList(json['sections'])
            .map(ClassSection.fromJson)
            .toList(),
      );
}