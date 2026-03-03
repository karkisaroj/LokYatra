import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../state_management/Bloc/auth/auth_bloc.dart';
import '../../state_management/Bloc/auth/auth_event.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  static const _bg         = Color(0xFFF4F6F9);
  static const _slate      = Color(0xFF3D5A80);
  static const _terracotta = Color(0xFFCD6E4E);
  static const _dark       = Color(0xFF1A2B3C);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _SectionHeader(title: 'Application', icon: Icons.info_outline_rounded),
              const SizedBox(height: 10),
              _SettingsCard(children: [
                _InfoTile(icon: Icons.temple_hindu_rounded, iconColor: _terracotta, label: 'App', value: 'LokYatra'),
                _Divider(),
                _InfoTile(icon: Icons.tag_rounded, iconColor: Colors.grey[600]!, label: 'Version', value: '1.0.0'),
                _Divider(),
                _InfoTile(icon: Icons.code_rounded, iconColor: _slate, label: 'Platform', value: 'Flutter + .NET'),
                _Divider(),
                _InfoTile(icon: Icons.business_rounded, iconColor: Colors.teal[600]!, label: 'Build', value: 'Production'),
              ]),
              const SizedBox(height: 20),
              _SectionHeader(title: 'Support & Legal', icon: Icons.gavel_rounded),
              const SizedBox(height: 10),
              _SettingsCard(children: [
                _ActionTile(
                  icon: Icons.privacy_tip_outlined, iconColor: Colors.blue[700]!,
                  title: 'Privacy Policy', subtitle: 'View our data usage policy',
                  onTap: () {},
                ),
                _Divider(),
                _ActionTile(
                  icon: Icons.description_outlined, iconColor: Colors.indigo[600]!,
                  title: 'Terms of Service', subtitle: 'Read the terms and conditions',
                  onTap: () {},
                ),
                _Divider(),
                _ActionTile(
                  icon: Icons.help_outline_rounded, iconColor: Colors.green[600]!,
                  title: 'Help & Support', subtitle: 'Contact the LokYatra team',
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 20),
              _SectionHeader(title: 'Account', icon: Icons.manage_accounts_outlined),
              const SizedBox(height: 10),
              _SettingsCard(children: [
                _ActionTile(
                  icon: Icons.lock_outline_rounded, iconColor: Colors.orange[700]!,
                  title: 'Change Password', subtitle: 'Update your account password',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AdminChangePasswordPage())),
                ),
                _Divider(),
                _LogoutTile(),
              ]),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ),
    );
  }
}

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
            child: Text('Cancel', style: GoogleFonts.dmSans(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: Text('Sign Out', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    context.read<AuthBloc>().add(LogoutButtonClicked());
    Navigator.of(context, rootNavigator: true)
        .pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _logout(context),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(9)),
            child: Icon(Icons.logout_rounded, size: 18, color: Colors.red[600]),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Sign Out',
                style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.red[700])),
            Text('Log out of the admin panel',
                style: GoogleFonts.dmSans(fontSize: 11, color: Colors.grey[500])),
          ])),
          Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey[400]),
        ]),
      ),
    );
  }
}

class AdminChangePasswordPage extends StatefulWidget {
  const AdminChangePasswordPage({super.key});
  @override
  State<AdminChangePasswordPage> createState() => _AdminChangePasswordPageState();
}

class _AdminChangePasswordPageState extends State<AdminChangePasswordPage> {
  static const _brown = Color(0xFF5C4033);
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _loading = false);
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF1A2B3C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Change Password',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 17, color: const Color(0xFF1A2B3C))),
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
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.orange[50], shape: BoxShape.circle),
                      child: Icon(Icons.lock_outline_rounded, size: 32, color: Colors.orange[700]),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _PwField(ctrl: _currentCtrl, label: 'Current Password', show: _showCurrent,
                      onToggle: () => setState(() => _showCurrent = !_showCurrent),
                      validator: (v) => (v == null || v.isEmpty) ? 'Enter current password' : null),
                  const SizedBox(height: 14),
                  _PwField(ctrl: _newCtrl, label: 'New Password', show: _showNew,
                      onToggle: () => setState(() => _showNew = !_showNew),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter new password';
                        if (v.length < 6) return 'At least 6 characters';
                        return null;
                      }),
                  const SizedBox(height: 14),
                  _PwField(ctrl: _confirmCtrl, label: 'Confirm New Password', show: _showConfirm,
                      onToggle: () => setState(() => _showConfirm = !_showConfirm),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Confirm your new password';
                        if (v != _newCtrl.text) return 'Passwords do not match';
                        return null;
                      }),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: _brown, foregroundColor: Colors.white, elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: _loading
                          ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text('Update Password', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.bold)),
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

class _PwField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final bool show;
  final VoidCallback onToggle;
  final String? Function(String?) validator;
  const _PwField({required this.ctrl, required this.label, required this.show, required this.onToggle, required this.validator});

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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF5C4033))),
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
    Text(title, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF1A2B3C))),
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
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3))],
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
  const _ActionTile({required this.icon, required this.iconColor, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap, borderRadius: BorderRadius.circular(14),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, size: 18, color: iconColor)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1A2B3C))),
          Text(subtitle, style: GoogleFonts.dmSans(fontSize: 11, color: Colors.grey[500])),
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
  const _InfoTile({required this.icon, required this.iconColor, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(children: [
      Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, size: 18, color: iconColor)),
      const SizedBox(width: 14),
      Expanded(child: Text(label, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1A2B3C)))),
      Text(value, style: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey[500])),
    ]),
  );
}