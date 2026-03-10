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
import '../../../data/datasources/quiz_remote_datasource.dart';
import '../../state_management/Bloc/notification/notification_bloc.dart';
import '../../widgets/Helpers/NotificationsPage.dart';
import '../OwnerScreen/ProfileImageWidget.dart';
import 'MyReviewsPage.dart';
import 'Savedhomestayspage.dart';
import 'TouristBookingsPage.dart';
import 'QuizHistoryPage.dart';
import 'EditProfilePage.dart';
import 'HelpSupportPage.dart';
import 'AboutLokyatraPage.dart';
import 'ChangePasswordPage.dart';

const Color brownColor   = Color(0xFFCD6E4E);
const Color darkColor    = Color(0xFF2D1B10);
const Color pageBg       = Color(0xFFF7F3EF);

const Color headerStart  = Color(0xFFF0E6DE);
const Color headerMid    = Color(0xFFE8C9B8);
const Color headerEnd    = Color(0xFFD4906E);

const Color cardWhite    = Colors.white;

const Color accentGreen  = Color(0xFF22C55E);
const Color accentBlue   = Color(0xFF3B82F6);
const Color accentAmber  = Color(0xFFF59E0B);
const Color accentRed    = Color(0xFFEF4444);
const Color accentTeal   = Color(0xFF14B8A6);
const Color accentPurple = Color(0xFFA855F7);
const Color accentSlate  = Color(0xFF94A3B8);

class TouristProfilePage extends StatefulWidget {
  const TouristProfilePage({super.key});

  @override
  State<TouristProfilePage> createState() => _TouristProfilePageState();
}

class _TouristProfilePageState extends State<TouristProfilePage> {
  String? profileImageUrl;
  String name       = '';
  String email      = '';
  String phone      = '';
  int    quizPoints = 0;
  bool   loading    = true;

  bool get isVerified => name.trim().isNotEmpty && phone.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    loadProfile();
    loadBookingCount();
  }

  Future<void> loadProfile() async {
    final savedName   = await SqliteService().get('user_name');
    final savedEmail  = await SqliteService().get('user_email');
    final savedImage  = await SqliteService().get('user_image');
    final savedPhone  = await SqliteService().get('user_phone');
    final savedPoints = await SqliteService().get('user_quiz_points');

    if (mounted) {
      setState(() {
        name            = savedName  ?? '';
        email           = savedEmail ?? '';
        phone           = savedPhone ?? '';
        quizPoints      = int.tryParse(savedPoints ?? '0') ?? 0;
        profileImageUrl = (savedImage != null && savedImage.isNotEmpty) ? savedImage : null;
      });
    }
    await fetchFromServer();
  }

  Future<void> fetchFromServer() async {
    try {
      final res = await UserRemoteDatasource().getCurrentUser();
      if (res.statusCode == 200) {
        final data        = res.data as Map<String, dynamic>;
        final serverName  = data['name']         as String? ?? '';
        final serverEmail = data['email']        as String? ?? '';
        final serverPhone = data['phoneNumber']  as String? ?? '';
        final serverImage = data['profileImage'] as String? ?? '';

        await SqliteService().put('user_name',  serverName);
        await SqliteService().put('user_email', serverEmail);
        await SqliteService().put('user_phone', serverPhone);
        await SqliteService().put('user_image', serverImage);

        if (mounted) {
          setState(() {
            name            = serverName;
            email           = serverEmail;
            phone           = serverPhone;
            profileImageUrl = serverImage.isNotEmpty ? serverImage : null;
          });
        }
      }

      final quizRes = await QuizRemoteDatasource().getHistory();
      if (quizRes.statusCode == 200 && mounted) {
        final d       = quizRes.data as Map<String, dynamic>;
        final history = (d['history'] as List? ?? []);

        final sumFromHistory = history.fold<int>(
          0, (s, h) => s + ((h as Map)['pointsEarned'] as int? ?? 0),
        );
        final apiTotal  = d['totalPoints']  as int? ?? 0;
        final apiUsable = d['usablePoints'] as int?
            ?? d['remainingPoints'] as int?;
        final usable    = apiUsable ?? (apiTotal > 0 ? apiTotal : sumFromHistory);

        await SqliteService().put('user_quiz_points', usable.toString());
        if (mounted) setState(() => quizPoints = usable);
      }
    } catch (e) {
      debugPrint('fetchProfile error: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> loadBookingCount() async {
    try { context.read<BookingBloc>().add(const LoadMyBookings()); } catch (_) {}
  }

  void goToQuizHistory() =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizHistoryPage()));

  void goToEditProfile() async {
    final updated = await Navigator.push<bool>(
        context, MaterialPageRoute(builder: (_) => const EditProfilePage()));
    if (updated == true) loadProfile();
  }

  void goToChangePassword() =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordPage()));

  void goToHelpSupport() =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportPage()));

  void goToAbout() =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutLokyatraPage()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(children: [
          buildHeader(),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: buildPointsCard(),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: buildActivitySection(),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: buildSettingsSection(),
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: buildLogout(),
          ),
          SizedBox(height: 32.h),
        ]),
      ),
    );
  }

  Widget buildHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(bottom: 56.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [headerStart, headerMid, headerEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(36.r)),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -30, right: -30,
                child: Container(
                  width: 160.w, height: 160.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: brownColor.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: 10, left: -40,
                child: Container(
                  width: 120.w, height: 120.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: brownColor.withValues(alpha: 0.06),
                  ),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 16.w, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('My Profile',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                color: darkColor,
                              )),
                          Row(children: [
                            HeaderIconBtn(
                              icon: Icons.notifications_outlined,
                              onTap: () => Navigator.push(context, MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<NotificationBloc>(),
                                  child: const NotificationsPage(),
                                ),
                              )),
                            ),
                            SizedBox(width: 8.w),
                            HeaderIconBtn(
                              icon: Icons.edit_outlined,
                              onTap: goToEditProfile,
                            ),
                          ]),
                        ],
                      ),

                      SizedBox(height: 24.h),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding: EdgeInsets.all(3.w),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: brownColor.withValues(alpha: 0.25),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: ProfileImageWidget(
                                    initialImageUrl: profileImageUrl,
                                    accent: brownColor,
                                    onUploaded: (newUrl) async {
                                      setState(() => profileImageUrl = newUrl);
                                      await SqliteService().put('user_image', newUrl);
                                    },
                                  ),
                                ),
                              ),

                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: goToEditProfile,
                                  child: Container(
                                    width: 22.w, height: 22.w,
                                    decoration: BoxDecoration(
                                      color: brownColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 1.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: brownColor.withValues(alpha: 0.4),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(Icons.edit_rounded,
                                        size: 11.sp, color: Colors.white),
                                  ),
                                ),
                              ),

                              if (isVerified)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 22.w, height: 22.w,
                                    decoration: BoxDecoration(
                                      color: accentGreen,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 1.5),
                                    ),
                                    child: Icon(Icons.check_rounded,
                                        size: 12.sp, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),

                          SizedBox(width: 16.w),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name.isEmpty ? 'Traveller' : name,
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 21.sp,
                                    fontWeight: FontWeight.bold,
                                    color: darkColor,
                                    height: 1.1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  email,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12.sp,
                                    color: darkColor.withValues(alpha: 0.55),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (phone.isNotEmpty) ...[
                                  SizedBox(height: 2.h),
                                  Row(children: [
                                    Icon(Icons.phone_outlined,
                                        size: 11.sp,
                                        color: darkColor.withValues(alpha: 0.4)),
                                    SizedBox(width: 4.w),
                                    Text(phone,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 11.sp,
                                          color: darkColor.withValues(alpha: 0.45),
                                        )),
                                  ]),
                                ],
                                SizedBox(height: 10.h),
                                Row(children: [
                                  PillBadge(
                                    label: 'Tourist',
                                    bgColor: brownColor.withValues(alpha: 0.12),
                                    textColor: brownColor,
                                    borderColor: brownColor.withValues(alpha: 0.25),
                                  ),
                                  if (isVerified) ...[
                                    SizedBox(width: 6.w),
                                    PillBadge(
                                      label: '✓ Verified',
                                      bgColor: accentGreen.withValues(alpha: 0.12),
                                      textColor: accentGreen,
                                      borderColor: accentGreen.withValues(alpha: 0.3),
                                    ),
                                  ],
                                ]),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 28.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Floating stats card ─────────────────────────────────────
        Positioned(
          bottom: 0,
          left: 20.w,
          right: 20.w,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
            decoration: BoxDecoration(
              color: cardWhite,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: brownColor.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MiniStat(
                  icon: Icons.quiz_outlined,
                  value: '$quizPoints',
                  label: 'Quiz Pts',
                  color: brownColor,
                ),
                const VertDivider(),
                MiniStat(
                  icon: Icons.local_offer_outlined,
                  value: 'Rs. ${(quizPoints / 2).toStringAsFixed(0)}',
                  label: 'Discount',
                  color: accentGreen,
                ),
                const VertDivider(),
                MiniStat(
                  icon: Icons.verified_outlined,
                  value: isVerified ? 'Yes' : 'No',
                  label: 'Verified',
                  color: isVerified ? accentGreen : accentSlate,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPointsCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: brownColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
              color: brownColor.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Points',
                  style: GoogleFonts.dmSans(fontSize: 13.sp, color: Colors.grey[500])),
              SizedBox(height: 4.h),
              Text('$quizPoints',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 36.sp, fontWeight: FontWeight.bold, color: darkColor)),
              SizedBox(height: 4.h),
              Text('≈ Rs. ${(quizPoints / 2).toStringAsFixed(0)} discount value',
                  style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.grey[400])),
              SizedBox(height: 14.h),
              GestureDetector(
                onTap: goToQuizHistory,
                child: Row(children: [
                  Text('View Points History',
                      style: GoogleFonts.dmSans(
                          fontSize: 13.sp, color: brownColor, fontWeight: FontWeight.w600)),
                  SizedBox(width: 4.w),
                  Icon(Icons.chevron_right_rounded, size: 16.sp, color: brownColor),
                ]),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: brownColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.workspace_premium_rounded, size: 36.sp, color: brownColor),
        ),
      ]),
    );
  }

  Widget buildActivitySection() {
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
            color: cardWhite,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Column(children: [
            ActivityTile(
              icon: Icons.calendar_month_outlined,
              iconColor: brownColor,
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
            rowDivider(),
            ActivityTile(
              icon: Icons.favorite_outline_rounded,
              iconColor: accentRed,
              label: 'Your Saved',
              sublabel: 'Saved homestays',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SavedHomestaysPage())),
            ),
            rowDivider(),
            ActivityTile(
              icon: Icons.rate_review_outlined,
              iconColor: accentAmber,
              label: 'My Reviews',
              sublabel: "Reviews you've written",
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MyReviewsPage())),
            ),
            rowDivider(),
            ActivityTile(
              icon: Icons.emoji_events_outlined,
              iconColor: accentGreen,
              label: 'Quiz History',
              sublabel: '$quizPoints total points earned',
              onTap: goToQuizHistory,
              isLast: true,
            ),
          ]),
        );
      },
    );
  }

  Widget rowDivider() =>
      Divider(height: 1, indent: 20.w, endIndent: 20.w, color: Colors.grey.shade100);

  Widget buildSettingsSection() {
    return Container(
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: [
        ActivityTile(
          icon: Icons.person_outline_rounded,
          iconColor: accentBlue,
          label: 'Edit Profile',
          sublabel: isVerified ? 'Verified profile' : 'Add phone to get verified',
          trailing: isVerified
              ? Icon(Icons.verified_rounded, size: 16.sp, color: accentGreen)
              : null,
          onTap: goToEditProfile,
          isFirst: true,
        ),
        rowDivider(),
        ActivityTile(
          icon: Icons.lock_reset_rounded,
          iconColor: accentAmber,
          label: 'Change Password',
          sublabel: 'Update your password',
          onTap: goToChangePassword,
        ),
        rowDivider(),
        ActivityTile(
          icon: Icons.notifications_outlined,
          iconColor: accentPurple,
          label: 'Notifications',
          sublabel: 'View your notifications',
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => BlocProvider.value(
                value: context.read<NotificationBloc>(),
                child: const NotificationsPage(),
              ))),
        ),
        rowDivider(),
        ActivityTile(
          icon: Icons.help_outline_rounded,
          iconColor: accentTeal,
          label: 'Help & Support',
          sublabel: 'Get assistance',
          onTap: goToHelpSupport,
        ),
        rowDivider(),
        ActivityTile(
          icon: Icons.info_outline_rounded,
          iconColor: accentSlate,
          label: 'About LokYatra',
          sublabel: 'v1.0.0',
          onTap: goToAbout,
          isLast: true,
        ),
      ]),
    );
  }

  Widget buildLogout() {
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
            style: GoogleFonts.dmSans(fontSize: 14.sp, fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          foregroundColor: accentRed,
          side: BorderSide(color: accentRed.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        ),
      ),
    );
  }
}

// ── Helper widgets ──────────────────────────────────────────────────────────

class HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const HeaderIconBtn({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38.w, height: 38.w,
        decoration: BoxDecoration(
          color: brownColor.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(color: brownColor.withValues(alpha: 0.2), width: 1),
        ),
        child: Icon(icon, color: darkColor.withValues(alpha: 0.7), size: 18.sp),
      ),
    );
  }
}

class PillBadge extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  final Color borderColor;
  const PillBadge({
    super.key,
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: borderColor),
      ),
      child: Text(label,
          style: GoogleFonts.dmSans(
              fontSize: 11.sp, color: textColor, fontWeight: FontWeight.w600)),
    );
  }
}

class MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const MiniStat({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16.sp, color: color),
        SizedBox(height: 4.h),
        FittedBox(
          child: Text(value,
              style: GoogleFonts.dmSans(
                  fontSize: 13.sp, fontWeight: FontWeight.bold, color: darkColor)),
        ),
        SizedBox(height: 2.h),
        Text(label, style: GoogleFonts.dmSans(fontSize: 10.sp, color: Colors.grey[500])),
      ]),
    );
  }
}

class VertDivider extends StatelessWidget {
  const VertDivider({super.key});
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 36.h, color: Colors.grey.shade200);
}

class ActivityTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String sublabel;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool isFirst;
  final bool isLast;

  const ActivityTile({
    super.key,
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
              width: 42.w, height: 42.w,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, size: 20.sp, color: iconColor),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.dmSans(
                          fontSize: 14.sp, fontWeight: FontWeight.w600, color: darkColor)),
                  SizedBox(height: 2.h),
                  Text(sublabel,
                      style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.grey[500])),
                ],
              ),
            ),
            if (trailing != null) ...[trailing!, SizedBox(width: 4.w)],
            Icon(Icons.chevron_right_rounded, color: Colors.grey[350], size: 20.sp),
          ]),
        ),
      ),
    );
  }
}