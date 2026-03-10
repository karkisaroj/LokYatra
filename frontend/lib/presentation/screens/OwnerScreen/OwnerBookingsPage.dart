import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../state_management/Bloc/booking/booking_bloc.dart';
import '../../state_management/Bloc/booking/booking_event.dart';
import '../../state_management/Bloc/booking/booking_state.dart';

const _terracotta = Color(0xFFCD6E4E);
const _dark       = Color(0xFF2D1B10);
const _cream      = Color(0xFFFAF7F2);

double _s(double v, bool wide) => wide ? v : v.sp;
double _w(double v, bool wide) => wide ? v : v.w;
double _h(double v, bool wide) => wide ? v : v.h;
double _r(double v, bool wide) => wide ? v : v.r;

class OwnerBookingsPage extends StatefulWidget {
  const OwnerBookingsPage({super.key});
  @override
  State<OwnerBookingsPage> createState() => _OwnerBookingsPageState();
}

class _OwnerBookingsPageState extends State<OwnerBookingsPage> {
  late final BookingBloc _bloc;
  @override
  void initState() { super.initState(); _bloc = BookingBloc()..add(const LoadOwnerBookings()); }
  @override
  void dispose() { _bloc.close(); super.dispose(); }
  @override
  Widget build(BuildContext context) => BlocProvider.value(value: _bloc, child: const _BookingsView());
}

class _BookingsView extends StatefulWidget {
  const _BookingsView();
  @override
  State<_BookingsView> createState() => _BookingsViewState();
}

class _BookingsViewState extends State<_BookingsView> {
  int _tab = 0;
  OwnerRevenueLoaded? _revenue;
  List<Map<String, dynamic>> _bookings = [];

  String _st(Map<String, dynamic> b) => (b['booking']?['status'] ?? '').toString();

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Bookings',
            style: GoogleFonts.playfairDisplay(
                fontSize: _s(20, wide), fontWeight: FontWeight.bold, color: _dark)),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(height: 1, color: Colors.grey.shade200)),
      ),
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is OwnerBookingsLoaded) setState(() => _bookings = state.bookings);
          if (state is OwnerRevenueLoaded)  setState(() => _revenue = state);
          if (state is BookingActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message, style: GoogleFonts.dmSans()),
              backgroundColor: Colors.green[700],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_r(10, wide))),
            ));
          }
          if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message, style: GoogleFonts.dmSans()),
              backgroundColor: Colors.red[700],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_r(10, wide))),
            ));
          }
        },
        builder: (context, state) {
          if (state is BookingLoading && _revenue == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final pending   = _bookings.where((b) => _st(b) == 'Pending').toList();
          final confirmed = _bookings.where((b) => _st(b) == 'Confirmed').toList();
          final completed = _bookings.where((b) => _st(b) == 'Completed').toList();

          final tabs = [
            ('Pending',   pending,   pending.length),
            ('Confirmed', confirmed, confirmed.length),
            ('Completed', completed, completed.length),
            ('All',       _bookings, _bookings.length),
          ];
          final list = tabs[_tab].$2;

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: wide ? 900 : double.infinity),
              child: Column(children: [

                // Revenue card
                if (_revenue != null)
                  _RevenueCard(revenue: _revenue!, wide: wide),

                // Tab bar
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(
                      _w(16, wide), _h(12, wide), _w(16, wide), _h(12, wide)),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(_r(14, wide))),
                    padding: EdgeInsets.all(_w(4, wide)),
                    child: Row(
                      children: List.generate(4, (i) => Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _tab = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(vertical: _h(8, wide)),
                            decoration: BoxDecoration(
                              color: _tab == i ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(_r(10, wide)),
                              boxShadow: _tab == i
                                  ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 6, offset: const Offset(0, 2))]
                                  : [],
                            ),
                            child: Column(mainAxisSize: MainAxisSize.min, children: [
                              Text(tabs[i].$1,
                                  style: GoogleFonts.dmSans(
                                    fontSize: _s(11, wide),
                                    fontWeight: _tab == i ? FontWeight.bold : FontWeight.normal,
                                    color: _tab == i ? _dark : Colors.grey[500],
                                  )),
                              if (tabs[i].$3 > 0) ...[
                                SizedBox(height: _h(2, wide)),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: _w(6, wide), vertical: _h(1, wide)),
                                  decoration: BoxDecoration(
                                    color: _tab == i ? _terracotta : Colors.grey.shade400,
                                    borderRadius: BorderRadius.circular(_r(8, wide)),
                                  ),
                                  child: Text('${tabs[i].$3}',
                                      style: GoogleFonts.dmSans(
                                          fontSize: _s(9, wide),
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ]),
                          ),
                        ),
                      )),
                    ),
                  ),
                ),

                // Booking list
                Expanded(
                  child: RefreshIndicator(
                    color: _terracotta,
                    onRefresh: () async =>
                        context.read<BookingBloc>().add(const LoadOwnerBookings()),
                    child: list.isEmpty
                        ? _EmptyState(label: tabs[_tab].$1, wide: wide)
                        : ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                          _w(16, wide), _h(12, wide), _w(16, wide), _h(32, wide)),
                      itemCount: list.length,
                      itemBuilder: (_, i) => _BookingCard(
                        wide: wide,
                        data: list[i],
                        onConfirm: () => context.read<BookingBloc>().add(
                            UpdateBookingStatus(list[i]['booking']['id'] as int, 'Confirmed')),
                        onReject: (reason) => context.read<BookingBloc>().add(
                            UpdateBookingStatus(list[i]['booking']['id'] as int, 'Rejected',
                                rejectionReason: reason)),
                        onComplete: () => context.read<BookingBloc>().add(
                            UpdateBookingStatus(list[i]['booking']['id'] as int, 'Completed')),
                        onMarkPaid: () => _confirmMarkPaid(
                            context,
                            list[i]['booking']['id'] as int,
                            list[i]['booking']['totalPrice'],
                            list[i]['booking']['paymentMethod']?.toString() ?? ''),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }

  void _confirmMarkPaid(BuildContext ctx, int id, dynamic amount, String method) {
    final wide        = MediaQuery.of(ctx).size.width > 700;
    final methodLabel = method == 'Khalti' ? 'Khalti' : 'Cash on Arrival';
    showDialog(
      context: ctx,
      builder: (dCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_r(16, wide))),
        title: Text('Confirm Payment Received',
            style: GoogleFonts.playfairDisplay(
                fontSize: _s(18, wide), fontWeight: FontWeight.bold)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: EdgeInsets.all(_w(16, wide)),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(_r(12, wide)),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(children: [
              Icon(Icons.payments_outlined, color: Colors.green[700], size: _s(32, wide)),
              SizedBox(height: _h(8, wide)),
              Text('Rs. ${(amount as num?)?.toStringAsFixed(0) ?? '—'}',
                  style: GoogleFonts.dmSans(
                      fontSize: _s(22, wide), fontWeight: FontWeight.w800, color: Colors.green[800])),
              SizedBox(height: _h(4, wide)),
              Text('via $methodLabel',
                  style: GoogleFonts.dmSans(fontSize: _s(13, wide), color: Colors.green[700])),
            ]),
          ),
          SizedBox(height: _h(12, wide)),
          Text('This will mark the payment as received and add it to your revenue.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(fontSize: _s(13, wide), color: Colors.grey[600])),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: Text('Cancel', style: GoogleFonts.dmSans(color: Colors.grey[600])),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
            label: Text('Mark as Paid', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
            onPressed: () { Navigator.pop(dCtx); ctx.read<BookingBloc>().add(MarkPaymentReceived(id)); },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700], foregroundColor: Colors.white, elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_r(10, wide))),
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  final OwnerRevenueLoaded revenue;
  final bool wide;
  const _RevenueCard({required this.revenue, required this.wide});

  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.all(_w(16, wide)),
    padding: EdgeInsets.all(_w(18, wide)),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
          colors: [Color(0xFF2D1B10), Color(0xFF5C3D2E)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(_r(20, wide)),
      boxShadow: [BoxShadow(
          color: const Color(0xFF2D1B10).withValues(alpha: 0.3),
          blurRadius: 16, offset: const Offset(0, 8))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Total Revenue',
            style: GoogleFonts.dmSans(fontSize: _s(13, wide), color: Colors.white70)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: _w(10, wide), vertical: _h(4, wide)),
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(_r(20, wide))),
          child: Row(children: [
            Icon(Icons.check_circle_outline_rounded, size: _s(12, wide), color: Colors.greenAccent),
            SizedBox(width: _w(4, wide)),
            Text('${revenue.paidBookings} paid',
                style: GoogleFonts.dmSans(fontSize: _s(11, wide), color: Colors.white70)),
          ]),
        ),
      ]),
      SizedBox(height: _h(6, wide)),
      Text('Rs. ${revenue.totalRevenue.toStringAsFixed(0)}',
          style: GoogleFonts.playfairDisplay(
              fontSize: _s(32, wide), fontWeight: FontWeight.bold, color: Colors.white)),
      SizedBox(height: _h(16, wide)),
      Row(children: [
        Expanded(child: _Pill(wide: wide, label: 'Cash',    amount: revenue.cashRevenue,    icon: Icons.money_rounded,           color: Colors.greenAccent)),
        SizedBox(width: _w(10, wide)),
        Expanded(child: _Pill(wide: wide, label: 'Khalti',  amount: revenue.khaltiRevenue,  icon: Icons.phone_android_rounded,   color: Colors.purpleAccent)),
        SizedBox(width: _w(10, wide)),
        Expanded(child: _Pill(wide: wide, label: 'Pending', amount: revenue.pendingRevenue, icon: Icons.hourglass_bottom_rounded, color: Colors.amberAccent)),
      ]),
    ]),
  );
}

class _Pill extends StatelessWidget {
  final bool wide;
  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  const _Pill({required this.wide, required this.label, required this.amount,
    required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: _w(10, wide), vertical: _h(10, wide)),
    decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(_r(12, wide))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: _s(12, wide), color: color),
        SizedBox(width: _w(4, wide)),
        Text(label, style: GoogleFonts.dmSans(fontSize: _s(10, wide), color: Colors.white60)),
      ]),
      SizedBox(height: _h(4, wide)),
      Text('Rs. ${amount.toStringAsFixed(0)}',
          style: GoogleFonts.dmSans(
              fontSize: _s(13, wide), fontWeight: FontWeight.bold, color: Colors.white)),
    ]),
  );
}

class _BookingCard extends StatelessWidget {
  final bool wide;
  final Map<String, dynamic> data;
  final VoidCallback onConfirm, onComplete, onMarkPaid;
  final void Function(String) onReject;
  const _BookingCard({required this.wide, required this.data, required this.onConfirm,
    required this.onComplete, required this.onMarkPaid, required this.onReject});

  @override
  Widget build(BuildContext context) {
    final b           = (data['booking'] as Map<String, dynamic>?) ?? {};
    final status      = b['status']?.toString()        ?? 'Pending';
    final payStatus   = b['paymentStatus']?.toString() ?? 'Unpaid';
    final payMethod   = b['paymentMethod']?.toString() ?? '';
    final tourist     = data['touristName']?.toString()  ?? 'Tourist';
    final phone       = data['touristPhone']?.toString() ?? '';
    final homestay    = data['homestayName']?.toString() ?? 'Homestay';
    final checkIn     = _fmt(b['checkIn']);
    final checkOut    = _fmt(b['checkOut']);
    final nights      = b['nights']  as int?    ?? 0;
    final rooms       = b['rooms']   as int?    ?? 0;
    final guests      = b['guests']  as int?    ?? 0;
    final total       = (b['totalPrice'] as num?)?.toDouble() ?? 0;
    final specReq     = b['specialRequests']?.toString()  ?? '';
    final rejReason   = b['rejectionReason']?.toString()  ?? '';
    final isPaid      = payStatus == 'Paid';
    final isKhalti    = payMethod == 'Khalti';
    final canMarkPaid = (status == 'Confirmed' || status == 'Completed') && !isPaid;

    return Container(
      margin: EdgeInsets.only(bottom: _h(16, wide)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_r(18, wide)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12, offset: const Offset(0, 5))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Header
        Container(
          padding: EdgeInsets.all(_w(14, wide)),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.vertical(top: Radius.circular(_r(18, wide))),
          ),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(homestay,
                  style: GoogleFonts.playfairDisplay(
                      fontSize: _s(16, wide), fontWeight: FontWeight.bold, color: _dark)),
              SizedBox(height: _h(2, wide)),
              Text('${nights}n · $rooms room${rooms != 1 ? 's' : ''} · $guests guest${guests != 1 ? 's' : ''}',
                  style: GoogleFonts.dmSans(fontSize: _s(11, wide), color: Colors.grey[500])),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              _StatusBadge(status: status, wide: wide),
              SizedBox(height: _h(4, wide)),
              _PaymentBadge(payStatus: payStatus, wide: wide),
            ]),
          ]),
        ),

        Padding(
          padding: EdgeInsets.all(_w(14, wide)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Tourist
            Row(children: [
              Container(
                width: wide ? 38 : 38.w,
                height: wide ? 38 : 38.h,
                decoration: BoxDecoration(
                    color: _terracotta.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(Icons.person_rounded, size: _s(20, wide), color: _terracotta),
              ),
              SizedBox(width: _w(10, wide)),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tourist,
                    style: GoogleFonts.dmSans(
                        fontSize: _s(14, wide), fontWeight: FontWeight.w600, color: _dark)),
                if (phone.isNotEmpty)
                  Text(phone,
                      style: GoogleFonts.dmSans(fontSize: _s(12, wide), color: Colors.grey[500])),
              ])),
            ]),

            SizedBox(height: _h(12, wide)),

            // Dates
            Row(children: [
              Expanded(child: _DateTile(wide: wide, label: 'Check-in',  value: checkIn,  icon: Icons.login_rounded)),
              SizedBox(width: _w(8, wide)),
              Expanded(child: _DateTile(wide: wide, label: 'Check-out', value: checkOut, icon: Icons.logout_rounded)),
            ]),

            SizedBox(height: _h(12, wide)),

            // Total + method
            Container(
              padding: EdgeInsets.all(_w(12, wide)),
              decoration: BoxDecoration(
                  color: _cream, borderRadius: BorderRadius.circular(_r(10, wide))),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Total',
                      style: GoogleFonts.dmSans(fontSize: _s(11, wide), color: Colors.grey[500])),
                  Text('Rs. ${total.toStringAsFixed(0)}',
                      style: GoogleFonts.dmSans(
                          fontSize: _s(20, wide), fontWeight: FontWeight.w800, color: _terracotta)),
                ]),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: _w(10, wide), vertical: _h(5, wide)),
                  decoration: BoxDecoration(
                    color: isKhalti ? Colors.purple.shade50 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(_r(20, wide)),
                    border: Border.all(
                        color: isKhalti ? Colors.purple.shade200 : Colors.green.shade200),
                  ),
                  child: Row(children: [
                    Icon(isKhalti ? Icons.phone_android_rounded : Icons.money_rounded,
                        size: _s(13, wide),
                        color: isKhalti ? Colors.purple[700] : Colors.green[700]),
                    SizedBox(width: _w(4, wide)),
                    Text(isKhalti ? 'Khalti' : 'Cash on Arrival',
                        style: GoogleFonts.dmSans(
                            fontSize: _s(11, wide), fontWeight: FontWeight.w600,
                            color: isKhalti ? Colors.purple[700] : Colors.green[700])),
                  ]),
                ),
              ]),
            ),

            if (specReq.isNotEmpty) ...[
              SizedBox(height: _h(10, wide)),
              _NoteBox(wide: wide, text: specReq,
                  icon: Icons.sticky_note_2_outlined,
                  bg: Colors.amber.shade50, border: Colors.amber.shade200, textColor: Colors.amber.shade900,
                  iconColor: Colors.amber.shade700),
            ],

            if (rejReason.isNotEmpty) ...[
              SizedBox(height: _h(10, wide)),
              _NoteBox(wide: wide, text: rejReason,
                  icon: Icons.cancel_outlined,
                  bg: Colors.red.shade50, border: Colors.red.shade200,
                  textColor: Colors.red.shade700, iconColor: Colors.red.shade700),
            ],

            SizedBox(height: _h(14, wide)),

            if (status == 'Pending')
              Row(children: [
                Expanded(child: _ActionBtn(wide: wide, label: 'Confirm',
                    color: Colors.green[700]!, onTap: onConfirm)),
                SizedBox(width: _w(10, wide)),
                Expanded(child: _OutlineBtn(wide: wide, label: 'Reject',
                    color: Colors.red, onTap: () => _showRejectDialog(context))),
              ]),

            if (status == 'Confirmed')
              Row(children: [
                if (canMarkPaid) ...[
                  Expanded(child: _ActionBtn(wide: wide, label: 'Mark as Paid',
                      color: Colors.green[700]!, icon: Icons.payments_rounded, onTap: onMarkPaid)),
                  SizedBox(width: _w(10, wide)),
                ],
                Expanded(child: _OutlineBtn(wide: wide, label: 'Complete Stay',
                    color: Colors.blue, onTap: onComplete)),
              ]),

            if (status == 'Completed' && canMarkPaid)
              SizedBox(
                width: double.infinity,
                child: _ActionBtn(wide: wide, label: 'Mark as Paid',
                    color: Colors.green[700]!, icon: Icons.payments_rounded, onTap: onMarkPaid),
              ),

            if (isPaid)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: _h(10, wide)),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(_r(10, wide)),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.check_circle_rounded, size: _s(16, wide), color: Colors.green[700]),
                  SizedBox(width: _w(6, wide)),
                  Text('Payment Received',
                      style: GoogleFonts.dmSans(
                          fontSize: _s(13, wide), fontWeight: FontWeight.w600,
                          color: Colors.green[700])),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_r(16, wide))),
        title: Text('Reject Booking',
            style: GoogleFonts.playfairDisplay(fontSize: _s(18, wide), fontWeight: FontWeight.bold)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Provide a reason for the tourist:',
              style: GoogleFonts.dmSans(fontSize: _s(13, wide), color: Colors.grey[600])),
          SizedBox(height: _h(12, wide)),
          TextField(
            controller: ctrl, maxLines: 3,
            style: GoogleFonts.dmSans(fontSize: _s(14, wide)),
            decoration: InputDecoration(
              hintText: 'e.g. No availability on those dates...',
              hintStyle: GoogleFonts.dmSans(fontSize: _s(13, wide), color: Colors.grey[400]),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(_r(10, wide))),
              contentPadding: EdgeInsets.all(_w(12, wide)),
            ),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.dmSans(color: Colors.grey[600]))),
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); onReject(ctrl.text.trim()); },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700], foregroundColor: Colors.white, elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_r(8, wide)))),
            child: Text('Reject', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  String _fmt(dynamic raw) {
    if (raw == null) return '—';
    try {
      final d = DateTime.parse(raw.toString());
      const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${m[d.month - 1]} ${d.day}, ${d.year}';
    } catch (_) { return raw.toString(); }
  }
}

class _ActionBtn extends StatelessWidget {
  final bool wide;
  final String label;
  final Color color;
  final IconData? icon;
  final VoidCallback onTap;
  const _ActionBtn({required this.wide, required this.label, required this.color,
    required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) => ElevatedButton(
    onPressed: onTap,
    style: ElevatedButton.styleFrom(
      backgroundColor: color, foregroundColor: Colors.white, elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_r(10, wide))),
      padding: EdgeInsets.symmetric(vertical: _h(12, wide)),
    ),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      if (icon != null) ...[Icon(icon!, size: _s(16, wide)), SizedBox(width: _w(6, wide))],
      Text(label, style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: _s(13, wide))),
    ]),
  );
}

class _OutlineBtn extends StatelessWidget {
  final bool wide;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _OutlineBtn({required this.wide, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onTap,
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: color.withValues(alpha: 0.5)),
      foregroundColor: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_r(10, wide))),
      padding: EdgeInsets.symmetric(vertical: _h(12, wide)),
    ),
    child: Text(label,
        style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: _s(13, wide))),
  );
}

class _NoteBox extends StatelessWidget {
  final bool wide;
  final String text;
  final IconData icon;
  final Color bg, border, textColor, iconColor;
  const _NoteBox({required this.wide, required this.text, required this.icon,
    required this.bg, required this.border, required this.textColor, required this.iconColor});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(_w(10, wide)),
    decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(_r(8, wide)),
        border: Border.all(color: border)),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: _s(13, wide), color: iconColor),
      SizedBox(width: _w(6, wide)),
      Expanded(child: Text(text,
          style: GoogleFonts.dmSans(fontSize: _s(12, wide), color: textColor))),
    ]),
  );
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final bool wide;
  const _StatusBadge({required this.status, required this.wide});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      'Pending'   => (Colors.orange.shade100, Colors.orange.shade800),
      'Confirmed' => (Colors.green.shade100,  Colors.green.shade800),
      'Rejected'  => (Colors.red.shade100,    Colors.red.shade800),
      'Completed' => (Colors.blue.shade100,   Colors.blue.shade800),
      _           => (Colors.grey.shade200,   Colors.grey.shade700),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _w(10, wide), vertical: _h(4, wide)),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(_r(20, wide))),
      child: Text(status,
          style: GoogleFonts.dmSans(
              fontSize: _s(11, wide), fontWeight: FontWeight.bold, color: fg)),
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  final String payStatus;
  final bool wide;
  const _PaymentBadge({required this.payStatus, required this.wide});

  @override
  Widget build(BuildContext context) {
    final isPaid = payStatus == 'Paid';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _w(8, wide), vertical: _h(3, wide)),
      decoration: BoxDecoration(
        color: isPaid ? Colors.green.shade50 : Colors.amber.shade50,
        borderRadius: BorderRadius.circular(_r(20, wide)),
        border: Border.all(color: isPaid ? Colors.green.shade300 : Colors.amber.shade300),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(isPaid ? Icons.check_circle_rounded : Icons.hourglass_empty_rounded,
            size: _s(10, wide), color: isPaid ? Colors.green[700] : Colors.amber[700]),
        SizedBox(width: _w(3, wide)),
        Text(isPaid ? 'Paid' : 'Unpaid',
            style: GoogleFonts.dmSans(
                fontSize: _s(10, wide), fontWeight: FontWeight.bold,
                color: isPaid ? Colors.green[700] : Colors.amber[700])),
      ]),
    );
  }
}

class _DateTile extends StatelessWidget {
  final bool wide;
  final String label, value;
  final IconData icon;
  const _DateTile({required this.wide, required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: _w(10, wide), vertical: _h(8, wide)),
    decoration: BoxDecoration(color: _cream, borderRadius: BorderRadius.circular(_r(8, wide))),
    child: Row(children: [
      Icon(icon, size: _s(14, wide), color: _terracotta),
      SizedBox(width: _w(6, wide)),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.dmSans(fontSize: _s(10, wide), color: Colors.grey[500])),
        Text(value, style: GoogleFonts.dmSans(
            fontSize: _s(12, wide), fontWeight: FontWeight.w600, color: _dark)),
      ])),
    ]),
  );
}

class _EmptyState extends StatelessWidget {
  final String label;
  final bool wide;
  const _EmptyState({required this.label, required this.wide});

  @override
  Widget build(BuildContext context) => ListView(children: [
    SizedBox(height: wide ? 80 : 80.h),
    Column(children: [
      Icon(Icons.inbox_outlined, size: _s(60, wide), color: Colors.grey[300]),
      SizedBox(height: _h(14, wide)),
      Text('No $label bookings',
          style: GoogleFonts.playfairDisplay(
              fontSize: _s(18, wide), fontWeight: FontWeight.bold, color: _dark)),
      SizedBox(height: _h(6, wide)),
      Text('They will appear here when guests book your homestay.',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(fontSize: _s(13, wide), color: Colors.grey[500])),
    ]),
  ]);
}