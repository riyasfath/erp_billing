import 'package:pokakbilling/models/data-models/notification_model.dart';

class NotificationController {
  final List<NotificationModel> notifications = [
    NotificationModel(
      title: 'Notification 1',
      message: 'This is the first notification message.',
    ),
    NotificationModel(
      title: 'Notification 2',
      message: 'This is the second notification message.',
    ),
  ];

  List<NotificationModel> getNotifications() {
    return notifications;
  }
}
