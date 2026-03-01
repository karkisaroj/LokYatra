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

const _bg      = Color(0xFFFAF7F2);
const _ink     = Color(0xFF1C1C1C);
const _brown   = Color(0xFF5C4033);
const _slate   = Color(0xFF2C3A4A);
const _muted   = Color(0xFF8A8279);
const _divider = Color(0xFFEDE8E1);
const _cardBg  = Color(0xFFFFFFFF);
const _tagBg   = Color(0xFFEEEBE5);
const _green   = Color(0xFF3D5A4F);

class OwnerProfilePage extends StatefulWidget {
  const OwnerProfilePage({super.key});

  @override
  State<OwnerProfilePage> createState() => _OwnerProfilePageState();
}

class _OwnerProfilePageState extends State<OwnerProfilePage> {
  late final BookingBloc _bookingBloc;

  String? _profileImageUrl;
  String _name  = '';
  String _email = '';
  String _phone = '';
  bool   _loading = true;

  OwnerRevenueLoaded? _revenue;
  List<Map<String, dynamic>> _bookings = [];

  @override
  void initState() {
    super.initState();
    _bookingBloc = BookingBloc()..add(const LoadOwnerBookings());
    _loadProfile();
  }

  @override
  void dispose() {
    _bookingBloc.close();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final sqlite = SqliteService();
    final name   = await sqlite.get('user_name');
    final email  = await sqlite.get('user_email');
    final image  = await sqlite.get('user_profile_image');
    final phone  = await sqlite.get('user_phone');

    if (mounted) {
      setState(() {
        _name  = name  ?? '';
        _email = email ?? '';
        _phone = phone ?? '';
        _profileImageUrl = (image != null && image.isNotEmpty) ? image : null;
      });
    }

    if (image == null || image.isEmpty) {
      await _fetchFromServer();
    } else {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _fetchFromServer() async {
    try {
      final res = await UserRemoteDatasource().getCurrentUser();
      if (res.statusCode == 200) {
        final data        = res.data as Map<String, dynamic>;
        final serverName  = data['name']         as String? ?? '';
        final serverEmail = data['email']        as String? ?? '';
        final serverPhone = data['phoneNumber']  as String? ?? '';
        final serverImage = data['profileImage'] as String? ?? '';

        final sqlite = SqliteService();
        await sqlite.put('user_name',          serverName);
        await sqlite.put('user_email',         serverEmail);
        await sqlite.put('user_profile_image', serverImage);
        await sqlite.put('user_phone',         serverPhone);

        if (mounted) {
          setState(() {
            _name  = serverName;
            _email = serverEmail;
            _phone = serverPhone;
            _profileImageUrl = serverImage.isNotEmpty ? serverImage : null;
          });
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _logout() {
    context.read<AuthBloc>().add(LogoutButtonClicked());
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(backgroundColor: _bg, body: Center(child: CircularProgressIndicator()));
    }

    return BlocProvider.value(
      value: _bookingBloc,
      child: BlocListener<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is OwnerBookingsLoaded) {
            setState(() => _bookings = state.bookings);
          }
          if (state is OwnerRevenueLoaded) {
            setState(() => _revenue = state);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: IconButton(onPressed: (){
             Navigator.pop(context);
            }, icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.sp, color: _ink),)
          ),
          backgroundColor: _bg,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                _HeroCard(
                  name: _name, email: _email, phone: _phone,
                  profileImageUrl: _profileImageUrl,
                  onImageUploaded: (url) => setState(() => _profileImageUrl = url),
                ),

                SizedBox(height: 14.h),

                _StatsRow(bookings: _bookings),

                SizedBox(height: 14.h),

                _EarningsCard(revenue: _revenue, bookings: _bookings),

                SizedBox(height: 14.h),

                _PersonalInfoCard(
                  name: _name, email: _email, phone: _phone,
                  onEdit: () async {
                    final updated = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(builder: (_) => const OwnerEditProfilePage()),
                    );
                    if (updated == true) _loadProfile();
                  },
                ),

                SizedBox(height: 14.h),

                _KhaltiCard(),

                SizedBox(height: 14.h),

                _PerformanceCard(bookings: _bookings),

                SizedBox(height: 14.h),

                _ActionTile(
                  icon: Icons.lock_outline_rounded,
                  label: 'Change Password',
                  onTap: () => Navigator.pushNamed(context, '/change-password'),
                ),

                SizedBox(height: 10.h),

                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton.icon(
                    onPressed: _logout,
                    icon: Icon(Icons.logout_rounded, size: 18.sp),
                    label: Text('Logout',
                        style: GoogleFonts.dmSans(fontSize: 15.sp, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B3A3A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    ),
                  ),
                ),

                SizedBox(height: 20.h),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String name, email, phone;
  final String? profileImageUrl;
  final void Function(String) onImageUploaded;
  const _HeroCard({required this.name, required this.email, required this.phone,
    required this.profileImageUrl, required this.onImageUploaded});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _divider),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ProfileImageWidget(
            initialImageUrl: profileImageUrl,
            accentColor: _brown,
            onUploaded: onImageUploaded,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name.isEmpty ? 'Owner' : name,
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 18.sp, fontWeight: FontWeight.bold, color: _ink)),
              SizedBox(height: 5.h),
              Row(children: [
                Icon(Icons.location_on_outlined, size: 13.sp, color: _muted),
                SizedBox(width: 3.w),
                Text('Nepal', style: GoogleFonts.dmSans(fontSize: 12.sp, color: _muted)),
              ]),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _tagBg,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: _divider),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.home_work_outlined, size: 11.sp, color: _brown),
                  SizedBox(width: 5.w),
                  Text('Homestay Owner',
                      style: GoogleFonts.dmSans(fontSize: 11.sp, color: _brown, fontWeight: FontWeight.w600)),
                ]),
              ),
            ]),
          ),
        ]),
        SizedBox(height: 14.h),
        Container(height: 1, color: _divider),
        SizedBox(height: 12.h),
        Text('Sharing Nepal\'s culture and heritage with travelers from around the world.',
            style: GoogleFonts.dmSans(fontSize: 12.sp, color: _muted, height: 1.5)),
      ]),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final List<Map<String, dynamic>> bookings;
  const _StatsRow({required this.bookings});

  @override
  Widget build(BuildContext context) {
    final totalBookings    = bookings.length;
    final confirmedCount   = bookings.where((b) => b['booking']?['status'] == 'Confirmed').length;
    final completedCount   = bookings.where((b) => b['booking']?['status'] == 'Completed').length;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _divider),
      ),
      child: Row(children: [
        _StatCell(icon: Icons.calendar_month_outlined, value: '$totalBookings', label: 'Total Bookings', color: _slate),
        _vDivider(),
        _StatCell(icon: Icons.check_circle_outline_rounded, value: '$confirmedCount', label: 'Confirmed', color: _green),
        _vDivider(),
        _StatCell(icon: Icons.done_all_rounded, value: '$completedCount', label: 'Completed', color: const Color(0xFF8B7355)),
      ]),
    );
  }

  Widget _vDivider() => Container(width: 1, height: 36.h, color: _divider,
      margin: EdgeInsets.symmetric(horizontal: 4.w));
}

class _StatCell extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;
  const _StatCell({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Icon(icon, size: 20.sp, color: color),
      SizedBox(height: 5.h),
      Text(value, style: GoogleFonts.dmSans(fontSize: 17.sp, fontWeight: FontWeight.bold, color: _ink)),
      Text(label, style: GoogleFonts.dmSans(fontSize: 10.sp, color: _muted)),
    ]),
  );
}

class _EarningsCard extends StatelessWidget {
  final OwnerRevenueLoaded? revenue;
  final List<Map<String, dynamic>> bookings;
  const _EarningsCard({required this.revenue, required this.bookings});

  @override
  Widget build(BuildContext context) {
    final totalRevenue  = revenue?.totalRevenue  ?? 0.0;
    final cashRevenue   = revenue?.cashRevenue   ?? 0.0;
    final khaltiRevenue = revenue?.khaltiRevenue ?? 0.0;
    final paidBookings  = revenue?.paidBookings  ?? 0;

    final pendingAmount = bookings
        .where((b) => b['booking']?['status'] == 'Confirmed' && b['booking']?['paymentStatus'] != 'Paid')
        .fold(0.0, (sum, b) => sum + ((b['booking']?['totalPrice'] as num?)?.toDouble() ?? 0));

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _divider),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.account_balance_wallet_outlined, color: _green, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Total Earnings',
                style: GoogleFonts.dmSans(fontSize: 12.sp, color: _muted)),
            Text('Rs. ${totalRevenue.toStringAsFixed(0)}',
                style: GoogleFonts.dmSans(fontSize: 22.sp, fontWeight: FontWeight.bold, color: _green)),
          ]),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: _green.withValues(alpha: 0.2)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.check_circle_outline_rounded, size: 11.sp, color: _green),
              SizedBox(width: 4.w),
              Text('$paidBookings paid',
                  style: GoogleFonts.dmSans(fontSize: 11.sp, color: _green, fontWeight: FontWeight.w600)),
            ]),
          ),
        ]),
        SizedBox(height: 16.h),
        Row(children: [
          _EarningChip(label: 'Cash', value: 'Rs. ${cashRevenue.toStringAsFixed(0)}',
              icon: Icons.money_rounded, iconColor: _green),
          SizedBox(width: 8.w),
          _EarningChip(label: 'Khalti', value: 'Rs. ${khaltiRevenue.toStringAsFixed(0)}',
              icon: Icons.phone_android_rounded, iconColor: const Color(0xFF5C35AA)),
          SizedBox(width: 8.w),
          _EarningChip(label: 'Pending', value: 'Rs. ${pendingAmount.toStringAsFixed(0)}',
              icon: Icons.hourglass_bottom_rounded, iconColor: const Color(0xFF8B7355), isPending: true),
        ]),
      ]),
    );
  }
}

class _EarningChip extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color iconColor;
  final bool isPending;
  const _EarningChip({required this.label, required this.value,
    required this.icon, required this.iconColor, this.isPending = false});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isPending ? const Color(0xFFFFF8EE) : _tagBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: isPending ? const Color(0xFFE8D5B0) : _divider),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 11.sp, color: iconColor),
          SizedBox(width: 4.w),
          Text(label, style: GoogleFonts.dmSans(fontSize: 9.sp, color: _muted, fontWeight: FontWeight.w500)),
        ]),
        SizedBox(height: 5.h),
        Text(value, style: GoogleFonts.dmSans(fontSize: 12.sp, fontWeight: FontWeight.bold, color: _ink)),
      ]),
    ),
  );
}

class _PersonalInfoCard extends StatelessWidget {
  final String name, email, phone;
  final VoidCallback onEdit;
  const _PersonalInfoCard({required this.name, required this.email,
    required this.phone, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _divider),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Icon(Icons.person_outline_rounded, size: 17.sp, color: _brown),
            SizedBox(width: 8.w),
            Text('Personal Information',
                style: GoogleFonts.dmSans(fontSize: 14.sp, fontWeight: FontWeight.bold, color: _ink)),
          ]),
          GestureDetector(
            onTap: onEdit,
            child: Row(children: [
              Icon(Icons.edit_outlined, size: 14.sp, color: _muted),
              SizedBox(width: 4.w),
              Text('Edit', style: GoogleFonts.dmSans(fontSize: 13.sp, color: _muted, fontWeight: FontWeight.w500)),
            ]),
          ),
        ]),
        SizedBox(height: 16.h),
        _InfoField(icon: Icons.person_outline_rounded, label: 'Full Name',      value: name.isEmpty  ? '—' : name),
        _InfoField(icon: Icons.email_outlined,          label: 'Email Address', value: email.isEmpty ? '—' : email),
        _InfoField(icon: Icons.phone_outlined,          label: 'Phone Number',  value: phone.isEmpty ? '—' : phone, last: true),
      ]),
    );
  }
}

class _InfoField extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final bool last;
  const _InfoField({required this.icon, required this.label, required this.value, this.last = false});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Icon(icon, size: 13.sp, color: _muted),
      SizedBox(width: 6.w),
      Text(label, style: GoogleFonts.dmSans(fontSize: 11.sp, color: _muted, fontWeight: FontWeight.w500)),
    ]),
    SizedBox(height: 5.h),
    Padding(
      padding: EdgeInsets.only(left: 19.w),
      child: Text(value, style: GoogleFonts.dmSans(fontSize: 14.sp, color: _ink)),
    ),
    if (!last) ...[SizedBox(height: 12.h), Container(height: 1, color: _divider), SizedBox(height: 12.h)],
  ]);
}

class _KhaltiCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _divider),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: const Color(0xFF5C35AA).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.account_balance_wallet_rounded,
                  color: const Color(0xFF5C35AA), size: 18.sp),
            ),
            SizedBox(width: 10.w),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Khalti Payment Details',
                  style: GoogleFonts.dmSans(fontSize: 14.sp, fontWeight: FontWeight.bold, color: _ink)),
              Text('For receiving payments',
                  style: GoogleFonts.dmSans(fontSize: 11.sp, color: _muted)),
            ]),
          ]),

        ]),
        SizedBox(height: 14.h),
        Container(height: 1, color: _divider),
        SizedBox(height: 12.h),
        Text('Khalti ID / Mobile Number',
            style: GoogleFonts.dmSans(fontSize: 11.sp, color: _muted, fontWeight: FontWeight.w500)),
        SizedBox(height: 5.h),
        Text('9800000005',
            style: GoogleFonts.dmSans(fontSize: 15.sp, fontWeight: FontWeight.bold, color: _ink)),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: _green.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: _green.withValues(alpha: 0.15)),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.info_outline_rounded, size: 14.sp, color: _green),
            SizedBox(width: 8.w),
            Expanded(child: Text(
              'Earnings will be transferred to this Khalti account after guest check-out.',
              style: GoogleFonts.dmSans(fontSize: 11.sp, color: _green, height: 1.5),
            )),
          ]),
        ),
      ]),
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  final List<Map<String, dynamic>> bookings;
  const _PerformanceCard({required this.bookings});

  @override
  Widget build(BuildContext context) {
    final total     = bookings.length;
    final confirmed = bookings.where((b) => b['booking']?['status'] == 'Confirmed' || b['booking']?['status'] == 'Completed').length;
    final acceptRate = total > 0 ? (confirmed / total * 100).round() : 0;
    final isSuperhost = acceptRate >= 90 && total >= 10;

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _divider),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.military_tech_outlined, size: 18.sp, color: _brown),
          SizedBox(width: 8.w),
          Text('Performance Highlights',
              style: GoogleFonts.dmSans(fontSize: 14.sp, fontWeight: FontWeight.bold, color: _ink)),
        ]),
        SizedBox(height: 14.h),
        _PerfRow(
          icon: Icons.star_rounded,
          iconBg: _green.withValues(alpha: 0.1),
          iconColor: _green,
          title: 'Superhost Status',
          subtitle: isSuperhost ? 'Top-rated host' : 'Reach 90% acceptance to unlock',
          trailing: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: isSuperhost ? _green : _tagBg,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(isSuperhost ? 'Active' : 'Inactive',
                style: GoogleFonts.dmSans(
                    fontSize: 11.sp,
                    color: isSuperhost ? Colors.white : _muted,
                    fontWeight: FontWeight.w600)),
          ),
        ),
        SizedBox(height: 10.h),
        _PerfRow(
          icon: Icons.trending_up_rounded,
          iconBg: _brown.withValues(alpha: 0.1),
          iconColor: _brown,
          title: 'Total Bookings',
          subtitle: 'All time',
          trailing: Text('$total',
              style: GoogleFonts.dmSans(fontSize: 15.sp, fontWeight: FontWeight.bold, color: _brown)),
        ),
        SizedBox(height: 10.h),
        _PerfRow(
          icon: Icons.home_outlined,
          iconBg: _slate.withValues(alpha: 0.1),
          iconColor: _slate,
          title: 'Acceptance Rate',
          subtitle: 'Confirmed + Completed vs total',
          trailing: Text('$acceptRate%',
              style: GoogleFonts.dmSans(fontSize: 15.sp, fontWeight: FontWeight.bold, color: _slate)),
        ),
      ]),
    );
  }
}

class _PerfRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, subtitle;
  final Widget trailing;
  const _PerfRow({required this.icon, required this.iconBg, required this.iconColor,
    required this.title, required this.subtitle, required this.trailing});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
    decoration: BoxDecoration(color: _tagBg, borderRadius: BorderRadius.circular(12.r)),
    child: Row(children: [
      Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10.r)),
        child: Icon(icon, size: 16.sp, color: iconColor),
      ),
      SizedBox(width: 12.w),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.dmSans(fontSize: 13.sp, fontWeight: FontWeight.w600, color: _ink)),
        Text(subtitle, style: GoogleFonts.dmSans(fontSize: 11.sp, color: _muted)),
      ])),
      trailing,
    ]),
  );
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _divider),
      ),
      child: Row(children: [
        Icon(icon, size: 18.sp, color: _slate),
        SizedBox(width: 12.w),
        Expanded(child: Text(label,
            style: GoogleFonts.dmSans(fontSize: 14.sp, fontWeight: FontWeight.w500, color: _ink))),
        Icon(Icons.chevron_right_rounded, size: 20.sp, color: _muted),
      ]),
    ),
  );
}