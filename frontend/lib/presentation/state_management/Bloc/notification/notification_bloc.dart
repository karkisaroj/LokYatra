import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/datasources/notification_remote_datasource.dart';
import '../../../../data/models/AppNotification.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final _ds = NotificationRemoteDatasource();
  Timer? _pollTimer;

  NotificationBloc() : super(const NotificationInitial()) {
    on<LoadNotifications>(_onLoad);
    on<StartNotificationPolling>(_onStartPolling);
    on<StopNotificationPolling>(_onStopPolling);
    on<MarkNotificationRead>(_onMarkRead);
    on<MarkAllNotificationsRead>(_onMarkAllRead);
    on<DeleteNotification>(_onDelete);
    on<ClearAllNotifications>(_onClearAll);
  }

  List<AppNotification> get _current =>
      state is NotificationsLoaded
          ? (state as NotificationsLoaded).notifications
          : [];

  Future<void> _onLoad(LoadNotifications e, Emitter emit) async {
    if (state is NotificationInitial) emit(const NotificationLoading());
    try {
      final res = await _ds.getMyNotifications();
      if (res.statusCode == 200) {
        final data = res.data as Map<String, dynamic>;
        final list = (data['notifications'] as List<dynamic>)
            .map((j) => AppNotification.fromJson(j as Map<String, dynamic>))
            .toList();
        emit(NotificationsLoaded(
          notifications: list,
          unreadCount:   data['unreadCount'] as int,
        ));
      }
    } catch (_) {
      if (state is NotificationInitial) emit(const NotificationError('Failed to load'));
    }
  }

  void _onStartPolling(StartNotificationPolling e, Emitter emit) {
    _pollTimer?.cancel();
    add(const LoadNotifications());
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      add(const LoadNotifications());
    });
  }

  void _onStopPolling(StopNotificationPolling e, Emitter emit) {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _onMarkRead(MarkNotificationRead e, Emitter emit) async {
    try {
      await _ds.markRead(e.id);
      final updated = _current
          .map((n) => n.id == e.id ? n.copyWith(isRead: true) : n)
          .toList();
      emit(NotificationsLoaded(
        notifications: updated,
        unreadCount:   updated.where((n) => !n.isRead).length,
      ));
    } catch (_) {}
  }

  Future<void> _onMarkAllRead(MarkAllNotificationsRead e, Emitter emit) async {
    try {
      await _ds.markAllRead();
      final updated = _current.map((n) => n.copyWith(isRead: true)).toList();
      emit(NotificationsLoaded(notifications: updated, unreadCount: 0));
    } catch (_) {}
  }

  Future<void> _onDelete(DeleteNotification e, Emitter emit) async {
    try {
      await _ds.deleteNotification(e.id);
      final updated = _current.where((n) => n.id != e.id).toList();
      emit(NotificationsLoaded(
        notifications: updated,
        unreadCount:   updated.where((n) => !n.isRead).length,
      ));
    } catch (_) {}
  }

  Future<void> _onClearAll(ClearAllNotifications e, Emitter emit) async {
    try {
      await _ds.clearAll();
      emit(const NotificationsLoaded(notifications: [], unreadCount: 0));
    } catch (_) {}
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }
}