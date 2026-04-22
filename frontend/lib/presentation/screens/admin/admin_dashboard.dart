import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
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

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  static const _bg = Color(0xFFF3F4F7);
  static const _ink = Color(0xFF1E1E2D);
  static const _muted = Color(0xFF71717A);

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
    if (n >= 1_000) return 'Rs. ${(n / 1_000).toStringAsFixed(1)}K';
    return 'Rs. ${n.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = context.watch<BookingBloc>().state;
    final homestayState = context.watch<HomestayBloc>().state;
    final sitesState = context.watch<SitesBloc>().state;
    final userState = context.watch<UserBloc>().state;

    final bookings = bookingState is AllBookingsLoaded ? bookingState.bookings : <Map<String, dynamic>>[];
    final homestays = homestayState is TouristAllHomestaysLoaded
        ? homestayState.homestays
        : (homestayState is OwnerHomestaysLoaded ? homestayState.homestays : []);
    final sites = sitesState is SitesLoaded ? sitesState.sites : [];
    final users = userState is UserLoaded ? userState.users : [];

    final totalRevenue = bookings.fold<double>(0, (s, b) => s + _price(b));
    final pendingCount = bookings.where((b) => _status(b) == 'pending').length;
    final confirmedCount = bookings.where((b) => _status(b) == 'confirmed').length;
    final activeHosts = homestays.map((h) => h.owner?.userId).where((id) => id != null).toSet().length;

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


    final chartData = _getMonthlyRevenue(bookings);

    final recent = (List<Map<String, dynamic>>.from(bookings)
      ..sort((a, b) => _createdAt(b).compareTo(_createdAt(a)))).take(6).toList();

    final isLoading = bookingState is BookingLoading;
    final isDesktop = MediaQuery.of(context).size.width >= 1100;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF1E1E2D)));
    }

    return Container(
      color: _bg,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16, vertical: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          FadeInLeft(
            child: Text('Dashboard Overview',
                style: GoogleFonts.outfit(
                  fontSize: isDesktop ? 28 : 24,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                )),
          ),
          const SizedBox(height: 24),
          _statsGrid(isDesktop, users.length, sites.length, homestays.length, totalRevenue),
          const SizedBox(height: 32),
          if (isDesktop)
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                flex: 3,
                child: Column(children: [
                  FadeInUp(delay: const Duration(milliseconds: 200), child: _RevenueChart(chartData)),
                  const SizedBox(height: 24),
                  FadeInUp(delay: const Duration(milliseconds: 300), child: _recentBookings(recent)),
                ]),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: FadeInRight(child: _quickStats(todayBookings, pendingCount, confirmedCount, activeHosts, monthlyRevenue)),
              ),
            ])
          else
            Column(children: [
              _RevenueChart(chartData),
              const SizedBox(height: 24),
              _quickStats(todayBookings, pendingCount, confirmedCount, activeHosts, monthlyRevenue),
              const SizedBox(height: 24),
              _recentBookings(recent),
            ]),
        ]),
      ),
    );
  }

  List<double> _getMonthlyRevenue(List<Map<String, dynamic>> bookings) {
    final now = DateTime.now();
    final data = List.filled(6, 0.0);
    for (var b in bookings) {
      final raw = _createdAt(b);
      if (raw.isEmpty) continue;
      try {
        final dt = DateTime.parse(raw);
        final diff = (now.year * 12 + now.month) - (dt.year * 12 + dt.month);
        if (diff >= 0 && diff < 6) {
          data[5 - diff] += _price(b);
        }
      } catch (_) {}
    }
    return data;
  }

  Widget _statsGrid(bool isDesktop, int users, int sites, int homestays, double revenue) {
    final items = [
      (label: 'Total Users', value: '$users', icon: Icons.people_rounded, accent: const Color(0xFF6366F1)),
      (label: 'Heritage Sites', value: '$sites', icon: Icons.account_balance_rounded, accent: const Color(0xFF8B5CF6)),
      (label: 'Homestays', value: '$homestays', icon: Icons.cottage_rounded, accent: const Color(0xFFEC4899)),
      (label: 'Total Earnings', value: _fmt(revenue), icon: Icons.account_balance_wallet_rounded, accent: const Color(0xFF10B981)),
    ];
    
    return LayoutBuilder(builder: (context, constraints) {
      final crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 600 ? 2 : 1);
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 2.2,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) => FadeInDown(
          delay: Duration(milliseconds: i * 100),
          child: _StatCard(
            label: items[i].label,
            value: items[i].value,
            icon: items[i].icon,
            accent: items[i].accent,
          ),
        ),
      );
    });
  }

  Widget _recentBookings(List<Map<String, dynamic>> recent) {
    return _Card(
      title: 'Recent Activity',
      subtitle: 'Latest guest bookings across all regions',
      child: recent.isEmpty
          ? Center(child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text('No recent activity', style: GoogleFonts.inter(color: _muted)),
            ))
          : Column(children: recent.map((b) => _BookingRow(
              name: b['touristName']?.toString() ?? 'Tourist',
              homestay: b['homestayName']?.toString() ?? 'Homestay',
              status: _status(b),
              createdAt: _createdAt(b),
            )).toList()),
    );
  }

  Widget _quickStats(int today, int pending, int confirmed, int hosts, double monthly) {
    final items = [
      (label: "Today's Bookings", value: '$today', color: const Color(0xFF1E1E2D)),
      (label: 'Pending Requests', value: '$pending', color: const Color(0xFFF59E0B)),
      (label: 'Confirmed Stays', value: '$confirmed', color: const Color(0xFF10B981)),
      (label: 'Active Hosts', value: '$hosts', color: const Color(0xFF8B5CF6)),
      (label: 'This Month', value: _fmt(monthly), color: const Color(0xFFEC4899)),
    ];

    return _Card(
      title: 'Summary Stats',
      child: Column(
        children: items.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(children: [
            Container(
              width: 4, 
              height: 32, 
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [e.color, e.color.withValues(alpha: 0.5)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(e.label, style: GoogleFonts.inter(fontSize: 14, color: _muted, fontWeight: FontWeight.w600))),
            Text(e.value, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: _ink)),
          ]),
        )).toList(),
      ),
    );
  }
}

class _RevenueChart extends StatelessWidget {
  final List<double> data;
  const _RevenueChart(this.data);

  @override
  Widget build(BuildContext context) {
    final maxVal = data.isEmpty ? 100.0 : data.reduce((a, b) => a > b ? a : b) * 1.2;
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final currentMonth = DateTime.now().month;

    return _Card(
      title: 'Revenue Analytics',
      subtitle: 'Monthly performance trends',
      child: SizedBox(
        height: 260,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true, 
              drawVerticalLine: false,
              horizontalInterval: maxVal / 5,
              getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withValues(alpha: 0.1), strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: maxVal / 5,
                  getTitlesWidget: (val, _) => Text(
                    val >= 1000 ? '${(val/1000).toInt()}k' : val.toInt().toString(),
                    style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF71717A)),
                  ),
                  reservedSize: 32,
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (val, _) {
                    int index = (currentMonth - 6 + val.toInt()) % 12;
                    if (index < 0) index += 12;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(months[index], style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF71717A))),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value * 1.05)).toList(),
                isCurved: true,
                color: const Color(0xFFE2E8F0),
                barWidth: 2,
                isStrokeCapRound: true,
                dashArray: [5, 5],
                dotData: const FlDotData(show: false),
              ),
              LineChartBarData(
                spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                isCurved: true,
                color: const Color(0xFF1E1E2D),
                barWidth: 4,
                isStrokeCapRound: true,
                dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: const Color(0xFF1E1E2D),
                )),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [const Color(0xFF1E1E2D).withValues(alpha: 0.15), Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color accent;
  const _StatCard({required this.label, required this.value, required this.icon, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: accent, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF71717A))),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF1E1E2D))),
          ]),
        ),
      ]),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  const _Card({required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF1E1E2D))),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF71717A))),
        ],
        const SizedBox(height: 24),
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
    'completed': Color(0xFF0EA5E9),
    'cancelled': Color(0xFFEF4444),
    'rejected': Color(0xFFF43F5E),
    'pending': Color(0xFFF59E0B),
  };

  String _timeAgo() {
    if (createdAt.isEmpty) return '';
    try {
      final diff = DateTime.now().difference(DateTime.parse(createdAt).toLocal());
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) { return ''; }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor[status] ?? const Color(0xFFF59E0B);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: color.withValues(alpha: 0.1),
          child: Text(name[0].toUpperCase(), style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1E1E2D))),
            Text(homestay, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF71717A)), overflow: TextOverflow.ellipsis),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(status[0].toUpperCase() + status.substring(1), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
          Text(_timeAgo(), style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFFA1A1AA))),
        ]),
      ]),
    );
  }
}


