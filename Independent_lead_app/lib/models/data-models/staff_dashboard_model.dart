// lib/models/data-models/staff_dashboard_model.dart  (NEW)
// Maps GET /staff/dashboard/

int _i(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse('${v ?? ''}') ?? 0;
}

double _d(dynamic v) {
  if (v is num) return v.toDouble();
  return double.tryParse('${v ?? ''}') ?? 0;
}

String _s(dynamic v) => v == null ? '' : v.toString();

List<Map<String, dynamic>> _list(dynamic v) => v is List
    ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : <Map<String, dynamic>>[];

Map<String, dynamic> _map(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

class ActivityStats {
  final int followUps, meetings, calls, emails, whatsapp;
  const ActivityStats({
    this.followUps = 0,
    this.meetings = 0,
    this.calls = 0,
    this.emails = 0,
    this.whatsapp = 0,
  });

  factory ActivityStats.fromJson(Map<String, dynamic> j) => ActivityStats(
        followUps: _i(j['follow_ups']),
        meetings: _i(j['meetings']),
        calls: _i(j['calls']),
        emails: _i(j['emails']),
        whatsapp: _i(j['whatsapp']),
      );
}

class OutcomeLead {
  final int id;
  final String name, company, reason;
  final double revenue;
  const OutcomeLead({
    required this.id,
    required this.name,
    required this.company,
    this.revenue = 0,
    this.reason = '',
  });

  factory OutcomeLead.fromJson(Map<String, dynamic> j) => OutcomeLead(
        id: _i(j['id']),
        name: _s(j['name']),
        company: _s(j['company']),
        revenue: _d(j['revenue']),
        reason: _s(j['reason']),
      );
}

class LeadOutcomes {
  final int converted, lost;
  final double conversionRate, revenueClosed;
  final List<OutcomeLead> convertedLeads, lostLeads;
  const LeadOutcomes({
    this.converted = 0,
    this.lost = 0,
    this.conversionRate = 0,
    this.revenueClosed = 0,
    this.convertedLeads = const [],
    this.lostLeads = const [],
  });

  factory LeadOutcomes.fromJson(Map<String, dynamic> j) => LeadOutcomes(
        converted: _i(j['converted']),
        lost: _i(j['lost']),
        conversionRate: _d(j['conversion_rate']),
        revenueClosed: _d(j['revenue_closed']),
        convertedLeads: _list(j['converted_leads'])
            .map(OutcomeLead.fromJson)
            .toList(),
        lostLeads:
            _list(j['lost_leads']).map(OutcomeLead.fromJson).toList(),
      );
}

class WeeklyPoint {
  final String day, date;
  final int calls, meetings;
  const WeeklyPoint({
    required this.day,
    required this.date,
    this.calls = 0,
    this.meetings = 0,
  });

  factory WeeklyPoint.fromJson(Map<String, dynamic> j) => WeeklyPoint(
        day: _s(j['day']),
        date: _s(j['date']),
        calls: _i(j['calls']),
        meetings: _i(j['meetings']),
      );
}

class CalendarEvent {
  final String date; // yyyy-MM-dd
  final int followUps, meetings, calls, emails, whatsapp;
  const CalendarEvent({
    required this.date,
    this.followUps = 0,
    this.meetings = 0,
    this.calls = 0,
    this.emails = 0,
    this.whatsapp = 0,
  });

  int get total => followUps + meetings + calls + emails + whatsapp;

  factory CalendarEvent.fromJson(Map<String, dynamic> j) => CalendarEvent(
        date: _s(j['date']),
        followUps: _i(j['follow_ups']),
        meetings: _i(j['meetings']),
        calls: _i(j['calls']),
        emails: _i(j['emails']),
        whatsapp: _i(j['whatsapp']),
      );
}

class TimelineItem {
  final int id;
  final String title, type, time, lead, status;
  const TimelineItem({
    required this.id,
    required this.title,
    this.type = '',
    this.time = '',
    this.lead = '',
    this.status = '',
  });

  factory TimelineItem.fromJson(Map<String, dynamic> j) => TimelineItem(
        id: _i(j['id']),
        title: _s(j['title']),
        type: _s(j['type']),
        time: _s(j['time']),
        lead: _s(j['lead']),
        status: _s(j['status']),
      );
}

class StaffDashboard {
  final int tasksLinedUp;
  final ActivityStats stats;
  final LeadOutcomes outcomes;
  final List<WeeklyPoint> weekly;
  final List<CalendarEvent> calendar;
  final List<TimelineItem> meetingsAndCalls, followUps, recent;

  const StaffDashboard({
    this.tasksLinedUp = 0,
    this.stats = const ActivityStats(),
    this.outcomes = const LeadOutcomes(),
    this.weekly = const [],
    this.calendar = const [],
    this.meetingsAndCalls = const [],
    this.followUps = const [],
    this.recent = const [],
  });

  factory StaffDashboard.fromJson(Map<String, dynamic> j) => StaffDashboard(
        tasksLinedUp: _i(j['tasks_lined_up_count']),
        stats: ActivityStats.fromJson(_map(j['activity_stats'])),
        outcomes: LeadOutcomes.fromJson(_map(j['lead_outcomes'])),
        weekly:
            _list(j['weekly_activity']).map(WeeklyPoint.fromJson).toList(),
        calendar:
            _list(j['calendar_events']).map(CalendarEvent.fromJson).toList(),
        meetingsAndCalls: _list(j['meetings_and_calls'])
            .map(TimelineItem.fromJson)
            .toList(),
        followUps:
            _list(j['follow_ups']).map(TimelineItem.fromJson).toList(),
        recent: _list(j['recent_activities'])
            .map(TimelineItem.fromJson)
            .toList(),
      );
}