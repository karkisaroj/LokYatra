import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/constants.dart';
import 'loginPage.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  const ResetPasswordPage({super.key, required this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  static const _brown = Color(0xFF8B5E3C);
  static const _dark  = Color(0xFF2D1B10);
  static const _cream = Color(0xFFFAF7F2);

  final _formKey      = GlobalKey<FormState>();
  final _tokenCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();

  bool _loading       = false;
  bool _showPassword  = false;
  bool _showConfirm   = false;
  bool _success       = false;

  final Dio _dio = Dio(BaseOptions(
    baseUrl: apiBaseUrl,
    validateStatus: (s) => s != null && s < 600,
  ));

  @override
  void dispose() {
    _tokenCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final res = await _dio.post('api/Auth/reset-password', data: {
        'email':       widget.email,
        'token':       _tokenCtrl.text.trim(),
        'newPassword': _passwordCtrl.text,
      });

      if (!mounted) return;

      if (res.statusCode == 200) {
        setState(() => _success = true);
      } else {
        final msg = (res.data as Map?)?['message'] ?? 'Reset failed';
        _showError(msg.toString());
      }
    } catch (e) {
      _showError('Network error. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.dmSans()),
      backgroundColor: Colors.red[700],
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _success ? _buildSuccess() : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 20.h),
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          SizedBox(height: 20.h),

          Container(
            width: 60.w, height: 60.h,
            decoration: BoxDecoration(color: _cream, shape: BoxShape.circle),
            child: Icon(Icons.mark_email_read_outlined, color: _brown, size: 30.sp),
          ),

          SizedBox(height: 24.h),

          Text('Check Your Email',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 26.sp, fontWeight: FontWeight.bold, color: _dark)),

          SizedBox(height: 10.h),

          RichText(text: TextSpan(children: [
            TextSpan(
              text: "We sent a 6-digit code to ",
              style: GoogleFonts.dmSans(fontSize: 14.sp, color: Colors.grey[600]),
            ),
            TextSpan(
              text: widget.email,
              style: GoogleFonts.dmSans(
                  fontSize: 14.sp, fontWeight: FontWeight.bold, color: _brown),
            ),
          ])),

          SizedBox(height: 32.h),

          Text('Reset Code',
              style: GoogleFonts.dmSans(
                  fontSize: 13.sp, fontWeight: FontWeight.w600, color: _dark)),
          SizedBox(height: 8.h),
          TextFormField(
            controller: _tokenCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
                fontSize: 22.sp, fontWeight: FontWeight.bold,
                letterSpacing: 8.0, color: _dark),
            decoration: InputDecoration(
              hintText: '• • • • • •',
              hintStyle: GoogleFonts.dmSans(
                  fontSize: 18.sp, color: Colors.grey[300], letterSpacing: 6.0),
              filled: true,
              fillColor: const Color(0xFFF8F8F8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: _brown, width: 1.5),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 16.h),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Enter the 6-digit code';
              if (v.trim().length != 6) return 'Code must be exactly 6 digits';
              return null;
            },
          ),

          SizedBox(height: 20.h),

          Text('New Password',
              style: GoogleFonts.dmSans(
                  fontSize: 13.sp, fontWeight: FontWeight.w600, color: _dark)),
          SizedBox(height: 8.h),
          TextFormField(
            controller: _passwordCtrl,
            obscureText: !_showPassword,
            style: GoogleFonts.dmSans(fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: 'Enter new password',
              hintStyle: GoogleFonts.dmSans(color: Colors.grey[400], fontSize: 13.sp),
              prefixIcon: Icon(Icons.lock_outline_rounded,
                  color: Colors.grey[400], size: 20.sp),
              suffixIcon: IconButton(
                icon: Icon(
                  _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey[400], size: 20.sp,
                ),
                onPressed: () => setState(() => _showPassword = !_showPassword),
              ),
              filled: true,
              fillColor: const Color(0xFFF8F8F8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: _brown, width: 1.5),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 6) return 'Minimum 6 characters';
              return null;
            },
          ),

          SizedBox(height: 16.h),

          Text('Confirm Password',
              style: GoogleFonts.dmSans(
                  fontSize: 13.sp, fontWeight: FontWeight.w600, color: _dark)),
          SizedBox(height: 8.h),
          TextFormField(
            controller: _confirmCtrl,
            obscureText: !_showConfirm,
            style: GoogleFonts.dmSans(fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: 'Re-enter new password',
              hintStyle: GoogleFonts.dmSans(color: Colors.grey[400], fontSize: 13.sp),
              prefixIcon: Icon(Icons.lock_outline_rounded,
                  color: Colors.grey[400], size: 20.sp),
              suffixIcon: IconButton(
                icon: Icon(
                  _showConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey[400], size: 20.sp,
                ),
                onPressed: () => setState(() => _showConfirm = !_showConfirm),
              ),
              filled: true,
              fillColor: const Color(0xFFF8F8F8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: _brown, width: 1.5),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please confirm your password';
              if (v != _passwordCtrl.text) return 'Passwords do not match';
              return null;
            },
          ),

          SizedBox(height: 32.h),

          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _brown,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r)),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : Text('Reset Password',
                  style: GoogleFonts.dmSans(
                      fontSize: 15.sp, fontWeight: FontWeight.bold)),
            ),
          ),

          SizedBox(height: 20.h),

          Center(
            child: TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_ios_rounded,
                  size: 12.sp, color: Colors.grey[500]),
              label: Text("Didn't get the code? Go back",
                  style: GoogleFonts.dmSans(
                      fontSize: 13.sp, color: Colors.grey[500])),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildSuccess() {
    return Padding(
      padding: EdgeInsets.all(28.w),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

        Container(
          width: 90.w, height: 90.h,
          decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9), shape: BoxShape.circle),
          child: Icon(Icons.check_rounded, color: Colors.green[700], size: 50.sp),
        ),

        SizedBox(height: 28.h),

        Text('Password Reset!',
            style: GoogleFonts.playfairDisplay(
                fontSize: 28.sp, fontWeight: FontWeight.bold, color: _dark)),

        SizedBox(height: 12.h),

        Text(
          'Your password has been updated successfully. You can now log in with your new password.',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(fontSize: 14.sp, color: Colors.grey[600], height: 1.5),
        ),

        SizedBox(height: 40.h),

        SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton(
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _brown,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r)),
            ),
            child: Text('Back to Login',
                style: GoogleFonts.dmSans(
                    fontSize: 15.sp, fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    );
  }
}