import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/sqlite_service.dart';
import '../../../data/datasources/user_remote_datasource.dart';
import 'ProfileImageWidget.dart';

const editProfileInk    = Color(0xFF2D1B10);
const editProfileAccent = Color(0xFFCD6E4E);
const editProfileCream  = Color(0xFFFAF7F2);

double epFontSize(double v, bool wide) => wide ? v : v.sp;
double epWidth(double v, bool wide)    => wide ? v : v.w;
double epHeight(double v, bool wide)   => wide ? v : v.h;
double epRadius(double v, bool wide)   => wide ? v : v.r;

class OwnerEditProfilePage extends StatefulWidget {
  const OwnerEditProfilePage({super.key});
  @override
  State<OwnerEditProfilePage> createState() => OwnerEditProfilePageState();
}

class OwnerEditProfilePageState extends State<OwnerEditProfilePage> {
  final nameCtrl  = TextEditingController();
  final phoneCtrl = TextEditingController();
  final formKey   = GlobalKey<FormState>();
  String? imageUrl;
  bool busy           = false;
  bool verified       = false;
  bool loadingProfile = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
    nameCtrl.addListener(checkVerified);
    phoneCtrl.addListener(checkVerified);
  }

  void checkVerified() => setState(() =>
  verified = nameCtrl.text.trim().isNotEmpty && phoneCtrl.text.trim().isNotEmpty);

  Future<void> loadProfile() async {
    setState(() => loadingProfile = true);
    try {
      // Always try API first — it is the source of truth
      final res = await UserRemoteDatasource().getCurrentUser();
      if (res.statusCode == 200 && mounted) {
        final data   = res.data as Map<String, dynamic>;
        final aName  = data['name']?.toString()         ?? '';
        final aPhone = data['phoneNumber']?.toString()  ?? '';
        final aImg   = data['profileImage']?.toString() ?? '';

        nameCtrl.text  = aName;
        phoneCtrl.text = aPhone;

        // Keep SQLite in sync with latest server values
        final db = SqliteService();
        await db.put('user_name',  aName);
        await db.put('user_phone', aPhone);

        setState(() {
          imageUrl       = aImg.isNotEmpty ? aImg : null;
          verified       = aName.isNotEmpty && aPhone.isNotEmpty;
          loadingProfile = false;
        });
        return;
      }
    } catch (_) {}

    // API failed — fall back to SQLite (offline)
    try {
      final db    = SqliteService();
      final name  = await db.get('user_name')          ?? '';
      final phone = await db.get('user_phone')         ?? '';
      final img   = await db.get('user_profile_image') ?? '';
      nameCtrl.text  = name;
      phoneCtrl.text = phone;
      setState(() {
        imageUrl       = img.isNotEmpty ? img : null;
        verified       = name.isNotEmpty && phone.isNotEmpty;
        loadingProfile = false;
      });
    } catch (_) {
      if (mounted) setState(() => loadingProfile = false);
    }
  }

  Future<void> saveProfile() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => busy = true);
    try {
      final newName  = nameCtrl.text.trim();
      final newPhone = phoneCtrl.text.trim(); // empty string = user cleared it

      final res = await UserRemoteDatasource().updateProfile(
        name:        newName,
        phoneNumber: newPhone, // always sent even if empty
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        final data = res.data as Map<String, dynamic>;

        // Use server-confirmed values
        final savedName  = data['name']?.toString()        ?? newName;
        final savedPhone = data['phoneNumber']?.toString() ?? newPhone;
        final savedImg   = data['profileImage']?.toString() ?? '';

        // Update SQLite with what server confirmed
        final db = SqliteService();
        await db.put('user_name',  savedName);
        await db.put('user_phone', savedPhone);
        if (savedImg.isNotEmpty) await db.put('user_profile_image', savedImg);

        nameCtrl.text  = savedName;
        phoneCtrl.text = savedPhone;

        if (mounted) Navigator.pop(context, true);
      } else {
        showError(((res.data as Map?)?['message'] ?? 'Update failed').toString());
      }
    } on DioException catch (e) {
      if (!mounted) return;
      showError((e.response?.data as Map?)?['message']?.toString() ?? 'Network error');
    } catch (e) {
      if (mounted) showError('Something went wrong');
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
            borderRadius: BorderRadius.circular(epRadius(10, wide))),
        margin: EdgeInsets.all(epWidth(16, wide))));
  }

  @override
  void dispose() { nameCtrl.dispose(); phoneCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: editProfileCream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded,
                color: editProfileInk, size: epFontSize(22, wide)),
            onPressed: () => Navigator.pop(context)),
        title: Text('Edit Profile',
            style: GoogleFonts.playfairDisplay(
                fontSize: epFontSize(20, wide),
                fontWeight: FontWeight.bold,
                color: editProfileInk)),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(height: 1, color: Colors.grey.shade200)),
      ),
      body: loadingProfile
          ? const Center(child: CircularProgressIndicator(color: editProfileAccent))
          : Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: wide ? 520 : double.infinity),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: epWidth(20, wide), vertical: epHeight(24, wide)),
            child: Form(
              key: formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [

                ProfileImageWidget(
                  initialImageUrl: imageUrl,
                  accent: editProfileAccent,
                  onUploaded: (url) => setState(() => imageUrl = url),
                ),

                SizedBox(height: epHeight(10, wide)),

                verified
                    ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.verified_rounded,
                      size: epFontSize(15, wide), color: editProfileAccent),
                  SizedBox(width: epWidth(5, wide)),
                  Text('Verified Profile',
                      style: GoogleFonts.dmSans(
                          fontSize: epFontSize(12, wide),
                          color: editProfileAccent,
                          fontWeight: FontWeight.w600)),
                ])
                    : Text('Add name & phone to get verified',
                    style: GoogleFonts.dmSans(
                        fontSize: epFontSize(12, wide),
                        color: Colors.grey[500])),

                SizedBox(height: epHeight(28, wide)),

                fieldLabel(wide, 'Full Name'),
                SizedBox(height: epHeight(8, wide)),
                buildField(
                  wide, nameCtrl, 'Your full name',
                  Icons.person_outline_rounded,
                  validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),

                SizedBox(height: epHeight(18, wide)),

                fieldLabel(wide, 'Phone Number'),
                SizedBox(height: epHeight(8, wide)),
                buildField(
                  wide, phoneCtrl, 'e.g. +977 98XXXXXXXX',
                  Icons.phone_outlined,
                  inputType: TextInputType.phone,
                ),

                SizedBox(height: epHeight(18, wide)),

                Container(
                  padding: EdgeInsets.all(epWidth(14, wide)),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(epRadius(12, wide)),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(children: [
                    Icon(Icons.lock_outline_rounded,
                        size: epFontSize(14, wide), color: Colors.grey[500]),
                    SizedBox(width: epWidth(8, wide)),
                    Expanded(child: Text('Email address cannot be changed.',
                        style: GoogleFonts.dmSans(
                            fontSize: epFontSize(12, wide),
                            color: Colors.grey[500]))),
                  ]),
                ),

                SizedBox(height: epHeight(32, wide)),

                SizedBox(
                  width: double.infinity,
                  height: epHeight(52, wide),
                  child: ElevatedButton(
                    onPressed: busy ? null : saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: editProfileAccent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                      editProfileAccent.withValues(alpha: 0.5),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(epRadius(14, wide))),
                    ),
                    child: busy
                        ? SizedBox(
                        width: epWidth(20, wide),
                        height: epHeight(20, wide),
                        child: const CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                        : Text('Save Changes',
                        style: GoogleFonts.dmSans(
                            fontSize: epFontSize(15, wide),
                            fontWeight: FontWeight.w700)),
                  ),
                ),

                SizedBox(height: epHeight(20, wide)),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget fieldLabel(bool wide, String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(text,
        style: GoogleFonts.dmSans(
            fontSize: epFontSize(12, wide),
            fontWeight: FontWeight.w600,
            color: Colors.grey[600])),
  );

  Widget buildField(
      bool wide,
      TextEditingController ctrl,
      String hint,
      IconData icon, {
        TextInputType? inputType,
        String? Function(String?)? validator,
      }) =>
      TextFormField(
        controller: ctrl,
        keyboardType: inputType,
        validator: validator,
        style: GoogleFonts.dmSans(
            fontSize: epFontSize(14, wide), color: editProfileInk),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.dmSans(
              fontSize: epFontSize(14, wide), color: Colors.grey[400]),
          prefixIcon: Icon(icon,
              size: epFontSize(18, wide), color: Colors.grey[400]),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
              horizontal: epWidth(16, wide), vertical: epHeight(16, wide)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(epRadius(12, wide)),
              borderSide: BorderSide(color: Colors.grey.shade200)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(epRadius(12, wide)),
              borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(epRadius(12, wide)),
              borderSide: const BorderSide(color: editProfileAccent, width: 1.5)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(epRadius(12, wide)),
              borderSide: BorderSide(color: Colors.red.shade300)),
        ),
      );
}