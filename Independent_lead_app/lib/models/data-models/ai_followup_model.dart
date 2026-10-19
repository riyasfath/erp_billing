// lib/models/data-models/ai_followup_model.dart  (NEW)

int _i(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse('${v ?? ''}') ?? 0;
}

String _s(dynamic v, [String d = '']) => v == null ? d : v.toString();

class AiFollowup {
  final int id;
  final int lead;
  final String? leadName;
  final String? leadCompany;
  final String channel; // email | whatsapp
  final String purpose;
  final String tone;
  final String language;
  final String length;
  final String message;
  final String status; // GENERATED | SENT | REPLIED | FAILED
  final String createdAt;
  final String? sentAt;

  const AiFollowup({
    required this.id,
    required this.lead,
    this.leadName,
    this.leadCompany,
    required this.channel,
    this.purpose = 'general_followup',
    this.tone = 'professional',
    this.language = 'English',
    this.length = 'medium',
    required this.message,
    this.status = 'GENERATED',
    required this.createdAt,
    this.sentAt,
  });

  factory AiFollowup.fromJson(Map<String, dynamic> j) => AiFollowup(
        id: _i(j['id']),
        lead: _i(j['lead'] ?? j['lead_id']),
        leadName: j['lead_name']?.toString(),
        leadCompany: j['lead_company']?.toString(),
        channel: _s(j['channel'], 'email'),
        purpose: _s(j['purpose'], 'general_followup'),
        tone: _s(j['tone'], 'professional'),
        language: _s(j['language'], 'English'),
        length: _s(j['length'], 'medium'),
        message: _s(j['message']),
        status: _s(j['status'], 'GENERATED').toUpperCase(),
        createdAt: _s(j['created_at'], DateTime.now().toIso8601String()),
        sentAt: j['sent_at']?.toString(),
      );

  /// The generate endpoint may return only a few fields; fill the rest from
  /// the request we sent.
  factory AiFollowup.fromGenerate(
    Map<String, dynamic> res, {
    required int leadId,
    required String channel,
    String? tone,
    String? length,
    String? language,
    String? purpose,
  }) {
    final merged = <String, dynamic>{
      'lead': leadId,
      'channel': channel,
      if (tone != null) 'tone': tone,
      if (length != null) 'length': length,
      if (language != null) 'language': language,
      if (purpose != null) 'purpose': purpose,
      ...res,
    };
    return AiFollowup.fromJson(merged);
  }

  AiFollowup copyWith({String? message, String? status, String? sentAt}) =>
      AiFollowup(
        id: id,
        lead: lead,
        leadName: leadName,
        leadCompany: leadCompany,
        channel: channel,
        purpose: purpose,
        tone: tone,
        language: language,
        length: length,
        message: message ?? this.message,
        status: status ?? this.status,
        createdAt: createdAt,
        sentAt: sentAt ?? this.sentAt,
      );

  DateTime? get created => DateTime.tryParse(createdAt)?.toLocal();

  String get purposeLabel => purpose.replaceAll('_', ' ').toUpperCase();
}