import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/image_proxy.dart';
import 'package:lokyatra_frontend/data/datasources/homestays_remote_datasource.dart';
import 'package:lokyatra_frontend/data/models/Homestay.dart';
import 'package:lokyatra_frontend/presentation/screens/OwnerScreen/HomestayAddPage.dart';
import 'package:lokyatra_frontend/presentation/screens/OwnerScreen/HomestayDetailPage.dart';
import 'package:lokyatra_frontend/presentation/screens/OwnerScreen/HomestayEditPage.dart';
import 'package:lokyatra_frontend/presentation/screens/OwnerScreen/HomestayListingsPage.dart';
import '../../state_management/Bloc/homestays/HomestayBloc.dart';
import '../../state_management/Bloc/homestays/HomestayEvent.dart';
import '../../state_management/Bloc/homestays/HomestayState.dart';

class OwnerHomePage extends StatefulWidget {
  const OwnerHomePage({super.key});

  @override
  State<OwnerHomePage> createState() => _OwnerHomePageState();
}

class _OwnerHomePageState extends State<OwnerHomePage> {
  static const _brown = Color(0xFF5C4033);
  static const _bg = Color(0xFFF5EFE9);

  @override
  void initState() {
    super.initState();
    context.read<HomestayBloc>().add(const LoadMyHomestays());
  }

  void _reload() {
    if (mounted) context.read<HomestayBloc>().add(const LoadMyHomestays());
  }

  void _goToDetail(Homestay h) =>
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => HomestayDetailPage(homestay: h)))
          .then((_) => _reload());

  void _goToEdit(Homestay h) =>
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => HomestayEditPage(homestay: h)))
          .then((updated) {
        if (updated == true) _reload();
      });

  void _goToAdd() =>
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const HomestayAddPage()))
          .then((added) {
        if (added == true) _reload();
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F4),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('LokYatra',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D1B10))),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 7.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.person_outline_rounded,
                              size: 16.sp, color: _brown),
                          SizedBox(width: 6.w),
                          Text('Host',
                              style: GoogleFonts.dmSans(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: _brown)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // ── Earnings Card ────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Earnings',
                              style: GoogleFonts.dmSans(
                                  fontSize: 13.sp, color: Colors.grey[600])),
                          Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: _brown.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.attach_money,
                                color: _brown, size: 22.sp),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text('Rs. 15,000',
                          style: GoogleFonts.playfairDisplay(
                              fontSize: 30.sp,
                              fontWeight: FontWeight.bold,
                              color: _brown)),
                      SizedBox(height: 2.h),
                      Text('This month',
                          style: GoogleFonts.dmSans(
                              fontSize: 12.sp, color: Colors.grey[500])),
                      SizedBox(height: 16.h),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r)),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            backgroundColor: Colors.white,
                          ),
                          child: Text('View Balance Details',
                              style: GoogleFonts.dmSans(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2D1B10))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // ── Quick Actions ────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.add_rounded,
                        label: 'Add Listing',
                        onTap: _goToAdd,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.calendar_today_outlined,
                        label: 'Availability',
                        onTap: () {
                          final bloc = context.read<HomestayBloc>();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: bloc,
                                child: const HomestayListingsPage(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // ── My Homestays header ──────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('My Homestays',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D1B10))),
                    GestureDetector(
                      onTap: _goToAdd,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 7.h),
                        decoration: BoxDecoration(
                          color: _brown,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.add, color: Colors.white, size: 14.sp),
                            SizedBox(width: 4.w),
                            Text('Add',
                                style: GoogleFonts.dmSans(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              // ── Bloc-driven homestay list ────────────────────────────
              BlocBuilder<HomestayBloc, HomestayState>(
                builder: (context, state) {
                  if (state is HomestayLoading) {
                    return Padding(
                      padding: EdgeInsets.all(24.h),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (state is HomestayError) {
                    return Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.error_outline,
                                color: Colors.red, size: 36.sp),
                            SizedBox(height: 8.h),
                            Text(state.message,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.dmSans(
                                    fontSize: 13.sp, color: Colors.grey)),
                            SizedBox(height: 12.h),
                            TextButton(
                              onPressed: _reload,
                              child: Text('Retry',
                                  style: GoogleFonts.dmSans(color: _brown)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is HomestaysLoaded) {
                    if (state.homestays.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.all(24.h),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.home_outlined,
                                  size: 48.sp, color: Colors.grey[300]),
                              SizedBox(height: 12.h),
                              Text('No homestays yet',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 14.sp, color: Colors.grey)),
                              SizedBox(height: 8.h),
                              TextButton(
                                onPressed: _goToAdd,
                                child: Text('Add your first one',
                                    style: GoogleFonts.dmSans(color: _brown)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final preview = state.homestays.take(3).toList();
                    return Column(
                      children: [
                        ...preview.map((h) => Padding(
                          padding:
                          EdgeInsets.fromLTRB(20.w, 0, 20.w, 10.h),
                          child: _HomestayRow(
                            key: ValueKey(h.id),
                            homestay: h,
                            onEdit: () => _goToEdit(h),
                            onTap: () => _goToDetail(h),
                            onReload: _reload,
                          ),
                        )),
                        if (state.homestays.length > 3)
                          Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: TextButton(
                              onPressed: () {},
                              child: Text(
                                'View all ${state.homestays.length} homestays →',
                                style: GoogleFonts.dmSans(
                                    fontSize: 13.sp, color: _brown),
                              ),
                            ),
                          ),
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),

              SizedBox(height: 20.h),

              // ── Booking Requests ─────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Booking Requests',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D1B10))),
                    Text('View All',
                        style: GoogleFonts.dmSans(
                            fontSize: 13.sp,
                            color: _brown,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
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
                  child: Row(
                    children: [
                      Container(
                        width: 42.w,
                        height: 42.h,
                        decoration: BoxDecoration(
                          color: _bg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person_outline_rounded,
                            size: 22.sp, color: _brown),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('No new requests',
                                style: GoogleFonts.dmSans(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600)),
                            Text('New booking requests will appear here',
                                style: GoogleFonts.dmSans(
                                    fontSize: 11.sp, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Quick Action Card ────────────────────────────────────────────────────────

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  static const _brown = Color(0xFF5C4033);

  const _QuickActionCard({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: _brown.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 22.sp, color: _brown),
            ),
            SizedBox(height: 10.h),
            Text(label,
                style: GoogleFonts.dmSans(
                    fontSize: 13.sp, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ── Homestay Row — StatefulWidget to handle optimistic toggle ────────────────

class _HomestayRow extends StatefulWidget {
  final Homestay homestay;
  final VoidCallback onEdit;
  final VoidCallback onTap;
  final VoidCallback onReload;

  const _HomestayRow({
    super.key,
    required this.homestay,
    required this.onEdit,
    required this.onTap,
    required this.onReload,
  });

  @override
  State<_HomestayRow> createState() => _HomestayRowState();
}

class _HomestayRowState extends State<_HomestayRow> {
  static const _brown = Color(0xFF5C4033);

  late bool _isVisible;
  bool _toggling = false;

  @override
  void initState() {
    super.initState();
    _isVisible = widget.homestay.isVisible;
  }

  // When parent rebuilds with new homestay data, sync local state
  @override
  void didUpdateWidget(_HomestayRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.homestay.isVisible != widget.homestay.isVisible) {
      _isVisible = widget.homestay.isVisible;
    }
  }

  Future<void> _toggleVisibility() async {
    if (_toggling) return;
    final newVal = !_isVisible;

    // Optimistic update
    setState(() {
      _isVisible = newVal;
      _toggling = true;
    });

    try {
      final res = await HomestaysRemoteDatasource()
          .toggleVisibility(widget.homestay.id, newVal);

      if (res.statusCode != 200 && res.statusCode != 204) {
        // Revert on failure
        if (mounted) setState(() => _isVisible = !newVal);
        _snack('Failed to update visibility');
      } else {
        _snack(
          newVal ? '${widget.homestay.name} is now Active' : '${widget.homestay.name} is now Inactive',
          isError: false,
        );
        // Tell parent to reload bloc so list stays in sync
        widget.onReload();
      }
    } catch (_) {
      if (mounted) setState(() => _isVisible = !newVal);
      _snack('Connection error. Try again.');
    } finally {
      if (mounted) setState(() => _toggling = false);
    }
  }

  void _snack(String msg, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.dmSans()),
      backgroundColor: isError ? Colors.red[700] : Colors.green[600],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      margin: EdgeInsets.all(12.w),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.homestay;
    final firstImage = h.imageUrls.isNotEmpty ? h.imageUrls.first : null;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: firstImage != null
                  ? ProxyImage(
                imageUrl: firstImage,
                width: 72.w,
                height: 72.h,
                borderRadiusValue: 0,
              )
                  : Container(
                width: 72.w,
                height: 72.h,
                color: const Color(0xFFF5EFE9),
                child: Icon(Icons.home_outlined, size: 28.sp, color: _brown),
              ),
            ),
            SizedBox(width: 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + status pill
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          h.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.dmSans(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2D1B10)),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: _isVisible
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: _isVisible
                                ? Colors.green.shade300
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          _isVisible ? 'Active' : 'Inactive',
                          style: GoogleFonts.dmSans(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: _isVisible
                                ? Colors.green.shade700
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 4.h),
                  Text('Rs. ${h.pricePerNight.toStringAsFixed(0)} / night',
                      style: GoogleFonts.dmSans(
                          fontSize: 11.sp, color: Colors.grey[500])),
                  SizedBox(height: 8.h),

                  // Edit + Pause/Resume buttons
                  Row(
                    children: [
                      _ActionBtn(
                        icon: Icons.edit_outlined,
                        label: 'Edit',
                        onTap: widget.onEdit,
                      ),
                      SizedBox(width: 8.w),
                      _ActionBtn(
                        icon: _toggling
                            ? Icons.hourglass_top_rounded
                            : _isVisible
                            ? Icons.pause_circle_outline
                            : Icons.play_circle_outline,
                        label: _toggling
                            ? '...'
                            : _isVisible
                            ? 'Pause'
                            : 'Resume',
                        onTap: _toggling ? () {} : _toggleVisibility,
                        isActive: !_isVisible, // highlights Resume in brown
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Action Button ────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  static const _brown = Color(0xFF5C4033);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
        decoration: BoxDecoration(
          border: Border.all(
            color: isActive ? _brown.withValues(alpha: 0.4) : Colors.grey.shade200,
          ),
          borderRadius: BorderRadius.circular(20.r),
          color: isActive
              ? _brown.withValues(alpha: 0.06)
              : Colors.grey.shade50,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12.sp, color: _brown),
            SizedBox(width: 4.w),
            Text(label,
                style: GoogleFonts.dmSans(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: _brown)),
          ],
        ),
      ),
    );
  }
}