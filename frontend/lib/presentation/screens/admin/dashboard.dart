import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/homestays/HomestayBloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/homestays/HomestayEvent.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/homestays/HomestayState.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_event.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_state.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/user/user_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/user/user_event.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/user/user_state.dart';
import '../../state_management/Bloc/Booking/booking_bloc.dart';
import '../../state_management/Bloc/Booking/booking_event.dart';
import '../../state_management/Bloc/Booking/booking_state.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  static const _bg     = Color(0xFFF7F8FC);
  static const _ink    = Color(0xFF1C1F26);
  static const _muted  = Color(0xFF6B7280);
  static const _border = Color(0xFFE8EAF0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingBloc>().add(const LoadAllBookings());
      context.read<UserBloc>().add(FetchUsers());
      context.read<SitesBloc>().add(const LoadSites());
      context.read<HomestayBloc>().add(const TouristLoadAllHomestays());
    });
  }

  Map<String, dynamic> _inner(Map<String, dynamic> b) =>
      (b['booking'] as Map?)?.cast<String, dynamic>() ?? b;

  String _status(Map<String, dynamic> b) =>
      (_inner(b)['status'] ?? 'pending').toString().toLowerCase();

  double _price(Map<String, dynamic> b) =>
      ((_inner(b)['totalPrice'] ?? _inner(b)['amount'] ?? 0) as num).toDouble();

  String _createdAt(Map<String, dynamic> b) =>
      (_inner(b)['createdAt'] ?? _inner(b)['checkIn'] ?? '').toString();

  static String _fmt(double n) {
    if (n >= 1_000_000) return 'Rs. ${(n / 1_000_000).toStringAsFixed(1)}M';
    if (n >= 1_000)     return 'Rs. ${(n / 1_000).toStringAsFixed(1)}K';
    return 'Rs. ${n.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final bookingState  = context.watch<BookingBloc>().state;
    final homestayState = context.watch<HomestayBloc>().state;
    final sitesState    = context.watch<SitesBloc>().state;
    final userState     = context.watch<UserBloc>().state;

    final bookings  = bookingState is AllBookingsLoaded ? bookingState.bookings : <Map<String, dynamic>>[];
    final homestays = homestayState is TouristAllHomestaysLoaded
        ? homestayState.homestays
        : (homestayState is OwnerHomestaysLoaded ? homestayState.homestays : []);
    final sites = sitesState is SitesLoaded ? sitesState.sites : [];
    final users = userState is UserLoaded ? userState.users : [];

    final totalRevenue   = bookings.fold<double>(0, (s, b) => s + _price(b));
    final pendingCount   = bookings.where((b) => _status(b) == 'pending').length;
    final confirmedCount = bookings.where((b) => _status(b) == 'confirmed').length;
    final activeHosts    = homestays.map((h) => h.owner?.userId).where((id) => id != null).toSet().length;

    final today = DateTime.now();
    final todayBookings = bookings.where((b) {
      final raw = _createdAt(b);
      if (raw.isEmpty) return false;
      try {
        final dt = DateTime.parse(raw);
        return dt.year == today.year && dt.month == today.month && dt.day == today.day;
      } catch (_) { return false; }
    }).length;

    final monthlyRevenue = bookings.fold<double>(0, (s, b) {
      final raw = _createdAt(b);
      if (raw.isEmpty) return s;
      try {
        final dt = DateTime.parse(raw);
        if (dt.year == today.year && dt.month == today.month) return s + _price(b);
      } catch (_) {}
      return s;
    });

    final recent = (List<Map<String, dynamic>>.from(bookings)
      ..sort((a, b) => _createdAt(b).compareTo(_createdAt(a)))).take(6).toList();

    final isLoading = bookingState is BookingLoading;
    final isMobile  = MediaQuery.of(context).size.width < 700;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: _bg,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _header(isMobile, totalRevenue, bookings.length),
          SizedBox(height: isMobile ? 20 : 28),
          _statsGrid(isMobile, users.length, sites.length, homestays.length, totalRevenue),
          SizedBox(height: isMobile ? 20 : 28),
          isMobile
              ? Column(children: [
                  _recentBookings(recent),
                  const SizedBox(height: 16),
                  _quickStats(isMobile, todayBookings, pendingCount, confirmedCount, activeHosts, monthlyRevenue),
                ])
              : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(flex: 3, child: _recentBookings(recent)),
                  const SizedBox(width: 20),
                  Expanded(flex: 2, child: _quickStats(isMobile, todayBookings, pendingCount, confirmedCount, activeHosts, monthlyRevenue)),
                ]),
        ]),
      ),
    );
  }

  Widget _header(bool isMobile, double revenue, int totalBookings) {
    final month = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][DateTime.now().month - 1];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Overview', style: GoogleFonts.inter(fontSize: isMobile ? 22 : 26, fontWeight: FontWeight.w700, color: _ink)),
      const SizedBox(height: 4),
      Text('$month ${DateTime.now().year}  ·  $totalBookings bookings  ·  ${_fmt(revenue)} total',
          style: GoogleFonts.inter(fontSize: 13, color: _muted)),
    ]);
  }

  Widget _statsGrid(bool isMobile, int users, int sites, int homestays, double revenue) {
    final items = [
      (label: 'Users',          value: '$users',      icon: Icons.people_alt_outlined,      accent: const Color(0xFF4F6AF5)),
      (label: 'Heritage Sites', value: '$sites',      icon: Icons.account_balance_outlined, accent: const Color(0xFF8B5CF6)),
      (label: 'Homestays',      value: '$homestays',  icon: Icons.cottage_outlined,         accent: const Color(0xFFEC4899)),
      (label: 'Total Revenue',  value: _fmt(revenue), icon: Icons.bar_chart_rounded,        accent: const Color(0xFF10B981)),
    ];
    if (isMobile) {
      return Row(children: [
        Expanded(child: Column(children: [
          _StatCard(label: items[0].label, value: items[0].value, icon: items[0].icon, accent: items[0].accent, compact: true),
          const SizedBox(height: 10),
          _StatCard(label: items[2].label, value: items[2].value, icon: items[2].icon, accent: items[2].accent, compact: true),
        ])),
        const SizedBox(width: 10),
        Expanded(child: Column(children: [
          _StatCard(label: items[1].label, value: items[1].value, icon: items[1].icon, accent: items[1].accent, compact: true),
          const SizedBox(height: 10),
          _StatCard(label: items[3].label, value: items[3].value, icon: items[3].icon, accent: items[3].accent, compact: true),
        ])),
      ]);
    }
    return Row(children: items
        .map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6),
            child: _StatCard(label: c.label, value: c.value, icon: c.icon, accent: c.accent))))
        .toList());
  }

  Widget _recentBookings(List<Map<String, dynamic>> recent) {
    return _Card(
      title: 'Recent Bookings',
      child: recent.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(child: Text('No bookings yet', style: GoogleFonts.inter(color: _muted))),
            )
          : Column(children: recent.map((b) => _BookingRow(
              name: b['touristName']?.toString() ?? 'Tourist',
              homestay: b['homestayName']?.toString() ?? 'Homestay',
              status: _status(b),
              createdAt: _createdAt(b),
            )).toList()),
    );
  }

  Widget _quickStats(bool isMobile, int today, int pending, int confirmed, int hosts, double monthly) {
    final items = [
      (label: "Today's Bookings", value: '$today',       accent: const Color(0xFF4F6AF5)),
      (label: 'Pending',          value: '$pending',     accent: const Color(0xFFF59E0B)),
      (label: 'Confirmed',        value: '$confirmed',   accent: const Color(0xFF10B981)),
      (label: 'Active Hosts',     value: '$hosts',       accent: const Color(0xFF8B5CF6)),
      (label: 'Monthly Revenue',  value: _fmt(monthly),  accent: const Color(0xFFEC4899)),
    ];
    return _Card(
      title: 'Quick Stats',
      child: Column(
        children: items.map((e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(children: [
            Container(width: 4, height: 32, decoration: BoxDecoration(color: e.accent, borderRadius: BorderRadius.circular(4))),
            const SizedBox(width: 12),
            Expanded(child: Text(e.label, style: GoogleFonts.inter(fontSize: 13, color: _muted))),
            Text(e.value, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: _ink)),
          ]),
        )).toList(),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color accent;
  final bool compact;
  const _StatCard({required this.label, required this.value, required this.icon, required this.accent, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 14 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EAF0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: compact
          ? Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 16, color: accent),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF1C1F26))),
                Text(label, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF6B7280)), maxLines: 1, overflow: TextOverflow.ellipsis),
              ])),
            ])
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 20, color: accent),
              ),
              const SizedBox(height: 14),
              Text(value, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF1C1F26))),
              const SizedBox(height: 3),
              Text(label, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6B7280))),
            ]),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EAF0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF1C1F26))),
        const SizedBox(height: 16),
        const Divider(height: 1, color: Color(0xFFE8EAF0)),
        const SizedBox(height: 16),
        child,
      ]),
    );
  }
}

class _BookingRow extends StatelessWidget {
  final String name, homestay, status, createdAt;
  const _BookingRow({required this.name, required this.homestay, required this.status, required this.createdAt});

  static const _statusColor = {
    'confirmed': Color(0xFF10B981),
    'completed': Color(0xFF059669),
    'cancelled': Color(0xFFEF4444),
    'rejected' : Color(0xFFEF4444),
    'pending'  : Color(0xFFF59E0B),
  };

  String _timeAgo() {
    if (createdAt.isEmpty) return '';
    try {
      final diff = DateTime.now().difference(DateTime.parse(createdAt).toLocal());
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24)   return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) { return ''; }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor[status] ?? const Color(0xFFF59E0B);
    final label = status[0].toUpperCase() + status.substring(1);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1C1F26))),
            const SizedBox(height: 2),
            Text(homestay, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280)), overflow: TextOverflow.ellipsis),
          ]),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
          ),
          if (_timeAgo().isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(_timeAgo(), style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF9CA3AF))),
          ],
        ]),
      ]),
    );
  }
}
