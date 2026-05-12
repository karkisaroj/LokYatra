abstract class NotificationEvent {
  const NotificationEvent();
}

class LoadNotifications  extends NotificationEvent {
  const LoadNotifications();
}

class StartNotificationPolling extends NotificationEvent {
  const StartNotificationPolling();
}

class StopNotificationPolling extends NotificationEvent {
  const StopNotificationPolling();
}

class MarkNotificationRead extends NotificationEvent {
  final int id;
  const MarkNotificationRead(this.id);
}

class MarkAllNotificationsRead extends NotificationEvent {
  const MarkAllNotificationsRead();
}

class DeleteNotification extends NotificationEvent {
  final int id;
  const DeleteNotification(this.id);
}

class ClearAllNotifications extends NotificationEvent {
  const ClearAllNotifications();
}