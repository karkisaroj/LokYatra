import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/services/sqlite_service.dart';
import 'package:lokyatra_frontend/data/datasources/user_remote_datasource.dart';
import 'package:lokyatra_frontend/presentation/widgets/Helpers/notifications_page.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/notification/notification_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/notification/notification_event.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/Booking/booking_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/Booking/booking_event.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/Booking/booking_state.dart';

const _bg      = Color(0xFFFAF7F2);
const _ink     = Color(0xFF1C1C1C);
const _brown   = Color(0xFF5C4033);
const _slate   = Color(0xFF2C3A4A);
const _muted   = Color(0xFF8A8279);
const _divider = Color(0xFFEDE8E1);
const _cardBg  = Color(0xFFFFFFFF);
const _tagBg   = Color(0xFFEEEBE5);
const _green   = Color(0xFF3D5A4F);

double _s(double v, bool wide) => wide ? v : v.sp;
double _w(double v, bool wide) => wide ? v : v.w;
double _h(double v, bool wide) => wide ? v : v.h;
double _r(double v, bool wide) => wide ? v : v.r;

class OwnerHome extends StatefulWidget {
  const OwnerHome({super.key});
  @override
  State<OwnerHome> createState() => _OwnerHomeState();
}

class _OwnerHomeState extends State<OwnerHome> {
  String? _profileImageUrl;
  String _name = '';
  String _email = '';
  bool _loading = true;
  late final BookingBloc _bookingBloc;
  OwnerRevenueLoaded? _revenue;

  @override
  void initState() {
    super.initState();
    _bookingBloc = BookingBloc()..add(const LoadOwnerBookings());
    _loadProfile();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<NotificationBloc>().add(const StartNotificationPolling());
    });
  }

  @override
  void dispose() {
    _bookingBloc.close();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final sqlite = SqliteService();
    final name  = await sqlite.get('user_name');
    final email = await sqlite.get('user_email');
    final image = await sqlite.get('user_profile_image');
    if (mounted) {
      setState(() {
        _name = name ?? '';
        _email = email ?? '';
        _profileImageUrl = (image != null && image.isNotEmpty) ? image : null;
      });
    }
    if (image == null || image.isEmpty) {
      await _fetchFromServer();
    } else {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _fetchFromServer() async {
    try {
      final res = await UserRemoteDatasource().getCurrentUser();
      if (res.statusCode == 200) {
        final data        = res.data as Map<String, dynamic>;
        final serverName  = data['name']         as String? ?? '';
        final serverEmail = data['email']        as String? ?? '';
        final serverImage = data['profileImage'] as String? ?? '';
        final sqlite = SqliteService();
        await sqlite.put('user_name', serverName);
        await sqlite.put('user_email', serverEmail);
        await sqlite.put('user_profile_image', serverImage);
        if (mounted) {
          setState(() {
            _name = serverName;
            _email = serverEmail;
            _profileImageUrl = serverImage.isNotEmpty ? serverImage : null;
          });
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(backgroundColor: _bg, body: Center(child: CircularProgressIndicator()));
    }
    final wide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: BlocProvider.value(
          value: _bookingBloc,
          child: BlocListener<BookingBloc, BookingState>(
            listener: (context, state) {
              if (state is OwnerRevenueLoaded && mounted) setState(() => _revenue = state);
            },
            child: RefreshIndicator(
              color: _brown,
              onRefresh: () async {
                context.read<NotificationBloc>().add(const LoadNotifications());
                await _loadProfile();
                _bookingBloc.add(const LoadOwnerBookings());
              },
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: wide ? 860 : double.infinity),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                        horizontal: _w(16, wide), vertical: _h(20, wide)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('My Dashboard',
                            style: GoogleFonts.playfairDisplay(
                                fontSize: _s(22, wide),
                                fontWeight: FontWeight.bold,
                                color: _ink)),
                        BellButton(),
                      ]),
                      SizedBox(height: _h(16, wide)),
                      _HeaderCard(
                        wide: wide,
                        name: _name,
                        email: _email,
                        profileImageUrl: _profileImageUrl,
                        onProfileTap: () =>
                            Navigator.pushNamed(context, '/ownerProfile').then((_) => _loadProfile()),
                      ),
                      SizedBox(height: _h(20, wide)),
                      _QuickStatsSection(wide: wide),
                      SizedBox(height: _h(20, wide)),
                      _BalanceOverviewCard(
                        wide: wide,
                        onViewDetails: () => Navigator.pushNamed(context, '/ownerBalance'),
                        revenue: _revenue,
                      ),
                      SizedBox(height: _h(20, wide)),
                      _QuickLinksSection(
                        wide: wide,
                        onViewBalance: () => Navigator.pushNamed(context, '/ownerBalance'),
                      ),
                      SizedBox(height: _h(20, wide)),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final bool wide;
  final String name, email;
  final String? profileImageUrl;
  final VoidCallback onProfileTap;
  const _HeaderCard({
    required this.wide,
    required this.name,
    required this.email,
    required this.profileImageUrl,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(_w(16, wide)),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(_r(16, wide)),
        border: Border.all(color: _divider),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(children: [
        GestureDetector(
          onTap: onProfileTap,
          child: Container(
            width: wide ? 60 : 60.w,
            height: wide ? 60 : 60.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _brown, width: 2),
              image: profileImageUrl != null
                  ? DecorationImage(image: NetworkImage(profileImageUrl!), fit: BoxFit.cover)
                  : null,
              color: profileImageUrl == null ? _brown.withValues(alpha: 0.1) : null,
            ),
            child: profileImageUrl == null
                ? Icon(Icons.person_rounded, size: _s(30, wide), color: _brown)
                : null,
          ),
        ),
        SizedBox(width: _w(14, wide)),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            name.isEmpty ? 'Owner' : name,
            style: GoogleFonts.playfairDisplay(
                fontSize: _s(18, wide), fontWeight: FontWeight.bold, color: _ink),
          ),
          SizedBox(height: _h(4, wide)),
          Text(
            email.isEmpty ? 'email@example.com' : email,
            style: GoogleFonts.dmSans(fontSize: _s(12, wide), color: _muted),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: _h(8, wide)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: _w(10, wide), vertical: _h(4, wide)),
            decoration: BoxDecoration(
              color: _tagBg,
              borderRadius: BorderRadius.circular(_r(20, wide)),
              border: Border.all(color: _divider),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.home_work_outlined, size: _s(11, wide), color: _brown),
              SizedBox(width: _w(4, wide)),
              Text('Homestay Owner',
                  style: GoogleFonts.dmSans(
                      fontSize: _s(11, wide), color: _brown, fontWeight: FontWeight.w600)),
            ]),
          ),
        ])),
        GestureDetector(
          onTap: onProfileTap,
          child: Container(
            padding: EdgeInsets.all(_w(8, wide)),
            decoration: const BoxDecoration(color: _tagBg, shape: BoxShape.circle),
            child: Icon(Icons.arrow_forward_rounded, size: _s(16, wide), color: _brown),
          ),
        ),
      ]),
    );
  }
}

class _QuickStatsSection extends StatelessWidget {
  final bool wide;
  const _QuickStatsSection({required this.wide});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Quick Overview',
          style: GoogleFonts.dmSans(
              fontSize: _s(16, wide), fontWeight: FontWeight.bold, color: _ink)),
      SizedBox(height: _h(12, wide)),
      Row(children: [
        Expanded(child: _StatCard(wide: wide, icon: Icons.calendar_month_outlined, label: 'Bookings',   value: '12',  color: _slate)),
        SizedBox(width: _w(10, wide)),
        Expanded(child: _StatCard(wide: wide, icon: Icons.home_work_outlined,      label: 'Properties', value: '2',   color: _brown)),
        SizedBox(width: _w(10, wide)),
        Expanded(child: _StatCard(wide: wide, icon: Icons.star_rounded,            label: 'Rating',     value: '4.8', color: _green)),
      ]),
    ]);
  }
}

class _StatCard extends StatelessWidget {
  final bool wide;
  final IconData icon;
  final String label, value;
  final Color color;
  const _StatCard({required this.wide, required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(_w(12, wide)),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(_r(12, wide)),
        border: Border.all(color: _divider),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
          padding: EdgeInsets.all(_w(8, wide)),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(_r(8, wide))),
          child: Icon(icon, size: _s(16, wide), color: color),
        ),
        SizedBox(height: _h(6, wide)),
        Text(value,
            style: GoogleFonts.dmSans(
                fontSize: _s(16, wide), fontWeight: FontWeight.bold, color: _ink)),
        SizedBox(height: _h(2, wide)),
        Text(label,
            style: GoogleFonts.dmSans(fontSize: _s(10, wide), color: _muted),
            textAlign: TextAlign.center),
      ]),
    );
  }
}

class _BalanceOverviewCard extends StatelessWidget {
  final bool wide;
  final VoidCallback onViewDetails;
  final OwnerRevenueLoaded? revenue;
  const _BalanceOverviewCard({required this.wide, required this.onViewDetails, required this.revenue});

  @override
  Widget build(BuildContext context) {
    final available = revenue?.totalRevenue ?? 0.0;
    return Container(
      padding: EdgeInsets.all(_w(16, wide)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [_slate, Color(0xFF3D5A6F)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(_r(16, wide)),
        boxShadow: [BoxShadow(color: _slate.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Available Balance',
              style: GoogleFonts.dmSans(fontSize: _s(13, wide), color: Colors.white70)),
          Icon(Icons.account_balance_wallet_rounded, size: _s(20, wide), color: Colors.white70),
        ]),
        SizedBox(height: _h(12, wide)),
        Text('Rs. ${available.toStringAsFixed(0)}',
            style: GoogleFonts.playfairDisplay(
                fontSize: _s(32, wide), fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: _h(12, wide)),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('This Month',
                style: GoogleFonts.dmSans(fontSize: _s(11, wide), color: Colors.white60)),
            SizedBox(height: _h(2, wide)),
            Text('Rs. ${available.toStringAsFixed(0)}',
                style: GoogleFonts.dmSans(
                    fontSize: _s(14, wide), fontWeight: FontWeight.bold, color: Colors.white)),
          ]),
          ElevatedButton(
            onPressed: onViewDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, foregroundColor: _slate, elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: _w(16, wide), vertical: _h(8, wide)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_r(10, wide))),
            ),
            child: Text('View Details',
                style: GoogleFonts.dmSans(fontSize: _s(12, wide), fontWeight: FontWeight.bold)),
          ),
        ]),
      ]),
    );
  }
}

class _QuickLinksSection extends StatelessWidget {
  final bool wide;
  final VoidCallback onViewBalance;
  const _QuickLinksSection({required this.wide, required this.onViewBalance});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Quick Actions',
          style: GoogleFonts.dmSans(
              fontSize: _s(16, wide), fontWeight: FontWeight.bold, color: _ink)),
      SizedBox(height: _h(12, wide)),
      _ActionButton(wide: wide, icon: Icons.account_balance_wallet_outlined,
          title: 'Manage Balance', subtitle: 'View earnings and payment methods',
          color: _green, onTap: onViewBalance),
      SizedBox(height: _h(10, wide)),
      _ActionButton(wide: wide, icon: Icons.calendar_month_outlined,
          title: 'View Bookings', subtitle: 'Check pending and confirmed bookings',
          color: _slate, onTap: () => Navigator.pushNamed(context, '/ownerBookings')),
      SizedBox(height: _h(10, wide)),
      _ActionButton(wide: wide, icon: Icons.home_work_outlined,
          title: 'Manage Listings', subtitle: 'Edit your homestay details',
          color: _brown, onTap: () => Navigator.pushNamed(context, '/ownerListings')),
    ]);
  }
}

class _ActionButton extends StatelessWidget {
  final bool wide;
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({
    required this.wide, required this.icon, required this.title,
    required this.subtitle, required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(_w(14, wide)),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(_r(12, wide)),
          border: Border.all(color: _divider),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          Container(
            padding: EdgeInsets.all(_w(10, wide)),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(_r(10, wide))),
            child: Icon(icon, size: _s(18, wide), color: color),
          ),
          SizedBox(width: _w(12, wide)),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: GoogleFonts.dmSans(
                    fontSize: _s(13, wide), fontWeight: FontWeight.w600, color: _ink)),
            SizedBox(height: _h(2, wide)),
            Text(subtitle,
                style: GoogleFonts.dmSans(fontSize: _s(11, wide), color: _muted)),
          ])),
          Icon(Icons.arrow_forward_rounded, size: _s(18, wide), color: _muted),
        ]),
      ),
    );
  }
}

