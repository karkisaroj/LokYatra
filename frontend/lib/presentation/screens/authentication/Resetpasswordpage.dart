import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/services/constants.dart';
import 'loginPage.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  const ResetPasswordPage({super.key, required this.email});
  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  static const ink    = Color(0xFF2D1B10);
  static const accent = Color(0xFF3C3B3B);

  final _formKey      = GlobalKey<FormState>();
  final _tokenCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();

  bool _loading      = false;
  bool _showPassword = false;
  bool _showConfirm  = false;
  bool _success      = false;

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
      final res = await _dio.post(resetPassword, data: {
        'email':       widget.email,
        'token':       _tokenCtrl.text.trim(),
        'newPassword': _passwordCtrl.text,
      });
      if (!mounted) return;
      if (res.statusCode == 200) {
        setState(() => _success = true);
      } else {
        final msg =
            (res.data as Map?)?['message'] ?? 'Reset failed';
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
          child: _success ? _buildSuccess() : _buildForm()),
    );
  }

  Widget _buildForm() {
    return Center(
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
                    child: const Icon(Icons.mark_email_read_outlined,
                        color: accent, size: 28),
                  ),
                  const SizedBox(height: 20),
                  Text('Check Your Email',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: ink)),
                  const SizedBox(height: 10),
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: 'We sent a 6-digit code to ',
                        style: GoogleFonts.dmSans(
                            fontSize: 14, color: Colors.grey[500]),
                      ),
                      TextSpan(
                        text: widget.email,
                        style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: accent),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 28),
                  Text('Reset Code',
                      style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: ink)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _tokenCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8.0,
                        color: ink),
                    decoration: InputDecoration(
                      hintText: '• • • • • •',
                      hintStyle: GoogleFonts.dmSans(
                          fontSize: 18,
                          color: Colors.grey[300],
                          letterSpacing: 6.0),
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
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 16),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Enter the 6-digit code';
                      }
                      if (v.trim().length != 6) {
                        return 'Code must be exactly 6 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  Text('New Password',
                      style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: ink)),
                  const SizedBox(height: 8),
                  _PwField(
                    ctrl: _passwordCtrl,
                    hint: 'Enter new password',
                    show: _showPassword,
                    onToggle: () =>
                        setState(() => _showPassword = !_showPassword),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Password is required';
                      }
                      if (v.length < 6) return 'Minimum 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  Text('Confirm Password',
                      style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: ink)),
                  const SizedBox(height: 8),
                  _PwField(
                    ctrl: _confirmCtrl,
                    hint: 'Re-enter new password',
                    show: _showConfirm,
                    onToggle: () =>
                        setState(() => _showConfirm = !_showConfirm),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (v != _passwordCtrl.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
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
                          : Text('Reset Password',
                          style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_ios_rounded,
                          size: 12, color: Colors.grey[500]),
                      label: Text("Didn't get the code? Go back",
                          style: GoogleFonts.dmSans(
                              fontSize: 13, color: Colors.grey[500])),
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88, height: 88,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D52).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Color(0xFF2E7D52), size: 48),
                ),
                const SizedBox(height: 28),
                Text('Password Reset!',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: ink)),
                const SizedBox(height: 12),
                Text(
                  'Your password has been updated successfully. You can now log in with your new password.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.grey[500],
                      height: 1.5),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginPage()),
                          (route) => false,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Back to Login',
                        style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}

class _PwField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final bool show;
  final VoidCallback onToggle;
  final String? Function(String?) validator;
  const _PwField({
    required this.ctrl, required this.hint,
    required this.show, required this.onToggle,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: ctrl,
    obscureText: !show,
    validator: validator,
    style: GoogleFonts.dmSans(fontSize: 14),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle:
      GoogleFonts.dmSans(color: Colors.grey[400], fontSize: 13),
      prefixIcon: Icon(Icons.lock_outline_rounded,
          color: Colors.grey[400], size: 20),
      suffixIcon: IconButton(
        icon: Icon(
            show
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.grey[400], size: 20),
        onPressed: onToggle,
      ),
      filled: true,
      fillColor: const Color(0xFFF8F8F8),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: Color(0xFFCD6E4E), width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(
          vertical: 16, horizontal: 16),
    ),
  );
}