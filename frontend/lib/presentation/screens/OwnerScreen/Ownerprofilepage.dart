import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/data/datasources/user_remote_datasource.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/auth/auth_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/auth/auth_event.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/booking/booking_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/booking/booking_event.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/booking/booking_state.dart';
import '../../../core/services/sqlite_service.dart';
import 'Ownereditprofilepage.dart';
import 'ProfileImageWidget.dart';

const _ink    = Color(0xFF2D1B10);
const _accent = Color(0xFFCD6E4E);
const _cream  = Color(0xFFFAF7F2);
const _green  = Color(0xFF2E7D52);
const _slate  = Color(0xFF2C3A4A);
const _khalti = Color(0xFF5C35AA);

double _s(double v, bool wide) => wide ? v : v.sp;
double _w(double v, bool wide) => wide ? v : v.w;
double _h(double v, bool wide) => wide ? v : v.h;
double _r(double v, bool wide) => wide ? v : v.r;

class OwnerProfilePage extends StatefulWidget {
  const OwnerProfilePage({super.key});
  @override
  State<OwnerProfilePage> createState() => _OwnerProfilePageState();
}

class _OwnerProfilePageState extends State<OwnerProfilePage> {
  late final BookingBloc _bloc;
  String? _img;
  String _name = '', _email = '', _phone = '';
  bool _busy = true;
  OwnerRevenueLoaded? _revenue;
  List<Map<String, dynamic>> _bookings = [];

  @override
  void initState() {
    super.initState();
    _bloc = BookingBloc()..add(const LoadOwnerBookings());
    _load();
  }

  @override
  void dispose() { _bloc.close(); super.dispose(); }

  Future<void> _load() async {
    final db    = SqliteService();
    final name  = await db.get('user_name');
    final email = await db.get('user_email');
    final img   = await db.get('user_profile_image');
    final phone = await db.get('user_phone');
    if (mounted) {
      setState(() {
      _name = name ?? ''; _email = email ?? ''; _phone = phone ?? '';
      _img = (img != null && img.isNotEmpty) ? img : null;
    });
    }
    if (img == null || img.isEmpty) {
      await _fromServer();
    } else if (mounted) {
      setState(() => _busy = false);
    }
  }

  Future<void> _fromServer() async {
    try {
      final res = await UserRemoteDatasource().getCurrentUser();
      if (res.statusCode == 200) {
        final d = res.data as Map<String, dynamic>;
        final n = d['name']         as String? ?? '';
        final e = d['email']        as String? ?? '';
        final p = d['phoneNumber']  as String? ?? '';
        final i = d['profileImage'] as String? ?? '';
        final db = SqliteService();
        await db.put('user_name', n);
        await db.put('user_email', e);
        await db.put('user_profile_image', i);
        await db.put('user_phone', p);
        if (mounted) setState(() { _name = n; _email = e; _phone = p; _img = i.isNotEmpty ? i : null; });
      }
    } catch (_) {} finally { if (mounted) setState(() => _busy = false); }
  }

  void _logout() {
    context.read<AuthBloc>().add(LogoutButtonClicked());
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    if (_busy) return const Scaffold(backgroundColor: _cream, body: Center(child: CircularProgressIndicator(color: _accent)));
    final wide = MediaQuery.of(context).size.width > 700;

    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<BookingBloc, BookingState>(
        listener: (_, state) {
          if (state is OwnerBookingsLoaded) setState(() => _bookings = state.bookings);
          if (state is OwnerRevenueLoaded)  setState(() => _revenue = state);
        },
        child: Scaffold(
          backgroundColor: _cream,
          appBar: AppBar(
            backgroundColor: Colors.white, elevation: 0,
            automaticallyImplyLeading: false,
            leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, size: _s(20, wide), color: _ink),
                onPressed: () => Navigator.pop(context)),
            title: Text('Profile',
                style: GoogleFonts.playfairDisplay(
                    fontSize: _s(20, wide), fontWeight: FontWeight.bold, color: _ink)),
            centerTitle: true,
            bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Divider(height: 1, color: Colors.grey.shade200)),
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: wide ? 860 : double.infinity),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                      horizontal: _w(16, wide), vertical: _h(20, wide)),
                  child: wide
                      ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SizedBox(width: 320, child: _leftColumn(wide)),
                    SizedBox(width: _w(20, wide)),
                    Expanded(child: _rightColumn(wide)),
                  ])
                      : Column(children: [
                    _leftColumn(wide),
                    SizedBox(height: _h(14, wide)),
                    _rightColumn(wide),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _leftColumn(bool wide) => Column(children: [
    _HeroCard(wide: wide, name: _name, email: _email, phone: _phone, img: _img,
        onImgUploaded: (url) => setState(() => _img = url)),
    SizedBox(height: _h(14, wide)),
    _StatsRow(wide: wide, bookings: _bookings),
    SizedBox(height: _h(14, wide)),
    _InfoCard(
      wide: wide, name: _name, email: _email, phone: _phone,
      onEdit: () async {
        final ok = await Navigator.push<bool>(context,
            MaterialPageRoute(builder: (_) => const OwnerEditProfilePage()));
        if (ok == true) _load();
      },
    ),
    SizedBox(height: _h(14, wide)),
    _ActionTile(wide: wide, icon: Icons.lock_outline_rounded, label: 'Change Password',
        onTap: () => Navigator.pushNamed(context, '/change-password')),
    SizedBox(height: _h(20, wide)),
  ]);

  Widget _rightColumn(bool wide) => Column(children: [
    _EarningsCard(wide: wide, revenue: _revenue, bookings: _bookings),
    SizedBox(height: _h(14, wide)),
    _KhaltiCard(wide: wide),
    SizedBox(height: _h(14, wide)),
    _PerformanceCard(wide: wide, bookings: _bookings),
    SizedBox(height: _h(20, wide)),
    SizedBox(
      width: double.infinity,
      height: wide ? 52 : 52.h,
      child: ElevatedButton.icon(
        onPressed: _logout,
        icon: Icon(Icons.logout_rounded, size: _s(18, wide)),
        label: Text('Logout',
            style: GoogleFonts.dmSans(
                fontSize: _s(15, wide), fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B3A3A),
          foregroundColor: Colors.white, elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_r(14, wide))),
        ),
      ),
    ),
    SizedBox(height: _h(20, wide)),
  ]);
}

class _HeroCard extends StatelessWidget {
  final bool wide;
  final String name, email, phone;
  final String? img;
  final void Function(String) onImgUploaded;
  const _HeroCard({required this.wide, required this.name, required this.email,
    required this.phone, required this.img, required this.onImgUploaded});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(_w(18, wide)),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(_r(20, wide)),
      border: Border.all(color: Colors.grey.shade100),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ProfileImageWidget(initialImageUrl: img, accent: _accent, onUploaded: onImgUploaded),
        SizedBox(width: _w(14, wide)),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name.isEmpty ? 'Owner' : name,
              style: GoogleFonts.playfairDisplay(
                  fontSize: _s(18, wide), fontWeight: FontWeight.bold, color: _ink)),
          SizedBox(height: _h(4, wide)),
          Row(children: [
            Icon(Icons.location_on_outlined, size: _s(13, wide), color: Colors.grey[500]),
            SizedBox(width: _w(3, wide)),
            Text('Nepal', style: GoogleFonts.dmSans(fontSize: _s(12, wide), color: Colors.grey[500])),
          ]),
          SizedBox(height: _h(8, wide)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: _w(10, wide), vertical: _h(4, wide)),
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(_r(20, wide)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.home_work_outlined, size: _s(11, wide), color: _accent),
              SizedBox(width: _w(5, wide)),
              Text('Homestay Owner',
                  style: GoogleFonts.dmSans(
                      fontSize: _s(11, wide), color: _accent, fontWeight: FontWeight.w600)),
            ]),
          ),
        ])),
      ]),
      SizedBox(height: _h(14, wide)),
      Divider(color: Colors.grey.shade100),
      SizedBox(height: _h(10, wide)),
      Text("Sharing Nepal's culture and heritage with travelers from around the world.",
          style: GoogleFonts.dmSans(fontSize: _s(12, wide), color: Colors.grey[500], height: 1.5)),
    ]),
  );
}

class _StatsRow extends StatelessWidget {
  final bool wide;
  final List<Map<String, dynamic>> bookings;
  const _StatsRow({required this.wide, required this.bookings});

  @override
  Widget build(BuildContext context) {
    final total = bookings.length;
    final conf  = bookings.where((b) => b['booking']?['status'] == 'Confirmed').length;
    final done  = bookings.where((b) => b['booking']?['status'] == 'Completed').length;
    return Container(
      padding: EdgeInsets.symmetric(vertical: _h(16, wide), horizontal: _w(8, wide)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_r(16, wide)),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(children: [
        _Cell(wide: wide, icon: Icons.calendar_month_outlined,      val: '$total', label: 'Total Bookings', color: _slate),
        _vDiv(wide),
        _Cell(wide: wide, icon: Icons.check_circle_outline_rounded, val: '$conf',  label: 'Confirmed',      color: _green),
        _vDiv(wide),
        _Cell(wide: wide, icon: Icons.done_all_rounded,             val: '$done',  label: 'Completed',      color: _accent),
      ]),
    );
  }

  Widget _vDiv(bool wide) => Container(
      width: 1, height: wide ? 36 : 36.h,
      color: Colors.grey.shade200,
      margin: EdgeInsets.symmetric(horizontal: _w(4, wide)));
}

class _Cell extends StatelessWidget {
  final bool wide;
  final IconData icon;
  final String val, label;
  final Color color;
  const _Cell({required this.wide, required this.icon, required this.val,
    required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Icon(icon, size: _s(20, wide), color: color),
    SizedBox(height: _h(5, wide)),
    Text(val, style: GoogleFonts.dmSans(fontSize: _s(17, wide), fontWeight: FontWeight.bold, color: _ink)),
    Text(label, style: GoogleFonts.dmSans(fontSize: _s(10, wide), color: Colors.grey[500])),
  ]));
}

class _EarningsCard extends StatelessWidget {
  final bool wide;
  final OwnerRevenueLoaded? revenue;
  final List<Map<String, dynamic>> bookings;
  const _EarningsCard({required this.wide, required this.revenue, required this.bookings});

  @override
  Widget build(BuildContext context) {
    final total = revenue?.totalRevenue  ?? 0.0;
    final cash  = revenue?.cashRevenue   ?? 0.0;
    final khal  = revenue?.khaltiRevenue ?? 0.0;
    final paid  = revenue?.paidBookings  ?? 0;
    final pend  = bookings
        .where((b) => b['booking']?['status'] == 'Confirmed' && b['booking']?['paymentStatus'] != 'Paid')
        .fold(0.0, (s, b) => s + ((b['booking']?['totalPrice'] as num?)?.toDouble() ?? 0));

    return Container(
      padding: EdgeInsets.all(_w(18, wide)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_r(16, wide)),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: EdgeInsets.all(_w(10, wide)),
            decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(_r(12, wide))),
            child: Icon(Icons.account_balance_wallet_outlined, color: _green, size: _s(22, wide)),
          ),
          SizedBox(width: _w(12, wide)),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Total Earnings',
                style: GoogleFonts.dmSans(fontSize: _s(12, wide), color: Colors.grey[500])),
            Text('Rs. ${total.toStringAsFixed(0)}',
                style: GoogleFonts.dmSans(
                    fontSize: _s(22, wide), fontWeight: FontWeight.bold, color: _green)),
          ]),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: _w(10, wide), vertical: _h(4, wide)),
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(_r(20, wide)),
              border: Border.all(color: _green.withValues(alpha: 0.2)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.check_circle_outline_rounded, size: _s(11, wide), color: _green),
              SizedBox(width: _w(4, wide)),
              Text('$paid paid',
                  style: GoogleFonts.dmSans(
                      fontSize: _s(11, wide), color: _green, fontWeight: FontWeight.w600)),
            ]),
          ),
        ]),
        SizedBox(height: _h(16, wide)),
        Row(children: [
          Expanded(child: _EChip(wide: wide, label: 'Cash',    val: 'Rs. ${cash.toStringAsFixed(0)}', icon: Icons.money_rounded,           color: _green)),
          SizedBox(width: _w(8, wide)),
          Expanded(child: _EChip(wide: wide, label: 'Khalti',  val: 'Rs. ${khal.toStringAsFixed(0)}', icon: Icons.phone_android_rounded,   color: _khalti)),
          SizedBox(width: _w(8, wide)),
          Expanded(child: _EChip(wide: wide, label: 'Pending', val: 'Rs. ${pend.toStringAsFixed(0)}', icon: Icons.hourglass_bottom_rounded, color: Colors.orange, pend: true)),
        ]),
      ]),
    );
  }
}

class _EChip extends StatelessWidget {
  final bool wide;
  final String label, val;
  final IconData icon;
  final Color color;
  final bool pend;
  const _EChip({required this.wide, required this.label, required this.val,
    required this.icon, required this.color, this.pend = false});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: _w(10, wide), vertical: _h(10, wide)),
    decoration: BoxDecoration(
      color: pend ? const Color(0xFFFFF8EE) : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(_r(12, wide)),
      border: Border.all(color: pend ? const Color(0xFFE8D5B0) : Colors.grey.shade200),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: _s(11, wide), color: color),
        SizedBox(width: _w(4, wide)),
        Text(label,
            style: GoogleFonts.dmSans(
                fontSize: _s(9, wide), color: Colors.grey[500], fontWeight: FontWeight.w500)),
      ]),
      SizedBox(height: _h(5, wide)),
      Text(val,
          style: GoogleFonts.dmSans(
              fontSize: _s(12, wide), fontWeight: FontWeight.bold, color: _ink)),
    ]),
  );
}

class _InfoCard extends StatelessWidget {
  final bool wide;
  final String name, email, phone;
  final VoidCallback onEdit;
  const _InfoCard({required this.wide, required this.name, required this.email,
    required this.phone, required this.onEdit});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(_w(18, wide)),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(_r(16, wide)),
      border: Border.all(color: Colors.grey.shade100),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Icon(Icons.person_outline_rounded, size: _s(17, wide), color: _accent),
          SizedBox(width: _w(8, wide)),
          Text('Personal Information',
              style: GoogleFonts.dmSans(
                  fontSize: _s(14, wide), fontWeight: FontWeight.bold, color: _ink)),
        ]),
        GestureDetector(
          onTap: onEdit,
          child: Row(children: [
            Icon(Icons.edit_outlined, size: _s(14, wide), color: Colors.grey[500]),
            SizedBox(width: _w(4, wide)),
            Text('Edit', style: GoogleFonts.dmSans(fontSize: _s(13, wide), color: Colors.grey[500])),
          ]),
        ),
      ]),
      SizedBox(height: _h(16, wide)),
      _IField(wide: wide, icon: Icons.person_outline_rounded, label: 'Full Name',     val: name.isEmpty  ? '—' : name),
      _IField(wide: wide, icon: Icons.email_outlined,         label: 'Email Address', val: email.isEmpty ? '—' : email),
      _IField(wide: wide, icon: Icons.phone_outlined,         label: 'Phone Number',  val: phone.isEmpty ? '—' : phone, last: true),
    ]),
  );
}

class _IField extends StatelessWidget {
  final bool wide;
  final IconData icon;
  final String label, val;
  final bool last;
  const _IField({required this.wide, required this.icon, required this.label,
    required this.val, this.last = false});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Icon(icon, size: _s(13, wide), color: Colors.grey[500]),
      SizedBox(width: _w(6, wide)),
      Text(label,
          style: GoogleFonts.dmSans(
              fontSize: _s(11, wide), color: Colors.grey[500], fontWeight: FontWeight.w500)),
    ]),
    SizedBox(height: _h(5, wide)),
    Padding(
      padding: EdgeInsets.only(left: _w(19, wide)),
      child: Text(val, style: GoogleFonts.dmSans(fontSize: _s(14, wide), color: _ink)),
    ),
    if (!last) ...[
      SizedBox(height: _h(12, wide)),
      Divider(color: Colors.grey.shade100),
      SizedBox(height: _h(12, wide)),
    ],
  ]);
}

class _KhaltiCard extends StatelessWidget {
  final bool wide;
  const _KhaltiCard({required this.wide});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(_w(18, wide)),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(_r(16, wide)),
      border: Border.all(color: Colors.grey.shade100),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          padding: EdgeInsets.all(_w(8, wide)),
          decoration: BoxDecoration(
              color: _khalti.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(_r(10, wide))),
          child: Icon(Icons.account_balance_wallet_rounded, color: _khalti, size: _s(18, wide)),
        ),
        SizedBox(width: _w(10, wide)),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Khalti Payment Details',
              style: GoogleFonts.dmSans(
                  fontSize: _s(14, wide), fontWeight: FontWeight.bold, color: _ink)),
          Text('For receiving payments',
              style: GoogleFonts.dmSans(fontSize: _s(11, wide), color: Colors.grey[500])),
        ]),
      ]),
      SizedBox(height: _h(14, wide)),
      Divider(color: Colors.grey.shade100),
      SizedBox(height: _h(12, wide)),
      Text('Khalti ID / Mobile Number',
          style: GoogleFonts.dmSans(
              fontSize: _s(11, wide), color: Colors.grey[500], fontWeight: FontWeight.w500)),
      SizedBox(height: _h(5, wide)),
      Text('9800000005',
          style: GoogleFonts.dmSans(
              fontSize: _s(15, wide), fontWeight: FontWeight.bold, color: _ink)),
      SizedBox(height: _h(12, wide)),
      Container(
        padding: EdgeInsets.all(_w(12, wide)),
        decoration: BoxDecoration(
          color: _green.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(_r(10, wide)),
          border: Border.all(color: _green.withValues(alpha: 0.15)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.info_outline_rounded, size: _s(14, wide), color: _green),
          SizedBox(width: _w(8, wide)),
          Expanded(child: Text(
              'Earnings will be transferred to this Khalti account after guest check-out.',
              style: GoogleFonts.dmSans(fontSize: _s(11, wide), color: _green, height: 1.5))),
        ]),
      ),
    ]),
  );
}

class _PerformanceCard extends StatelessWidget {
  final bool wide;
  final List<Map<String, dynamic>> bookings;
  const _PerformanceCard({required this.wide, required this.bookings});

  @override
  Widget build(BuildContext context) {
    final total     = bookings.length;
    final conf      = bookings.where((b) {
      final s = b['booking']?['status'];
      return s == 'Confirmed' || s == 'Completed';
    }).length;
    final rate      = total > 0 ? (conf / total * 100).round() : 0;
    final superhost = rate >= 90 && total >= 10;

    return Container(
      padding: EdgeInsets.all(_w(18, wide)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_r(16, wide)),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.military_tech_outlined, size: _s(18, wide), color: _accent),
          SizedBox(width: _w(8, wide)),
          Text('Performance',
              style: GoogleFonts.dmSans(
                  fontSize: _s(14, wide), fontWeight: FontWeight.bold, color: _ink)),
        ]),
        SizedBox(height: _h(14, wide)),
        _PRow(
          wide: wide,
          icon: Icons.star_rounded, iconBg: _green.withValues(alpha: 0.1), iconColor: _green,
          title: 'Superhost Status',
          sub: superhost ? 'Top-rated host' : 'Reach 90% acceptance to unlock',
          trailing: Container(
            padding: EdgeInsets.symmetric(horizontal: _w(10, wide), vertical: _h(4, wide)),
            decoration: BoxDecoration(
                color: superhost ? _green : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(_r(20, wide))),
            child: Text(superhost ? 'Active' : 'Inactive',
                style: GoogleFonts.dmSans(
                    fontSize: _s(11, wide),
                    color: superhost ? Colors.white : Colors.grey[500],
                    fontWeight: FontWeight.w600)),
          ),
        ),
        SizedBox(height: _h(10, wide)),
        _PRow(
          wide: wide,
          icon: Icons.trending_up_rounded, iconBg: _accent.withValues(alpha: 0.1), iconColor: _accent,
          title: 'Total Bookings', sub: 'All time',
          trailing: Text('$total',
              style: GoogleFonts.dmSans(
                  fontSize: _s(15, wide), fontWeight: FontWeight.bold, color: _accent)),
        ),
        SizedBox(height: _h(10, wide)),
        _PRow(
          wide: wide,
          icon: Icons.home_outlined, iconBg: _slate.withValues(alpha: 0.1), iconColor: _slate,
          title: 'Acceptance Rate', sub: 'Confirmed + Completed vs total',
          trailing: Text('$rate%',
              style: GoogleFonts.dmSans(
                  fontSize: _s(15, wide), fontWeight: FontWeight.bold, color: _slate)),
        ),
      ]),
    );
  }
}

class _PRow extends StatelessWidget {
  final bool wide;
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, sub;
  final Widget trailing;
  const _PRow({required this.wide, required this.icon, required this.iconBg,
    required this.iconColor, required this.title, required this.sub, required this.trailing});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: _w(12, wide), vertical: _h(12, wide)),
    decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(_r(12, wide))),
    child: Row(children: [
      Container(
        padding: EdgeInsets.all(_w(8, wide)),
        decoration: BoxDecoration(
            color: iconBg, borderRadius: BorderRadius.circular(_r(10, wide))),
        child: Icon(icon, size: _s(16, wide), color: iconColor),
      ),
      SizedBox(width: _w(12, wide)),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: GoogleFonts.dmSans(
                fontSize: _s(13, wide), fontWeight: FontWeight.w600, color: _ink)),
        Text(sub,
            style: GoogleFonts.dmSans(fontSize: _s(11, wide), color: Colors.grey[500])),
      ])),
      trailing,
    ]),
  );
}

class _ActionTile extends StatelessWidget {
  final bool wide;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionTile({required this.wide, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: _w(16, wide), vertical: _h(14, wide)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_r(14, wide)),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(children: [
        Icon(icon, size: _s(18, wide), color: _slate),
        SizedBox(width: _w(12, wide)),
        Expanded(child: Text(label,
            style: GoogleFonts.dmSans(
                fontSize: _s(14, wide), fontWeight: FontWeight.w500, color: _ink))),
        Icon(Icons.chevron_right_rounded, size: _s(20, wide), color: Colors.grey[400]),
      ]),
    ),
  );
}