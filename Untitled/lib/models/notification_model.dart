/// A single notification. PARSING NOTE: no sample of a filled
/// GET /api/notifications/ item was provided, so field names are read
/// defensively (a few common alternates per field). Send me one real
/// item and I'll lock this down exactly.
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type; // e.g. 'order' | 'promo' | 'system' — unconfirmed
  final bool isRead;
  final DateTime? createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.createdAt,
  });

  NotificationModel copyAsRead() => NotificationModel(
        id: id,
        title: title,
        message: message,
        type: type,
        isRead: true,
        createdAt: createdAt,
      );

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? json['heading']?.toString() ?? 'Notification',
      message: json['message']?.toString() ??
          json['body']?.toString() ??
          json['description']?.toString() ??
          '',
      type: json['type']?.toString() ?? json['notification_type']?.toString() ?? 'general',
      isRead: json['is_read'] == true || json['read'] == true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }
}