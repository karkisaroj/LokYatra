import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/datasources/User_remote_datasource.dart';

const pageInk    = Color(0xFF2D1B10);
const pageAccent = Color(0xFFCD6E4E);
const pageCream  = Color(0xFFFAF7F2);
const pageGreen  = Color(0xFF2E7D52);

double fontSize(double v, bool wide)   => wide ? v : v.sp;
double widthVal(double v, bool wide)   => wide ? v : v.w;
double heightVal(double v, bool wide)  => wide ? v : v.h;
double radiusVal(double v, bool wide)  => wide ? v : v.r;

class OwnerChangePasswordPage extends StatefulWidget {
  const OwnerChangePasswordPage({super.key});
  @override
  State<OwnerChangePasswordPage> createState() => OwnerChangePasswordPageState();
}

class OwnerChangePasswordPageState extends State<OwnerChangePasswordPage> {
  final formKey  = GlobalKey<FormState>();
  final currCtrl = TextEditingController();
  final nextCtrl = TextEditingController();
  final confCtrl = TextEditingController();
  bool showCurr  = false;
  bool showNext  = false;
  bool showConf  = false;
  bool busy      = false;

  @override
  void dispose() {
    currCtrl.dispose(); nextCtrl.dispose(); confCtrl.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => busy = true);
    try {
      final res = await UserRemoteDatasource().changePassword(
          currentPassword: currCtrl.text, newPassword: nextCtrl.text);
      if (!mounted) return;
      if (res.statusCode == 200) {
        final wide = MediaQuery.of(context).size.width > 700;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Password changed successfully!', style: GoogleFonts.dmSans()),
            backgroundColor: pageGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radiusVal(10, wide)))));
        Navigator.pop(context);
      } else {
        showError(((res.data as Map?)?['message'] ?? 'Failed to change password').toString());
      }
    } catch (e) {
      showError(e is DioException
          ? ((e.response?.data as Map?)?['message'] ?? 'Something went wrong').toString()
          : 'Error: $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void showError(String msg) {
    final wide = MediaQuery.of(context).size.width > 700;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg, style: GoogleFonts.dmSans()),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusVal(10, wide)))));
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: pageCream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                size: fontSize(18, wide), color: pageInk),
            onPressed: () => Navigator.pop(context)),
        title: Text('Change Password',
            style: GoogleFonts.playfairDisplay(
                fontSize: fontSize(20, wide),
                fontWeight: FontWeight.bold,
                color: pageInk)),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(height: 1, color: Colors.grey.shade200)),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: wide ? 520 : double.infinity),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(widthVal(20, wide)),
            child: Form(
              key: formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                SizedBox(height: heightVal(8, wide)),

                Container(
                  padding: EdgeInsets.all(widthVal(14, wide)),
                  decoration: BoxDecoration(
                    color: pageGreen.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(radiusVal(12, wide)),
                    border: Border.all(color: pageGreen.withValues(alpha: 0.2)),
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(Icons.shield_outlined, size: fontSize(18, wide), color: pageGreen),
                    SizedBox(width: widthVal(10, wide)),
                    Expanded(child: Text(
                        'For your security, enter your current password before setting a new one.',
                        style: GoogleFonts.dmSans(
                            fontSize: fontSize(12, wide), color: pageGreen, height: 1.4))),
                  ]),
                ),

                SizedBox(height: heightVal(28, wide)),

                fieldLabel(wide, 'Current Password'),
                SizedBox(height: heightVal(6, wide)),
                TextFormField(
                  controller: currCtrl,
                  obscureText: !showCurr,
                  style: GoogleFonts.dmSans(fontSize: fontSize(14, wide)),
                  decoration: fieldDecoration(wide, 'Enter your current password',
                      Icons.lock_outline_rounded, showCurr,
                          () => setState(() => showCurr = !showCurr)),
                  validator: (v) =>
                  (v == null || v.isEmpty) ? 'Current password is required' : null,
                ),

                SizedBox(height: heightVal(20, wide)),

                fieldLabel(wide, 'New Password'),
                SizedBox(height: heightVal(6, wide)),
                TextFormField(
                  controller: nextCtrl,
                  obscureText: !showNext,
                  style: GoogleFonts.dmSans(fontSize: fontSize(14, wide)),
                  decoration: fieldDecoration(wide, 'Enter new password',
                      Icons.lock_reset_rounded, showNext,
                          () => setState(() => showNext = !showNext)),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'New password is required';
                    if (v.length < 6) return 'Minimum 6 characters';
                    if (v == currCtrl.text) return 'New password must differ from current';
                    return null;
                  },
                ),

                SizedBox(height: heightVal(20, wide)),

                fieldLabel(wide, 'Confirm New Password'),
                SizedBox(height: heightVal(6, wide)),
                TextFormField(
                  controller: confCtrl,
                  obscureText: !showConf,
                  style: GoogleFonts.dmSans(fontSize: fontSize(14, wide)),
                  decoration: fieldDecoration(wide, 'Re-enter new password',
                      Icons.lock_outline_rounded, showConf,
                          () => setState(() => showConf = !showConf)),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please confirm your password';
                    if (v != nextCtrl.text) return 'Passwords do not match';
                    return null;
                  },
                ),

                SizedBox(height: heightVal(12, wide)),

                Container(
                  padding: EdgeInsets.all(widthVal(12, wide)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(radiusVal(10, wide)),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Password must:',
                        style: GoogleFonts.dmSans(
                            fontSize: fontSize(11, wide),
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600])),
                    SizedBox(height: heightVal(6, wide)),
                    ruleRow(wide, 'Be at least 6 characters long'),
                    ruleRow(wide, 'Be different from your current password'),
                  ]),
                ),

                SizedBox(height: heightVal(36, wide)),

                SizedBox(
                  width: double.infinity,
                  height: heightVal(52, wide),
                  child: ElevatedButton(
                    onPressed: busy ? null : submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pageAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      disabledBackgroundColor: pageAccent.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(radiusVal(14, wide))),
                    ),
                    child: busy
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.lock_reset_rounded, size: fontSize(18, wide)),
                      SizedBox(width: widthVal(8, wide)),
                      Text('Update Password',
                          style: GoogleFonts.dmSans(
                              fontSize: fontSize(15, wide),
                              fontWeight: FontWeight.bold)),
                    ]),
                  ),
                ),

                SizedBox(height: heightVal(20, wide)),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget fieldLabel(bool wide, String text) => Text(text,
      style: GoogleFonts.dmSans(
          fontSize: fontSize(13, wide),
          fontWeight: FontWeight.w600,
          color: pageInk));

  Widget ruleRow(bool wide, String text) => Padding(
    padding: EdgeInsets.only(bottom: heightVal(3, wide)),
    child: Row(children: [
      Icon(Icons.check_circle_outline_rounded,
          size: fontSize(13, wide), color: Colors.grey[500]),
      SizedBox(width: widthVal(6, wide)),
      Text(text,
          style: GoogleFonts.dmSans(
              fontSize: fontSize(11, wide), color: Colors.grey[500])),
    ]),
  );

  InputDecoration fieldDecoration(
      bool wide,
      String hint,
      IconData icon,
      bool visible,
      VoidCallback onToggle,
      ) =>
      InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.dmSans(
            color: Colors.grey[400], fontSize: fontSize(13, wide)),
        prefixIcon: Icon(icon, color: Colors.grey[400], size: fontSize(20, wide)),
        suffixIcon: IconButton(
          icon: Icon(
              visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: Colors.grey[400],
              size: fontSize(20, wide)),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusVal(12, wide)),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusVal(12, wide)),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusVal(12, wide)),
            borderSide: const BorderSide(color: pageAccent, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusVal(12, wide)),
            borderSide: BorderSide(color: Colors.red.shade300)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusVal(12, wide)),
            borderSide: BorderSide(color: Colors.red.shade300, width: 1.5)),
        contentPadding: EdgeInsets.symmetric(
            vertical: heightVal(16, wide), horizontal: widthVal(16, wide)),
      );
}