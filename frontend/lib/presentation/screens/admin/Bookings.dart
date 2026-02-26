// lib/presentation/screens/admin/Bookings.dart
//
// Replace the existing stub Bookings widget with this full implementation.
// Provides BookingBloc internally so it doesn't depend on a parent provider.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../state_management/Bloc/Booking/booking_bloc.dart';
import '../../state_management/Bloc/Booking/booking_event.dart';
import '../../state_management/Bloc/Booking/booking_state.dart';


class Bookings extends StatelessWidget {
  const Bookings({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookingBloc()..add(const LoadAllBookings()),
      child: const _AdminBookingsBody(),
    );
  }
}


class _AdminBookingsBody extends StatefulWidget {
  const _AdminBookingsBody();

  @override
  State<_AdminBookingsBody> createState() => _AdminBookingsBodyState();
}

class _AdminBookingsBodyState extends State<_AdminBookingsBody> {
  static const _slate      = Color(0xFF3D5A80);
  static const _bg         = Color(0xFFF4F6F9);

  String _search     = '';
  String _statusFilter = 'All'; // All | Pending | Confirmed | Completed | Cancelled | Rejected

  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filtered(List<Map<String, dynamic>> all) {
    var list = all;

    if (_statusFilter != 'All') {
      list = list.where((b) {
        final status = (b['booking']?['status'] ?? '').toString();
        return status == _statusFilter;
      }).toList();
    }

    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((b) {
        final tourist  = (b['touristName']  ?? '').toString().toLowerCase();
        final homestay = (b['homestayName'] ?? '').toString().toLowerCase();
        final id       = (b['booking']?['id'] ?? '').toString();
        return tourist.contains(q) || homestay.contains(q) || id.contains(q);
      }).toList();
    }

    return list;
  }

  Map<String, int> _counts(List<Map<String, dynamic>> all) {
    final m = <String, int>{
      'All': all.length,
      'Pending': 0, 'Confirmed': 0, 'Completed': 0,
      'Cancelled': 0, 'Rejected': 0,
    };
    for (final b in all) {
      final s = (b['booking']?['status'] ?? '').toString();
      m[s] = (m[s] ?? 0) + 1;
    }
    return m;
  }

  double _revenue(List<Map<String, dynamic>> all) => all
      .where((b) => (b['booking']?['status'] ?? '') == 'Completed')
      .fold(0.0, (sum, b) =>
  sum + ((b['booking']?['totalPrice'] as num?)?.toDouble() ?? 0));

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingBloc, BookingState>(
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
          return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.wifi_off_rounded, size: 48.sp, color: Colors.grey[300]),
            SizedBox(height: 12.h),
            Text(state.message,
                style: GoogleFonts.dmSans(color: Colors.grey[500])),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () =>
                  context.read<BookingBloc>().add(const LoadAllBookings()),
              style: ElevatedButton.styleFrom(
                  backgroundColor: _slate, foregroundColor: Colors.white),
              child: Text('Retry', style: GoogleFonts.dmSans()),
            ),
          ]));
        }

        final all = state is AllBookingsLoaded ? state.bookings : <Map<String, dynamic>>[];
        final counts   = _counts(all);
        final filtered = _filtered(all);
        final revenue  = _revenue(all);

        return Container(
          color: _bg,
          child: Column(children: [
            _StatsRow(
              total:    all.length,
              pending:  counts['Pending']   ?? 0,
              active:   counts['Confirmed'] ?? 0,
              revenue:  revenue,
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
              child: Row(children: [
                Expanded(
                  child: Container(
                    height: 42.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _search = v),
                      style: GoogleFonts.dmSans(fontSize: 13.sp),
                      decoration: InputDecoration(
                        hintText: 'Search by tourist, homestay, or booking ID…',
                        hintStyle: GoogleFonts.dmSans(
                            fontSize: 12.sp, color: Colors.grey[400]),
                        prefixIcon: Icon(Icons.search,
                            size: 18.sp, color: Colors.grey[400]),
                        border: InputBorder.none,
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 10.h),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                IconButton(
                  onPressed: () =>
                      context.read<BookingBloc>().add(const LoadAllBookings()),
                  icon: Icon(Icons.refresh_rounded,
                      color: _slate, size: 22.sp),
                  tooltip: 'Refresh',
                ),
              ]),
            ),

            SizedBox(
              height: 46.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                children: [
                  'All', 'Pending', 'Confirmed', 'Completed', 'Cancelled', 'Rejected'
                ].map((s) {
                  final isSelected = _statusFilter == s;
                  final count = counts[s] ?? 0;
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: GestureDetector(
                      onTap: () => setState(() => _statusFilter = s),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _statusColor(s) : Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isSelected
                                ? _statusColor(s) : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(children: [
                          Text(s,
                              style: GoogleFonts.dmSans(
                                fontSize: 12.sp,
                                fontWeight: isSelected
                                    ? FontWeight.bold : FontWeight.normal,
                                color: isSelected
                                    ? Colors.white : Colors.grey[700],
                              )),
                          if (count > 0) ...[
                            SizedBox(width: 4.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5.w, vertical: 1.h),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.3)
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text('$count',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white : Colors.grey[700],
                                  )),
                            ),
                          ],
                        ]),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 6.h),
              child: Row(children: [
                Text('${filtered.length} booking${filtered.length != 1 ? 's' : ''}',
                    style: GoogleFonts.dmSans(
                        fontSize: 12.sp, color: Colors.grey[500])),
              ]),
            ),

            Expanded(
              child: RefreshIndicator(
                color: _slate,
                onRefresh: () async =>
                    context.read<BookingBloc>().add(const LoadAllBookings()),
                child: filtered.isEmpty
                    ? _EmptyState(filter: _statusFilter, search: _search)
                    : ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                      16.w, 0, 16.w, 32.h),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) =>
                      _AdminBookingCard(data: filtered[i]),
                ),
              ),
            ),
          ]),
        );
      },
    );
  }

  Color _statusColor(String s) => switch (s) {
    'Pending'   => Colors.orange[700]!,
    'Confirmed' => Colors.green[600]!,
    'Completed' => Colors.blue[600]!,
    'Cancelled' => Colors.grey[600]!,
    'Rejected'  => Colors.red[600]!,
    _           => const Color(0xFF3D5A80),
  };
}


class _StatsRow extends StatelessWidget {
  final int total;
  final int pending;
  final int active;
  final double revenue;
  const _StatsRow({
    required this.total,
    required this.pending,
    required this.active,
    required this.revenue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      child: Row(children: [
        _StatBox(label: 'Total', value: '$total',
            color: const Color(0xFF3D5A80),
            icon: Icons.calendar_month_rounded),
        _vDivider(),
        _StatBox(label: 'Pending', value: '$pending',
            color: Colors.orange[700]!,
            icon: Icons.hourglass_top_rounded),
        _vDivider(),
        _StatBox(label: 'Active', value: '$active',
            color: Colors.green[600]!,
            icon: Icons.check_circle_outline_rounded),
        _vDivider(),
        _StatBox(
            label: 'Revenue',
            value: 'Rs.${(revenue / 1000).toStringAsFixed(1)}k',
            color: const Color(0xFFCD6E4E),
            icon: Icons.payments_outlined),
      ]),
    );
  }

  Widget _vDivider() => Container(
      width: 1, height: 40.h, color: Colors.grey.shade200,
      margin: EdgeInsets.symmetric(horizontal: 8.w));
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _StatBox({
    required this.label, required this.value,
    required this.color, required this.icon,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Icon(icon, size: 20.sp, color: color),
      SizedBox(height: 4.h),
      Text(value,
          style: GoogleFonts.dmSans(
              fontSize: 16.sp, fontWeight: FontWeight.bold, color: color)),
      Text(label,
          style: GoogleFonts.dmSans(fontSize: 10.sp, color: Colors.grey[500])),
    ]),
  );
}


class _AdminBookingCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _AdminBookingCard({required this.data});

  static const _dark  = Color(0xFF1A2B3C);
  static const _slate = Color(0xFF3D5A80);

  @override
  Widget build(BuildContext context) {
    final b            = (data['booking'] as Map<String, dynamic>?) ?? {};
    final id           = b['id'] as int? ?? 0;
    final status       = b['status']?.toString()        ?? 'Pending';
    final checkIn      = _fmtDate(b['checkIn']);
    final checkOut     = _fmtDate(b['checkOut']);
    final nights       = b['nights']  as int?  ?? 0;
    final rooms        = b['rooms']   as int?  ?? 0;
    final guests       = b['guests']  as int?  ?? 0;
    final total        = (b['totalPrice'] as num?)?.toDouble() ?? 0;
    final payMethod    = b['paymentMethod']?.toString()  ?? '';
    final specialReq   = b['specialRequests']?.toString() ?? '';
    final rejReason    = b['rejectionReason']?.toString() ?? '';
    final createdAt    = _fmtDateTime(b['createdAt']);

    final touristName  = data['touristName']?.toString()   ?? 'Unknown Tourist';
    final touristPhone = data['touristPhone']?.toString()  ?? '';
    final homestayName = data['homestayName']?.toString()  ?? 'Unknown Homestay';
    final ownerName    = data['ownerName']?.toString()     ?? 'Unknown Owner';

    final (statusColor, statusBg) = _statusColors(status);

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: _slate.withValues(alpha: 0.04),
            borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
            border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(Icons.tag_rounded, size: 13.sp, color: Colors.grey[500]),
                SizedBox(width: 3.w),
                Text('Booking #$id',
                    style: GoogleFonts.dmSans(
                        fontSize: 12.sp, fontWeight: FontWeight.bold,
                        color: _dark)),
                SizedBox(width: 8.w),
                Text(createdAt,
                    style: GoogleFonts.dmSans(
                        fontSize: 11.sp, color: Colors.grey[400])),
              ]),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(status,
                    style: GoogleFonts.dmSans(
                        fontSize: 11.sp, fontWeight: FontWeight.bold,
                        color: statusColor)),
              ),
            ],
          ),
        ),

        Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Row(children: [
              Expanded(child: _PersonTile(
                icon: Icons.person_outline_rounded,
                label: 'Tourist',
                name: touristName,
                sub: touristPhone.isNotEmpty ? touristPhone : null,
                color: _slate,
              )),
              SizedBox(width: 10.w),
              Expanded(child: _PersonTile(
                icon: Icons.home_outlined,
                label: 'Owner',
                name: ownerName,
                color: const Color(0xFFCD6E4E),
              )),
            ]),

            SizedBox(height: 12.h),

            Row(children: [
              Icon(Icons.hotel_outlined, size: 14.sp, color: Colors.grey[500]),
              SizedBox(width: 6.w),
              Expanded(child: Text(homestayName,
                  style: GoogleFonts.dmSans(
                      fontSize: 13.sp, fontWeight: FontWeight.w600,
                      color: _dark))),
            ]),

            SizedBox(height: 10.h),
            Divider(height: 1, color: Colors.grey.shade100),
            SizedBox(height: 10.h),

            Row(children: [
              _InfoChip(
                  icon: Icons.login_rounded,
                  label: 'In',
                  value: checkIn),
              SizedBox(width: 8.w),
              _InfoChip(
                  icon: Icons.logout_rounded,
                  label: 'Out',
                  value: checkOut),
              SizedBox(width: 8.w),
              _InfoChip(
                  icon: Icons.nights_stay_outlined,
                  label: 'Nights',
                  value: '$nights'),
            ]),

            SizedBox(height: 8.h),

            Row(children: [
              _InfoChip(
                  icon: Icons.king_bed_outlined,
                  label: 'Rooms',
                  value: '$rooms'),
              SizedBox(width: 8.w),
              _InfoChip(
                  icon: Icons.people_outline_rounded,
                  label: 'Guests',
                  value: '$guests'),
              SizedBox(width: 8.w),
              _InfoChip(
                  icon: payMethod == 'Khalti'
                      ? Icons.payment_rounded
                      : Icons.money_outlined,
                  label: 'Pay',
                  value: payMethod == 'Khalti'
                      ? 'Khalti' : 'On Arrival'),
            ]),

            SizedBox(height: 10.h),
            Divider(height: 1, color: Colors.grey.shade100),
            SizedBox(height: 10.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Amount',
                    style: GoogleFonts.dmSans(
                        fontSize: 12.sp, color: Colors.grey[500])),
                Text('Rs. ${total.toStringAsFixed(0)}',
                    style: GoogleFonts.dmSans(
                        fontSize: 17.sp, fontWeight: FontWeight.w800,
                        color: const Color(0xFFCD6E4E))),
              ],
            ),

            if (specialReq.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.sticky_note_2_outlined,
                      size: 13.sp, color: Colors.amber[700]),
                  SizedBox(width: 6.w),
                  Expanded(child: Text(specialReq,
                      style: GoogleFonts.dmSans(
                          fontSize: 12.sp, color: Colors.amber[900]))),
                ]),
              ),
            ],

            if (rejReason.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.info_outline_rounded,
                      size: 13.sp, color: Colors.red[700]),
                  SizedBox(width: 6.w),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rejection reason:',
                          style: GoogleFonts.dmSans(
                              fontSize: 10.sp, fontWeight: FontWeight.bold,
                              color: Colors.red[800])),
                      Text(rejReason,
                          style: GoogleFonts.dmSans(
                              fontSize: 12.sp, color: Colors.red[700])),
                    ],
                  )),
                ]),
              ),
            ],
          ]),
        ),
      ]),
    );
  }

  (Color, Color) _statusColors(String s) => switch (s) {
    'Pending'   => (Colors.orange[800]!, Colors.orange.shade50),
    'Confirmed' => (Colors.green[800]!,  Colors.green.shade50),
    'Completed' => (Colors.blue[800]!,   Colors.blue.shade50),
    'Cancelled' => (Colors.grey[700]!,   Colors.grey.shade100),
    'Rejected'  => (Colors.red[700]!,    Colors.red.shade50),
    _           => (Colors.grey[700]!,   Colors.grey.shade100),
  };

  String _fmtDate(dynamic raw) {
    if (raw == null) return '—';
    try {
      final d = DateTime.parse(raw.toString());
      const m = ['Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${m[d.month - 1]} ${d.day}, ${d.year}';
    } catch (_) { return raw.toString(); }
  }

  String _fmtDateTime(dynamic raw) {
    if (raw == null) return '';
    try {
      final d = DateTime.parse(raw.toString()).toLocal();
      const m = ['Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${m[d.month - 1]} ${d.day}  ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
    } catch (_) { return ''; }
  }
}


class _PersonTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String name;
  final String? sub;
  final Color color;
  const _PersonTile({
    required this.icon, required this.label,
    required this.name, required this.color, this.sub,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(10.w),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(10.r),
    ),
    child: Row(children: [
      Icon(icon, size: 15.sp, color: color),
      SizedBox(width: 6.w),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: GoogleFonts.dmSans(
                fontSize: 9.sp, color: color, fontWeight: FontWeight.w600)),
        Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(
                fontSize: 12.sp, fontWeight: FontWeight.bold,
                color: const Color(0xFF1A2B3C))),
        if (sub != null)
          Text(sub!,
              style: GoogleFonts.dmSans(fontSize: 10.sp, color: Colors.grey[500])),
      ])),
    ]),
  );
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoChip({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
    decoration: BoxDecoration(
      color: const Color(0xFFF4F6F9),
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12.sp, color: Colors.grey[500]),
      SizedBox(width: 4.w),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: GoogleFonts.dmSans(fontSize: 9.sp, color: Colors.grey[400])),
        Text(value,
            style: GoogleFonts.dmSans(
                fontSize: 11.sp, fontWeight: FontWeight.bold,
                color: const Color(0xFF1A2B3C))),
      ]),
    ]),
  );
}

class _EmptyState extends StatelessWidget {
  final String filter;
  final String search;
  const _EmptyState({required this.filter, required this.search});

  @override
  Widget build(BuildContext context) => ListView(children: [
    SizedBox(height: 80.h),
    Column(children: [
      Icon(Icons.calendar_month_outlined, size: 56.sp, color: Colors.grey[300]),
      SizedBox(height: 16.h),
      Text(
        search.isNotEmpty
            ? 'No results for "$search"'
            : filter == 'All'
            ? 'No bookings yet'
            : 'No $filter bookings',
        style: GoogleFonts.dmSans(
            fontSize: 16.sp, fontWeight: FontWeight.bold,
            color: const Color(0xFF1A2B3C)),
      ),
      SizedBox(height: 6.h),
      Text('Pull down to refresh',
          style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.grey[400])),
    ]),
  ]);
}