int _sAsInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
DateTime? _sAsDate(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());

class AdminSupportStatsModel {
  final int totalTickets;
  final int newTickets;
  final int pendingTickets;
  final int resolvedToday;
  final int rejectedTickets;
  final int spamTickets;

  AdminSupportStatsModel({
    required this.totalTickets,
    required this.newTickets,
    required this.pendingTickets,
    required this.resolvedToday,
    required this.rejectedTickets,
    required this.spamTickets,
  });

  factory AdminSupportStatsModel.fromJson(Map<String, dynamic> json) => AdminSupportStatsModel(
        totalTickets: _sAsInt(json['total_tickets']),
        newTickets: _sAsInt(json['new_tickets']),
        pendingTickets: _sAsInt(json['pending_tickets']),
        resolvedToday: _sAsInt(json['resolved_today']),
        rejectedTickets: _sAsInt(json['rejected_tickets']),
        spamTickets: _sAsInt(json['spam_tickets']),
      );
}

/// Same shape for list items and single-ticket detail.
class AdminSupportTicketModel {
  final int id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String subject;
  final String message;
  final String status; // new | in_progress | resolved | rejected | spam (unconfirmed full set)
  final String statusDisplay;
  final DateTime? createdAt;
  final String createdAtFmt;
  final DateTime? updatedAt;
  final String updatedAtFmt;

  AdminSupportTicketModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.subject,
    required this.message,
    required this.status,
    required this.statusDisplay,
    this.createdAt,
    required this.createdAtFmt,
    this.updatedAt,
    required this.updatedAtFmt,
  });

  factory AdminSupportTicketModel.fromJson(Map<String, dynamic> json) => AdminSupportTicketModel(
        id: _sAsInt(json['id']),
        fullName: json['full_name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phoneNumber: json['phone_number']?.toString() ?? '',
        subject: json['subject']?.toString() ?? '',
        message: json['message']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        statusDisplay: json['status_display']?.toString() ?? '',
        createdAt: _sAsDate(json['created_at']),
        createdAtFmt: json['created_at_fmt']?.toString() ?? '',
        updatedAt: _sAsDate(json['updated_at']),
        updatedAtFmt: json['updated_at_fmt']?.toString() ?? '',
      );
}