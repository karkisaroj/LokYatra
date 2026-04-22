import '../../../../data/models/app_notification.dart';

abstract class NotificationState {
  const NotificationState();
}

class NotificationInitial extends NotificationState { const NotificationInitial(); }
class NotificationLoading  extends NotificationState { const NotificationLoading(); }

class NotificationsLoaded extends NotificationState {
  final List<AppNotification> notifications;
  final int unreadCount;
  const NotificationsLoaded({required this.notifications, required this.unreadCount});
}

class NotificationError extends NotificationState {
  final String message;
  const NotificationError(this.message);
}
