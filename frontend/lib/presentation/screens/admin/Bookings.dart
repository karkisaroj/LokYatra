import 'package:flutter/foundation.dart';
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
      child: const _Body(),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();
  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  static const _slate      = Color(0xFF3D5A80);
  static const _bg         = Color(0xFFF4F6F9);
  static const _terracotta = Color(0xFFCD6E4E);

  String _search = '';
  String _statusFilter = 'All';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Map<String, dynamic> _inner(Map<String, dynamic> b) =>
      (b['booking'] as Map?)?.cast<String, dynamic>() ?? b;

  String _statusOf(Map<String, dynamic> b) =>
      (_inner(b)['status'] ?? '').toString();

  double _priceOf(Map<String, dynamic> b) =>
      ((_inner(b)['totalPrice'] ?? 0) as num).toDouble();

  String _createdAt(Map<String, dynamic> b) =>
      (_inner(b)['createdAt'] ?? '').toString();

  List<Map<String, dynamic>> _filtered(List<Map<String, dynamic>> all) {
    var list = all;
    if (_statusFilter != 'All') {
      list = list.where((b) => _statusOf(b) == _statusFilter).toList();
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((b) {
        final tourist  = (b['touristName']  ?? '').toString().toLowerCase();
        final homestay = (b['homestayName'] ?? '').toString().toLowerCase();
        final id       = (_inner(b)['id']   ?? '').toString();
        return tourist.contains(q) || homestay.contains(q) || id.contains(q);
      }).toList();
    }
    return list;
  }

  Map<String, int> _counts(List<Map<String, dynamic>> all) {
    final m = <String, int>{'All': all.length, 'Pending': 0, 'Confirmed': 0, 'Completed': 0, 'Cancelled': 0, 'Rejected': 0};
    for (final b in all) {
      final s = _statusOf(b);
      m[s] = (m[s] ?? 0) + 1;
    }
    return m;
  }

  double _revenue(List<Map<String, dynamic>> all) => all
      .where((b) => _statusOf(b) == 'Completed')
      .fold(0.0, (s, b) => s + _priceOf(b));

  Color _statusColor(String s) => switch (s) {
    'Pending'   => const Color(0xFF5B8CDB),
    'Confirmed' => const Color(0xFF2E9E6B),
    'Completed' => _slate,
    'Cancelled' => const Color(0xFF78909C),
    'Rejected'  => const Color(0xFFE05252),
    _           => _slate,
  };

  (Color, Color) _statusPair(String s) {
    final c = _statusColor(s);
    return (c, c.withValues(alpha: 0.08));
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb || MediaQuery.of(context).size.width > 700;
    return BlocConsumer<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message, style: GoogleFonts.dmSans()),
            backgroundColor: const Color(0xFF2E9E6B),
            behavior: SnackBarBehavior.floating,
          ));
        }
        if (state is BookingError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message, style: GoogleFonts.dmSans()),
            backgroundColor: const Color(0xFFE05252),
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      builder: (context, state) {
        if (state is BookingLoading) return const Center(child: CircularProgressIndicator());
        if (state is BookingError) {
          return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(state.message, style: GoogleFonts.dmSans(color: Colors.grey[500])),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<BookingBloc>().add(const LoadAllBookings()),
              style: ElevatedButton.styleFrom(backgroundColor: _slate, foregroundColor: Colors.white),
              child: Text('Retry', style: GoogleFonts.dmSans()),
            ),
          ]));
        }

        final all      = state is AllBookingsLoaded ? state.bookings : <Map<String, dynamic>>[];
        final counts   = _counts(all);
        final filtered = _filtered(all);
        final revenue  = _revenue(all);

        return Container(
          color: _bg,
          child: isWeb ? _webLayout(all, counts, filtered, revenue) : _mobileLayout(all, counts, filtered, revenue),
        );
      },
    );
  }

  Widget _webLayout(List all, Map<String, int> counts, List filtered, double revenue) {
    return Column(children: [
      _webHeader(all, counts, revenue),
      _webFilters(counts),
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
        child: Row(children: [
          Text('${filtered.length} booking${filtered.length != 1 ? 's' : ''}',
              style: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey[500])),
          const Spacer(),
          TextButton.icon(
            onPressed: () => context.read<BookingBloc>().add(const LoadAllBookings()),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: Text('Refresh', style: GoogleFonts.dmSans(fontSize: 13)),
            style: TextButton.styleFrom(foregroundColor: _slate),
          ),
        ]),
      ),
      Expanded(
        child: filtered.isEmpty
            ? _emptyState()
            : _webTable(filtered.cast<Map<String, dynamic>>()),
      ),
    ]);
  }

  Widget _webHeader(List all, Map<String, int> counts, double revenue) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Bookings', style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1A2B3C))),
            const SizedBox(height: 2),
            Text('Manage all homestay reservations', style: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey[500])),
          ]),
        ),
        const SizedBox(width: 32),
        _webStatCard('Total', '${all.length}', const Color(0xFF3D5A80)),
        const SizedBox(width: 12),
        _webStatCard('Pending', '${counts['Pending'] ?? 0}', const Color(0xFF5B8CDB)),
        const SizedBox(width: 12),
        _webStatCard('Confirmed', '${counts['Confirmed'] ?? 0}', const Color(0xFF2E9E6B)),
        const SizedBox(width: 12),
        _webStatCard('Revenue', 'Rs.${(revenue / 1000).toStringAsFixed(1)}k', const Color(0xFFCD6E4E)),
        const SizedBox(width: 24),
        SizedBox(
          width: 260,
          height: 38,
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _search = v),
            style: GoogleFonts.dmSans(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search bookings...',
              hintStyle: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey[400]),
              prefixIcon: Icon(Icons.search, size: 17, color: Colors.grey[400]),
              filled: true, fillColor: const Color(0xFFF4F6F9),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _webStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(children: [
        Text(value, style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: GoogleFonts.dmSans(fontSize: 11, color: Colors.grey[500])),
      ]),
    );
  }

  Widget _webFilters(Map<String, int> counts) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Row(children: [
        ...['All', 'Pending', 'Confirmed', 'Completed', 'Cancelled', 'Rejected'].map((s) {
          final isSelected = _statusFilter == s;
          final count = counts[s] ?? 0;
          final color = _statusColor(s);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _statusFilter = s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? color : Colors.grey.shade300),
                ),
                child: Row(children: [
                  Text(s, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.grey[600])),
                  if (count > 0) ...[
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white.withValues(alpha: 0.25) : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('$count', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.grey[600])),
                    ),
                  ],
                ]),
              ),
            ),
          );
        }),
      ]),
    );
  }

  Widget _webTable(List<Map<String, dynamic>> data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(children: [
              SizedBox(width: 60, child: _th('ID')),
              Expanded(flex: 2, child: _th('Tourist')),
              Expanded(flex: 2, child: _th('Homestay')),
              SizedBox(width: 110, child: _th('Dates')),
              SizedBox(width: 90, child: _th('Payment')),
              SizedBox(width: 100, child: _th('Amount')),
              SizedBox(width: 100, child: _th('Status')),
            ]),
          ),
          Expanded(
            child: RefreshIndicator(
              color: _slate,
              onRefresh: () async => context.read<BookingBloc>().add(const LoadAllBookings()),
              child: ListView.separated(
                itemCount: data.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
                itemBuilder: (_, i) => _webRow(data[i]),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _webRow(Map<String, dynamic> b) {
    final inner     = _inner(b);
    final id        = inner['id'] ?? 0;
    final status    = _statusOf(b);
    final tourist   = (b['touristName']  ?? '—').toString();
    final homestay  = (b['homestayName'] ?? '—').toString();
    final checkIn   = _fmtDate(inner['checkIn']);
    final checkOut  = _fmtDate(inner['checkOut']);
    final method    = (inner['paymentMethod'] ?? '').toString();
    final total     = _priceOf(b);
    final (sc, sb)  = _statusPair(status);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(children: [
        SizedBox(width: 60, child: Text('#$id', style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey[500]))),
        Expanded(flex: 2, child: Text(tourist, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1A2B3C)))),
        Expanded(flex: 2, child: Text(homestay, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey[600]))),
        SizedBox(width: 110, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(checkIn, style: GoogleFonts.dmSans(fontSize: 11, color: const Color(0xFF1A2B3C))),
          Text(checkOut, style: GoogleFonts.dmSans(fontSize: 11, color: Colors.grey[400])),
        ])),
        SizedBox(width: 90, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: method.toLowerCase() == 'khalti' ? Colors.purple.shade50 : Colors.green.shade50,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(method.isEmpty ? 'Cash' : method,
              style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600,
                  color: method.toLowerCase() == 'khalti' ? Colors.purple[700] : Colors.green[700])),
        )),
        SizedBox(width: 100, child: Text('Rs. ${total.toStringAsFixed(0)}',
            style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: _terracotta))),
        SizedBox(width: 100, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: sb, borderRadius: BorderRadius.circular(20)),
          child: Text(status, style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.bold, color: sc)),
        )),
      ]),
    );
  }

  Widget _mobileLayout(List all, Map<String, int> counts, List filtered, double revenue) {
    return Column(children: [
      Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
        child: Row(children: [
          _StatBox(label: 'Total',   value: '${all.length}',                              color: _slate,                      icon: Icons.calendar_month_rounded),
          _vDivider(),
          _StatBox(label: 'Pending', value: '${counts['Pending'] ?? 0}',                  color: const Color(0xFF5B8CDB),     icon: Icons.hourglass_top_rounded),
          _vDivider(),
          _StatBox(label: 'Active',  value: '${counts['Confirmed'] ?? 0}',                color: const Color(0xFF2E9E6B),     icon: Icons.check_circle_outline_rounded),
          _vDivider(),
          _StatBox(label: 'Revenue', value: 'Rs.${(revenue / 1000).toStringAsFixed(1)}k', color: _terracotta, icon: Icons.payments_outlined),
        ]),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
        child: Row(children: [
          Expanded(child: Container(
            height: 42.h,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.r), border: Border.all(color: Colors.grey.shade200)),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _search = v),
              style: GoogleFonts.dmSans(fontSize: 13.sp),
              decoration: InputDecoration(
                hintText: 'Search bookings…',
                hintStyle: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, size: 18.sp, color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10.h),
              ),
            ),
          )),
          SizedBox(width: 10.w),
          IconButton(
            onPressed: () => context.read<BookingBloc>().add(const LoadAllBookings()),
            icon: Icon(Icons.refresh_rounded, color: _slate, size: 22.sp),
          ),
        ]),
      ),
      SizedBox(
        height: 46.h,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          children: ['All', 'Pending', 'Confirmed', 'Completed', 'Cancelled', 'Rejected'].map((s) {
            final isSelected = _statusFilter == s;
            final count = counts[s] ?? 0;
            final color = _statusColor(s);
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: GestureDetector(
                onTap: () => setState(() => _statusFilter = s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isSelected ? color : Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: isSelected ? color : Colors.grey.shade300),
                  ),
                  child: Row(children: [
                    Text(s, style: GoogleFonts.dmSans(fontSize: 12.sp, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.grey[700])),
                    if (count > 0) ...[
                      SizedBox(width: 4.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white.withValues(alpha: 0.3) : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text('$count', style: GoogleFonts.dmSans(fontSize: 10.sp, fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.grey[700])),
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
              style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.grey[500])),
        ]),
      ),
      Expanded(
        child: RefreshIndicator(
          color: _slate,
          onRefresh: () async => context.read<BookingBloc>().add(const LoadAllBookings()),
          child: filtered.isEmpty
              ? _emptyState()
              : ListView.builder(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 32.h),
            itemCount: filtered.length,
            itemBuilder: (_, i) => _BookingCard(data: filtered[i] as Map<String, dynamic>),
          ),
        ),
      ),
    ]);
  }

  Widget _emptyState() => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(Icons.calendar_month_outlined, size: 56, color: Colors.grey[300]),
    const SizedBox(height: 16),
    Text(_search.isNotEmpty ? 'No results for "$_search"' : _statusFilter == 'All' ? 'No bookings yet' : 'No $_statusFilter bookings',
        style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A2B3C))),
    const SizedBox(height: 6),
    Text('Pull down to refresh', style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey[400])),
  ]));

  Widget _th(String label) => Text(label, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey[600]));

  Widget _vDivider() => Container(width: 1, height: 40.h, color: Colors.grey.shade200, margin: EdgeInsets.symmetric(horizontal: 8.w));

  String _fmtDate(dynamic raw) {
    if (raw == null) return '—';
    try {
      final d = DateTime.parse(raw.toString());
      const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${m[d.month - 1]} ${d.day}, ${d.year}';
    } catch (_) { return raw.toString(); }
  }
}

class _StatBox extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _StatBox({required this.label, required this.value, required this.color, required this.icon});
  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Icon(icon, size: 20.sp, color: color),
    SizedBox(height: 4.h),
    FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: GoogleFonts.dmSans(fontSize: 16.sp, fontWeight: FontWeight.bold, color: color))),
    Text(label, style: GoogleFonts.dmSans(fontSize: 10.sp, color: Colors.grey[500])),
  ]));
}

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _BookingCard({required this.data});

  static const _dark      = Color(0xFF1A2B3C);
  static const _slate     = Color(0xFF3D5A80);
  static const _terracotta = Color(0xFFCD6E4E);

  Map<String, dynamic> get _b => (data['booking'] as Map?)?.cast<String, dynamic>() ?? data;

  (Color, Color) _statusPair(String s) {
    final c = switch (s) {
      'Pending'   => const Color(0xFF5B8CDB),
      'Confirmed' => const Color(0xFF2E9E6B),
      'Completed' => _slate,
      'Cancelled' => const Color(0xFF78909C),
      'Rejected'  => const Color(0xFFE05252),
      _           => _slate,
    };
    return (c, c.withValues(alpha: 0.08));
  }

  String _fmtDate(dynamic raw) {
    if (raw == null) return '—';
    try {
      final d = DateTime.parse(raw.toString());
      const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${m[d.month - 1]} ${d.day}, ${d.year}';
    } catch (_) { return raw.toString(); }
  }

  String _fmtDateTime(dynamic raw) {
    if (raw == null) return '';
    try {
      final d = DateTime.parse(raw.toString()).toLocal();
      const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${m[d.month - 1]} ${d.day}  ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
    } catch (_) { return ''; }
  }

  @override
  Widget build(BuildContext context) {
    final id           = _b['id'] as int? ?? 0;
    final status       = (_b['status'] ?? 'Pending').toString();
    final checkIn      = _fmtDate(_b['checkIn']);
    final checkOut     = _fmtDate(_b['checkOut']);
    final nights       = _b['nights']  as int? ?? 0;
    final rooms        = _b['rooms']   as int? ?? 0;
    final guests       = _b['guests']  as int? ?? 0;
    final total        = ((_b['totalPrice'] as num?)?.toDouble()) ?? 0;
    final payMethod    = _b['paymentMethod']?.toString()  ?? '';
    final specialReq   = _b['specialRequests']?.toString() ?? '';
    final rejReason    = _b['rejectionReason']?.toString() ?? '';
    final createdAt    = _fmtDateTime(_b['createdAt']);
    final touristName  = data['touristName']?.toString()  ?? 'Unknown Tourist';
    final touristPhone = data['touristPhone']?.toString() ?? '';
    final homestayName = data['homestayName']?.toString() ?? 'Unknown Homestay';
    final ownerName    = data['ownerName']?.toString()    ?? 'Unknown Owner';
    final (sc, sb)     = _statusPair(status);

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: _slate.withValues(alpha: 0.04),
            borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
            border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
          ),
          child: Row(children: [
            Icon(Icons.tag_rounded, size: 13.sp, color: Colors.grey[500]),
            SizedBox(width: 3.w),
            Text('Booking #$id', style: GoogleFonts.dmSans(fontSize: 12.sp, fontWeight: FontWeight.bold, color: _dark)),
            SizedBox(width: 8.w),
            Text(createdAt, style: GoogleFonts.dmSans(fontSize: 11.sp, color: Colors.grey[400])),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
              decoration: BoxDecoration(color: sb, borderRadius: BorderRadius.circular(20.r)),
              child: Text(status, style: GoogleFonts.dmSans(fontSize: 11.sp, fontWeight: FontWeight.bold, color: sc)),
            ),
          ]),
        ),
        Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: _PersonTile(icon: Icons.person_outline_rounded, label: 'Tourist', name: touristName, sub: touristPhone.isNotEmpty ? touristPhone : null, color: _slate)),
              SizedBox(width: 10.w),
              Expanded(child: _PersonTile(icon: Icons.home_outlined, label: 'Owner', name: ownerName, color: _terracotta)),
            ]),
            SizedBox(height: 12.h),
            Row(children: [
              Icon(Icons.hotel_outlined, size: 14.sp, color: Colors.grey[500]),
              SizedBox(width: 6.w),
              Expanded(child: Text(homestayName, style: GoogleFonts.dmSans(fontSize: 13.sp, fontWeight: FontWeight.w600, color: _dark))),
            ]),
            SizedBox(height: 10.h),
            Divider(height: 1, color: Colors.grey.shade100),
            SizedBox(height: 10.h),
            Row(children: [
              _InfoChip(icon: Icons.login_rounded,          label: 'In',     value: checkIn),
              SizedBox(width: 8.w),
              _InfoChip(icon: Icons.logout_rounded,         label: 'Out',    value: checkOut),
              SizedBox(width: 8.w),
              _InfoChip(icon: Icons.nights_stay_outlined,   label: 'Nights', value: '$nights'),
            ]),
            SizedBox(height: 8.h),
            Row(children: [
              _InfoChip(icon: Icons.king_bed_outlined,      label: 'Rooms',  value: '$rooms'),
              SizedBox(width: 8.w),
              _InfoChip(icon: Icons.people_outline_rounded, label: 'Guests', value: '$guests'),
              SizedBox(width: 8.w),
              _InfoChip(icon: payMethod.toLowerCase() == 'khalti' ? Icons.payment_rounded : Icons.money_outlined, label: 'Pay', value: payMethod.isEmpty ? 'Cash' : payMethod),
            ]),
            SizedBox(height: 10.h),
            Divider(height: 1, color: Colors.grey.shade100),
            SizedBox(height: 10.h),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Total Amount', style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.grey[500])),
              Text('Rs. ${total.toStringAsFixed(0)}', style: GoogleFonts.dmSans(fontSize: 17.sp, fontWeight: FontWeight.w800, color: _terracotta)),
            ]),
            if (specialReq.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8.r), border: Border.all(color: Colors.amber.shade200)),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.sticky_note_2_outlined, size: 13.sp, color: Colors.amber[700]),
                  SizedBox(width: 6.w),
                  Expanded(child: Text(specialReq, style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.amber[900]))),
                ]),
              ),
            ],
            if (rejReason.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8.r), border: Border.all(color: Colors.red.shade200)),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.info_outline_rounded, size: 13.sp, color: Colors.red[700]),
                  SizedBox(width: 6.w),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Rejection reason:', style: GoogleFonts.dmSans(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.red[800])),
                    Text(rejReason, style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.red[700])),
                  ])),
                ]),
              ),
            ],
          ]),
        ),
      ]),
    );
  }
}

class _PersonTile extends StatelessWidget {
  final IconData icon;
  final String label, name;
  final String? sub;
  final Color color;
  const _PersonTile({required this.icon, required this.label, required this.name, required this.color, this.sub});
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(10.w),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(10.r)),
    child: Row(children: [
      Icon(icon, size: 15.sp, color: color),
      SizedBox(width: 6.w),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.dmSans(fontSize: 9.sp, color: color, fontWeight: FontWeight.w600)),
        Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.dmSans(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1A2B3C))),
        if (sub != null) Text(sub!, style: GoogleFonts.dmSans(fontSize: 10.sp, color: Colors.grey[500])),
      ])),
    ]),
  );
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoChip({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
    decoration: BoxDecoration(color: const Color(0xFFF4F6F9), borderRadius: BorderRadius.circular(8.r)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12.sp, color: Colors.grey[500]),
      SizedBox(width: 4.w),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.dmSans(fontSize: 9.sp, color: Colors.grey[400])),
        Text(value, style: GoogleFonts.dmSans(fontSize: 11.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1A2B3C))),
      ]),
    ]),
  );
}