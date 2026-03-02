import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});
  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  static const _slate      = Color(0xFF3D5A80);
  static const _bg         = Color(0xFFF4F6F9);
  static const _terracotta = Color(0xFFCD6E4E);

  bool _notificationsEnabled = true;
  bool _emailAlerts          = true;
  bool _darkMode             = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          //  Notifications
          _SectionHeader(title: 'Notifications', icon: Icons.notifications_outlined),
          SizedBox(height: 10.h),
          _SettingsCard(children: [
            _SwitchTile(
              icon: Icons.notifications_active_outlined,
              iconColor: _terracotta,
              title: 'Push Notifications',
              subtitle: 'Receive alerts for new bookings',
              value: _notificationsEnabled,
              onChanged: (v) => setState(() => _notificationsEnabled = v),
            ),
            _Divider(),
            _SwitchTile(
              icon: Icons.email_outlined,
              iconColor: _slate,
              title: 'Email Alerts',
              subtitle: 'Get daily summary emails',
              value: _emailAlerts,
              onChanged: (v) => setState(() => _emailAlerts = v),
            ),
          ]),
          SizedBox(height: 20.h),



          _SectionHeader(title: 'About', icon: Icons.info_outline_rounded),
          SizedBox(height: 10.h),
          _SettingsCard(children: [
            _InfoTile(icon: Icons.temple_hindu_rounded, iconColor: _terracotta, label: 'App', value: 'LokYatra'),
            _Divider(),
            _InfoTile(icon: Icons.tag_rounded, iconColor: Colors.grey[600]!, label: 'Version', value: '1.0.0'),
            _Divider(),
            _InfoTile(icon: Icons.code_rounded, iconColor: _slate, label: 'Platform', value: 'Flutter + .NET'),
            _Divider(),
            _ActionTile(
              icon: Icons.privacy_tip_outlined,
              iconColor: Colors.blue[700]!,
              title: 'Privacy Policy',
              subtitle: 'View our data usage policy',
              onTap: () => _showSnack('Opens privacy policy'),
            ),
            _Divider(),
            _ActionTile(
              icon: Icons.description_outlined,
              iconColor: Colors.indigo[600]!,
              title: 'Terms of Service',
              subtitle: 'Read the terms and conditions',
              onTap: () => _showSnack('Opens terms of service'),
            ),
          ]),

        ]),
      ),
    );
  }

  void _showSnack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.dmSans()),
      backgroundColor: success ? Colors.green[700] : Colors.grey[700],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      margin: EdgeInsets.all(16.w),
    ));
  }

  void _confirmClearCache() {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      title: Text('Clear Cache?', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
      content: Text('This will remove all locally stored images and data. The app will re-download content when needed.',
          style: GoogleFonts.dmSans(fontSize: 13.sp, color: Colors.grey[600])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.dmSans(color: Colors.grey[600]))),
        ElevatedButton(
          onPressed: () { Navigator.pop(context); _showSnack('Cache cleared', success: true); },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[700], elevation: 0),
          child: Text('Clear', style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    ));
  }

}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const _SectionHeader({required this.title, required this.icon, this.color = const Color(0xFF1A2B3C)});

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 17.sp, color: color),
    SizedBox(width: 7.w),
    Text(title, style: GoogleFonts.dmSans(fontSize: 13.sp, fontWeight: FontWeight.w700, color: color)),
    SizedBox(width: 10.w),
    Expanded(child: Divider(color: Colors.grey.shade200)),
  ]);
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: Colors.grey.shade100),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3))],
    ),
    child: Column(children: children),
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.w),
    child: Divider(height: 1, color: Colors.grey.shade100),
  );
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile({required this.icon, required this.iconColor, required this.title,
    required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
    child: Row(children: [
      Container(padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(9.r)),
          child: Icon(icon, size: 18.sp, color: iconColor)),
      SizedBox(width: 14.w),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.dmSans(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1A2B3C))),
        Text(subtitle, style: GoogleFonts.dmSans(fontSize: 11.sp, color: Colors.grey[500])),
      ])),
      Switch(value: value, onChanged: onChanged, activeColor: iconColor),
    ]),
  );
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, subtitle;
  final VoidCallback onTap;
  final bool destructive;
  const _ActionTile({required this.icon, required this.iconColor, required this.title,
    required this.subtitle, required this.onTap, this.destructive = false});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14.r),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(children: [
        Container(padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(9.r)),
            child: Icon(icon, size: 18.sp, color: iconColor)),
        SizedBox(width: 14.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.dmSans(fontSize: 14.sp, fontWeight: FontWeight.w600,
              color: destructive ? Colors.red[700]! : const Color(0xFF1A2B3C))),
          Text(subtitle, style: GoogleFonts.dmSans(fontSize: 11.sp, color: Colors.grey[500])),
        ])),
        Icon(Icons.chevron_right_rounded, size: 18.sp, color: Colors.grey[400]),
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
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    child: Row(children: [
      Container(padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(9.r)),
          child: Icon(icon, size: 18.sp, color: iconColor)),
      SizedBox(width: 14.w),
      Expanded(child: Text(label, style: GoogleFonts.dmSans(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1A2B3C)))),
      Text(value, style: GoogleFonts.dmSans(fontSize: 13.sp, color: Colors.grey[500])),
    ]),
  );
}