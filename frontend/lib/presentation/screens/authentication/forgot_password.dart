import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/services/constants.dart';
import 'Resetpasswordpage.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});
  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  static const ink    = Color(0xFF2D1B10);
  static const accent = Color(0xFF474646);

  final _emailCtrl = TextEditingController();
  final _formKey   = GlobalKey<FormState>();
  bool _loading    = false;

  final Dio _dio = Dio(BaseOptions(
    baseUrl: apiBaseUrl,
    validateStatus: (s) => s != null && s < 600,
    connectTimeout: connectTimeout,
    receiveTimeout: receiveTimeout,
    sendTimeout: sendTimeout,
  ));

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final res = await _dio.post(forgetPassword,
          data: {'email': _emailCtrl.text.trim()});
      if (!mounted) return;
      if (res.statusCode == 200) {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) =>
              ResetPasswordPage(email: _emailCtrl.text.trim()),
        ));
      } else {
        final msg =
            (res.data as Map?)?['message'] ?? 'Something went wrong';
        _showError(msg.toString());
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionTimeout) {
        _showError('Request timed out. Please try again.');
      } else if (e.response != null) {
        final msg = (e.response?.data as Map?)?['message'] ?? 'Something went wrong';
        _showError(msg.toString());
      } else {
        _showError('Network error. Please try again.');
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock_reset,
                            color: accent, size: 28),
                      ),
                      const SizedBox(height: 20),
                      Text('Forgot Password?',
                          style: GoogleFonts.playfairDisplay(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: ink)),
                      const SizedBox(height: 10),
                      Text(
                        "Enter your email and we'll send you a 6-digit code to reset your password.",
                        style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: Colors.grey[500],
                            height: 1.5),
                      ),
                      const SizedBox(height: 32),
                      Text('Email Address',
                          style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: ink)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.dmSans(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Enter your email address',
                          hintStyle: GoogleFonts.dmSans(
                              color: Colors.grey[400], fontSize: 13),
                          prefixIcon: Icon(
                              Icons.mail_outline_rounded,
                              color: Colors.grey[400], size: 20),
                          filled: true,
                          fillColor: const Color(0xFFF8F8F8),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              BorderSide(color: Colors.grey.shade200)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              BorderSide(color: Colors.grey.shade200)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: accent, width: 1.5)),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!v.contains('@') || !v.contains('.')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: accent.withValues(alpha: 0.15)),
                        ),
                        child: Row(children: [
                          Icon(Icons.info_outline_rounded,
                              size: 14, color: accent),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'A 6-digit code will be sent to your email. It expires in 15 minutes.',
                              style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: Colors.grey[600]),
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity, height: 50,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _loading
                              ? const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2)
                              : Text('Send Reset Code',
                              style: GoogleFonts.dmSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Back to Login',
                              style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  color: Colors.grey[500])),
                        ),
                      ),
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}