import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/homestays/homestay_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/homestays/homestay_event.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/homestays/homestay_state.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_event.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_state.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/user/user_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/user/user_event.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/user/user_state.dart';
import '../../state_management/Bloc/Booking/booking_bloc.dart';
import '../../state_management/Bloc/Booking/booking_event.dart';
import '../../state_management/Bloc/Booking/booking_state.dart';

class AdminReports extends StatefulWidget {
  const AdminReports({super.key});
  @override
  State<AdminReports> createState() => _AdminReportsState();
}

class _AdminReportsState extends State<AdminReports> {
  static const _accent = Color(0xFF6366F1);
  static const _ink    = Color(0xFF0F172A);
  static const _muted  = Color(0xFF64748B);
  static const _bg     = Color(0xFFF8FAFC);
  static const _emerald = Color(0xFF10B981);
  static const _teal    = Color(0xFF14B8A6);
  static const _brown   = Color(0xFF78350F);
  static const _terracotta = Color(0xFFCD6E4E);
  static const _months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  void _refresh() {
    context.read<BookingBloc>().add(const LoadAllBookings());
    context.read<UserBloc>().add(FetchUsers());
    context.read<SitesBloc>().add(const LoadSites());
    context.read<HomestayBloc>().add(const TouristLoadAllHomestays());
  }


  Map<String, dynamic> _inner(Map<String, dynamic> b) =>
      (b['booking'] as Map?)?.cast<String, dynamic>() ?? b;

  String _status(Map<String, dynamic> b) =>
      (_inner(b)['status'] ?? 'pending').toString().toLowerCase();

  num _price(Map<String, dynamic> b) =>
      (_inner(b)['totalPrice'] ?? _inner(b)['amount'] ?? 0) as num;

  String _touristName(Map<String, dynamic> b) =>
      (b['touristName'] ?? b['tourist']?['name'] ?? 'Tourist').toString();

  String _homestayName(Map<String, dynamic> b) =>
      (b['homestayName'] ?? b['homestay']?['name'] ?? 'Homestay').toString();

  String _createdAt(Map<String, dynamic> b) =>
      (_inner(b)['createdAt'] ?? _inner(b)['checkIn'] ?? '').toString();

  @override
  Widget build(BuildContext context) {
    final bookingState = context.watch<BookingBloc>().state;
    final homestayState = context.watch<HomestayBloc>().state;
    final sitesState = context.watch<SitesBloc>().state;
    final userState = context.watch<UserBloc>().state;

    final isLoading = bookingState is BookingLoading;
    final bookings = bookingState is AllBookingsLoaded ? bookingState.bookings : <Map<String, dynamic>>[];
    final homestays = homestayState is TouristAllHomestaysLoaded ? homestayState.homestays
        : homestayState is OwnerHomestaysLoaded ? homestayState.homestays : [];
    final sites = sitesState is SitesLoaded ? sitesState.sites : [];
    final users = userState is UserLoaded ? userState.users : [];

    final total = bookings.length;
    final pending = bookings.where((b) => _status(b) == 'pending').length;
    final confirmed = bookings.where((b) => _status(b) == 'confirmed').length;
    final completed = bookings.where((b) => _status(b) == 'completed').length;
    final cancelled = bookings.where((b) => _status(b) == 'cancelled' || _status(b) == 'rejected').length;
    final revenue = bookings.fold<double>(0, (s, b) => s + _price(b).toDouble());

    final monthly = {for (final m in _months) m: 0};
    for (final b in bookings) {
      final raw = _createdAt(b);
      if (raw.isNotEmpty) {
        try {
          final dt = DateTime.parse(raw);
          monthly[_months[dt.month - 1]] = (monthly[_months[dt.month - 1]] ?? 0) + 1;
        } catch (_) {}
      }
    }

    final counts = <String, int>{};
    final revMap = <String, double>{};
    for (final b in bookings) {
      final name = _homestayName(b);
      counts[name] = (counts[name] ?? 0) + 1;
      revMap[name] = (revMap[name] ?? 0) + _price(b).toDouble();
    }
    final top = (counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
        .take(5).map((e) => {'name': e.key, 'bookings': e.value, 'revenue': revMap[e.key] ?? 0.0}).toList();

    final recent = (List<Map<String, dynamic>>.from(bookings)
      ..sort((a, b) => _createdAt(b).compareTo(_createdAt(a))))
        .take(5).toList();

    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 700;
      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 16.w, vertical: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text('Reports & Analytics',
                  style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: _ink))),
              IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh_rounded, color: _accent)),
            ]),
            const SizedBox(height: 4),
            Text('Live data from bookings, users & listings',
                style: GoogleFonts.inter(fontSize: 13, color: _muted, fontWeight: FontWeight.w500)),
            SizedBox(height: 20.h),
            if (isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(60), child: CircularProgressIndicator()))
            else ...[
              if (isWide) ...[
                Row(children: [
                  Expanded(child: _StatCard(icon: Icons.book_online_rounded, label: 'Total Bookings', value: '$total', color: _accent)),
                  const SizedBox(width: 14),
                  Expanded(child: _StatCard(icon: Icons.payments_rounded, label: 'Total Revenue', value: 'Rs. ${_fmt(revenue)}', color: _emerald)),
                  const SizedBox(width: 14),
                  Expanded(child: _StatCard(icon: Icons.people_rounded, label: 'Total Users', value: '${users.length}', color: Colors.blue[600]!)),
                  const SizedBox(width: 14),
                  Expanded(child: _StatCard(icon: Icons.home_work_rounded, label: 'Homestays', value: '${homestays.length}', color: Colors.orange[600]!)),
                ]),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: _StatCard(icon: Icons.temple_hindu_rounded, label: 'Cultural Sites', value: '${sites.length}', color: Colors.purple[600]!)),
                  const SizedBox(width: 14),
                  Expanded(child: _StatCard(icon: Icons.pending_actions_rounded, label: 'Pending', value: '$pending', color: Colors.amber[700]!)),
                  const SizedBox(width: 14),
                  Expanded(child: _StatCard(icon: Icons.check_circle_rounded, label: 'Completed', value: '$completed', color: _emerald)),
                  const SizedBox(width: 14),
                  Expanded(child: _StatCard(icon: Icons.cancel_rounded, label: 'Cancelled', value: '$cancelled', color: Colors.red[500]!)),
                ]),
                const SizedBox(height: 24),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(flex: 3, child: _barChart(monthly)),
                  const SizedBox(width: 14),
                  Expanded(flex: 2, child: _statusChart(total, completed, confirmed, pending, cancelled)),
                ]),
                const SizedBox(height: 14),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: _topCard(top)),
                  const SizedBox(width: 14),
                  Expanded(child: _recentCard(recent)),
                ]),
              ] else ...[
                Row(children: [
                  Expanded(child: _StatCard(icon: Icons.book_online_rounded, label: 'Bookings', value: '$total', color: _teal)),
                  SizedBox(width: 10.w),
                  Expanded(child: _StatCard(icon: Icons.payments_rounded, label: 'Revenue', value: 'Rs. ${_fmt(revenue)}', color: Colors.green[700]!)),
                ]),
                SizedBox(height: 10.h),
                Row(children: [
                  Expanded(child: _StatCard(icon: Icons.people_rounded, label: 'Users', value: '${users.length}', color: _brown)),
                  SizedBox(width: 10.w),
                  Expanded(child: _StatCard(icon: Icons.home_work_rounded, label: 'Homestays', value: '${homestays.length}', color: _terracotta)),
                ]),
                SizedBox(height: 10.h),
                Row(children: [
                  Expanded(child: _StatCard(icon: Icons.temple_hindu_rounded, label: 'Sites', value: '${sites.length}', color: const Color(0xFF7B5EA7))),
                  SizedBox(width: 10.w),
                  Expanded(child: _StatCard(icon: Icons.pending_actions_rounded, label: 'Pending', value: '$pending', color: Colors.orange[700]!)),
                ]),
                SizedBox(height: 10.h),
                Row(children: [
                  Expanded(child: _StatCard(icon: Icons.check_circle_rounded, label: 'Completed', value: '$completed', color: Colors.green[600]!)),
                  SizedBox(width: 10.w),
                  Expanded(child: _StatCard(icon: Icons.cancel_rounded, label: 'Cancelled', value: '$cancelled', color: Colors.red[400]!)),
                ]),
                SizedBox(height: 20.h),
                _barChart(monthly),
                SizedBox(height: 14.h),
                _statusChart(total, completed, confirmed, pending, cancelled),
                SizedBox(height: 14.h),
                _topCard(top),
                SizedBox(height: 14.h),
                _recentCard(recent),
              ],
            ],
            SizedBox(height: 40.h),
          ]),
        ),
      );
    });
  }

  Widget _barChart(Map<String, int> monthly) {
    final maxVal = monthly.values.fold<int>(1, (m, v) => v > m ? v : m);
    return _Card(title: 'Bookings by Month', icon: Icons.bar_chart_rounded, color: _accent,
      child: SizedBox(height: 150, child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: monthly.entries.map((e) {
          final frac = maxVal > 0 ? e.value / maxVal : 0.0;
          return Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              if (e.value > 0) Text('${e.value}', style: GoogleFonts.inter(fontSize: 9, color: _muted, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOut,
                height: frac < 0.01 ? 4 : 110 * frac,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [_accent, _accent.withValues(alpha: 0.6)],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ),
              const SizedBox(height: 6),
              Text(e.key, style: GoogleFonts.inter(fontSize: 9, color: _muted, fontWeight: FontWeight.w600)),
            ]),
          ));
        }).toList(),
      )),
    );
  }

  Widget _statusChart(int total, int completed, int confirmed, int pending, int cancelled) {
    final t = total > 0 ? total.toDouble() : 1;
    final segs = [
      _Seg('Completed', completed / t, _emerald),
      _Seg('Confirmed', confirmed / t, _accent),
      _Seg('Pending', pending / t, Colors.amber[600]!),
      _Seg('Cancelled', cancelled / t, Colors.red[400]!),
    ];
    return _Card(title: 'Booking Status', icon: Icons.pie_chart_rounded, color: Colors.orange[600]!,
      child: Column(children: [
        ClipRRect(borderRadius: BorderRadius.circular(10), child: SizedBox(height: 20,
          child: Row(children: segs.map((s) => s.frac > 0
              ? Expanded(flex: (s.frac * 100).round().clamp(1, 100), child: Container(color: s.color))
              : const SizedBox.shrink()).toList()),
        )),
        const SizedBox(height: 20),
        ...segs.map((s) => Padding(padding: const EdgeInsets.only(bottom: 12),
          child: Row(children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: s.color, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Expanded(child: Text(s.label, style: GoogleFonts.inter(fontSize: 13, color: _ink, fontWeight: FontWeight.w500))),
            Text('${(s.frac * 100).toStringAsFixed(1)}%', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: _ink)),
          ]),
        )),
      ]),
    );
  }

  Widget _topCard(List<Map<String, dynamic>> top) {
    final medals = [Colors.amber[700]!, const Color(0xFF94A3B8), const Color(0xFFB45309)];
    return _Card(title: 'Top Homestays', icon: Icons.emoji_events_rounded, color: Colors.amber[700]!,
      child: top.isEmpty
          ? Center(child: Padding(padding: const EdgeInsets.all(20), child: Text('No bookings yet', style: GoogleFonts.inter(color: _muted))))
          : Column(children: top.asMap().entries.map((entry) {
        final i = entry.key;
        final h = entry.value;
        final c = i < 3 ? medals[i] : _muted;
        return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Row(children: [
            Container(width: 28, height: 28,
                decoration: BoxDecoration(color: c.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: Center(child: Text('${i + 1}', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: c)))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(h['name'] as String, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: _ink)),
              Text('${h['bookings']} bookings · Rs. ${_fmt(h['revenue'])}',
                  style: GoogleFonts.inter(fontSize: 11, color: _muted, fontWeight: FontWeight.w500)),
            ])),
          ]),
        );
      }).toList()),
    );
  }

  Widget _recentCard(List<Map<String, dynamic>> recent) => _Card(
    title: 'Recent Bookings', icon: Icons.history_rounded, color: _accent,
    child: recent.isEmpty
        ? Center(child: Padding(padding: const EdgeInsets.all(20), child: Text('No bookings yet', style: GoogleFonts.inter(color: _muted))))
        : Column(children: recent.map((b) {
      final name = _touristName(b);
      final home = _homestayName(b);
      final status = _status(b);
      final amt = _price(b);
      final sc = status == 'confirmed' || status == 'completed' ? _emerald
          : status == 'cancelled' || status == 'rejected' ? Colors.red[500]! : Colors.amber[700]!;
      return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Row(children: [
          CircleAvatar(radius: 16, backgroundColor: _accent.withValues(alpha: 0.1),
              child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: _accent))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: _ink)),
            Text(home, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 11, color: _muted, fontWeight: FontWeight.w500)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: sc.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(status[0].toUpperCase() + status.substring(1),
                    style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: sc))),
            const SizedBox(height: 4),
            Text('Rs. ${_fmt(amt)}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: _ink)),
          ]),
        ]),
      );
    }).toList()),
  );

  static String _fmt(dynamic n) {
    final d = (n as num?)?.toDouble() ?? 0;
    if (d >= 1000000) return '${(d / 1000000).toStringAsFixed(1)}M';
    if (d >= 1000) return '${(d / 1000).toStringAsFixed(1)}K';
    return d.toStringAsFixed(0);
  }
}

class _Card extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;
  const _Card({required this.title, required this.icon, required this.color, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 8))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: color)),
        const SizedBox(width: 12),
        Flexible(child: Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)))),
      ]),
      const SizedBox(height: 20),
      child,
    ]),
  );
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 18, offset: const Offset(0, 6))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 20, color: color)),
      const SizedBox(height: 14),
      Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
      const SizedBox(height: 2),
      Text(label, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B), fontWeight: FontWeight.w600)),
    ]),
  );
}

class _Seg {
  final String label;
  final double frac;
  final Color color;
  const _Seg(this.label, this.frac, this.color);
}
