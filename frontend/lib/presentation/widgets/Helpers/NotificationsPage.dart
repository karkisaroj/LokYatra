import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/AppNotification.dart';
import '../../state_management/Bloc/notification/notification_bloc.dart';
import '../../state_management/Bloc/notification/notification_event.dart';
import '../../state_management/Bloc/notification/notification_state.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  static const _dark       = Color(0xFF2D1B10);
  static const _cream      = Color(0xFFFAF7F2);
  static const _terracotta = Color(0xFFCD6E4E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18.sp, color: _dark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Notifications',
            style: GoogleFonts.playfairDisplay(
                fontSize: 18.sp, fontWeight: FontWeight.bold, color: _dark)),
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationsLoaded && state.notifications.isNotEmpty) {
                return TextButton(
                  onPressed: () => context.read<NotificationBloc>()
                      .add(const MarkAllNotificationsRead()),
                  child: Text('Mark all read',
                      style: GoogleFonts.dmSans(
                          fontSize: 12.sp, color: _terracotta,
                          fontWeight: FontWeight.w600)),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationsLoaded && state.notifications.isNotEmpty) {
                return IconButton(
                  icon: Icon(Icons.delete_sweep_outlined, size: 20.sp, color: Colors.grey[500]),
                  tooltip: 'Clear all',
                  onPressed: () => _confirmClearAll(context),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none_rounded,
                      size: 64.sp, color: Colors.grey[300]),
                  SizedBox(height: 16.h),
                  Text('No notifications yet',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 18.sp, color: Colors.grey[400])),
                  SizedBox(height: 8.h),
                  Text('You\'re all caught up!',
                      style: GoogleFonts.dmSans(
                          fontSize: 13.sp, color: Colors.grey[400])),
                ],
              ));
            }

            return RefreshIndicator(
              color: _terracotta,
              onRefresh: () async =>
                  context.read<NotificationBloc>().add(const LoadNotifications()),
              child: ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                itemCount: state.notifications.length,
                separatorBuilder: (_, __) => SizedBox(height: 8.h),
                itemBuilder: (context, i) =>
                    _NotificationCard(notification: state.notifications[i]),
              ),
            );
          }

          if (state is NotificationError) {
            return Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off_rounded, size: 48.sp, color: Colors.grey[300]),
                SizedBox(height: 12.h),
                Text('Could not load notifications',
                    style: GoogleFonts.dmSans(color: Colors.grey[500])),
                SizedBox(height: 12.h),
                ElevatedButton(
                  onPressed: () => context.read<NotificationBloc>()
                      .add(const LoadNotifications()),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _terracotta, elevation: 0),
                  child: Text('Retry', style: GoogleFonts.dmSans(color: Colors.white)),
                ),
              ],
            ));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Clear All?',
            style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
        content: Text('All notifications will be deleted.',
            style: GoogleFonts.dmSans(color: Colors.grey[600])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.dmSans(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<NotificationBloc>().add(const ClearAllNotifications());
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700], elevation: 0),
            child: Text('Clear All',
                style: GoogleFonts.dmSans(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}


class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  const _NotificationCard({required this.notification});

  static const _dark       = Color(0xFF2D1B10);
  static const _terracotta = Color(0xFFCD6E4E);

  @override
  Widget build(BuildContext context) {
    final info = _typeInfo(notification.type);

    return Dismissible(
      key: Key('notif_${notification.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Icon(Icons.delete_outline_rounded, color: Colors.red[700], size: 22.sp),
      ),
      onDismissed: (_) => context.read<NotificationBloc>()
          .add(DeleteNotification(notification.id)),
      child: GestureDetector(
        onTap: () {
          if (!notification.isRead) {
            context.read<NotificationBloc>()
                .add(MarkNotificationRead(notification.id));
          }
        },
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white : info.tint,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: notification.isRead
                  ? Colors.grey.shade200
                  : info.color.withValues(alpha: 0.25),
            ),
            boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6, offset: const Offset(0, 2),
            )],
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Icon
            Container(
              width: 42.w, height: 42.h,
              decoration: BoxDecoration(
                color: info.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(info.icon, size: 20.sp, color: info.color),
            ),

            SizedBox(width: 12.w),

            // Content
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(notification.title,
                    style: GoogleFonts.dmSans(
                        fontSize: 13.sp,
                        fontWeight: notification.isRead
                            ? FontWeight.w500 : FontWeight.w700,
                        color: _dark))),
                if (!notification.isRead)
                  Container(
                    width: 8.w, height: 8.h,
                    decoration: BoxDecoration(
                        color: _terracotta, shape: BoxShape.circle),
                  ),
              ]),
              SizedBox(height: 4.h),
              Text(notification.message,
                  style: GoogleFonts.dmSans(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                      height: 1.4)),
              SizedBox(height: 6.h),
              Text(_timeAgo(notification.createdAt),
                  style: GoogleFonts.dmSans(
                      fontSize: 11.sp, color: Colors.grey[400])),
            ])),
          ]),
        ),
      ),
    );
  }

  ({IconData icon, Color color, Color tint}) _typeInfo(String type) {
    return switch (type) {
      'booking_created'   => (
      icon:  Icons.calendar_month_outlined,
      color: const Color(0xFF2C3A4A),
      tint:  const Color(0xFFF0F4F8),
      ),
      'booking_confirmed' => (
      icon:  Icons.check_circle_outline_rounded,
      color: const Color(0xFF3D5A4F),
      tint:  const Color(0xFFF0F7F4),
      ),
      'booking_rejected'  => (
      icon:  Icons.cancel_outlined,
      color: Colors.red.shade700,
      tint:  Colors.red.shade50,
      ),
      'booking_completed' => (
      icon:  Icons.done_all_rounded,
      color: const Color(0xFF8B7355),
      tint:  const Color(0xFFFAF7F2),
      ),
      'payment_received'  => (
      icon:  Icons.payments_outlined,
      color: const Color(0xFF5C35AA),
      tint:  const Color(0xFFF5F0FF),
      ),
      'booking_cancelled' => (
      icon:  Icons.event_busy_outlined,
      color: Colors.orange.shade700,
      tint:  Colors.orange.shade50,
      ),
      _ => (
      icon:  Icons.notifications_outlined,
      color: const Color(0xFFCD6E4E),
      tint:  const Color(0xFFFDF3EE),
      ),
    };
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1)  return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours   < 24) return '${diff.inHours}h ago';
    if (diff.inDays    < 7)  return '${diff.inDays}d ago';
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[dt.month - 1]} ${dt.day}';
  }
}

class BellButton extends StatelessWidget {
  const BellButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        final unread = state is NotificationsLoaded ? state.unreadCount : 0;

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BlocProvider.value(
              value: context.read<NotificationBloc>(),
              child: const NotificationsPage(),
            )),
          ),
          child: Stack(clipBehavior: Clip.none, children: [
            Container(
              width: 40.w, height: 40.h,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Icon(
                unread > 0
                    ? Icons.notifications_rounded
                    : Icons.notifications_none_rounded,
                size: 20.sp,
                color: unread > 0
                    ? const Color(0xFFCD6E4E)
                    : Colors.grey[500],
              ),
            ),
            if (unread > 0)
              Positioned(
                top: -2, right: -2,
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: const BoxDecoration(
                    color: Color(0xFFCD6E4E),
                    shape: BoxShape.circle,
                  ),
                  constraints: BoxConstraints(minWidth: 18.w, minHeight: 18.h),
                  child: Text(
                    unread > 99 ? '99+' : '$unread',
                    style: GoogleFonts.dmSans(
                        fontSize: 9.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ]),
        );
      },
    );
  }
}