int _nAsInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
DateTime? _nAsDate(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());

class AdminNotificationModel {
  final int id;
  final String notificationType; // order | return | employee | support | ...
  final String title;
  final String message;
  final String? link;
  final bool isRead;
  final DateTime? createdAt;
  final String createdAtFmt;

  AdminNotificationModel({
    required this.id,
    required this.notificationType,
    required this.title,
    required this.message,
    this.link,
    required this.isRead,
    this.createdAt,
    required this.createdAtFmt,
  });

  /// Pulls the trailing integer id out of links like "/admin/orders/419"
  /// or "/admin/support/ticket/4" — used to deep-link on tap.
  int? get linkedId {
    if (link == null) return null;
    final match = RegExp(r'(\d+)/?$').firstMatch(link!);
    return match != null ? int.tryParse(match.group(1)!) : null;
  }

  AdminNotificationModel copyAsRead() => AdminNotificationModel(
        id: id,
        notificationType: notificationType,
        title: title,
        message: message,
        link: link,
        isRead: true,
        createdAt: createdAt,
        createdAtFmt: createdAtFmt,
      );

  factory AdminNotificationModel.fromJson(Map<String, dynamic> json) => AdminNotificationModel(
        id: _nAsInt(json['id']),
        notificationType: json['notification_type']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        message: json['message']?.toString() ?? '',
        link: json['link']?.toString(),
        isRead: json['is_read'] == true,
        createdAt: _nAsDate(json['created_at']),
        createdAtFmt: json['created_at_fmt']?.toString() ?? '',
      );
}