// // // lib/models/data-models/activity_model.dart
// // class ActivityModel {
// //   final String id;
// //   final int leadId;
// //   final String activityType;
// //   final String action;
// //   final String? createdAt;
// //   final String? createdBy;

// //   ActivityModel({
// //     required this.id,
// //     required this.leadId,
// //     required this.activityType,
// //     required this.action,
// //     this.createdAt,
// //     this.createdBy,
// //   });

// //   factory ActivityModel.fromJson(Map<String, dynamic> json) {
// //     return ActivityModel(
// //       id: json['id']?.toString() ??
// //           DateTime.now().millisecondsSinceEpoch.toString(),
// //       leadId: json['lead'] is int
// //           ? json['lead'] as int
// //           : int.tryParse('${json['lead']}') ?? 0,
// //       activityType: json['activity_type']?.toString() ?? '',
// //       action: json['action']?.toString() ?? '',
// //       createdAt:
// //           json['created_at']?.toString() ?? json['createdAt']?.toString(),
// //       createdBy:
// //           json['created_by']?.toString() ?? json['createdBy']?.toString(),
// //     );
// //   }

// //   Map<String, dynamic> toJson() {
// //     return {
// //       'id': id,
// //       'lead': leadId,
// //       'activity_type': activityType,
// //       'action': action,
// //     };
// //   }
// // }
// // lib/models/data-models/activity_model.dart

// import 'dart:convert';

// // ── Counts ────────────────────────────────────────────────────────────────────
// class ActivityCounts {
//   final int allActivity;
//   final int calls;
//   final int meetings;
//   final int mails;
//   final int completed;
//   final int overdue;

//   ActivityCounts({
//     required this.allActivity,
//     required this.calls,
//     required this.meetings,
//     required this.mails,
//     required this.completed,
//     required this.overdue,
//   });

//   factory ActivityCounts.fromJson(Map<String, dynamic> json) => ActivityCounts(
//         allActivity: json['all_activity'] ?? 0,
//         calls: json['calls'] ?? 0,
//         meetings: json['meetings'] ?? 0,
//         mails: json['mails'] ?? 0,
//         completed: json['completed'] ?? 0,
//         overdue: json['overdue'] ?? 0,
//       );

//   factory ActivityCounts.empty() => ActivityCounts(
//         allActivity: 0,
//         calls: 0,
//         meetings: 0,
//         mails: 0,
//         completed: 0,
//         overdue: 0,
//       );
// }

// // ── Followup item ─────────────────────────────────────────────────────────────
// class ActivityFollowup {
//   final int id;
//   final String title;
//   final String leadName;
//   final String type; // call / meeting / email / whatsapp
//   final String date;
//   final String time;
//   final String status;
//   final String notes;
//   final String phone;
//   final String email;

//   ActivityFollowup({
//     required this.id,
//     required this.title,
//     required this.leadName,
//     required this.type,
//     required this.date,
//     required this.time,
//     required this.status,
//     required this.notes,
//     required this.phone,
//     required this.email,
//   });

//   factory ActivityFollowup.fromJson(Map<String, dynamic> j) => ActivityFollowup(
//         id: j['id'] ?? 0,
//         title: j['title'] ?? j['subject'] ?? '',
//         leadName: j['lead_name'] ?? j['leadName'] ?? '',
//         type: j['type'] ?? 'call',
//         date: j['date'] ?? '',
//         time: j['time'] ?? '',
//         status: j['status'] ?? '',
//         notes: j['notes'] ?? j['description'] ?? '',
//         phone: j['phone'] ?? '',
//         email: j['email'] ?? '',
//       );
// }

// // ── Meeting item ──────────────────────────────────────────────────────────────
// class ActivityMeeting {
//   final int id;
//   final String title;
//   final String leadName;
//   final String date;
//   final String time;
//   final String status;
//   final String meetingPlace;
//   final String description;
//   final String phone;
//   final String email;

//   ActivityMeeting({
//     required this.id,
//     required this.title,
//     required this.leadName,
//     required this.date,
//     required this.time,
//     required this.status,
//     required this.meetingPlace,
//     required this.description,
//     required this.phone,
//     required this.email,
//   });

//   factory ActivityMeeting.fromJson(Map<String, dynamic> j) => ActivityMeeting(
//         id: j['id'] ?? j['meeting_id'] ?? 0,
//         title: j['title'] ?? j['subject'] ?? '',
//         leadName: j['lead_name'] ?? j['leadName'] ?? '',
//         date: j['date'] ?? '',
//         time: j['time'] ?? '',
//         status: j['status'] ?? '',
//         meetingPlace: j['meeting_place'] ?? j['location'] ?? '',
//         description: j['description'] ?? '',
//         phone: j['phone'] ?? '',
//         email: j['email'] ?? '',
//       );
// }

// // ── Reminder item ─────────────────────────────────────────────────────────────
// class ActivityReminder {
//   final int id;
//   final String subject;
//   final String leadName;
//   final String type;
//   final String date;
//   final String time;
//   final String status;
//   final String notes;
//   final String phone;
//   final String email;

//   ActivityReminder({
//     required this.id,
//     required this.subject,
//     required this.leadName,
//     required this.type,
//     required this.date,
//     required this.time,
//     required this.status,
//     required this.notes,
//     required this.phone,
//     required this.email,
//   });

//   factory ActivityReminder.fromJson(Map<String, dynamic> j) => ActivityReminder(
//         id: j['id'] ?? 0,
//         subject: j['subject'] ?? j['title'] ?? '',
//         leadName: j['lead_name'] ?? j['leadName'] ?? '',
//         type: j['type'] ?? 'call',
//         date: j['date'] ?? '',
//         time: j['time'] ?? '',
//         status: j['status'] ?? '',
//         notes: j['notes'] ?? '',
//         phone: j['phone'] ?? '',
//         email: j['email'] ?? '',
//       );
// }

// // ── Full response ─────────────────────────────────────────────────────────────
// class ActivityResponse {
//   final ActivityCounts counts;
//   final List<ActivityFollowup> followups;
//   final List<ActivityMeeting> meetings;
//   final List<ActivityReminder> reminders;

//   ActivityResponse({
//     required this.counts,
//     required this.followups,
//     required this.meetings,
//     required this.reminders,
//   });

//   factory ActivityResponse.fromJson(Map<String, dynamic> json) {
//     final counts =
//         ActivityCounts.fromJson(json['activity_counts'] ?? <String, dynamic>{});

//     final data = json['data'] as Map<String, dynamic>? ?? {};

//     final followups = (data['followups'] as List? ?? [])
//         .map((e) => ActivityFollowup.fromJson(e as Map<String, dynamic>))
//         .toList();

//     final meetings = (data['meetings'] as List? ?? [])
//         .map((e) => ActivityMeeting.fromJson(e as Map<String, dynamic>))
//         .toList();

//     final reminders = (data['reminders'] as List? ?? [])
//         .map((e) => ActivityReminder.fromJson(e as Map<String, dynamic>))
//         .toList();

//     return ActivityResponse(
//       counts: counts,
//       followups: followups,
//       meetings: meetings,
//       reminders: reminders,
//     );
//   }

//   factory ActivityResponse.empty() => ActivityResponse(
//         counts: ActivityCounts.empty(),
//         followups: [],
//         meetings: [],
//         reminders: [],
//       );
// }
// lib/models/activity_leads/activity.dart

// // lib/models/data-models/activity_model.dart
// class ActivityModel {
//   final String id;
//   final int leadId;
//   final String activityType;
//   final String action;
//   final String? createdAt;
//   final String? createdBy;

//   ActivityModel({
//     required this.id,
//     required this.leadId,
//     required this.activityType,
//     required this.action,
//     this.createdAt,
//     this.createdBy,
//   });

//   factory ActivityModel.fromJson(Map<String, dynamic> json) {
//     return ActivityModel(
//       id: json['id']?.toString() ??
//           DateTime.now().millisecondsSinceEpoch.toString(),
//       leadId: json['lead'] is int
//           ? json['lead'] as int
//           : int.tryParse('${json['lead']}') ?? 0,
//       activityType: json['activity_type']?.toString() ?? '',
//       action: json['action']?.toString() ?? '',
//       createdAt:
//           json['created_at']?.toString() ?? json['createdAt']?.toString(),
//       createdBy:
//           json['created_by']?.toString() ?? json['createdBy']?.toString(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'lead': leadId,
//       'activity_type': activityType,
//       'action': action,
//     };
//   }
// }

// ── Counts ────────────────────────────────────────────────────────────────────
class ActivityCounts {
  final int allActivity;
  final int calls;
  final int meetings;
  final int mails;
  final int completed;
  final int overdue;

  ActivityCounts({
    required this.allActivity,
    required this.calls,
    required this.meetings,
    required this.mails,
    required this.completed,
    required this.overdue,
  });

  factory ActivityCounts.fromJson(Map<String, dynamic> json) => ActivityCounts(
        allActivity: json['all_activity'] ?? 0,
        calls: json['calls'] ?? 0,
        meetings: json['meetings'] ?? 0,
        mails: json['mails'] ?? 0,
        completed: json['completed'] ?? 0,
        overdue: json['overdue'] ?? 0,
      );

  factory ActivityCounts.empty() => ActivityCounts(
        allActivity: 0,
        calls: 0,
        meetings: 0,
        mails: 0,
        completed: 0,
        overdue: 0,
      );
}

// ── Followup item ─────────────────────────────────────────────────────────────
class ActivityFollowup {
  final int id;
  final String title;
  final String leadName;
  final String type; // call / meeting / email / whatsapp
  final String date;
  final String time;
  final String status;
  final String notes;
  final String phone;
  final String email;

  ActivityFollowup({
    required this.id,
    required this.title,
    required this.leadName,
    required this.type,
    required this.date,
    required this.time,
    required this.status,
    required this.notes,
    required this.phone,
    required this.email,
  });

  factory ActivityFollowup.fromJson(Map<String, dynamic> j) => ActivityFollowup(
        id: j['id'] ?? 0,
        title: j['title'] ?? j['subject'] ?? '',
        leadName: j['lead_name'] ?? j['leadName'] ?? '',
        type: j['type'] ?? 'call',
        date: j['date'] ?? '',
        time: j['time'] ?? '',
        status: j['status'] ?? '',
        notes: j['notes'] ?? j['description'] ?? '',
        phone: j['phone'] ?? '',
        email: j['email'] ?? '',
      );
}

// ── Meeting item ──────────────────────────────────────────────────────────────
class ActivityMeeting {
  final int id;
  final String title;
  final String leadName;
  final String date;
  final String time;
  final String status;
  final String meetingPlace;
  final String description;
  final String phone;
  final String email;

  ActivityMeeting({
    required this.id,
    required this.title,
    required this.leadName,
    required this.date,
    required this.time,
    required this.status,
    required this.meetingPlace,
    required this.description,
    required this.phone,
    required this.email,
  });

  factory ActivityMeeting.fromJson(Map<String, dynamic> j) => ActivityMeeting(
        id: j['id'] ?? j['meeting_id'] ?? 0,
        title: j['title'] ?? j['subject'] ?? '',
        leadName: j['lead_name'] ?? j['leadName'] ?? '',
        date: j['date'] ?? '',
        time: j['time'] ?? '',
        status: j['status'] ?? '',
        meetingPlace: j['meeting_place'] ?? j['location'] ?? '',
        description: j['description'] ?? '',
        phone: j['phone'] ?? '',
        email: j['email'] ?? '',
      );
}

// ── Reminder item ─────────────────────────────────────────────────────────────
class ActivityReminder {
  final int id;
  final String subject;
  final String leadName;
  final String type;
  final String date;
  final String time;
  final String status;
  final String notes;
  final String phone;
  final String email;

  ActivityReminder({
    required this.id,
    required this.subject,
    required this.leadName,
    required this.type,
    required this.date,
    required this.time,
    required this.status,
    required this.notes,
    required this.phone,
    required this.email,
  });

  factory ActivityReminder.fromJson(Map<String, dynamic> j) => ActivityReminder(
        id: j['id'] ?? 0,
        subject: j['subject'] ?? j['title'] ?? '',
        leadName: j['lead_name'] ?? j['leadName'] ?? '',
        type: j['type'] ?? 'call',
        date: j['date'] ?? '',
        time: j['time'] ?? '',
        status: j['status'] ?? '',
        notes: j['notes'] ?? '',
        phone: j['phone'] ?? '',
        email: j['email'] ?? '',
      );
}

// ── Full API response ─────────────────────────────────────────────────────────
class ActivityResponse {
  final ActivityCounts counts;
  final List<ActivityFollowup> followups;
  final List<ActivityMeeting> meetings;
  final List<ActivityReminder> reminders;

  ActivityResponse({
    required this.counts,
    required this.followups,
    required this.meetings,
    required this.reminders,
  });

  factory ActivityResponse.fromJson(Map<String, dynamic> json) {
    final counts = ActivityCounts.fromJson(
        (json['activity_counts'] as Map<String, dynamic>?) ?? {});

    final data = (json['data'] as Map<String, dynamic>?) ?? {};

    final followups = ((data['followups'] as List?) ?? [])
        .map((e) => ActivityFollowup.fromJson(e as Map<String, dynamic>))
        .toList();

    final meetings = ((data['meetings'] as List?) ?? [])
        .map((e) => ActivityMeeting.fromJson(e as Map<String, dynamic>))
        .toList();

    final reminders = ((data['reminders'] as List?) ?? [])
        .map((e) => ActivityReminder.fromJson(e as Map<String, dynamic>))
        .toList();

    return ActivityResponse(
      counts: counts,
      followups: followups,
      meetings: meetings,
      reminders: reminders,
    );
  }

  factory ActivityResponse.empty() => ActivityResponse(
        counts: ActivityCounts.empty(),
        followups: [],
        meetings: [],
        reminders: [],
      );
}
