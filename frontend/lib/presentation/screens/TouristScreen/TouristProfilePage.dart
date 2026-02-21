import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/data/datasources/user_remote_datasource.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/auth/auth_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/auth/auth_event.dart';
import 'package:lokyatra_frontend/presentation/widgets/Helpers/SecureStorageService.dart';
import '../OwnerScreen/ProfileImageWidget.dart';

class TouristProfilePage extends StatefulWidget {
  const TouristProfilePage({super.key});

  @override
  State<TouristProfilePage> createState() => _TouristProfilePageState();
}

class _TouristProfilePageState extends State<TouristProfilePage> {
  static const _brown = Color(0xFF5C4033);

  String? _profileImageUrl;
  String _name = '';
  String _email = '';
  String _phone = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    // First load from local SharedPreferences (fast)
    final name  = await SecureStorageService.getUserName();
    final email = await SecureStorageService.getUserEmail();
    final image = await SecureStorageService.getProfileImage();
    final phone = await SecureStorageService.getPhoneNumber();

    if (mounted) {
      setState(() {
        _name  = name  ?? '';
        _email = email ?? '';
        _phone = phone ?? '';
        _profileImageUrl = (image != null && image.isNotEmpty) ? image : null;
      });
    }

    // If profile image is missing locally, fetch fresh from backend
    // This covers the case after logout → login where prefs were cleared
    if (image == null || image.isEmpty) {
      await _fetchFromServer();
    } else {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _fetchFromServer() async {
    try {
      final res = await UserRemoteDatasource().getMe();
      print('getMe status: ${res.statusCode}');
      print('getMe data: ${res.data}');
      if (res.statusCode == 200) {
        final data = res.data as Map<String, dynamic>;
        final serverName  = data['name']         as String? ?? '';
        final serverEmail = data['email']        as String? ?? '';
        final serverPhone = data['phoneNumber']  as String? ?? '';
        final serverImage = data['profileImage'] as String? ?? '';

        // Save fresh data back to SharedPreferences
        await SecureStorageService.saveUserProfile(
          name: serverName,
          email: serverEmail,
          profileImage: serverImage,
          phoneNumber: serverPhone,
        );

        if (mounted) {
          setState(() {
            _name  = serverName;
            _email = serverEmail;
            _phone = serverPhone;
            _profileImageUrl =
            serverImage.isNotEmpty ? serverImage : null;
          });
        }
      }
    } catch (e) {
      print('getMe error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F4),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding:
          EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            children: [
              SizedBox(height: 20.h),

              // Profile image — tappable to change
              ProfileImageWidget(
                initialImageUrl: _profileImageUrl,
                accentColor: _brown,
                onUploaded: (newUrl) =>
                    setState(() => _profileImageUrl = newUrl),
              ),

              SizedBox(height: 14.h),

              Text(
                _name.isEmpty ? 'Owner' : _name,
                style: GoogleFonts.playfairDisplay(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D1B10)),
              ),
              SizedBox(height: 4.h),

              Text(_email,
                  style: GoogleFonts.dmSans(
                      fontSize: 13.sp, color: Colors.grey[500])),

              if (_phone.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Text(_phone,
                    style: GoogleFonts.dmSans(
                        fontSize: 12.sp, color: Colors.grey[400])),
              ],

              SizedBox(height: 6.h),

              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _brown.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text('Homestay Owner',
                    style: GoogleFonts.dmSans(
                        fontSize: 12.sp,
                        color: _brown,
                        fontWeight: FontWeight.w600)),
              ),

              SizedBox(height: 28.h),

              ...[
                (Icons.person_outline_rounded, 'Edit Profile'),
                (Icons.notifications_outlined, 'Notifications'),
                (Icons.help_outline_rounded, 'Help & Support'),
                (Icons.info_outline_rounded, 'About LokYatra'),
              ].map((item) =>
                  _MenuItem(icon: item.$1, label: item.$2)),

              SizedBox(height: 24.h),

              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: OutlinedButton.icon(
                  onPressed: () {
                    context
                        .read<AuthBloc>()
                        .add(LogoutButtonClicked());
                    Navigator.pushReplacementNamed(
                        context, '/login');
                  },
                  icon: Icon(Icons.logout_rounded, size: 18.sp),
                  label: Text('Logout',
                      style: GoogleFonts.dmSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red[600],
                    side: BorderSide(color: Colors.red.shade300),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12.r)),
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

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  static const _brown = Color(0xFF5C4033);

  const _MenuItem({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: _brown.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 18.sp, color: _brown),
        ),
        title: Text(label,
            style: GoogleFonts.dmSans(
                fontSize: 14.sp, fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.chevron_right_rounded,
            color: Colors.grey[400], size: 20.sp),
      ),
    );
  }
}