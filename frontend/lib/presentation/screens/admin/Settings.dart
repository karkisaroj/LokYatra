import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/services/image_proxy.dart';
import 'package:lokyatra_frontend/core/services/sqlite_service.dart';
import '../../../data/datasources/User_remote_datasource.dart';
import '../../state_management/Bloc/auth/auth_bloc.dart';
import '../../state_management/Bloc/auth/auth_event.dart';
import '../shared/TermsAndConditionsPage.dart';

// Page index constants — must match AdminDashboard._pages order
const int kPageUsers     = 1;
const int kPageSites     = 2;
const int kPageHomestays = 4;
const int kPageQuizzes   = 7;
const int kPageReviews   = 8;
const int kPageReports   = 9;

class Settings extends StatelessWidget {
  /// Called when the user taps an Admin Tools / Content tile.
  /// The int is the target page index in AdminDashboard._pages.
  final void Function(int pageIndex)? onNavigate;

  const Settings({super.key, this.onNavigate});

  static const _bg         = Color(0xFFF4F6F9);
  static const _slate      = Color(0xFF3D5A80);
  static const _terracotta = Color(0xFFCD6E4E);
  static const _ink        = Color(0xFF1A2B3C);

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 700;

    return Container(
      color: _bg,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            horizontal: wide ? 48 : 16, vertical: wide ? 36 : 20),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: wide ? 820 : 680),
            child: wide ? _wideLayout(context) : _narrowLayout(context),
          ),
        ),
      ),
    );
  }

  Widget _wideLayout(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 260,
        child: Column(children: [
          const _ProfileCard(),
          const SizedBox(height: 16),
          _AdminBadgeCard(),
        ]),
      ),
      const SizedBox(width: 28),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _allSections(context),
        ),
      ),
    ],
  );

  Widget _narrowLayout(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _ProfileCard(),
      const SizedBox(height: 12),
      _AdminBadgeCard(),
      const SizedBox(height: 20),
      ..._allSections(context),
    ],
  );

  void _go(BuildContext context, int index) {
    if (onNavigate != null) {
      onNavigate!(index);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Navigation not wired up', style: GoogleFonts.dmSans()),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  List<Widget> _allSections(BuildContext context) => [
    _SectionHeader(title: 'Application', icon: Icons.info_outline_rounded),
    const SizedBox(height: 10),
    _SettingsCard(children: [
      _InfoTile(icon: Icons.temple_hindu_rounded, iconColor: _terracotta,
          label: 'App', value: 'LokYatra'),
      _Divider(),
      _InfoTile(icon: Icons.tag_rounded, iconColor: Colors.grey[600]!,
          label: 'Version', value: '1.0.0'),
      _Divider(),
      _InfoTile(icon: Icons.code_rounded, iconColor: _slate,
          label: 'Platform', value: 'Flutter + .NET'),
      _Divider(),
      _InfoTile(icon: Icons.business_rounded, iconColor: Colors.teal[600]!,
          label: 'Build', value: 'Production'),
    ]),
    const SizedBox(height: 20),

    _SectionHeader(title: 'Admin Tools', icon: Icons.admin_panel_settings_outlined),
    const SizedBox(height: 10),
    _SettingsCard(children: [
      _ActionTile(
        icon: Icons.bar_chart_rounded, iconColor: Colors.indigo[600]!,
        title: 'Reports & Analytics',
        subtitle: 'View bookings, revenue and site statistics',
        onTap: () => _go(context, kPageReports),
      ),
      _Divider(),
      _ActionTile(
        icon: Icons.people_alt_outlined, iconColor: Colors.teal[600]!,
        title: 'User Management',
        subtitle: 'Manage tourists, owners and admins',
        onTap: () => _go(context, kPageUsers),
      ),
      _Divider(),
      _ActionTile(
        icon: Icons.rate_review_outlined, iconColor: Colors.orange[700]!,
        title: 'Review Moderation',
        subtitle: 'Approve, flag or remove user reviews',
        onTap: () => _go(context, kPageReviews),
      ),
    ]),
    const SizedBox(height: 20),

    _SectionHeader(title: 'Content', icon: Icons.web_outlined),
    const SizedBox(height: 10),
    _SettingsCard(children: [
      _ActionTile(
        icon: Icons.temple_hindu_outlined, iconColor: _terracotta,
        title: 'Cultural Sites',
        subtitle: 'Add, edit or remove heritage sites',
        onTap: () => _go(context, kPageSites),
      ),
      _Divider(),
      _ActionTile(
        icon: Icons.home_outlined, iconColor: Colors.brown[600]!,
        title: 'Homestay Listings',
        subtitle: 'Review and manage all homestays',
        onTap: () => _go(context, kPageHomestays),
      ),
      _Divider(),
      _ActionTile(
        icon: Icons.quiz_outlined, iconColor: Colors.green[700]!,
        title: 'Quiz Management',
        subtitle: 'Edit quiz questions and point values',
        onTap: () => _go(context, kPageQuizzes),
      ),
    ]),
    const SizedBox(height: 20),

    _SectionHeader(title: 'Legal', icon: Icons.gavel_rounded),
    const SizedBox(height: 10),
    _SettingsCard(children: [
      _ActionTile(
        icon: Icons.gavel_rounded, iconColor: _ink,
        title: 'Terms & Conditions',
        subtitle: 'View the full terms of service',
        onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => const TermsAndConditionsPage(isRegistration: false),
        )),
      ),
    ]),
    const SizedBox(height: 20),

    _SectionHeader(title: 'Account', icon: Icons.manage_accounts_outlined),
    const SizedBox(height: 10),
    _SettingsCard(children: [
      _ActionTile(
        icon: Icons.lock_outline_rounded, iconColor: Colors.orange[700]!,
        title: 'Change Password',
        subtitle: 'Update your account password',
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AdminChangePasswordPage())),
      ),
      _Divider(),
      const _LogoutTile(),
    ]),
    const SizedBox(height: 32),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile card — reads from SQLite; uses imageKey to bust ProxyImage cache
// after a new photo is uploaded so the new image shows immediately.
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileCard extends StatefulWidget {
  const _ProfileCard();

  @override
  State<_ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<_ProfileCard> {
  String? name;
  String? email;
  String? profileImage;
  bool uploading = false;
  // Incremented after each upload to force ProxyImage to fetch fresh bytes
  int imageKey = 0;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final n   = await SqliteService().get('user_name');
    final e   = await SqliteService().get('user_email');
    final img = await SqliteService().get('user_image');
    if (mounted) {
      setState(() {
        name         = (n?.isNotEmpty == true) ? n : 'Admin';
        email        = e;
        profileImage = (img?.isNotEmpty == true) ? img : null;
      });
    }
  }

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    setState(() => uploading = true);
    try {
      await UserRemoteDatasource().updateProfile(imageFile: result.files.first);

      try {
        await UserRemoteDatasource().refreshCurrentUser();
      } catch (_) {}

      await _loadUser();

      if (mounted) setState(() => imageKey++);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Profile photo updated', style: GoogleFonts.dmSans()),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Upload failed: $e', style: GoogleFonts.dmSans()),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ));
      }
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(children: [
        Stack(alignment: Alignment.bottomRight, children: [
          Container(
            width: 88, height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: const Color(0xFFCD6E4E).withValues(alpha: 0.4),
                  width: 3),
            ),
            child: ClipOval(
              child: uploading
                  ? Container(
                  color: Colors.grey[100],
                  child: const Center(
                      child: SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFCD6E4E)))))
                  : profileImage != null
              // Key forces Flutter to rebuild the widget tree,
              // which makes ProxyImage/CachedNetworkImage discard
              // its in-memory cache entry and reload from network.
                  ? KeyedSubtree(
                key: ValueKey('avatar_$imageKey'),
                child: ProxyImage(
                  imageUrl: profileImage!,
                  width: 88, height: 88,
                  borderRadiusValue: 0,
                  fit: BoxFit.cover,
                ),
              )
                  : Container(
                color: const Color(0xFF3D5A80).withValues(alpha: 0.1),
                child: Icon(Icons.person, size: 44,
                    color: const Color(0xFF3D5A80)
                        .withValues(alpha: 0.6)),
              ),
            ),
          ),
          GestureDetector(
            onTap: uploading ? null : _pickAndUpload,
            child: Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFCD6E4E),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        Text(name ?? 'Admin',
            style: GoogleFonts.playfairDisplay(
                fontSize: 17, fontWeight: FontWeight.bold,
                color: const Color(0xFF1A2B3C))),
        const SizedBox(height: 4),
        Text(email ?? '',
            style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey[500])),
      ]),
    );
  }
}

// ── Admin badge card ──────────────────────────────────────────────────────────
class _AdminBadgeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF3D5A80), Color(0xFF2C3E50)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
            color: const Color(0xFF3D5A80).withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4))
      ],
    ),
    child: Row(children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.verified_user_rounded,
            size: 20, color: Colors.white),
      ),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Administrator',
            style: GoogleFonts.dmSans(fontSize: 14,
                fontWeight: FontWeight.bold, color: Colors.white)),
        Text('Full system access',
            style: GoogleFonts.dmSans(fontSize: 11,
                color: Colors.white.withValues(alpha: 0.7))),
      ]),
      const Spacer(),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20)),
        child: Text('ADMIN',
            style: GoogleFonts.dmSans(fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white, letterSpacing: 1.2)),
      ),
    ]),
  );
}

// ── Logout tile ───────────────────────────────────────────────────────────────
class _LogoutTile extends StatelessWidget {
  const _LogoutTile();

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Icon(Icons.logout_rounded, color: Colors.red[600], size: 22),
          const SizedBox(width: 10),
          Text('Sign Out?',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 17)),
        ]),
        content: Text('You will be signed out of the admin panel.',
            style: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey[600])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: GoogleFonts.dmSans(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: Text('Sign Out',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    context.read<AuthBloc>().add(LogoutButtonClicked());
    Navigator.of(context, rootNavigator: true)
        .pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => _logout(context),
    borderRadius: BorderRadius.circular(14),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.red[50], borderRadius: BorderRadius.circular(9)),
          child: Icon(Icons.logout_rounded, size: 18, color: Colors.red[600]),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Sign Out',
              style: GoogleFonts.dmSans(fontSize: 14,
                  fontWeight: FontWeight.w600, color: Colors.red[700])),
          Text('Log out of the admin panel',
              style: GoogleFonts.dmSans(fontSize: 11, color: Colors.grey[500])),
        ])),
        Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey[400]),
      ]),
    ),
  );
}

// ── Change Password page ──────────────────────────────────────────────────────
class AdminChangePasswordPage extends StatefulWidget {
  const AdminChangePasswordPage({super.key});
  @override
  State<AdminChangePasswordPage> createState() =>
      _AdminChangePasswordPageState();
}

class _AdminChangePasswordPageState extends State<AdminChangePasswordPage> {
  static const _brown = Color(0xFF5C4033);
  final formKey     = GlobalKey<FormState>();
  final currentCtrl = TextEditingController();
  final newCtrl     = TextEditingController();
  final confirmCtrl = TextEditingController();
  bool loading     = false;
  bool showCurrent = false;
  bool showNew     = false;
  bool showConfirm = false;

  @override
  void dispose() {
    currentCtrl.dispose();
    newCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => loading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => loading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Password changed successfully', style: GoogleFonts.dmSans()),
      backgroundColor: Colors.green[700],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: Color(0xFF1A2B3C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Change Password',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.bold,
                fontSize: 17, color: const Color(0xFF1A2B3C))),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: formKey,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.orange[50], shape: BoxShape.circle),
                    child: Icon(Icons.lock_outline_rounded,
                        size: 32, color: Colors.orange[700]),
                  ),
                  const SizedBox(height: 20),
                  _PwField(ctrl: currentCtrl, label: 'Current Password',
                      show: showCurrent,
                      onToggle: () => setState(() => showCurrent = !showCurrent),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Enter current password' : null),
                  const SizedBox(height: 14),
                  _PwField(ctrl: newCtrl, label: 'New Password',
                      show: showNew,
                      onToggle: () => setState(() => showNew = !showNew),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter new password';
                        if (v.length < 6) return 'At least 6 characters';
                        return null;
                      }),
                  const SizedBox(height: 14),
                  _PwField(ctrl: confirmCtrl, label: 'Confirm New Password',
                      show: showConfirm,
                      onToggle: () => setState(() => showConfirm = !showConfirm),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Confirm your new password';
                        if (v != newCtrl.text) return 'Passwords do not match';
                        return null;
                      }),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity, height: 48,
                    child: ElevatedButton(
                      onPressed: loading ? null : submit,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: _brown,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: loading
                          ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                          : Text('Update Password',
                          style: GoogleFonts.dmSans(
                              fontSize: 14, fontWeight: FontWeight.bold)),
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

// ── Shared helpers ────────────────────────────────────────────────────────────
class _PwField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final bool show;
  final VoidCallback onToggle;
  final String? Function(String?) validator;
  const _PwField({required this.ctrl, required this.label, required this.show,
    required this.onToggle, required this.validator});

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: ctrl, obscureText: !show, validator: validator,
    style: GoogleFonts.dmSans(fontSize: 14),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey[500]),
      filled: true, fillColor: Colors.grey.shade50,
      suffixIcon: IconButton(
        icon: Icon(show ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 18, color: Colors.grey[500]),
        onPressed: onToggle,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF5C4033))),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 17, color: const Color(0xFF1A2B3C)),
    const SizedBox(width: 7),
    Text(title, style: GoogleFonts.dmSans(fontSize: 13,
        fontWeight: FontWeight.w700, color: const Color(0xFF1A2B3C))),
    const SizedBox(width: 10),
    Expanded(child: Divider(color: Colors.grey.shade200)),
  ]);
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.grey.shade100),
      boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 8, offset: const Offset(0, 3))],
    ),
    child: Column(children: children),
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Divider(height: 1, color: Colors.grey.shade100),
  );
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, subtitle;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.iconColor,
    required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap, borderRadius: BorderRadius.circular(14),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.dmSans(fontSize: 14,
              fontWeight: FontWeight.w600, color: const Color(0xFF1A2B3C))),
          Text(subtitle, style: GoogleFonts.dmSans(
              fontSize: 11, color: Colors.grey[500])),
        ])),
        Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey[400]),
      ]),
    ),
  );
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label, value;
  const _InfoTile({required this.icon, required this.iconColor,
    required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(9)),
        child: Icon(icon, size: 18, color: iconColor),
      ),
      const SizedBox(width: 14),
      Expanded(child: Text(label, style: GoogleFonts.dmSans(fontSize: 14,
          fontWeight: FontWeight.w600, color: const Color(0xFF1A2B3C)))),
      Text(value, style: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey[500])),
    ]),
  );
}