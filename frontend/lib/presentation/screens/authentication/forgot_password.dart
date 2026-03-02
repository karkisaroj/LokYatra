import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/constants.dart';
import 'Resetpasswordpage.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  static const _brown = Color(0xFF7E695C);
  static const _dark  = Color(0xFF2D1B10);
  static const _cream = Color(0xFFFAF7F2);

  final _emailCtrl = TextEditingController();
  final _formKey   = GlobalKey<FormState>();
  bool _loading    = false;

  final Dio _dio = Dio(BaseOptions(
    baseUrl: apiBaseUrl,
    validateStatus: (s) => s != null && s < 600,
  ));

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final res = await _dio.post(forgetPassword, data: {
        'email': _emailCtrl.text.trim(),
      });

      if (!mounted) return;

      if (res.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResetPasswordPage(email: _emailCtrl.text.trim()),
          ),
        );
      } else {
        final msg = (res.data as Map?)?['message'] ?? 'Something went wrong';
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
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 20.h),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              SizedBox(height: 40.h),

              Container(
                width: 60.w, height: 60.h,
                decoration: BoxDecoration(
                  color: _cream,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lock_reset_rounded, color: _brown, size: 30.sp),
              ),

              SizedBox(height: 24.h),

              Text('Forgot Password?',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 28.sp, fontWeight: FontWeight.bold, color: _dark)),

              SizedBox(height: 10.h),

              Text("Enter your email and we'll send you a 6-digit code to reset your password.",
                  style: GoogleFonts.dmSans(fontSize: 14.sp, color: Colors.grey[600], height: 1.5)),

              SizedBox(height: 36.h),

              Text('Email Address',
                  style: GoogleFonts.dmSans(
                      fontSize: 13.sp, fontWeight: FontWeight.w600, color: _dark)),

              SizedBox(height: 8.h),

              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.dmSans(fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: 'Enter your email address',
                  hintStyle: GoogleFonts.dmSans(color: Colors.grey[400], fontSize: 13.sp),
                  prefixIcon: Icon(Icons.mail_outline_rounded, color: Colors.grey[400], size: 20.sp),
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
                  if (v == null || v.trim().isEmpty) return 'Email is required';
                  if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
                  return null;
                },
              ),

              SizedBox(height: 12.h),

              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(children: [
                  Icon(Icons.info_outline_rounded, size: 14.sp, color: Colors.amber[700]),
                  SizedBox(width: 8.w),
                  Expanded(child: Text(
                    'A 6-digit code will be sent to your email. It expires in 15 minutes.',
                    style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.amber[900]),
                  )),
                ]),
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
                      : Text('Send Reset Code',
                      style: GoogleFonts.dmSans(
                          fontSize: 15.sp, fontWeight: FontWeight.bold)),
                ),
              ),

              SizedBox(height: 20.h),

              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Back to Login',
                      style: GoogleFonts.dmSans(
                          fontSize: 14.sp,
                          color: Colors.grey[500],
                          decoration: TextDecoration.underline)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}