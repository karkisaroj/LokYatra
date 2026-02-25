// lib/presentation/screens/OwnerScreen/OwnerBookingsPage.dart

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

// This state owns the BookingBloc and provides it to the view below.
// By owning the bloc here we avoid depending on any parent BlocProvider,
// which eliminates all IndexedStack / FocusScope context timing crashes.
class _OwnerBookingsPageState extends State<OwnerBookingsPage> {
  late final BookingBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = BookingBloc()..add(const LoadOwnerBookings());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: const _OwnerBookingsView(),
    );
  }
}

// All the actual UI lives here — it can safely use context.read<BookingBloc>()
// because BlocProvider.value is always directly above it.
class _OwnerBookingsView extends StatefulWidget {
  const _OwnerBookingsView();

  @override
  State<_OwnerBookingsView> createState() => _OwnerBookingsViewState();
}

class _OwnerBookingsViewState extends State<_OwnerBookingsView> {
  static const _terracotta = Color(0xFFCD6E4E);
  static const _dark       = Color(0xFF2D1B10);
  static const _cream      = Color(0xFFFAF7F2);

  int _selectedTab = 0;
  OwnerRevenueLoaded? _revenue;
  List<Map<String, dynamic>> _bookings = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Bookings',
            style: GoogleFonts.playfairDisplay(
                fontSize: 20.sp, fontWeight: FontWeight.bold, color: _dark)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is OwnerBookingsLoaded) {
            setState(() => _bookings = state.bookings);
          }
          if (state is OwnerRevenueLoaded) {
            setState(() => _revenue = state);
          }
          if (state is BookingActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message, style: GoogleFonts.dmSans()),
              backgroundColor: Colors.green[700],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r)),
            ));
          }
          if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message, style: GoogleFonts.dmSans()),
              backgroundColor: Colors.red[700],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r)),
            ));
          }
        },
        builder: (context, state) {
          if (state is BookingLoading && _revenue == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // Always use cached _bookings — the current state may be
          // OwnerRevenueLoaded which would make the list appear empty.
          final bookings = _bookings;

          final pending   = bookings.where((b) => _st(b) == 'Pending').toList();
          final confirmed = bookings.where((b) => _st(b) == 'Confirmed').toList();
          final completed = bookings.where((b) => _st(b) == 'Completed').toList();

          final tabs = [
            ('Pending',   pending,   pending.length),
            ('Confirmed', confirmed, confirmed.length),
            ('Completed', completed, completed.length),
            ('All',       bookings,  bookings.length),
          ];

          return Column(children: [
            // ── Revenue summary card ───────────────────────────────────────
            if (_revenue != null)
              _RevenueCard(revenue: _revenue!),

            // ── Tab bar ────────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                padding: EdgeInsets.all(4.w),
                child: Row(
                  children: List.generate(4, (i) => Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        decoration: BoxDecoration(
                          color: _selectedTab == i
                              ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10.r),
                          boxShadow: _selectedTab == i
                              ? [BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 6, offset: const Offset(0, 2))]
                              : [],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(tabs[i].$1,
                                style: GoogleFonts.dmSans(
                                  fontSize: 11.sp,
                                  fontWeight: _selectedTab == i
                                      ? FontWeight.bold : FontWeight.normal,
                                  color: _selectedTab == i
                                      ? _dark : Colors.grey[500],
                                )),
                            if (tabs[i].$3 > 0) ...[
                              SizedBox(height: 2.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6.w, vertical: 1.h),
                                decoration: BoxDecoration(
                                  color: _selectedTab == i
                                      ? _terracotta : Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text('${tabs[i].$3}',
                                    style: GoogleFonts.dmSans(
                                        fontSize: 9.sp,
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

            // ── Booking list ───────────────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                color: _terracotta,
                onRefresh: () async =>
                    context.read<BookingBloc>().add(const LoadOwnerBookings()),
                child: tabs[_selectedTab].$2.isEmpty
                    ? _EmptyState(label: tabs[_selectedTab].$1)
                    : ListView.builder(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 32.h),
                  itemCount: tabs[_selectedTab].$2.length,
                  itemBuilder: (_, i) => _BookingCard(
                    data: tabs[_selectedTab].$2[i],
                    onConfirm: () => context.read<BookingBloc>().add(
                        UpdateBookingStatus(
                            tabs[_selectedTab].$2[i]['booking']['id'] as int,
                            'Confirmed')),
                    onReject: (reason) => context.read<BookingBloc>().add(
                        UpdateBookingStatus(
                            tabs[_selectedTab].$2[i]['booking']['id'] as int,
                            'Rejected',
                            rejectionReason: reason)),
                    onComplete: () => context.read<BookingBloc>().add(
                        UpdateBookingStatus(
                            tabs[_selectedTab].$2[i]['booking']['id'] as int,
                            'Completed')),
                    onMarkPaid: () => _confirmMarkPaid(
                        context,
                        tabs[_selectedTab].$2[i]['booking']['id'] as int,
                        tabs[_selectedTab].$2[i]['booking']['totalPrice'],
                        tabs[_selectedTab].$2[i]['booking']['paymentMethod']?.toString() ?? ''),
                  ),
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }

  String _st(Map<String, dynamic> b) =>
      (b['booking']?['status'] ?? '').toString();

  void _confirmMarkPaid(BuildContext ctx, int id, dynamic amount, String method) {
    final methodLabel = method == 'Khalti' ? 'Khalti' : 'Cash on Arrival';
    showDialog(
      context: ctx,
      builder: (dCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Confirm Payment Received',
            style: GoogleFonts.playfairDisplay(
                fontSize: 18.sp, fontWeight: FontWeight.bold)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(children: [
              Icon(Icons.payments_outlined, color: Colors.green[700], size: 32.sp),
              SizedBox(height: 8.h),
              Text('Rs. ${(amount as num?)?.toStringAsFixed(0) ?? '—'}',
                  style: GoogleFonts.dmSans(fontSize: 22.sp,
                      fontWeight: FontWeight.w800, color: Colors.green[800])),
              SizedBox(height: 4.h),
              Text('via $methodLabel',
                  style: GoogleFonts.dmSans(
                      fontSize: 13.sp, color: Colors.green[700])),
            ]),
          ),
          SizedBox(height: 12.h),
          Text('This will mark the payment as received and add it to your revenue.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                  fontSize: 13.sp, color: Colors.grey[600])),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: Text('Cancel',
                style: GoogleFonts.dmSans(color: Colors.grey[600])),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
            label: Text('Mark as Paid',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
            onPressed: () {
              Navigator.pop(dCtx);
              ctx.read<BookingBloc>().add(MarkPaymentReceived(id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Revenue summary card ──────────────────────────────────────────────────────

class _RevenueCard extends StatelessWidget {
  final OwnerRevenueLoaded revenue;
  const _RevenueCard({required this.revenue});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D1B10), Color(0xFF5C3D2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(
            color: const Color(0xFF2D1B10).withOpacity(0.3),
            blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Total Revenue',
              style: GoogleFonts.dmSans(
                  fontSize: 13.sp, color: Colors.white70)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(children: [
              Icon(Icons.check_circle_outline_rounded,
                  size: 12.sp, color: Colors.greenAccent),
              SizedBox(width: 4.w),
              Text('${revenue.paidBookings} paid',
                  style: GoogleFonts.dmSans(
                      fontSize: 11.sp, color: Colors.white70)),
            ]),
          ),
        ]),
        SizedBox(height: 6.h),
        Text('Rs. ${revenue.totalRevenue.toStringAsFixed(0)}',
            style: GoogleFonts.playfairDisplay(
                fontSize: 32.sp, fontWeight: FontWeight.bold,
                color: Colors.white)),

        SizedBox(height: 16.h),
        Row(children: [
          Expanded(child: _RevenuePill(
            label: 'Cash',
            amount: revenue.cashRevenue,
            icon: Icons.money_rounded,
            color: Colors.greenAccent,
          )),
          SizedBox(width: 10.w),
          Expanded(child: _RevenuePill(
            label: 'Khalti',
            amount: revenue.khaltiRevenue,
            icon: Icons.phone_android_rounded,
            color: Colors.purpleAccent,
          )),
          SizedBox(width: 10.w),
          Expanded(child: _RevenuePill(
            label: 'Pending',
            amount: revenue.pendingRevenue,
            icon: Icons.hourglass_bottom_rounded,
            color: Colors.amberAccent,
          )),
        ]),
      ]),
    );
  }
}

class _RevenuePill extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  const _RevenuePill(
      {required this.label, required this.amount,
        required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 12.sp, color: color),
        SizedBox(width: 4.w),
        Text(label, style: GoogleFonts.dmSans(
            fontSize: 10.sp, color: Colors.white60)),
      ]),
      SizedBox(height: 4.h),
      Text('Rs. ${amount.toStringAsFixed(0)}',
          style: GoogleFonts.dmSans(fontSize: 13.sp,
              fontWeight: FontWeight.bold, color: Colors.white)),
    ]),
  );
}

// ── Individual booking card ───────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onConfirm;
  final VoidCallback onComplete;
  final VoidCallback onMarkPaid;
  final void Function(String reason) onReject;

  const _BookingCard({
    required this.data,
    required this.onConfirm,
    required this.onComplete,
    required this.onMarkPaid,
    required this.onReject,
  });

  static const _dark       = Color(0xFF2D1B10);
  static const _terracotta = Color(0xFFCD6E4E);

  @override
  Widget build(BuildContext context) {
    final b             = (data['booking'] as Map<String, dynamic>?) ?? {};
    final status        = b['status']?.toString()        ?? 'Pending';
    final payStatus     = b['paymentStatus']?.toString() ?? 'Unpaid';
    final payMethod     = b['paymentMethod']?.toString() ?? '';
    final touristName   = data['touristName']?.toString()  ?? 'Tourist';
    final touristPhone  = data['touristPhone']?.toString() ?? '';
    final homestayName  = data['homestayName']?.toString() ?? 'Homestay';
    final checkIn       = _fmt(b['checkIn']);
    final checkOut      = _fmt(b['checkOut']);
    final nights        = b['nights']    as int?    ?? 0;
    final rooms         = b['rooms']     as int?    ?? 0;
    final guests        = b['guests']    as int?    ?? 0;
    final total         = (b['totalPrice'] as num?)?.toDouble() ?? 0;
    final specialReq    = b['specialRequests']?.toString() ?? '';
    final rejReason     = b['rejectionReason']?.toString() ?? '';
    final isPaid        = payStatus == 'Paid';
    final canMarkPaid   = (status == 'Confirmed' || status == 'Completed') && !isPaid;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
            blurRadius: 12, offset: const Offset(0, 5))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Header: homestay name + status badges ──────────────────────────
        Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
          ),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(homestayName,
                  style: GoogleFonts.playfairDisplay(fontSize: 16.sp,
                      fontWeight: FontWeight.bold, color: _dark)),
              SizedBox(height: 2.h),
              Text('${nights}n · ${rooms} room${rooms != 1 ? 's' : ''} · $guests guest${guests != 1 ? 's' : ''}',
                  style: GoogleFonts.dmSans(
                      fontSize: 11.sp, color: Colors.grey[500])),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              _StatusBadge(status),
              SizedBox(height: 4.h),
              _PaymentBadge(payStatus: payStatus, payMethod: payMethod),
            ]),
          ]),
        ),

        Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Tourist info
            Row(children: [
              Container(
                width: 38.w, height: 38.h,
                decoration: BoxDecoration(
                  color: _terracotta.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_rounded, size: 20.sp, color: _terracotta),
              ),
              SizedBox(width: 10.w),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(touristName,
                    style: GoogleFonts.dmSans(fontSize: 14.sp,
                        fontWeight: FontWeight.w600, color: _dark)),
                if (touristPhone.isNotEmpty)
                  Text(touristPhone,
                      style: GoogleFonts.dmSans(
                          fontSize: 12.sp, color: Colors.grey[500])),
              ])),
            ]),

            SizedBox(height: 12.h),

            // Dates
            Row(children: [
              Expanded(child: _DateTile(
                  label: 'Check-in', value: checkIn,
                  icon: Icons.login_rounded)),
              SizedBox(width: 8.w),
              Expanded(child: _DateTile(
                  label: 'Check-out', value: checkOut,
                  icon: Icons.logout_rounded)),
            ]),

            SizedBox(height: 12.h),

            // Total + payment method
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF7F2),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Total',
                        style: GoogleFonts.dmSans(
                            fontSize: 11.sp, color: Colors.grey[500])),
                    Text('Rs. ${total.toStringAsFixed(0)}',
                        style: GoogleFonts.dmSans(fontSize: 20.sp,
                            fontWeight: FontWeight.w800, color: _terracotta)),
                  ]),
                  // Payment method label
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: payMethod == 'Khalti'
                          ? Colors.purple.shade50 : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: payMethod == 'Khalti'
                            ? Colors.purple.shade200 : Colors.green.shade200,
                      ),
                    ),
                    child: Row(children: [
                      Icon(
                        payMethod == 'Khalti'
                            ? Icons.phone_android_rounded : Icons.money_rounded,
                        size: 13.sp,
                        color: payMethod == 'Khalti'
                            ? Colors.purple[700] : Colors.green[700],
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        payMethod == 'Khalti' ? 'Khalti' : 'Cash on Arrival',
                        style: GoogleFonts.dmSans(
                          fontSize: 11.sp, fontWeight: FontWeight.w600,
                          color: payMethod == 'Khalti'
                              ? Colors.purple[700] : Colors.green[700],
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),

            // Special requests
            if (specialReq.isNotEmpty) ...[
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.sticky_note_2_outlined,
                          size: 13.sp, color: Colors.amber[700]),
                      SizedBox(width: 6.w),
                      Expanded(child: Text(specialReq,
                          style: GoogleFonts.dmSans(
                              fontSize: 12.sp, color: Colors.amber[900]))),
                    ]),
              ),
            ],

            // Rejection reason
            if (rejReason.isNotEmpty) ...[
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.cancel_outlined,
                          size: 13.sp, color: Colors.red[700]),
                      SizedBox(width: 6.w),
                      Expanded(child: Text(rejReason,
                          style: GoogleFonts.dmSans(
                              fontSize: 12.sp, color: Colors.red[700]))),
                    ]),
              ),
            ],

            // ── Action buttons ─────────────────────────────────────────────
            SizedBox(height: 14.h),

            // Pending → Confirm / Reject
            if (status == 'Pending') ...[
              Row(children: [
                Expanded(child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text('Confirm',
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
                )),
                SizedBox(width: 10.w),
                Expanded(child: OutlinedButton(
                  onPressed: () => _showRejectDialog(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red.shade300),
                    foregroundColor: Colors.red[700],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text('Reject',
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
                )),
              ]),
            ],

            // Confirmed → Mark as Paid AND/OR Mark as Completed
            if (status == 'Confirmed') ...[
              Row(children: [
                if (canMarkPaid) ...[
                  Expanded(child: ElevatedButton.icon(
                    icon: Icon(Icons.payments_rounded, size: 16.sp),
                    label: Text('Mark as Paid',
                        style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
                    onPressed: onMarkPaid,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  )),
                  SizedBox(width: 10.w),
                ],
                Expanded(child: OutlinedButton(
                  onPressed: onComplete,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.blue.shade300),
                    foregroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text('Complete Stay',
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
                )),
              ]),
            ],

            // Completed + unpaid → still allow marking paid
            if (status == 'Completed' && canMarkPaid)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.payments_rounded, size: 16.sp),
                  label: Text('Mark as Paid',
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
                  onPressed: onMarkPaid,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                    padding: EdgeInsets.symmetric(vertical: 13.h),
                  ),
                ),
              ),

            // Paid confirmation pill
            if (isPaid)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.check_circle_rounded,
                      size: 16.sp, color: Colors.green[700]),
                  SizedBox(width: 6.w),
                  Text('Payment Received',
                      style: GoogleFonts.dmSans(fontSize: 13.sp,
                          fontWeight: FontWeight.w600, color: Colors.green[700])),
                ]),
              ),
          ]),
        ),
      ]),
    );
  }

  void _showRejectDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Reject Booking',
            style: GoogleFonts.playfairDisplay(
                fontSize: 18.sp, fontWeight: FontWeight.bold)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Provide a reason for the tourist:',
              style: GoogleFonts.dmSans(fontSize: 13.sp, color: Colors.grey[600])),
          SizedBox(height: 12.h),
          TextField(
            controller: ctrl,
            maxLines: 3,
            style: GoogleFonts.dmSans(fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: 'e.g. No availability on those dates...',
              hintStyle: GoogleFonts.dmSans(
                  fontSize: 13.sp, color: Colors.grey[400]),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r)),
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
              onReject(ctrl.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r)),
            ),
            child: Text('Reject',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  String _fmt(dynamic raw) {
    if (raw == null) return '—';
    try {
      final d = DateTime.parse(raw.toString());
      const m = ['Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${m[d.month - 1]} ${d.day}, ${d.year}';
    } catch (_) { return raw.toString(); }
  }
}

// ── Tiny shared widgets ───────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      'Pending'   => (Colors.orange.shade100,    Colors.orange.shade800),
      'Confirmed' => (Colors.green.shade100,     Colors.green.shade800),
      'Rejected'  => (Colors.red.shade100,       Colors.red.shade800),
      'Completed' => (Colors.blue.shade100,      Colors.blue.shade800),
      'Cancelled' => (Colors.grey.shade200,      Colors.grey.shade700),
      _           => (Colors.grey.shade200,      Colors.grey.shade700),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(color: bg,
          borderRadius: BorderRadius.circular(20.r)),
      child: Text(status,
          style: GoogleFonts.dmSans(fontSize: 11.sp,
              fontWeight: FontWeight.bold, color: fg)),
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  final String payStatus;
  final String payMethod;
  const _PaymentBadge({required this.payStatus, required this.payMethod});

  @override
  Widget build(BuildContext context) {
    final isPaid = payStatus == 'Paid';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: isPaid ? Colors.green.shade50 : Colors.amber.shade50,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
            color: isPaid ? Colors.green.shade300 : Colors.amber.shade300),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(
          isPaid ? Icons.check_circle_rounded : Icons.hourglass_empty_rounded,
          size: 10.sp,
          color: isPaid ? Colors.green[700] : Colors.amber[700],
        ),
        SizedBox(width: 3.w),
        Text(isPaid ? 'Paid' : 'Unpaid',
            style: GoogleFonts.dmSans(
              fontSize: 10.sp, fontWeight: FontWeight.bold,
              color: isPaid ? Colors.green[700] : Colors.amber[700],
            )),
      ]),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _DateTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
    decoration: BoxDecoration(
      color: const Color(0xFFFAF7F2),
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Row(children: [
      Icon(icon, size: 14.sp, color: const Color(0xFFCD6E4E)),
      SizedBox(width: 6.w),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.dmSans(
                fontSize: 10.sp, color: Colors.grey[500])),
            Text(value, style: GoogleFonts.dmSans(
                fontSize: 12.sp, fontWeight: FontWeight.w600,
                color: const Color(0xFF2D1B10))),
          ])),
    ]),
  );
}

class _EmptyState extends StatelessWidget {
  final String label;
  const _EmptyState({required this.label});

  @override
  Widget build(BuildContext context) => ListView(children: [
    SizedBox(height: 80.h),
    Column(children: [
      Icon(Icons.inbox_outlined, size: 60.sp, color: Colors.grey[300]),
      SizedBox(height: 14.h),
      Text('No $label bookings',
          style: GoogleFonts.playfairDisplay(fontSize: 18.sp,
              fontWeight: FontWeight.bold, color: const Color(0xFF2D1B10))),
      SizedBox(height: 6.h),
      Text('They will appear here when guests book your homestay.',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(fontSize: 13.sp, color: Colors.grey[500])),
    ]),
  ]);
}