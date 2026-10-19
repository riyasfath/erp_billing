class AddCallLogRequestModel {
  final int leadId;
  final String customerNumber;
  final String callType;
  final String status;
  final String leadStatus;
  final String leadSource;
  final int? durationSeconds;
  final String? nextFollowupDate;
  final String? notes;

  AddCallLogRequestModel({
    required this.leadId,
    required this.customerNumber,
    required this.callType,
    required this.status,
    required this.leadStatus,
    required this.leadSource,
    this.durationSeconds,
    this.nextFollowupDate,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'lead_id': leadId,
      'customer_number': customerNumber,
      'call_type': callType,
      'status': status,
      'lead_status': leadStatus,
      'lead_source': leadSource,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (nextFollowupDate != null && nextFollowupDate!.isNotEmpty)
        'next_followup_date': nextFollowupDate,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }
}

class AddCallLogResponseModel {
  final bool success;
  final String message;
  final int? callLogId;

  AddCallLogResponseModel({
    required this.success,
    required this.message,
    this.callLogId,
  });

  factory AddCallLogResponseModel.fromJson(Map<String, dynamic> json) {
    return AddCallLogResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      callLogId: json['call_log_id'] is int
          ? json['call_log_id']
          : int.tryParse(json['call_log_id']?.toString() ?? ''),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────
/// Dropdown option sets used by the Add Call Log form.
/// Kept here (rather than hardcoded in the widget) so they're easy to
/// update once the backend's accepted enum values are fully confirmed.
/// ─────────────────────────────────────────────────────────────────────────
class CallLogOptions {
  static const List<String> callTypes = ['outgoing', 'incoming'];

  static const List<String> callStatuses = [
    'answered',
    'missed',
    'no_answer',
    'busy',
    'failed',
  ];

  static const List<String> leadStatuses = [
    'NEW',
    'CONTACTED',
    'QUALIFIED',
    'CONVERTED',
    'LOST',
  ];

  static const List<String> leadSources = [
    'WEBSITE',
    'REFERRAL',
    'SOCIAL_MEDIA',
    'ADVERTISEMENT',
    'WALK_IN',
    'OTHER',
  ];
}
