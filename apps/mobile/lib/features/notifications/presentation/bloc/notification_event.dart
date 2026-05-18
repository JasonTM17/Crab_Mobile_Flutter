abstract class NotificationEvent {
  const NotificationEvent();
}

class LoadNotifications extends NotificationEvent {
  final int page;
  const LoadNotifications({this.page = 1});
}

class MarkNotificationRead extends NotificationEvent {
  final String notificationId;
  const MarkNotificationRead({required this.notificationId});
}

class MarkAllNotificationsRead extends NotificationEvent {
  const MarkAllNotificationsRead();
}

class NotificationReceived extends NotificationEvent {
  final Map<String, dynamic> data;
  const NotificationReceived({required this.data});
}
