import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import '../../../core/services/sqlite_service.dart';
import '../../../data/datasources/user_remote_datasource.dart';
import 'ProfileImageWidget.dart';

const _bg      = Color(0xFFFAF7F2);
const _ink     = Color(0xFF1C1C1C);
const _brown   = Color(0xFF5C4033);
const _muted   = Color(0xFF8A8279);
const _divider = Color(0xFFEDE8E1);
const _cardBg  = Color(0xFFFFFFFF);
const _slate   = Color(0xFF2C3A4A);

class OwnerEditProfilePage extends StatefulWidget {
  const OwnerEditProfilePage({super.key});

  @override
  State<OwnerEditProfilePage> createState() => _OwnerEditProfilePageState();
}

class _OwnerEditProfilePageState extends State<OwnerEditProfilePage> {
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _formKey   = GlobalKey<FormState>();

  String? _profileImageUrl;
  String? _pendingImagePath;
  String? _pendingImageFileName;
  bool _saving = false;
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _loadCached();
    _nameCtrl.addListener(_updateVerified);
    _phoneCtrl.addListener(_updateVerified);
  }

  void _updateVerified() {
    setState(() {
      _isVerified = _nameCtrl.text.trim().isNotEmpty && _phoneCtrl.text.trim().isNotEmpty;
    });
  }

  Future<void> _loadCached() async {
    final sqlite = SqliteService();
    final name   = await sqlite.get('user_name')          ?? '';
    final phone  = await sqlite.get('user_phone')         ?? '';
    final image  = await sqlite.get('user_profile_image') ?? '';
    _nameCtrl.text  = name;
    _phoneCtrl.text = phone;
    setState(() {
      _profileImageUrl = image.isNotEmpty ? image : null;
      _isVerified = name.isNotEmpty && phone.isNotEmpty;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final res = await UserRemoteDatasource().updateProfile(
        name:          _nameCtrl.text.trim(),
        phoneNumber:   _phoneCtrl.text.trim(),
        imagePath:     _pendingImagePath,
        imageFileName: _pendingImageFileName,
      );
      if (res.statusCode == 200) {
        final data     = res.data as Map<String, dynamic>;
        final newImage = data['profileImage'] as String? ?? '';
        final sqlite   = SqliteService();
        await sqlite.put('user_name',          _nameCtrl.text.trim());
        await sqlite.put('user_phone',         _phoneCtrl.text.trim());
        if (newImage.isNotEmpty) await sqlite.put('user_profile_image', newImage);
        if (mounted) Navigator.pop(context, true);
      } else {
        final msg = (res.data as Map?)?['message'] ?? 'Update failed';
        _showError(msg.toString());
      }
    } on DioException catch (e) {
      _showError((e.response?.data as Map?)?['message']?.toString() ?? 'Network error');
    } catch (_) {
      _showError('Something went wrong');
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
      margin: EdgeInsets.all(16.w),
    ));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _cardBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: _ink, size: 22.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Edit Profile',
            style: GoogleFonts.playfairDisplay(
                fontSize: 20.sp, fontWeight: FontWeight.bold, color: _ink)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _divider),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [

            ProfileImageWidget(
              initialImageUrl: _profileImageUrl,
              accentColor: _brown,
              onUploaded: (url) => setState(() => _profileImageUrl = url),
            ),

            SizedBox(height: 8.h),

            if (_isVerified)
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.verified_rounded, size: 15.sp, color: _brown),
                SizedBox(width: 5.w),
                Text('Verified Profile',
                    style: GoogleFonts.dmSans(
                        fontSize: 12.sp, color: _brown, fontWeight: FontWeight.w600)),
              ])
            else
              Text('Add name & phone to get verified',
                  style: GoogleFonts.dmSans(fontSize: 12.sp, color: _muted)),

            SizedBox(height: 28.h),

            _fieldLabel('Full Name'),
            SizedBox(height: 8.h),
            _buildField(
              controller: _nameCtrl,
              hint: 'Your full name',
              icon: Icons.person_outline_rounded,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),

            SizedBox(height: 18.h),

            _fieldLabel('Phone Number'),
            SizedBox(height: 8.h),
            _buildField(
              controller: _phoneCtrl,
              hint: 'e.g. +977 98XXXXXXXX',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),

            SizedBox(height: 18.h),

            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF0EDE8),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: _divider),
              ),
              child: Row(children: [
                Icon(Icons.lock_outline_rounded, size: 14.sp, color: _muted),
                SizedBox(width: 8.w),
                Expanded(child: Text('Email address cannot be changed.',
                    style: GoogleFonts.dmSans(fontSize: 12.sp, color: _muted))),
              ]),
            ),

            SizedBox(height: 32.h),

            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _slate,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _slate.withValues(alpha: 0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                ),
                child: _saving
                    ? SizedBox(
                    width: 20.w, height: 20.h,
                    child: const CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                    : Text('Save Changes',
                    style: GoogleFonts.dmSans(
                        fontSize: 15.sp, fontWeight: FontWeight.w700)),
              ),
            ),

            SizedBox(height: 20.h),
          ]),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(text,
        style: GoogleFonts.dmSans(
            fontSize: 12.sp, fontWeight: FontWeight.w600, color: _muted)),
  );

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: GoogleFonts.dmSans(fontSize: 14.sp, color: _ink),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.dmSans(fontSize: 14.sp, color: const Color(0xFFBBB5AE)),
          prefixIcon: Icon(icon, size: 18.sp, color: _muted),
          filled: true,
          fillColor: _cardBg,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
            borderSide: BorderSide(color: _slate, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.red.shade300),
          ),
        ),
      );
}