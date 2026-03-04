import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/services/sqlite_service.dart';
import 'package:lokyatra_frontend/data/datasources/user_remote_datasource.dart';
import '../OwnerScreen/ProfileImageWidget.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  static const _brown      = Color(0xFF8B5E3C);
  static const _terracotta = Color(0xFFCD6E4E);
  static const _dark       = Color(0xFF2D1B10);
  static const _cream      = Color(0xFFFAF7F2);

  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();

  String? _profileImageUrl;
  String  _email   = '';
  bool    _loading = true;
  bool    _saving  = false;

  bool get _isVerified =>
      _nameCtrl.text.trim().isNotEmpty && _phoneCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _nameCtrl.addListener(() => setState(() {}));
    _phoneCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final name  = await SqliteService().get('user_name');
    final email = await SqliteService().get('user_email');
    final phone = await SqliteService().get('user_phone');
    final image = await SqliteService().get('user_image');

    if (mounted) {
      setState(() {
        _nameCtrl.text  = name  ?? '';
        _phoneCtrl.text = phone ?? '';
        _email          = email ?? '';
        _profileImageUrl = (image != null && image.isNotEmpty) ? image : null;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final res = await UserRemoteDatasource().updateProfile(
        name:  _nameCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim(),
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        await SqliteService().put('user_name',  _nameCtrl.text.trim());
        await SqliteService().put('user_phone', _phoneCtrl.text.trim());
        if(!mounted)return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Profile updated!', style: GoogleFonts.dmSans()),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
        ));
      if(!mounted)return;
        Navigator.pop(context, true);
      } else {
        final msg = (res.data as Map?)?['message'] ?? 'Update failed';
        _showError(msg.toString());
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
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
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18.sp, color: _dark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Edit Profile',
            style: GoogleFonts.playfairDisplay(
                fontSize: 20.sp, fontWeight: FontWeight.bold, color: _dark)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Avatar section
                Center(
                  child: Column(children: [
                    ProfileImageWidget(
                      initialImageUrl: _profileImageUrl,
                      accentColor: _terracotta,
                      onUploaded: (newUrl) async {
                        setState(() => _profileImageUrl = newUrl);
                        await SqliteService().put('user_image', newUrl);
                      },
                    ),
                    SizedBox(height: 12.h),

                    // Verified badge
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _isVerified
                          ? Container(
                        key: const ValueKey('verified'),
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.verified_rounded,
                              size: 16.sp, color: Colors.green[700]),
                          SizedBox(width: 6.w),
                          Text('Verified Profile',
                              style: GoogleFonts.dmSans(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700])),
                        ]),
                      )
                          : Container(
                        key: const ValueKey('unverified'),
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.info_outline_rounded,
                              size: 14.sp, color: Colors.grey[500]),
                          SizedBox(width: 6.w),
                          Text('Add name & phone to get verified',
                              style: GoogleFonts.dmSans(
                                  fontSize: 12.sp, color: Colors.grey[500])),
                        ]),
                      ),
                    ),
                  ]),
                ),

                SizedBox(height: 28.h),

                // Email (read-only)
                label('Email Address'),
                SizedBox(height: 6.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(children: [
                    Icon(Icons.lock_outline_rounded,
                        size: 18.sp, color: Colors.grey[400]),
                    SizedBox(width: 10.w),
                    Text(_email,
                        style: GoogleFonts.dmSans(
                            fontSize: 14.sp, color: Colors.grey[500])),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text('Fixed',
                          style: GoogleFonts.dmSans(
                              fontSize: 10.sp, color: Colors.grey[600])),
                    ),
                  ]),
                ),

                SizedBox(height: 18.h),

                // Name
                label('Full Name'),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: _nameCtrl,
                  style: GoogleFonts.dmSans(fontSize: 14.sp),
                  decoration: _inputDeco(
                    hint: 'Enter your full name',
                    icon: Icons.person_outline_rounded,
                  ),
                  validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Name is required' : null,
                ),

                SizedBox(height: 18.h),

                // Phone
                label('Phone Number'),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.dmSans(fontSize: 14.sp),
                  decoration: _inputDeco(
                    hint: 'Enter your phone number',
                    icon: Icons.phone_outlined,
                  ),
                ),

                SizedBox(height: 12.h),

                // Verification hint
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(children: [
                    Icon(Icons.verified_outlined,
                        size: 14.sp, color: Colors.blue[700]),
                    SizedBox(width: 8.w),
                    Expanded(child: Text(
                      'Fill in both your name and phone number to earn a Verified Profile badge.',
                      style: GoogleFonts.dmSans(
                          fontSize: 12.sp, color: Colors.blue[800]),
                    )),
                  ]),
                ),

                SizedBox(height: 32.h),

                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brown,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r)),
                    ),
                    child: _saving
                        ? const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2)
                        : Text('Save Changes',
                        style: GoogleFonts.dmSans(
                            fontSize: 15.sp, fontWeight: FontWeight.bold)),
                  ),
                ),

                SizedBox(height: 20.h),
              ]),
        ),
      ),
    );
  }

  Widget label(String text) => Text(text,
      style: GoogleFonts.dmSans(
          fontSize: 13.sp, fontWeight: FontWeight.w600, color: _dark));

  InputDecoration _inputDeco({required String hint, required IconData icon}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.dmSans(color: Colors.grey[400], fontSize: 13.sp),
        prefixIcon: Icon(icon, color: Colors.grey[400], size: 20.sp),
        filled: true,
        fillColor: Colors.white,
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
      );
}