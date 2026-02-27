import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/services/sqlite_service.dart';
import 'package:lokyatra_frontend/data/datasources/user_remote_datasource.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/auth/auth_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/auth/auth_event.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/booking/booking_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/booking/booking_event.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/booking/booking_state.dart';
import '../OwnerScreen/ProfileImageWidget.dart';
import 'Savedhomestayspage.dart';
import 'TouristBookingsPage.dart';
import 'QuizHistoryPage.dart';
import 'EditProfilePage.dart';
import 'HelpSupportPage.dart';
import 'AboutLokyatraPage.dart';
import 'ChangePasswordPage.dart';

class TouristProfilePage extends StatefulWidget {
  const TouristProfilePage({super.key});

  @override
  State<TouristProfilePage> createState() => _TouristProfilePageState();
}

class _TouristProfilePageState extends State<TouristProfilePage> {
  static const _terracotta = Color(0xFFCD6E4E);
  static const _dark       = Color(0xFF2D1B10);
  static const _cream      = Color(0xFFFAF7F2);

  String? _profileImageUrl;
  String _name   = '';
  String _email  = '';
  String _phone  = '';
  int    _quizPoints = 0;
  bool   _loading    = true;

  bool get _isVerified => _name.trim().isNotEmpty && _phone.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadBookingCount();
  }

  Future<void> _loadProfile() async {
    final name   = await SqliteService().get('user_name');
    final email  = await SqliteService().get('user_email');
    final image  = await SqliteService().get('user_image');
    final phone  = await SqliteService().get('user_phone');
    final points = await SqliteService().get('user_quiz_points');

    if (mounted) {
      setState(() {
        _name        = name  ?? '';
        _email       = email ?? '';
        _phone       = phone ?? '';
        _quizPoints  = int.tryParse(points ?? '0') ?? 0;
        _profileImageUrl = (image != null && image.isNotEmpty) ? image : null;
      });
    }

    await _fetchFromServer();
  }

  Future<void> _fetchFromServer() async {
    try {
      final res = await UserRemoteDatasource().getCurrentUser();
      if (res.statusCode == 200) {
        final data       = res.data as Map<String, dynamic>;
        final serverName  = data['name']         as String? ?? '';
        final serverEmail = data['email']        as String? ?? '';
        final serverPhone = data['phoneNumber']  as String? ?? '';
        final serverImage = data['profileImage'] as String? ?? '';
        final serverPts   = data['quizPoints']   as int?    ?? 0;

        await SqliteService().put('user_name',        serverName);
        await SqliteService().put('user_email',       serverEmail);
        await SqliteService().put('user_phone',       serverPhone);
        await SqliteService().put('user_image',       serverImage);
        await SqliteService().put('user_quiz_points', serverPts.toString());

        if (mounted) {
          setState(() {
            _name        = serverName;
            _email       = serverEmail;
            _phone       = serverPhone;
            _quizPoints  = serverPts;
            _profileImageUrl = serverImage.isNotEmpty ? serverImage : null;
          });
        }
      }
    } catch (e) {
      debugPrint('fetchProfile error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadBookingCount() async {
    try { context.read<BookingBloc>().add(const LoadMyBookings()); } catch (_) {}
  }

  void _goToQuizHistory() {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const QuizHistoryPage()));
  }

  void _goToEditProfile() async {
    final updated = await Navigator.push<bool>(context,
        MaterialPageRoute(builder: (_) => const EditProfilePage()));
    if (updated == true) _loadProfile();
  }

  void _goToChangePassword() {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const ChangePasswordPage()));
  }

  void _goToHelpSupport() {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const HelpSupportPage()));
  }

  void _goToAbout() {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const AboutLokyatraPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(children: [
            _buildHeader(),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
              child: _buildPointsCard(),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _buildActivitySection(),
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _buildSettingsSection(),
            ),
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _buildLogout(),
            ),
            SizedBox(height: 32.h),
          ]),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 28.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28.r)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Profile',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 22.sp, fontWeight: FontWeight.bold, color: _dark)),
          IconButton(
            icon: Icon(Icons.edit_outlined, size: 20.sp, color: Colors.grey[500]),
            onPressed: _goToEditProfile,
            tooltip: 'Edit Profile',
          ),
        ]),
        SizedBox(height: 20.h),

        ProfileImageWidget(
          initialImageUrl: _profileImageUrl,
          accentColor: _terracotta,
          onUploaded: (newUrl) async {
            setState(() => _profileImageUrl = newUrl);
            await SqliteService().put('user_image', newUrl);
          },
        ),
        SizedBox(height: 14.h),

        // Name + verified badge
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            _name.isEmpty ? 'Tourist' : _name,
            style: GoogleFonts.playfairDisplay(
                fontSize: 20.sp, fontWeight: FontWeight.bold, color: _dark),
          ),
          if (_isVerified) ...[
            SizedBox(width: 6.w),
            Icon(Icons.verified_rounded, size: 20.sp, color: Colors.green[600]),
          ],
        ]),
        SizedBox(height: 4.h),
        Text(_email,
            style: GoogleFonts.dmSans(fontSize: 13.sp, color: Colors.grey[500])),
        if (_phone.isNotEmpty) ...[
          SizedBox(height: 2.h),
          Text(_phone,
              style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.grey[400])),
        ],
        SizedBox(height: 10.h),

        // Role badge + verified label
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: _terracotta.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: _terracotta.withValues(alpha: 0.3)),
            ),
            child: Text('Tourist',
                style: GoogleFonts.dmSans(fontSize: 12.sp,
                    color: _terracotta, fontWeight: FontWeight.w600)),
          ),
          if (_isVerified) ...[
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.verified_rounded,
                    size: 12.sp, color: Colors.green[700]),
                SizedBox(width: 4.w),
                Text('Verified',
                    style: GoogleFonts.dmSans(fontSize: 11.sp,
                        color: Colors.green[700], fontWeight: FontWeight.bold)),
              ]),
            ),
          ],
        ]),
      ]),
    );
  }

  Widget _buildPointsCard() {
    return Container(
      margin: EdgeInsets.only(top: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _terracotta.withValues(alpha: 0.12),
            _terracotta.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _terracotta.withValues(alpha: 0.15)),
      ),
      child: Row(children: [
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Total Points',
              style: GoogleFonts.dmSans(fontSize: 13.sp, color: Colors.grey[600])),
          SizedBox(height: 4.h),
          Text('$_quizPoints',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 36.sp, fontWeight: FontWeight.bold, color: _dark)),
          SizedBox(height: 4.h),
          Text('≈ Rs. ${(_quizPoints / 2).toStringAsFixed(0)} discount value',
              style: GoogleFonts.dmSans(
                  fontSize: 12.sp, color: Colors.grey[500])),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: _goToQuizHistory,
            child: Row(children: [
              Text('View Points History',
                  style: GoogleFonts.dmSans(fontSize: 13.sp,
                      color: _terracotta, fontWeight: FontWeight.w600)),
              SizedBox(width: 4.w),
              Icon(Icons.chevron_right_rounded, size: 16.sp, color: _terracotta),
            ]),
          ),
        ])),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: _terracotta.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.workspace_premium_rounded,
              size: 36.sp, color: _terracotta),
        ),
      ]),
    );
  }

  Widget _buildActivitySection() {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        int upcomingCount = 0;
        if (state is MyBookingsLoaded) {
          upcomingCount = state.bookings.where((b) {
            final s = (b['booking']?['status'] ?? '').toString();
            return s == 'Pending' || s == 'Confirmed';
          }).length;
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(children: [
            _ActivityTile(
              icon: Icons.calendar_month_outlined,
              iconColor: _terracotta,
              label: 'My Bookings',
              sublabel: upcomingCount > 0
                  ? '$upcomingCount upcoming'
                  : 'No upcoming bookings',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => BlocProvider.value(
                    value: context.read<BookingBloc>(),
                    child: const TouristBookingsPage(),
                  ))),
              isFirst: true,
            ),
            _divider(),
            _ActivityTile(
              icon: Icons.favorite_outline_rounded,
              iconColor: Colors.redAccent,
              label: 'Your Saved',
              sublabel: 'Saved homestays',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SavedHomestaysPage())),
            ),
            _divider(),
            _ActivityTile(
              icon: Icons.rate_review_outlined,
              iconColor: Colors.amber[700]!,
              label: 'My Reviews',
              sublabel: 'Coming soon',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Reviews coming soon!',
                      style: GoogleFonts.dmSans()),
                  behavior: SnackBarBehavior.floating,
                ),
              ),
            ),
            _divider(),
            _ActivityTile(
              icon: Icons.emoji_events_outlined,
              iconColor: Colors.green[700]!,
              label: 'Quiz History',
              sublabel: '$_quizPoints total points earned',
              onTap: _goToQuizHistory,
              isLast: true,
            ),
          ]),
        );
      },
    );
  }

  Widget _divider() => Divider(
      height: 1, indent: 20.w, endIndent: 20.w,
      color: Colors.grey.shade100);

  Widget _buildSettingsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        _ActivityTile(
          icon: Icons.person_outline_rounded,
          iconColor: Colors.blue[600]!,
          label: 'Edit Profile',
          sublabel: _isVerified
              ? 'Verified profile'
              : 'Add phone to get verified',
          trailing: _isVerified
              ? Icon(Icons.verified_rounded,
              size: 16.sp, color: Colors.green[600])
              : null,
          onTap: _goToEditProfile,
          isFirst: true,
        ),
        _divider(),
        _ActivityTile(
          icon: Icons.lock_reset_rounded,
          iconColor: Colors.orange[700]!,
          label: 'Change Password',
          sublabel: 'Update your password',
          onTap: _goToChangePassword,
        ),
        _divider(),
        _ActivityTile(
          icon: Icons.notifications_outlined,
          iconColor: Colors.purple[600]!,
          label: 'Notifications',
          sublabel: 'Coming soon',
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Notifications coming soon!',
                  style: GoogleFonts.dmSans()),
              behavior: SnackBarBehavior.floating,
            ),
          ),
        ),
        _divider(),
        _ActivityTile(
          icon: Icons.help_outline_rounded,
          iconColor: Colors.teal[600]!,
          label: 'Help & Support',
          sublabel: 'Get assistance',
          onTap: _goToHelpSupport,
        ),
        _divider(),
        _ActivityTile(
          icon: Icons.info_outline_rounded,
          iconColor: Colors.grey[600]!,
          label: 'About LokYatra',
          sublabel: 'v1.0.0',
          onTap: _goToAbout,
          isLast: true,
        ),
      ]),
    );
  }

  Widget _buildLogout() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: OutlinedButton.icon(
        onPressed: () {
          context.read<AuthBloc>().add(LogoutButtonClicked());
          Navigator.pushReplacementNamed(context, '/login');
        },
        icon: Icon(Icons.logout_rounded, size: 18.sp),
        label: Text('Logout',
            style: GoogleFonts.dmSans(
                fontSize: 14.sp, fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red[600],
          side: BorderSide(color: Colors.red.shade300),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r)),
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String sublabel;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool isFirst;
  final bool isLast;

  const _ActivityTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.sublabel,
    required this.onTap,
    this.trailing,
    this.isFirst = false,
    this.isLast  = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top:    isFirst ? Radius.circular(20.r) : Radius.zero,
          bottom: isLast  ? Radius.circular(20.r) : Radius.zero,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(children: [
            Container(
              width: 42.w, height: 42.h,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, size: 20.sp, color: iconColor),
            ),
            SizedBox(width: 14.w),
            Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: GoogleFonts.dmSans(fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D1B10))),
              SizedBox(height: 2.h),
              Text(sublabel,
                  style: GoogleFonts.dmSans(
                      fontSize: 12.sp, color: Colors.grey[500])),
            ])),
            if (trailing != null) ...[
              trailing!,
              SizedBox(width: 4.w),
            ],
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey[350], size: 20.sp),
          ]),
        ),
      ),
    );
  }
}