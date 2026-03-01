import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/datasources/User_remote_datasource.dart';

class OwnerChangePasswordPage extends StatefulWidget {
  const OwnerChangePasswordPage({super.key});

  @override
  State<OwnerChangePasswordPage> createState() => _OwnerChangePasswordPageState();
}

class _OwnerChangePasswordPageState extends State<OwnerChangePasswordPage> {
  static const _brown   = Color(0xFF5C4033);
  static const _dark    = Color(0xFF1C1C1C);
  static const _cream   = Color(0xFFFAF7F2);
  static const _divider = Color(0xFFEDE8E1);
  static const _muted   = Color(0xFF8A8279);
  static const _green   = Color(0xFF3D5A4F);

  final _formKey        = GlobalKey<FormState>();
  final _currentCtrl    = TextEditingController();
  final _newCtrl        = TextEditingController();
  final _confirmCtrl    = TextEditingController();

  bool _showCurrent = false;
  bool _showNew     = false;
  bool _showConfirm = false;
  bool _saving      = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final res = await UserRemoteDatasource().changePassword(
        currentPassword: _currentCtrl.text,
        newPassword:     _newCtrl.text,
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Password changed successfully!',
              style: GoogleFonts.dmSans()),
          backgroundColor: _green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        ));
        Navigator.pop(context);
      } else {
        final msg = (res.data as Map?)?['message'] ?? 'Failed to change password';
        _showError(msg.toString());
      }
    } catch (e) {
      final msg = (e is DioException)
          ? ((e.response?.data as Map?)?['message'] ?? 'Something went wrong')
          : 'Error: $e';
      _showError(msg.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.dmSans()),
      backgroundColor: Colors.red[700],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18.sp, color: _dark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Change Password',
            style: GoogleFonts.playfairDisplay(
                fontSize: 20.sp, fontWeight: FontWeight.bold, color: _dark)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: _divider),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            SizedBox(height: 8.h),

            // Info banner
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: _green.withValues(alpha: 0.2)),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.shield_outlined, size: 18.sp, color: _green),
                SizedBox(width: 10.w),
                Expanded(child: Text(
                  'For your security, enter your current password before setting a new one.',
                  style: GoogleFonts.dmSans(
                      fontSize: 12.sp, color: _green, height: 1.4),
                )),
              ]),
            ),

            SizedBox(height: 28.h),

            _Label('Current Password'),
            SizedBox(height: 6.h),
            TextFormField(
              controller: _currentCtrl,
              obscureText: !_showCurrent,
              style: GoogleFonts.dmSans(fontSize: 14.sp),
              decoration: _inputDeco(
                hint: 'Enter your current password',
                icon: Icons.lock_outline_rounded,
                showToggle: true,
                isVisible: _showCurrent,
                onToggle: () => setState(() => _showCurrent = !_showCurrent),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Current password is required';
                return null;
              },
            ),

            SizedBox(height: 20.h),

            _Label('New Password'),
            SizedBox(height: 6.h),
            TextFormField(
              controller: _newCtrl,
              obscureText: !_showNew,
              style: GoogleFonts.dmSans(fontSize: 14.sp),
              decoration: _inputDeco(
                hint: 'Enter new password',
                icon: Icons.lock_reset_rounded,
                showToggle: true,
                isVisible: _showNew,
                onToggle: () => setState(() => _showNew = !_showNew),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'New password is required';
                if (v.length < 6) return 'Minimum 6 characters';
                if (v == _currentCtrl.text) return 'New password must differ from current';
                return null;
              },
            ),

            SizedBox(height: 20.h),

            _Label('Confirm New Password'),
            SizedBox(height: 6.h),
            TextFormField(
              controller: _confirmCtrl,
              obscureText: !_showConfirm,
              style: GoogleFonts.dmSans(fontSize: 14.sp),
              decoration: _inputDeco(
                hint: 'Re-enter new password',
                icon: Icons.lock_outline_rounded,
                showToggle: true,
                isVisible: _showConfirm,
                onToggle: () => setState(() => _showConfirm = !_showConfirm),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please confirm your password';
                if (v != _newCtrl.text) return 'Passwords do not match';
                return null;
              },
            ),

            SizedBox(height: 12.h),

            // Password rules
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: _divider),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Password must:',
                    style: GoogleFonts.dmSans(
                        fontSize: 11.sp, fontWeight: FontWeight.w600,
                        color: _muted)),
                SizedBox(height: 6.h),
                _Rule('Be at least 6 characters long'),
                _Rule('Be different from your current password'),
              ]),
            ),

            SizedBox(height: 36.h),

            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: _saving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brown,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  disabledBackgroundColor: _brown.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r)),
                ),
                child: _saving
                    ? const CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2)
                    : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.lock_reset_rounded, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text('Update Password',
                      style: GoogleFonts.dmSans(
                          fontSize: 15.sp, fontWeight: FontWeight.bold)),
                ]),
              ),
            ),

            SizedBox(height: 20.h),
          ]),
        ),
      ),
    );
  }

  Widget _Label(String text) => Text(text,
      style: GoogleFonts.dmSans(
          fontSize: 13.sp, fontWeight: FontWeight.w600, color: _dark));

  Widget _Rule(String text) => Padding(
    padding: EdgeInsets.only(bottom: 3.h),
    child: Row(children: [
      Icon(Icons.check_circle_outline_rounded,
          size: 13.sp, color: _muted),
      SizedBox(width: 6.w),
      Text(text, style: GoogleFonts.dmSans(
          fontSize: 11.sp, color: _muted)),
    ]),
  );

  InputDecoration _inputDeco({
    required String hint,
    required IconData icon,
    bool showToggle = false,
    bool isVisible  = false,
    VoidCallback? onToggle,
  }) =>
      InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.dmSans(color: _muted, fontSize: 13.sp),
        prefixIcon: Icon(icon, color: _muted, size: 20.sp),
        suffixIcon: showToggle
            ? IconButton(
          icon: Icon(
            isVisible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: _muted, size: 20.sp,
          ),
          onPressed: onToggle,
        )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: _divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: _divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: _brown, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.red.shade300, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      );
}