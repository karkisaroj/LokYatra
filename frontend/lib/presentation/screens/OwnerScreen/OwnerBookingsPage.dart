import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../state_management/Bloc/booking/booking_bloc.dart';
import '../../state_management/Bloc/booking/booking_event.dart';
import '../../state_management/Bloc/booking/booking_state.dart';

class OwnerBookingsPage extends StatefulWidget {
  const OwnerBookingsPage({super.key});

  @override
  State<OwnerBookingsPage> createState() => _OwnerBookingsPageState();
}

class _OwnerBookingsPageState extends State<OwnerBookingsPage>
    with SingleTickerProviderStateMixin {
  static const _dark       = Color(0xFF2D1B10);
  static const _cream      = Color(0xFFFAF7F2);
  static const _brown      = Color(0xFF5C4033);
  static const _terracotta = Color(0xFFCD6E4E);

  late final TabController _tabController;
  final _tabs = const ['Pending', 'Confirmed', 'Rejected', 'All'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    context.read<BookingBloc>().add(const LoadOwnerBookings());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Bookings',
            style: GoogleFonts.playfairDisplay(
                fontSize: 20.sp, fontWeight: FontWeight.bold, color: _dark)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: _brown, size: 22.sp),
            onPressed: () =>
                context.read<BookingBloc>().add(const LoadOwnerBookings()),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: _brown,
          unselectedLabelColor: Colors.grey[500],
          indicatorColor: _brown,
          indicatorWeight: 2.5,
          labelStyle: GoogleFonts.dmSans(fontSize: 13.sp, fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 13.sp),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message, style: GoogleFonts.dmSans()),
              backgroundColor: Colors.green[700],
              behavior: SnackBarBehavior.floating,
            ));
          }
          if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message, style: GoogleFonts.dmSans()),
              backgroundColor: Colors.red[700],
              behavior: SnackBarBehavior.floating,
            ));
          }
        },
        builder: (context, state) {
          if (state is BookingLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BookingError) {
            return _ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<BookingBloc>().add(const LoadOwnerBookings()),
            );
          }
          if (state is OwnerBookingsLoaded) {
            String getStatus(Map<String, dynamic> b) =>
                (b['booking']?['status'] ?? '').toString();
            return TabBarView(
              controller: _tabController,
              children: [
                _BookingList(
                  bookings: state.bookings.where((b) => getStatus(b) == 'Pending').toList(),
                  emptyMessage: 'No pending bookings',
                  emptyIcon: Icons.hourglass_empty_rounded,
                ),
                _BookingList(
                  bookings: state.bookings.where((b) => getStatus(b) == 'Confirmed').toList(),
                  emptyMessage: 'No confirmed bookings',
                  emptyIcon: Icons.check_circle_outline_rounded,
                ),
                _BookingList(
                  bookings: state.bookings.where((b) => getStatus(b) == 'Rejected').toList(),
                  emptyMessage: 'No rejected bookings',
                  emptyIcon: Icons.cancel_outlined,
                ),
                _BookingList(
                  bookings: state.bookings,
                  emptyMessage: 'No bookings yet',
                  emptyIcon: Icons.calendar_today_outlined,
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ── Booking list with pull-to-refresh ────────────────────────────────────────

class _BookingList extends StatelessWidget {
  final List<Map<String, dynamic>> bookings;
  final String emptyMessage;
  final IconData emptyIcon;
  const _BookingList({
    required this.bookings,
    required this.emptyMessage,
    required this.emptyIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(emptyIcon, size: 56.sp, color: Colors.grey[300]),
          SizedBox(height: 14.h),
          Text(emptyMessage,
              style: GoogleFonts.dmSans(fontSize: 15.sp, color: Colors.grey[400])),
        ]),
      );
    }
    return RefreshIndicator(
      onRefresh: () async =>
          context.read<BookingBloc>().add(const LoadOwnerBookings()),
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: bookings.length,
        itemBuilder: (_, i) => _OwnerBookingCard(data: bookings[i]),
      ),
    );
  }
}

// ── Individual booking card ───────────────────────────────────────────────────

class _OwnerBookingCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _OwnerBookingCard({required this.data});

  static const _dark       = Color(0xFF2D1B10);
  static const _brown      = Color(0xFF5C4033);
  static const _terracotta = Color(0xFFCD6E4E);

  @override
  Widget build(BuildContext context) {
    final b            = (data['booking'] as Map<String, dynamic>?) ?? {};
    final id           = b['id'] as int? ?? 0;
    final touristName  = data['touristName']?.toString() ?? 'Guest';
    final touristPhone = data['touristPhone']?.toString() ?? '';
    final homestayName = data['homestayName']?.toString() ?? '';
    final status       = b['status']?.toString() ?? 'Pending';
    final checkIn      = _fmtDate(b['checkIn']);
    final checkOut     = _fmtDate(b['checkOut']);
    final nights       = b['nights'] as int? ?? 0;
    final rooms        = b['rooms'] as int? ?? 0;
    final guests       = b['guests'] as int? ?? 0;
    final total        = (b['totalPrice'] as num?)?.toDouble() ?? 0;
    final payMethod    = b['paymentMethod']?.toString() ?? '';
    final specialReq   = b['specialRequests']?.toString() ?? '';
    final rejReason    = b['rejectionReason']?.toString() ?? '';
    final isPending    = status == 'Pending';
    final isConfirmed  = status == 'Confirmed';

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _borderColor(status), width: isPending ? 1.5 : 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
            blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Card header ──────────────────────────────────────────────
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: _bgColor(status),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          ),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(homestayName,
                  style: GoogleFonts.dmSans(fontSize: 11.sp, color: Colors.grey[600])),
              Text('Booking #$id',
                  style: GoogleFonts.dmSans(fontSize: 14.sp,
                      fontWeight: FontWeight.bold, color: _dark)),
            ])),
            _StatusBadge(status: status),
          ]),
        ),

        Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Tourist info row
            Row(children: [
              CircleAvatar(
                radius: 18.r,
                backgroundColor: const Color(0xFFE8DCCD),
                child: Text(
                  touristName.isNotEmpty ? touristName[0].toUpperCase() : 'G',
                  style: GoogleFonts.dmSans(fontSize: 14.sp,
                      fontWeight: FontWeight.bold, color: _dark),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(touristName,
                    style: GoogleFonts.dmSans(fontSize: 14.sp,
                        fontWeight: FontWeight.bold, color: _dark)),
                if (touristPhone.isNotEmpty)
                  Row(children: [
                    Icon(Icons.phone_outlined, size: 12.sp, color: Colors.grey[500]),
                    SizedBox(width: 4.w),
                    Text(touristPhone,
                        style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.grey[500])),
                  ]),
              ])),
            ]),

            SizedBox(height: 14.h),
            Divider(color: Colors.grey.shade100),
            SizedBox(height: 12.h),

            // Check-in / check-out
            Row(children: [
              Expanded(child: _InfoTile(
                  icon: Icons.login_rounded, label: 'Check-in', value: checkIn)),
              SizedBox(width: 10.w),
              Expanded(child: _InfoTile(
                  icon: Icons.logout_rounded, label: 'Check-out', value: checkOut)),
            ]),
            SizedBox(height: 10.h),

            // Nights / rooms / guests chips
            Wrap(spacing: 8.w, children: [
              _ChipInfo('$nights night${nights != 1 ? 's' : ''}',
                  Icons.nights_stay_outlined),
              _ChipInfo('$rooms room${rooms != 1 ? 's' : ''}',
                  Icons.king_bed_outlined),
              _ChipInfo('$guests guest${guests != 1 ? 's' : ''}',
                  Icons.people_outline_rounded),
            ]),

            SizedBox(height: 12.h),

            // Price + payment method
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF7F2),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Total Amount',
                        style: GoogleFonts.dmSans(fontSize: 11.sp, color: Colors.grey[500])),
                    Text('Rs. ${total.toStringAsFixed(0)}',
                        style: GoogleFonts.dmSans(fontSize: 18.sp,
                            color: _terracotta, fontWeight: FontWeight.w800)),
                  ]),
                  _PayMethodBadge(payMethod: payMethod),
                ],
              ),
            ),

            // Special requests
            if (specialReq.isNotEmpty) ...[
              SizedBox(height: 10.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.sticky_note_2_outlined, size: 14.sp, color: Colors.amber[700]),
                  SizedBox(width: 6.w),
                  Expanded(child: Text(specialReq,
                      style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.amber[900]))),
                ]),
              ),
            ],

            // Rejection reason
            if (status == 'Rejected' && rejReason.isNotEmpty) ...[
              SizedBox(height: 10.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.cancel_outlined, size: 14.sp, color: Colors.red[700]),
                  SizedBox(width: 6.w),
                  Expanded(child: Text('Reason: $rejReason',
                      style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.red[800]))),
                ]),
              ),
            ],

            // ── Action buttons ─────────────────────────────────────
            if (isPending) ...[
              SizedBox(height: 16.h),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showRejectDialog(context, id),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text('Reject',
                        style: GoogleFonts.dmSans(fontSize: 14.sp,
                            color: Colors.red, fontWeight: FontWeight.w600)),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context
                        .read<BookingBloc>()
                        .add(UpdateBookingStatus(id, 'Confirmed')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text('Confirm',
                        style: GoogleFonts.dmSans(fontSize: 14.sp,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ]),
            ],

            if (isConfirmed) ...[
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: Icon(Icons.done_all_rounded, size: 16.sp),
                  label: Text('Mark as Completed',
                      style: GoogleFonts.dmSans(fontSize: 13.sp,
                          fontWeight: FontWeight.w600)),
                  onPressed: () => context
                      .read<BookingBloc>()
                      .add(UpdateBookingStatus(id, 'Completed')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _brown,
                    side: BorderSide(color: _brown),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                ),
              ),
            ],
          ]),
        ),
      ]),
    );
  }

  void _showRejectDialog(BuildContext context, int bookingId) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Reject Booking',
            style: GoogleFonts.playfairDisplay(
                fontSize: 18.sp, fontWeight: FontWeight.bold)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Provide a reason for the tourist (optional).',
              style: GoogleFonts.dmSans(fontSize: 13.sp, color: Colors.grey[600])),
          SizedBox(height: 12.h),
          TextField(
            controller: ctrl,
            maxLines: 3,
            style: GoogleFonts.dmSans(fontSize: 13.sp),
            decoration: InputDecoration(
              hintText: 'e.g. Dates unavailable, maintenance...',
              hintStyle: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.grey[400]),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
              contentPadding: EdgeInsets.all(12.w),
            ),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.dmSans(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<BookingBloc>().add(
                UpdateBookingStatus(bookingId, 'Rejected',
                    rejectionReason: ctrl.text.trim()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            child: Text('Reject',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Color _borderColor(String s) {
    switch (s) {
      case 'Pending':   return const Color(0xFFCD6E4E).withOpacity(0.3);
      case 'Confirmed': return Colors.green.shade200;
      case 'Rejected':  return Colors.red.shade200;
      case 'Completed': return Colors.blue.shade200;
      default:          return Colors.grey.shade200;
    }
  }

  Color _bgColor(String s) {
    switch (s) {
      case 'Pending':   return const Color(0xFFFFF8F5);
      case 'Confirmed': return Colors.green.shade50;
      case 'Rejected':  return Colors.red.shade50;
      case 'Completed': return Colors.blue.shade50;
      default:          return Colors.grey.shade50;
    }
  }

  String _fmtDate(dynamic raw) {
    if (raw == null) return '—';
    try {
      final d = DateTime.parse(raw.toString());
      const m = ['Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${d.day} ${m[d.month - 1]} ${d.year}';
    } catch (_) { return raw.toString(); }
  }
}

// ── Small reusable widgets ────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (status) {
      'Pending'   => (const Color(0xFFCD6E4E), Icons.hourglass_top_rounded),
      'Confirmed' => (Colors.green[700]!, Icons.check_circle_rounded),
      'Rejected'  => (Colors.red[700]!, Icons.cancel_rounded),
      'Completed' => (Colors.blue[700]!, Icons.done_all_rounded),
      _           => (Colors.grey, Icons.help_outline),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12.sp, color: color),
        SizedBox(width: 4.w),
        Text(status,
            style: GoogleFonts.dmSans(fontSize: 12.sp,
                fontWeight: FontWeight.bold, color: color)),
      ]),
    );
  }
}

class _PayMethodBadge extends StatelessWidget {
  final String payMethod;
  const _PayMethodBadge({required this.payMethod});

  @override
  Widget build(BuildContext context) {
    final isKhalti = payMethod == 'Khalti';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: isKhalti ? Colors.purple.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(children: [
        Icon(
          isKhalti ? Icons.account_balance_wallet_outlined : Icons.payments_outlined,
          size: 13.sp,
          color: isKhalti ? Colors.purple[700] : Colors.green[700],
        ),
        SizedBox(width: 4.w),
        Text(
          isKhalti ? 'Khalti' : 'Pay at Arrival',
          style: GoogleFonts.dmSans(fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: isKhalti ? Colors.purple[700] : Colors.green[700]),
        ),
      ]),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
    decoration: BoxDecoration(
      color: const Color(0xFFFAF7F2),
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Row(children: [
      Icon(icon, size: 14.sp, color: Colors.grey[500]),
      SizedBox(width: 6.w),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: GoogleFonts.dmSans(fontSize: 10.sp, color: Colors.grey[500])),
        Text(value,
            style: GoogleFonts.dmSans(fontSize: 12.sp,
                fontWeight: FontWeight.w600, color: const Color(0xFF2D1B10))),
      ])),
    ]),
  );
}

class _ChipInfo extends StatelessWidget {
  final String label;
  final IconData icon;
  const _ChipInfo(this.label, this.icon);

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12.sp, color: Colors.grey[600]),
      SizedBox(width: 4.w),
      Text(label,
          style: GoogleFonts.dmSans(fontSize: 11.sp, color: Colors.grey[700])),
    ]),
  );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.wifi_off_rounded, size: 48.sp, color: Colors.grey[300]),
        SizedBox(height: 12.h),
        Text(message, textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(fontSize: 14.sp, color: Colors.grey[500])),
        SizedBox(height: 16.h),
        ElevatedButton(
          onPressed: onRetry,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5C4033),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
          child: Text('Retry',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
        ),
      ]),
    ),
  );
}