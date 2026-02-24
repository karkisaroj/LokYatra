// lib/presentation/screens/TouristScreen/TouristBookingsPage.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../state_management/Bloc/booking/booking_bloc.dart';
import '../../state_management/Bloc/booking/booking_event.dart';
import '../../state_management/Bloc/booking/booking_state.dart';

class TouristBookingsPage extends StatefulWidget {
  const TouristBookingsPage({super.key});

  @override
  State<TouristBookingsPage> createState() => _TouristBookingsPageState();
}

class _TouristBookingsPageState extends State<TouristBookingsPage> {
  static const _dark       = Color(0xFF2D1B10);
  static const _cream      = Color(0xFFFAF7F2);
  static const _terracotta = Color(0xFFCD6E4E);

  int _selectedTab = 0; // 0=Upcoming, 1=Completed, 2=Cancelled

  @override
  void initState() {
    super.initState();
    context.read<BookingBloc>().add(const LoadMyBookings());
  }

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
        title: Text('My Bookings',
            style: GoogleFonts.playfairDisplay(
                fontSize: 20.sp, fontWeight: FontWeight.bold, color: _dark)),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
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
            return _ErrorView(onRetry: () =>
                context.read<BookingBloc>().add(const LoadMyBookings()));
          }
          if (state is MyBookingsLoaded) {
            final upcoming  = state.bookings.where((b) {
              final s = _status(b);
              return s == 'Pending' || s == 'Confirmed';
            }).toList();
            final completed = state.bookings.where((b) => _status(b) == 'Completed').toList();
            final cancelled = state.bookings.where((b) {
              final s = _status(b);
              return s == 'Cancelled' || s == 'Rejected';
            }).toList();

            final lists = [upcoming, completed, cancelled];
            final labels = ['Upcoming', 'Completed', 'Cancelled'];
            final counts = [upcoming.length, completed.length, cancelled.length];

            return Column(children: [
              // ── Custom tab bar ─────────────────────────────────────────────
              Container(
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  padding: EdgeInsets.all(4.w),
                  child: Row(
                    children: List.generate(3, (i) => Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          decoration: BoxDecoration(
                            color: _selectedTab == i
                                ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10.r),
                            boxShadow: _selectedTab == i
                                ? [BoxShadow(color: Colors.black.withOpacity(0.06),
                                blurRadius: 6, offset: const Offset(0, 2))]
                                : [],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(labels[i],
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13.sp,
                                    fontWeight: _selectedTab == i
                                        ? FontWeight.bold : FontWeight.normal,
                                    color: _selectedTab == i ? _dark : Colors.grey[500],
                                  )),
                              if (counts[i] > 0) ...[
                                SizedBox(width: 5.w),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: _selectedTab == i
                                        ? _terracotta : Colors.grey[400],
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Text('${counts[i]}',
                                      style: GoogleFonts.dmSans(
                                          fontSize: 10.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    )),
                  ),
                ),
              ),

              // ── List ──────────────────────────────────────────────────────
              Expanded(
                child: RefreshIndicator(
                  color: _terracotta,
                  onRefresh: () async =>
                      context.read<BookingBloc>().add(const LoadMyBookings()),
                  child: lists[_selectedTab].isEmpty
                      ? _EmptyState(tab: _selectedTab)
                      : ListView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
                    itemCount: lists[_selectedTab].length,
                    itemBuilder: (_, i) =>
                        _BookingCard(data: lists[_selectedTab][i]),
                  ),
                ),
              ),
            ]);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  String _status(Map<String, dynamic> b) =>
      (b['booking']?['status'] ?? '').toString();
}

// ── Main booking card (matches design image 2) ────────────────────────────────

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _BookingCard({required this.data});

  static const _dark       = Color(0xFF2D1B10);
  static const _terracotta = Color(0xFFCD6E4E);

  @override
  Widget build(BuildContext context) {
    final b            = (data['booking'] as Map<String, dynamic>?) ?? {};
    final id           = b['id'] as int? ?? 0;
    final homestayName = data['homestayName']?.toString() ?? 'Homestay';
    final location     = data['homestayLocation']?.toString() ?? '';
    final imageUrl     = data['homestayImage']?.toString() ?? '';
    final status       = b['status']?.toString() ?? 'Pending';
    final checkIn      = _fmtDate(b['checkIn']);
    final checkOut     = _fmtDate(b['checkOut']);
    final nights       = b['nights'] as int? ?? 0;
    final guests       = b['guests'] as int? ?? 0;
    final total        = (b['totalPrice'] as num?)?.toDouble() ?? 0;
    final payMethod    = b['paymentMethod']?.toString() ?? '';
    final specialReq   = b['specialRequests']?.toString() ?? '';
    final rejReason    = b['rejectionReason']?.toString() ?? '';
    final canCancel    = status == 'Pending' || status == 'Confirmed';

    // Generate a booking reference like LY-20251204-001
    final bookingRef = 'LY-${DateTime.now().year}${id.toString().padLeft(6, '0')}';

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14, offset: const Offset(0, 6))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Photo header with status badge + booking ref ───────────────────
        ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          child: Stack(children: [
            // Homestay image
            SizedBox(
              width: double.infinity,
              height: 170.h,
              child: imageUrl.isNotEmpty
                  ? Image.network(imageUrl, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallbackImage())
                  : _fallbackImage(),
            ),
            // Gradient overlay
            Container(
              width: double.infinity,
              height: 170.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.65),
                  ],
                ),
              ),
            ),
            // Status badge (top right)
            Positioned(
              top: 14.h, right: 14.w,
              child: _StatusPill(status: status),
            ),
            // Booking ref (bottom left)
            Positioned(
              bottom: 14.h, left: 14.w,
              child: Text(bookingRef,
                  style: GoogleFonts.dmSans(fontSize: 12.sp,
                      color: Colors.white70, letterSpacing: 0.5)),
            ),
          ]),
        ),

        Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Homestay name + location
            Text(homestayName,
                style: GoogleFonts.playfairDisplay(fontSize: 18.sp,
                    fontWeight: FontWeight.bold, color: _dark)),
            SizedBox(height: 4.h),
            if (location.isNotEmpty)
              Row(children: [
                Icon(Icons.location_on_outlined, size: 13.sp, color: Colors.grey[500]),
                SizedBox(width: 3.w),
                Text(location,
                    style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.grey[500])),
              ]),

            SizedBox(height: 14.h),

            // Check-in / Check-out
            Row(children: [
              Expanded(child: _DateBox(
                  icon: Icons.login_rounded, label: 'Check-in', value: checkIn)),
              SizedBox(width: 10.w),
              Expanded(child: _DateBox(
                  icon: Icons.logout_rounded, label: 'Check-out', value: checkOut)),
            ]),

            SizedBox(height: 12.h),

            // Nights + guests
            Row(children: [
              Icon(Icons.schedule_outlined, size: 15.sp, color: Colors.grey[500]),
              SizedBox(width: 5.w),
              Text('$nights night${nights != 1 ? 's' : ''}',
                  style: GoogleFonts.dmSans(fontSize: 13.sp, color: Colors.grey[600])),
              SizedBox(width: 16.w),
              Icon(Icons.people_outline_rounded, size: 15.sp, color: Colors.grey[500]),
              SizedBox(width: 5.w),
              Text('$guests guest${guests != 1 ? 's' : ''}',
                  style: GoogleFonts.dmSans(fontSize: 13.sp, color: Colors.grey[600])),
            ]),

            SizedBox(height: 14.h),

            // Total amount + payment
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF7F2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Amount',
                        style: GoogleFonts.dmSans(
                            fontSize: 13.sp, color: Colors.grey[600])),
                    Text('Rs. ${total.toStringAsFixed(0)}',
                        style: GoogleFonts.dmSans(fontSize: 18.sp,
                            color: _terracotta, fontWeight: FontWeight.w800)),
                  ],
                ),
                SizedBox(height: 6.h),
                Row(children: [
                  Icon(Icons.check_circle_rounded,
                      size: 13.sp,
                      color: payMethod == 'Khalti'
                          ? Colors.purple[700] : Colors.green[700]),
                  SizedBox(width: 5.w),
                  Text(payMethod == 'Khalti' ? 'Paid via Khalti' : 'Pay at Arrival',
                      style: GoogleFonts.dmSans(fontSize: 12.sp,
                          color: payMethod == 'Khalti'
                              ? Colors.purple[700] : Colors.green[700],
                          fontWeight: FontWeight.w500)),
                ]),
              ]),
            ),

            // Special requests
            if (specialReq.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.sticky_note_2_outlined,
                      size: 14.sp, color: Colors.amber[700]),
                  SizedBox(width: 8.w),
                  Expanded(child: Text(specialReq,
                      style: GoogleFonts.dmSans(
                          fontSize: 12.sp, color: Colors.amber[900]))),
                ]),
              ),
            ],

            // Rejection reason
            if ((status == 'Rejected' || status == 'Cancelled')
                && rejReason.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.info_outline_rounded,
                      size: 14.sp, color: Colors.red[700]),
                  SizedBox(width: 8.w),
                  Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Reason:', style: GoogleFonts.dmSans(
                        fontSize: 11.sp, fontWeight: FontWeight.bold,
                        color: Colors.red[800])),
                    Text(rejReason, style: GoogleFonts.dmSans(
                        fontSize: 12.sp, color: Colors.red[700])),
                  ])),
                ]),
              ),
            ],

            // Cancel button
            if (canCancel) ...[
              SizedBox(height: 14.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _showCancelDialog(context,
                      b['id'] as int? ?? 0),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red.shade300),
                    foregroundColor: Colors.red[600],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text('Cancel Booking',
                      style: GoogleFonts.dmSans(fontSize: 13.sp,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ]),
        ),
      ]),
    );
  }

  Widget _fallbackImage() => Container(
    color: Colors.grey.shade200,
    child: Center(child: Icon(Icons.hotel_outlined,
        size: 48.sp, color: Colors.grey[400])),
  );

  void _showCancelDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Cancel Booking',
            style: GoogleFonts.playfairDisplay(
                fontSize: 18.sp, fontWeight: FontWeight.bold)),
        content: Text('Are you sure? This cannot be undone.',
            style: GoogleFonts.dmSans(fontSize: 13.sp, color: Colors.grey[600])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Keep it',
                style: GoogleFonts.dmSans(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<BookingBloc>().add(CancelMyBooking(id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r)),
            ),
            child: Text('Yes, Cancel',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  String _fmtDate(dynamic raw) {
    if (raw == null) return '—';
    try {
      final d = DateTime.parse(raw.toString());
      const m = ['Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${m[d.month - 1]} ${d.day}, ${d.year}';
    } catch (_) { return raw.toString(); }
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, text) = switch (status) {
      'Pending'   => (Colors.orange,       'Pending'),
      'Confirmed' => (Colors.green[600]!,  'Confirmed'),
      'Rejected'  => (Colors.red[600]!,    'Rejected'),
      'Completed' => (Colors.blue[600]!,   'Completed'),
      'Cancelled' => (Colors.grey[600]!,   'Cancelled'),
      _           => (Colors.grey[600]!,   status),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(text,
          style: GoogleFonts.dmSans(fontSize: 12.sp,
              fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }
}

class _DateBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DateBox({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
    decoration: BoxDecoration(
      color: const Color(0xFFFAF7F2),
      borderRadius: BorderRadius.circular(10.r),
    ),
    child: Row(children: [
      Icon(icon, size: 15.sp, color: const Color(0xFFCD6E4E)),
      SizedBox(width: 6.w),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: GoogleFonts.dmSans(fontSize: 10.sp, color: Colors.grey[500])),
        Text(value,
            style: GoogleFonts.dmSans(fontSize: 13.sp,
                fontWeight: FontWeight.bold, color: const Color(0xFF2D1B10))),
      ])),
    ]),
  );
}

class _EmptyState extends StatelessWidget {
  final int tab;
  const _EmptyState({required this.tab});

  @override
  Widget build(BuildContext context) {
    final msgs = [
      ('No upcoming bookings', 'Browse homestays and make a booking!',
      Icons.calendar_today_outlined),
      ('No completed stays', 'Your completed trips will appear here.',
      Icons.done_all_rounded),
      ('No cancelled bookings', 'All clear — nothing was cancelled.',
      Icons.cancel_outlined),
    ];
    final (title, sub, icon) = msgs[tab];
    return ListView(children: [
      SizedBox(height: 80.h),
      Column(children: [
        Icon(icon, size: 64.sp, color: Colors.grey[300]),
        SizedBox(height: 16.h),
        Text(title, style: GoogleFonts.playfairDisplay(
            fontSize: 18.sp, fontWeight: FontWeight.bold,
            color: const Color(0xFF2D1B10))),
        SizedBox(height: 8.h),
        Text(sub, textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(fontSize: 13.sp, color: Colors.grey[500])),
      ]),
    ]);
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.wifi_off_rounded, size: 48.sp, color: Colors.grey[300]),
      SizedBox(height: 12.h),
      Text('Could not load bookings',
          style: GoogleFonts.dmSans(fontSize: 14.sp, color: Colors.grey[500])),
      SizedBox(height: 16.h),
      ElevatedButton(
        onPressed: onRetry,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFCD6E4E),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        ),
        child: Text('Retry',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
      ),
    ]),
  );
}