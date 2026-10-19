// Models for Staff Academic Lead Dashboard
// GET /leads/academic-dashboard/staff/

String _s(dynamic v) => v == null ? '' : v.toString();
int _i(dynamic v) => v is int ? v : int.tryParse(_s(v)) ?? 0;
int? _iOrNull(dynamic v) =>
    v == null ? null : (v is int ? v : int.tryParse(_s(v)));
DateTime? _date(dynamic v) {
  final s = _s(v);
  return s.isEmpty ? null : DateTime.tryParse(s);
}

Map<String, dynamic> _m(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

/// yyyy-MM-dd for API
String leadApiDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

// ─── Tabs / priority ─────────────────────────────────────────────────────────
// First 4 are priority_status buckets, last 2 are lead_status buckets.
enum LeadStage { priorityPending, prospects, warm, cold, rnr, notValid }

extension LeadStageApi on LeadStage {
  /// value for ?tab=
  String get tabKey => switch (this) {
        LeadStage.priorityPending => 'priority_pending',
        LeadStage.prospects => 'prospects',
        LeadStage.warm => 'warm',
        LeadStage.cold => 'cold',
        LeadStage.rnr => 'rnr',
        LeadStage.notValid => 'number_not_valid',
      };

  /// value to SEND in payload for priority_status (Prospects = "hot")
  String? get priorityValue => switch (this) {
        LeadStage.prospects => 'hot',
        LeadStage.warm => 'warm',
        LeadStage.cold => 'cold',
        _ => null,
      };

  bool get isPriority => index <= LeadStage.cold.index;

  static List<LeadStage> get priorities =>
      LeadStage.values.where((s) => s.isPriority).toList();
}

/// raw priority_status from API -> stage
LeadStage priorityStageOf(String? v) => switch (v) {
      'hot' => LeadStage.prospects,
      'warm' => LeadStage.warm,
      'cold' => LeadStage.cold,
      _ => LeadStage.priorityPending,
    };

// ─── Lead status choices ─────────────────────────────────────────────────────
class LeadStatusOption {
  final String key;
  final String label;
  const LeadStatusOption(this.key, this.label);
}

const List<LeadStatusOption> kLeadStatuses = [
  LeadStatusOption('new', 'New'),
  LeadStatusOption('rnr', 'RNR'),
  LeadStatusOption('number_not_valid', 'Number Not Valid'),
  LeadStatusOption('follow_up', 'Follow Up'),
  LeadStatusOption('contacted', 'Contacted'),
  LeadStatusOption('in_progress', 'In Progress'),
  LeadStatusOption('converted', 'Converted'),
  LeadStatusOption('lost', 'Lost'),
  LeadStatusOption('created', 'Created'),
  LeadStatusOption('prospects', 'Prospects'),
  LeadStatusOption('details_shared', 'Details Shared'),
  LeadStatusOption('registration', 'Registration'),
];

// ─── Course (for filter + add lead) ──────────────────────────────────────────
class StaffCourse {
  final int id;
  final String name;
  const StaffCourse({required this.id, required this.name});

  factory StaffCourse.fromJson(Map<String, dynamic> j) => StaffCourse(
        id: _i(j['id']),
        name: _s(j['name'] ?? j['course_name'] ?? j['title']),
      );
}

// ─── Lead ────────────────────────────────────────────────────────────────────
class AcademicLead {
  final int id;
  final String leadNumber;
  final String name;
  final String phone;
  final String email;
  final String qualification;
  final String addOn; // add_on_course_attended
  final DateTime? expectedStart;
  final int? courseId;
  final String courseName;
  final String courseEnquiry;
  final int callCount;
  final DateTime? nextFollowup;
  final String? priorityStatus; // hot | warm | cold | null
  final String priorityDisplay;
  final String leadStatus;
  final String leadStatusDisplay;
  final DateTime? leadDate;
  final int? salesperson;

  const AcademicLead({
    required this.id,
    required this.leadNumber,
    required this.name,
    required this.phone,
    required this.email,
    required this.qualification,
    required this.addOn,
    required this.expectedStart,
    required this.courseId,
    required this.courseName,
    required this.courseEnquiry,
    required this.callCount,
    required this.nextFollowup,
    required this.priorityStatus,
    required this.priorityDisplay,
    required this.leadStatus,
    required this.leadStatusDisplay,
    required this.leadDate,
    required this.salesperson,
  });

  LeadStage get priorityStage => priorityStageOf(priorityStatus);

  factory AcademicLead.fromJson(Map<String, dynamic> j) {
    final ps = j['priority_status'];
    return AcademicLead(
      id: _i(j['id']),
      leadNumber: _s(j['lead_number']),
      name: _s(j['name']),
      phone: _s(j['phone']),
      email: _s(j['email']),
      qualification: _s(j['qualification']),
      addOn: _s(j['add_on_course_attended']),
      expectedStart: _date(j['expected_starting_date']),
      courseId: _iOrNull(j['course']),
      courseName: _s(j['course_name']),
      courseEnquiry: _s(j['course_enquiry']),
      callCount: _i(j['call_count']),
      nextFollowup: _date(j['next_call_followup_date']),
      priorityStatus: ps == null ? null : ps.toString(),
      priorityDisplay: _s(j['priority_status_display']),
      leadStatus: _s(j['lead_status']),
      leadStatusDisplay: _s(j['lead_status_display']),
      leadDate: _date(j['lead_date']),
      salesperson: _iOrNull(j['salesperson']),
    );
  }
}

// ─── Dashboard response ──────────────────────────────────────────────────────
class StaffLeadDashboard {
  final String tab;
  final Map<LeadStage, int> counts;
  final List<AcademicLead> leads;

  const StaffLeadDashboard({
    required this.tab,
    required this.counts,
    required this.leads,
  });

  factory StaffLeadDashboard.fromJson(Map<String, dynamic> j) {
    final c = _m(j['counts']);
    final data = j['data'];
    return StaffLeadDashboard(
      tab: _s(j['tab']),
      counts: {for (final s in LeadStage.values) s: _i(c[s.tabKey])},
      leads: data is List
          ? data
              .whereType<Map>()
              .map((e) => AcademicLead.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : <AcademicLead>[],
    );
  }
}