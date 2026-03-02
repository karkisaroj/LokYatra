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
  static const _brown = Color(0xFF8B5E3C);
  static const _dark = Color(0xFF2D1B10);
  static const _terracotta = Color(0xFFCD6E4E);

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

  // unwrap nested booking object from API: { "booking": {...}, "touristName": "...", "homestayName": "..." }
  Map<String, dynamic> _inner(Map<String, dynamic> b) =>
      (b['booking'] as Map?)?.cast<String, dynamic>() ?? b;

  String _status(Map<String, dynamic> b) =>
      (_inner(b)['status'] ?? 'pending').toString().toLowerCase();

  double _price(Map<String, dynamic> b) =>
      ((_inner(b)['totalPrice'] ?? _inner(b)['amount'] ?? 0) as num).toDouble();

  String _createdAt(Map<String, dynamic> b) =>
      (_inner(b)['createdAt'] ?? _inner(b)['checkIn'] ?? '').toString();

  @override
  Widget build(BuildContext context) {
    final bookingState = context.watch<BookingBloc>().state;
    final homestayState = context.watch<HomestayBloc>().state;
    final sitesState = context.watch<SitesBloc>().state;
    final userState = context.watch<UserBloc>().state;

    final bookings = bookingState is AllBookingsLoaded ? bookingState.bookings : <Map<String, dynamic>>[];
    // final homestays = homestayState is TouristAllHomestaysLoaded ? homestayState.homestays
        // : homestayState is OwnerHomestaysLoaded ? homestayState.homestays : [];
    final sites = sitesState is SitesLoaded ? sitesState.sites : [];
    final users = userState is UserLoaded ? userState.users : [];

    // Compute stats
    final totalRevenue = bookings.fold<double>(0, (s, b) => s + _price(b));
    final pendingCount = bookings.where((b) => _status(b) == 'pending').length;
    final confirmedCount = bookings.where((b) => _status(b) == 'confirmed').length;

    // Today's bookings
    final today = DateTime.now();
    final todayBookings = bookings.where((b) {
      final raw = _createdAt(b);
      if (raw.isEmpty) return false;
      try {
        final dt = DateTime.parse(raw);
        return dt.year == today.year && dt.month == today.month && dt.day == today.day;
      } catch (_) { return false; }
    }).length;

    // This month's revenue
    final monthlyRevenue = bookings.fold<double>(0, (s, b) {
      final raw = _createdAt(b);
      if (raw.isEmpty) return s;
      try {
        final dt = DateTime.parse(raw);
        if (dt.year == today.year && dt.month == today.month) return s + _price(b);
      } catch (_) {}
      return s;
    });

    // Active hosts = unique owners from homestays
    // final activeHosts = homestays.map((h) => h.ownerId ?? h.owner?.id).where((id) => id != null).toSet().length;

    // Recent activity — last 5 bookings sorted by date
    final recent = (List<Map<String, dynamic>>.from(bookings)
      ..sort((a, b) => _createdAt(b).compareTo(_createdAt(a))))
        .take(5).toList();

    final isLoading = bookingState is BookingLoading;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Container(
      color: const Color(0xFFF5F5F5),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          if (isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
          else ...[
            isMobile
                ? Column(children: [
              _MetricCard(title: 'Total Users', value: '${users.length}', icon: Icons.people_rounded, color: _brown),
              _MetricCard(title: 'Heritage Sites', value: '${sites.length}', icon: Icons.temple_hindu_rounded, color: const Color(0xFF7B5EA7)),
              // _MetricCard(title: 'Homestays', value: '${homestays.length}', icon: Icons.home_work_rounded, color: _terracotta),
              _MetricCard(title: 'Total Revenue', value: 'Rs. ${_fmt(totalRevenue)}', icon: Icons.payments_rounded, color: Colors.green[700]!),
            ])
                : Row(children: [
              Expanded(child: _MetricCard(title: 'Total Users', value: '${users.length}', icon: Icons.people_rounded, color: _brown)),
              Expanded(child: _MetricCard(title: 'Heritage Sites', value: '${sites.length}', icon: Icons.temple_hindu_rounded, color: const Color(0xFF7B5EA7))),
              // Expanded(child: _MetricCard(title: 'Homestays', value: '${homestays.length}', icon: Icons.home_work_rounded, color: _terracotta)),
              Expanded(child: _MetricCard(title: 'Total Revenue', value: 'Rs. ${_fmt(totalRevenue)}', icon: Icons.payments_rounded, color: Colors.green[700]!)),
            ]),

            const SizedBox(height: 32),

            // ── Section boxes ─────────────────────────────────────────────
            isMobile
                ? Column(children: [
              _SectionBox(title: 'Recent Activity', child: _ActivityList(recent: recent, statusFn: _status, nameFn: (b) => b['touristName']?.toString() ?? 'Tourist', homestayFn: (b) => b['homestayName']?.toString() ?? 'Homestay', dateFn: _createdAt)),
              const SizedBox(height: 16),
              _SectionBox(title: 'Quick Stats', child: _QuickStats(
                todayBookings: todayBookings,
                pendingCount: pendingCount,
                confirmedCount: confirmedCount,
                // activeHosts: activeHosts,
                monthlyRevenue: monthlyRevenue,
                isMobile: isMobile,
              )),
            ])
                : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _SectionBox(title: 'Recent Activity', child: _ActivityList(recent: recent, statusFn: _status, nameFn: (b) => b['touristName']?.toString() ?? 'Tourist', homestayFn: (b) => b['homestayName']?.toString() ?? 'Homestay', dateFn: _createdAt))),
              const SizedBox(width: 16),
              Expanded(child: _SectionBox(title: 'Quick Stats', child: _QuickStats(
                todayBookings: todayBookings,
                pendingCount: pendingCount,
                confirmedCount: confirmedCount,
                // activeHosts: activeHosts,
                monthlyRevenue: monthlyRevenue,
                isMobile: isMobile,
              ))),
            ]),
          ],
        ]),
      ),
    );
  }

  static String _fmt(double n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toStringAsFixed(0);
  }
}

// ── Metric card ───────────────────────────────────────────────────────────────

class _MetricCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _MetricCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      width: isMobile ? double.infinity : null,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 22, color: color)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey[500])),
          const SizedBox(height: 3),
          Text(value, style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF2D1B10))),
        ])),
      ]),
    );
  }
}

// ── Section box ───────────────────────────────────────────────────────────────

class _SectionBox extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionBox({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 3))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF2D1B10))),
      const SizedBox(height: 16),
      child,
    ]),
  );
}

// ── Activity list ─────────────────────────────────────────────────────────────

class _ActivityList extends StatelessWidget {
  final List<Map<String, dynamic>> recent;
  final String Function(Map<String, dynamic>) statusFn, nameFn, homestayFn, dateFn;
  const _ActivityList({required this.recent, required this.statusFn, required this.nameFn, required this.homestayFn, required this.dateFn});

  String _timeAgo(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) { return ''; }
  }

  @override
  Widget build(BuildContext context) {
    if (recent.isEmpty) {
      return Center(child: Padding(padding: const EdgeInsets.all(20),
        child: Text('No bookings yet', style: GoogleFonts.dmSans(color: Colors.grey[400]))));
    }

    return Column(children: recent.map((b) {
      final status = statusFn(b);
      final name = nameFn(b);
      final home = homestayFn(b);
      final time = _timeAgo(dateFn(b));
      final color = status == 'confirmed' || status == 'completed'
          ? Colors.green[600]! : status == 'cancelled' || status == 'rejected'
          ? Colors.red[400]! : Colors.orange[600]!;
      final icon = status == 'confirmed' ? Icons.check_circle_outline
          : status == 'completed' ? Icons.done_all_rounded
          : status == 'cancelled' || status == 'rejected' ? Icons.cancel_outlined
          : Icons.pending_outlined;
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18)),
        title: Text('Booking ${status[0].toUpperCase()}${status.substring(1)} — $home',
            style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF2D1B10))),
        subtitle: Text('$name${time.isNotEmpty ? ' • $time' : ''}',
            style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey[500])),
      );
    }).toList());
  }
}

// ── Quick stats ───────────────────────────────────────────────────────────────

class _QuickStats extends StatelessWidget {
  final int todayBookings, pendingCount, confirmedCount;
  final double monthlyRevenue;
  final bool isMobile;
  const _QuickStats({required this.todayBookings, required this.pendingCount, required this.confirmedCount,  required this.monthlyRevenue, required this.isMobile});

  String _fmt(double n) {
    if (n >= 1000000) return 'Rs. ${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return 'Rs. ${(n / 1000).toStringAsFixed(1)}K';
    return 'Rs. ${n.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Wrap(spacing: 12, runSpacing: 12, children: [
      _StatTile(title: "Today's Bookings", value: '$todayBookings', width: isMobile ? (width / 2) - 42 : 150),
      _StatTile(title: 'Pending Approval', value: '$pendingCount', width: isMobile ? (width / 2) - 42 : 150),
      _StatTile(title: 'Confirmed', value: '$confirmedCount', width: isMobile ? (width / 2) - 42 : 150),
      // _StatTile(title: 'Active Hosts', value: '$activeHosts', width: isMobile ? (width / 2) - 42 : 150),
      _StatTile(title: 'Monthly Revenue', value: _fmt(monthlyRevenue), width: isMobile ? double.infinity : 312),
    ]);
  }
}

class _StatTile extends StatelessWidget {
  final String title, value;
  final double width;
  const _StatTile({required this.title, required this.value, required this.width});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Card(
      elevation: 0,
      color: const Color(0xFFFAF7F2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade100)),
      child: Padding(padding: const EdgeInsets.all(14), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey[500]), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          FittedBox(fit: BoxFit.scaleDown, child: Text(value,
              style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF2D1B10)))),
        ],
      )),
    ),
  );
}