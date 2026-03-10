import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/services/image_proxy.dart';
import 'package:lokyatra_frontend/data/datasources/homestays_remote_datasource.dart';
import 'package:lokyatra_frontend/data/models/Homestay.dart';
import 'package:lokyatra_frontend/presentation/screens/OwnerScreen/HomestayAddPage.dart';
import 'package:lokyatra_frontend/presentation/screens/OwnerScreen/HomestayEditPage.dart';
import 'package:lokyatra_frontend/presentation/screens/OwnerScreen/HomestayListingsPage.dart';
import 'package:lokyatra_frontend/presentation/screens/OwnerScreen/OwnerHomestayDetailPage.dart';
import '../../../core/services/sqlite_service.dart';
import '../../../data/datasources/User_remote_datasource.dart';
import '../../state_management/Bloc/homestays/HomestayBloc.dart';
import '../../state_management/Bloc/homestays/HomestayEvent.dart';
import '../../state_management/Bloc/homestays/HomestayState.dart';

const _ink    = Color(0xFF2D1B10);
const _accent = Color(0xFFCD6E4E);
const _cream  = Color(0xFFFAF7F2);

class OwnerHomePage extends StatefulWidget {
  const OwnerHomePage({super.key});
  @override
  State<OwnerHomePage> createState() => _OwnerHomePageState();
}

class _OwnerHomePageState extends State<OwnerHomePage> {
  String? _img;

  @override
  void initState() {
    super.initState();
    _loadImg();
    context.read<HomestayBloc>().add(const OwnerLoadMyHomestays());
  }

  void _reload() {
    if (mounted) context.read<HomestayBloc>().add(const OwnerLoadMyHomestays());
  }

  Future<void> _loadImg() async {
    final db     = SqliteService();
    final cached = await db.get('user_profile_image');
    if (mounted) setState(() => _img = (cached != null && cached.isNotEmpty) ? cached : null);
    if (await db.isOnline()) {
      try {
        final res = await UserRemoteDatasource().getCurrentUser();
        if (res.statusCode == 200) {
          final i = (res.data as Map<String, dynamic>)['profileImage'] as String? ?? '';
          if (i.isNotEmpty && i != cached) {
            await db.put('user_profile_image', i);
            if (mounted) setState(() => _img = i);
          }
        }
      } catch (_) {}
    }
  }

  void _goDetail(Homestay h) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => OwnerHomestayDetailPage(homestay: h)))
          .then((_) => _reload());

  void _goEdit(Homestay h) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => HomestayEditPage(homestay: h)))
          .then((ok) { if (ok == true) _reload(); });

  void _goAdd() =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => const HomestayAddPage()))
          .then((ok) { if (ok == true) _reload(); });

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 700;
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: wide ? 860 : double.infinity),
            child: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('LokYatra',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 22.sp, fontWeight: FontWeight.bold, color: _ink)),
                    CircleAvatar(
                      radius: 24.r,
                      backgroundColor: _accent.withValues(alpha: 0.1),
                      backgroundImage: _img != null ? NetworkImage(_img!) : null,
                      child: _img == null ? Icon(Icons.person, color: _accent, size: 24.sp) : null,
                    ),
                  ]),
                ),
                SizedBox(height: 16.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [_ink, Color(0xFF4A2D1E)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Total Earnings',
                          style: GoogleFonts.dmSans(fontSize: 13.sp, color: Colors.white60)),
                      SizedBox(height: 6.h),
                      Text('Rs. 15,000',
                          style: GoogleFonts.playfairDisplay(
                              fontSize: 30.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('This month',
                          style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.white60)),
                      SizedBox(height: 16.h),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                          ),
                          child: Text('View Balance Details',
                              style: GoogleFonts.dmSans(
                                  fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.white)),
                        ),
                      ),
                    ]),
                  ),
                ),
                SizedBox(height: 16.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(children: [
                    Expanded(child: _QuickBtn(Icons.add_rounded, 'Add Listing', _goAdd)),
                    SizedBox(width: 14.w),
                    Expanded(child: _QuickBtn(Icons.calendar_today_outlined, 'Availability', () {
                      final bloc = context.read<HomestayBloc>();
                      Navigator.push(context, MaterialPageRoute(
                          builder: (_) => BlocProvider.value(value: bloc, child: const HomestayListingsPage())));
                    })),
                  ]),
                ),
                SizedBox(height: 24.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('My Homestays',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 18.sp, fontWeight: FontWeight.bold, color: _ink)),
                    GestureDetector(
                      onTap: _goAdd,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                        decoration: BoxDecoration(color: _accent, borderRadius: BorderRadius.circular(20.r)),
                        child: Row(children: [
                          Icon(Icons.add, color: Colors.white, size: 14.sp),
                          SizedBox(width: 4.w),
                          Text('Add', style: GoogleFonts.dmSans(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.white)),
                        ]),
                      ),
                    ),
                  ]),
                ),
                SizedBox(height: 12.h),
                BlocBuilder<HomestayBloc, HomestayState>(
                  builder: (context, state) {
                    if (state is HomestayLoading) {
                      return const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator(color: _accent)));
                    }
                    if (state is HomestayError) {
                      return Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Column(children: [
                          Icon(Icons.error_outline, color: Colors.red, size: 36.sp),
                          SizedBox(height: 8.h),
                          Text(state.message, textAlign: TextAlign.center,
                              style: GoogleFonts.dmSans(fontSize: 13.sp, color: Colors.grey)),
                          TextButton(onPressed: _reload,
                              child: Text('Retry', style: GoogleFonts.dmSans(color: _accent))),
                        ]),
                      );
                    }
                    if (state is OwnerHomestaysLoaded) {
                      if (state.homestays.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.all(24.h),
                          child: Column(children: [
                            Icon(Icons.home_outlined, size: 48.sp, color: Colors.grey[300]),
                            SizedBox(height: 12.h),
                            Text('No homestays yet',
                                style: GoogleFonts.dmSans(fontSize: 14.sp, color: Colors.grey)),
                            TextButton(onPressed: _goAdd,
                                child: Text('Add your first one',
                                    style: GoogleFonts.dmSans(color: _accent))),
                          ]),
                        );
                      }
                      return Column(children: [
                        ...state.homestays.take(3).map((h) => Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 10.h),
                          child: _HomestayRow(
                            key: ValueKey(h.id),
                            homestay: h,
                            onEdit: () => _goEdit(h),
                            onTap: () => _goDetail(h),
                            onReload: _reload,
                          ),
                        )),
                        if (state.homestays.length > 3)
                          TextButton(
                            onPressed: () {},
                            child: Text('View all ${state.homestays.length} homestays',
                                style: GoogleFonts.dmSans(fontSize: 13.sp, color: _accent)),
                          ),
                      ]);
                    }
                    return const SizedBox.shrink();
                  },
                ),
                SizedBox(height: 20.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Booking Requests',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 18.sp, fontWeight: FontWeight.bold, color: _ink)),
                    Text('View All',
                        style: GoogleFonts.dmSans(fontSize: 13.sp, color: _accent, fontWeight: FontWeight.w600)),
                  ]),
                ),
                SizedBox(height: 12.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Row(children: [
                      CircleAvatar(
                        radius: 21.r,
                        backgroundColor: _accent.withValues(alpha: 0.08),
                        child: Icon(Icons.person_outline_rounded, size: 22.sp, color: _accent),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('No new requests',
                            style: GoogleFonts.dmSans(fontSize: 14.sp, fontWeight: FontWeight.w600, color: _ink)),
                        Text('New booking requests will appear here',
                            style: GoogleFonts.dmSans(fontSize: 11.sp, color: Colors.grey[500])),
                      ])),
                    ]),
                  ),
                ),
                SizedBox(height: 40.h),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickBtn(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(children: [
        Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(color: _accent.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, size: 22.sp, color: _accent)),
        SizedBox(height: 10.h),
        Text(label, style: GoogleFonts.dmSans(fontSize: 13.sp, fontWeight: FontWeight.w600, color: _ink)),
      ]),
    ),
  );
}

class _HomestayRow extends StatefulWidget {
  final Homestay homestay;
  final VoidCallback onEdit, onTap, onReload;
  const _HomestayRow({super.key, required this.homestay, required this.onEdit, required this.onTap, required this.onReload});
  @override
  State<_HomestayRow> createState() => _HomestayRowState();
}

class _HomestayRowState extends State<_HomestayRow> {
  late bool _visible;
  bool _toggling = false;

  @override
  void initState() { super.initState(); _visible = widget.homestay.isVisible; }

  @override
  void didUpdateWidget(_HomestayRow old) {
    super.didUpdateWidget(old);
    if (old.homestay.isVisible != widget.homestay.isVisible) _visible = widget.homestay.isVisible;
  }

  Future<void> _toggle() async {
    if (_toggling) return;
    final next = !_visible;
    setState(() { _visible = next; _toggling = true; });
    try {
      final res = await HomestaysRemoteDatasource().toggleVisibility(widget.homestay.id, next);
      if (res.statusCode != 200 && res.statusCode != 204) {
        if (mounted) setState(() => _visible = !next);
        _snack('Failed to update visibility');
      } else {
        _snack('${widget.homestay.name} is now ${next ? 'Active' : 'Inactive'}', ok: true);
        widget.onReload();
      }
    } catch (_) {
      if (mounted) setState(() => _visible = !next);
      _snack('Connection error. Try again.');
    } finally {
      if (mounted) setState(() => _toggling = false);
    }
  }

  void _snack(String msg, {bool ok = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.dmSans()),
      backgroundColor: ok ? Colors.green[600] : Colors.red[700],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      margin: EdgeInsets.all(12.w),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final h    = widget.homestay;
    final img  = h.imageUrls.isNotEmpty ? h.imageUrls.first : null;
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: img != null
                ? ProxyImage(imageUrl: img, width: 72.w, height: 72.h, borderRadiusValue: 0)
                : Container(width: 72.w, height: 72.h, color: _cream,
                child: Icon(Icons.home_outlined, size: 28.sp, color: _accent)),
          ),
          SizedBox(width: 12.w),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(h.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(fontSize: 14.sp, fontWeight: FontWeight.bold, color: _ink))),
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: _visible ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: _visible ? Colors.green.shade300 : Colors.grey.shade300),
                ),
                child: Text(_visible ? 'Active' : 'Inactive',
                    style: GoogleFonts.dmSans(fontSize: 10.sp, fontWeight: FontWeight.w600,
                        color: _visible ? Colors.green.shade700 : Colors.grey[600])),
              ),
            ]),
            SizedBox(height: 4.h),
            Text('Rs. ${h.pricePerNight.toStringAsFixed(0)} / night',
                style: GoogleFonts.dmSans(fontSize: 11.sp, color: Colors.grey[500])),
            SizedBox(height: 8.h),
            Row(children: [
              _Btn(Icons.edit_outlined, 'Edit', widget.onEdit),
              SizedBox(width: 8.w),
              _Btn(
                _toggling ? Icons.hourglass_top_rounded : _visible ? Icons.pause_circle_outline : Icons.play_circle_outline,
                _toggling ? '...' : _visible ? 'Pause' : 'Resume',
                _toggling ? () {} : _toggle,
                active: !_visible,
              ),
            ]),
          ])),
        ]),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  const _Btn(this.icon, this.label, this.onTap, {this.active = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      decoration: BoxDecoration(
        border: Border.all(color: active ? _accent.withValues(alpha: 0.4) : Colors.grey.shade200),
        borderRadius: BorderRadius.circular(20.r),
        color: active ? _accent.withValues(alpha: 0.06) : Colors.grey.shade50,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12.sp, color: _accent),
        SizedBox(width: 4.w),
        Text(label, style: GoogleFonts.dmSans(fontSize: 11.sp, fontWeight: FontWeight.w600, color: _accent)),
      ]),
    ),
  );
}