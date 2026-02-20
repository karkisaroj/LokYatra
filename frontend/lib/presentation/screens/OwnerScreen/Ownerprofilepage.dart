import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/auth/auth_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/auth/auth_event.dart';
import 'package:lokyatra_frontend/presentation/widgets/Helpers/SecureStorageService.dart';

import 'ProfileImageWidget.dart';

class OwnerProfilePage extends StatefulWidget {
  const OwnerProfilePage({super.key});

  @override
  State<OwnerProfilePage> createState() => _OwnerProfilePageState();
}

class _OwnerProfilePageState extends State<OwnerProfilePage> {
  static const _brown = Color(0xFF5C4033);

  String? _profileImageUrl;
  String _name = '';
  String _email = '';
  String _phone = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final name  = await SecureStorageService.getUserName();
    final email = await SecureStorageService.getUserEmail();
    final image = await SecureStorageService.getProfileImage();
    final phone = await SecureStorageService.getPhoneNumber();
    if (!mounted) return;
    setState(() {
      _name  = name  ?? '';
      _email = email ?? '';
      _phone = phone ?? '';
      _profileImageUrl = (image != null && image.isNotEmpty) ? image : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            children: [
              SizedBox(height: 20.h),

              // Profile image
              ProfileImageWidget(
                initialImageUrl: _profileImageUrl,
                accentColor: _brown,
                onUploaded: (newUrl) =>
                    setState(() => _profileImageUrl = newUrl),
              ),

              SizedBox(height: 14.h),

              // Name
              Text(
                _name.isEmpty ? 'Owner' : _name,
                style: GoogleFonts.playfairDisplay(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D1B10)),
              ),
              SizedBox(height: 4.h),

              // Email
              Text(_email,
                  style: GoogleFonts.dmSans(
                      fontSize: 13.sp, color: Colors.grey[500])),

              // Phone
              if (_phone.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Text(_phone,
                    style: GoogleFonts.dmSans(
                        fontSize: 12.sp, color: Colors.grey[400])),
              ],

              SizedBox(height: 6.h),

              // Role badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
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

              // Menu items
              ...[
                (Icons.person_outline_rounded, 'Edit Profile'),
                (Icons.notifications_outlined, 'Notifications'),
                (Icons.help_outline_rounded, 'Help & Support'),
                (Icons.info_outline_rounded, 'About LokYatra'),
              ].map((item) => _MenuItem(icon: item.$1, label: item.$2)),

              SizedBox(height: 24.h),

              // Logout
              SizedBox(
                width: double.infinity,
                height: 48.h,
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
                        borderRadius: BorderRadius.circular(12.r)),
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