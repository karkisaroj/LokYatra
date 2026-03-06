
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/services/sqlite_service.dart';
import 'package:lokyatra_frontend/data/datasources/user_remote_datasource.dart';
import 'package:lokyatra_frontend/presentation/widgets/Helpers/NotificationsPage.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/notification/notification_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/notification/notification_event.dart';

const _bg = Color(0xFFFAF7F2);
const _ink = Color(0xFF1C1C1C);
const _brown = Color(0xFF5C4033);
const _slate = Color(0xFF2C3A4A);
const _muted = Color(0xFF8A8279);
const _divider = Color(0xFFEDE8E1);
const _cardBg = Color(0xFFFFFFFF);
const _tagBg = Color(0xFFEEEBE5);
const _green = Color(0xFF3D5A4F);

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

  @override
  void initState() {
    super.initState();
    _loadProfile();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<NotificationBloc>().add(const StartNotificationPolling());
      }
    });
  }

  Future<void> _loadProfile() async {
    final sqlite = SqliteService();
    final name = await sqlite.get('user_name');
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
        final data = res.data as Map<String, dynamic>;
        final serverName = data['name'] as String? ?? '';
        final serverEmail = data['email'] as String? ?? '';
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

  void _navigateToProfile() {
    Navigator.pushNamed(context, '/ownerProfile').then((_) {
      _loadProfile();
    });
  }

  void _navigateToBalance() {
    Navigator.pushNamed(context, '/ownerBalance');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: RefreshIndicator(
          color: _brown,
          onRefresh: () async{
            context.read<NotificationBloc>().add(const LoadNotifications());
            await _loadProfile();
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('My Dashboard',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 22.sp, fontWeight: FontWeight.bold, color: _ink)),
                  BellButton(),
                ],
              ),
              SizedBox(height: 16.h),
              _HeaderCard(
                name: _name,
                email: _email,
                profileImageUrl: _profileImageUrl,
                onProfileTap: _navigateToProfile,
              ),

              SizedBox(height: 20.h),

              _QuickStatsSection(),

              SizedBox(height: 20.h),

              // ── Balance Overview Card ──────────────────────────────────────
              _BalanceOverviewCard(onViewDetails: _navigateToBalance),

              SizedBox(height: 20.h),

              // ── Quick Links ────────────────────────────────────────────────
              _QuickLinksSection(onViewBalance: _navigateToBalance),

              SizedBox(height: 20.h),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Header Card with Profile Picture ────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  final String name;
  final String email;
  final String? profileImageUrl;
  final VoidCallback onProfileTap;

  const _HeaderCard({
    required this.name,
    required this.email,
    required this.profileImageUrl,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Profile Picture (Clickable) ────────────────────────────────
          GestureDetector(
            onTap: onProfileTap,
            child: Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _brown, width: 2),
                image: profileImageUrl != null
                    ? DecorationImage(
                  image: NetworkImage(profileImageUrl!),
                  fit: BoxFit.cover,
                )
                    : null,
                color: profileImageUrl == null ? _brown.withValues(alpha: 0.1) : null,
              ),
              child: profileImageUrl == null
                  ? Icon(
                Icons.person_rounded,
                size: 30.sp,
                color: _brown,
              )
                  : null,
            ),
          ),

          SizedBox(width: 14.w),

          // ── Name & Email ───────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'Owner' : name,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: _ink,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  email.isEmpty ? 'email@example.com' : email,
                  style: GoogleFonts.dmSans(
                    fontSize: 12.sp,
                    color: _muted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _tagBg,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: _divider),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.home_work_outlined, size: 11.sp, color: _brown),
                      SizedBox(width: 4.w),
                      Text(
                        'Homestay Owner',
                        style: GoogleFonts.dmSans(
                          fontSize: 11.sp,
                          color: _brown,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Edit Profile Arrow ──────────────────────────────────────────
          GestureDetector(
            onTap: onProfileTap,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: _tagBg,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_forward_rounded, size: 16.sp, color: _brown),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick Stats Section ──────────────────────────────────────────────────────

class _QuickStatsSection extends StatelessWidget {
  const _QuickStatsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Overview',
          style: GoogleFonts.dmSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: _ink,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.calendar_month_outlined,
                label: 'Bookings',
                value: '12',
                color: _slate,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _StatCard(
                icon: Icons.home_work_outlined,
                label: 'Properties',
                value: '2',
                color: _brown,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _StatCard(
                icon: Icons.star_rounded,
                label: 'Rating',
                value: '4.8',
                color: _green,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 16.sp, color: color),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: _ink,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 10.sp,
              color: _muted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Balance Overview Card ────────────────────────────────────────────────────

class _BalanceOverviewCard extends StatelessWidget {
  final VoidCallback onViewDetails;

  const _BalanceOverviewCard({required this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_slate, Color(0xFF3D5A6F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: _slate.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Balance',
                style: GoogleFonts.dmSans(
                  fontSize: 13.sp,
                  color: Colors.white70,
                ),
              ),
              Icon(
                Icons.account_balance_wallet_rounded,
                size: 20.sp,
                color: Colors.white70,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'Rs. 15,000',
            style: GoogleFonts.playfairDisplay(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This Month',
                    style: GoogleFonts.dmSans(
                      fontSize: 11.sp,
                      color: Colors.white60,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Rs. 15,000',
                    style: GoogleFonts.dmSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: onViewDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _slate,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  'View Details',
                  style: GoogleFonts.dmSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Quick Links Section ──────────────────────────────────────────────────────

class _QuickLinksSection extends StatelessWidget {
  final VoidCallback onViewBalance;

  const _QuickLinksSection({required this.onViewBalance});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.dmSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: _ink,
          ),
        ),
        SizedBox(height: 12.h),
        _ActionButton(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Manage Balance',
          subtitle: 'View earnings and payment methods',
          color: _green,
          onTap: onViewBalance,
        ),
        SizedBox(height: 10.h),
        _ActionButton(
          icon: Icons.calendar_month_outlined,
          title: 'View Bookings',
          subtitle: 'Check pending and confirmed bookings',
          color: _slate,
          onTap: () => Navigator.pushNamed(context, '/ownerBookings'),
        ),
        SizedBox(height: 10.h),
        _ActionButton(
          icon: Icons.home_work_outlined,
          title: 'Manage Listings',
          subtitle: 'Edit your homestay details',
          color: _brown,
          onTap: () => Navigator.pushNamed(context, '/ownerListings'),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: _divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, size: 18.sp, color: color),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: _ink,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 11.sp,
                      color: _muted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_rounded, size: 18.sp, color: _muted),
          ],
        ),
      ),
    );
  }
}