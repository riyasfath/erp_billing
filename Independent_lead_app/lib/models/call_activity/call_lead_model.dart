/// ─────────────────────────────────────────────────────────────────────────
/// Lead shape returned by GET /call-activity/start-new_call/
/// Example:
/// {
///   "lead_id": 226,
///   "name": "testCall",
///   "phone": "+919496697204",
///   "email": "riyasfath@gmail.com",
///   "status": "NEW",
///   "source": "Website"
/// }
///
/// Kept separate from the main `LeadModel` (data-models/lead_model.dart)
/// because that model's `id` + `leadId` (string code like "LD12345") don't
/// match this endpoint's shape — here `lead_id` IS the numeric primary key,
/// which is also what /call-activity/call-details/<id>/ expects.
/// ─────────────────────────────────────────────────────────────────────────
class CallLeadModel {
  final int leadId;
  final String name;
  final String phone;
  final String? email;
  final String status;
  final String? source;

  CallLeadModel({
    required this.leadId,
    required this.name,
    required this.phone,
    this.email,
    required this.status,
    this.source,
  });

  factory CallLeadModel.fromJson(Map<String, dynamic> json) {
    return CallLeadModel(
      leadId: json['lead_id'] is int
          ? json['lead_id'] as int
          : int.tryParse(json['lead_id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? 'Unknown',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      status: json['status']?.toString() ?? 'NEW',
      source: json['source']?.toString(),
    );
  }
}

class CallLeadListResponseModel {
  final int count;
  final List<CallLeadModel> results;

  CallLeadListResponseModel({required this.count, required this.results});

  factory CallLeadListResponseModel.fromJson(Map<String, dynamic> json) {
    // Defensive: backend might key the array as "results" or "leads".
    final rawResults =
        (json['results'] as List?) ?? (json['leads'] as List?) ?? [];

    final parsed = rawResults
        .map((e) => CallLeadModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return CallLeadListResponseModel(
      count: json['count'] is int ? json['count'] as int : parsed.length,
      results: parsed,
    );
  }

  factory CallLeadListResponseModel.empty() =>
      CallLeadListResponseModel(count: 0, results: []);
}
