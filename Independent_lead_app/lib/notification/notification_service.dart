import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const String _meetingChannelId = 'meeting_channel';
  static const String _reminderChannelId = 'reminder_channel';
  static const String _contactChannelId = 'contact_channel';
  static const String _generalChannelId = 'general_channel';

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    try {
      final dynamic tzResult = await FlutterTimezone.getLocalTimezone();
      final String tzName =
          tzResult is String ? tzResult : (tzResult.identifier as String);
      tz.setLocalLocation(tz.getLocation(tzName));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    }

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {},
    );

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();

    _initialized = true;
  }

  AndroidNotificationDetails _androidDetails({
    required String channelId,
    required String channelName,
    required String channelDesc,
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) {
    return AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: importance,
      priority: priority,
      fullScreenIntent: false,
      styleInformation: const BigTextStyleInformation(''),
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      category: AndroidNotificationCategory.message,
    );
  }

  // ── Internal helpers ──────────────────────────────────────────────────────

  bool _isFollowup(String eventType) {
    final t = eventType.toUpperCase();
    return t == 'FOLLOW_UP' ||
        t == 'FOLLOWUP' ||
        t == 'FOLLOW-UP' ||
        t == 'CALL' ||
        t == 'EMAIL' ||
        t == 'WHATSAPP';
  }

  // Maps any activity/subtype string to a human-friendly label + emoji
  // Used for both Reminder and NewActivity notifications.
  String _activityLabel(String type) {
    switch (type.toLowerCase()) {
      case 'meeting':
        return '📅 Meeting';
      case 'follow_up':
      case 'follow-up':
      case 'followup':
        return '🔁 Follow-up';
      case 'call':
        return '📞 Call';
      case 'email':
        return '✉️ Email';
      case 'whatsapp':
        return '💬 WhatsApp';
      case 'message':
        return '📨 Message';
      case 'reminder':
        return '🔔 Reminder';
      default:
        return type;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 1. Meeting / Follow-up created
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> showMeetingCreatedNotification({
    required String title,
    required String meetingType,
    required String dateText,
    required String timeText,
    required String leadName,
  }) async {
    await init();

    final notifTitle = _isFollowup(meetingType)
        ? '✅ Follow-up Scheduled!'
        : '📅 Meeting Scheduled!';

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      notifTitle,
      '$title with $leadName · $dateText at $timeText',
      NotificationDetails(
        android: _androidDetails(
          channelId: _meetingChannelId,
          channelName: 'Meeting Notifications',
          channelDesc: 'Notifications when meetings or follow-ups are created',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 2. New contact reached out
  // ─────────────────────────────────────────────────────────────────────────
  // [via] = 'WhatsApp' | 'Call' | 'Email'
  Future<void> showContactCreatedNotification({
    required String phone,
    required String email,
    required String via,
  }) async {
    await init();

    final String notifTitle;
    final String body;

    switch (via.toLowerCase()) {
      case 'whatsapp':
        notifTitle = '💬 New Contact via WhatsApp';
        body = 'Reaching out to $phone on WhatsApp';
        break;
      case 'call':
        notifTitle = '📞 New Contact via Call';
        body = 'Calling $phone now';
        break;
      case 'email':
        notifTitle = '✉️ New Contact via Email';
        body = 'Sending email to $email';
        break;
      default:
        notifTitle = '👤 New Contact Created';
        body = phone.isNotEmpty ? phone : email;
    }

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      notifTitle,
      body,
      NotificationDetails(
        android: _androidDetails(
          channelId: _contactChannelId,
          channelName: 'Contact Notifications',
          channelDesc: 'Notifications when a new contact is reached out to',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 3. Reminder created
  // ─────────────────────────────────────────────────────────────────────────
  // [subtype] = 'Email' | 'Call' | 'WhatsApp' | 'Message' | 'Follow-up'
  Future<void> showReminderCreatedNotification({
    required String title,
    required String subtype,
    required String dateText,
    required String timeText,
    required String leadName,
  }) async {
    await init();

    final label = _activityLabel(subtype);

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '🔔 Reminder Scheduled!',
      '$title for $leadName · $label · $dateText at $timeText',
      NotificationDetails(
        android: _androidDetails(
          channelId: _generalChannelId,
          channelName: 'Reminder Notifications',
          channelDesc: 'Notifications when reminders are created',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 4. New Activity scheduled  (used by NewActivityScreen)
  // ─────────────────────────────────────────────────────────────────────────
  // [activityType] = 'Meeting' | 'Email' | 'Call' | 'WhatsApp' |
  //                  'Follow-up' | 'Reminder'
  Future<void> showActivityScheduledNotification({
    required String activityType,
    required String detail, // e.g. title or phone or subject
  }) async {
    await init();

    final label = _activityLabel(activityType);

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '$label Scheduled!',
      detail,
      NotificationDetails(
        android: _androidDetails(
          channelId: _generalChannelId,
          channelName: 'Activity Notifications',
          channelDesc: 'Notifications when activities are scheduled',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 5. Meeting / Follow-up 30-min reminder (scheduled)
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> scheduleMeetingReminder({
    required int meetingId,
    required String title,
    required String leadName,
    required String meetingType,
    required DateTime meetingDateTime,
  }) async {
    await init();

    final reminderTime = meetingDateTime.subtract(const Duration(minutes: 30));
    if (reminderTime.isBefore(DateTime.now())) return;

    final scheduledDate = tz.TZDateTime.from(reminderTime, tz.local);

    final reminderTitle = _isFollowup(meetingType)
        ? '⏰ Follow-up in 30 minutes!'
        : '⏰ Meeting in 30 minutes!';

    await _plugin.zonedSchedule(
      meetingId,
      reminderTitle,
      '$title with $leadName · $meetingType',
      scheduledDate,
      NotificationDetails(
        android: _androidDetails(
          channelId: _reminderChannelId,
          channelName: 'Meeting Reminders',
          channelDesc: '30-minute meeting and follow-up reminders',
          importance: Importance.max,
          priority: Priority.max,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelReminder(int meetingId) async {
    await _plugin.cancel(meetingId);
  }
}
