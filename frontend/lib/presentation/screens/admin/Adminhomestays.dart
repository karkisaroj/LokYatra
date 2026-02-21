import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/image_proxy.dart';
import '../../../data/models/Homestay.dart';
import '../../state_management/Bloc/homestays/HomestayBloc.dart';
import '../../state_management/Bloc/homestays/HomestayEvent.dart';
import '../../state_management/Bloc/homestays/HomestayState.dart';
import 'Adminhomestaydetailpage.dart';

class Homestays extends StatefulWidget {
  final ValueNotifier subtitleNotifier;
  const Homestays({super.key, required this.subtitleNotifier});

  @override
  State<Homestays> createState() => _HomestaysState();
}

class _HomestaysState extends State<Homestays> {
  static const _slate = Color(0xFF3D5A80);
  static const _bg = Color(0xFFF4F6F9);

  String _search = '';
  String _filter = 'All'; // 'All' | 'Active' | 'Paused'

  @override
  void initState() {
    super.initState();
    Future.microtask(() => widget.subtitleNotifier.value = 'Manage Homestays');
    context.read<HomestayBloc>().add(const TouristLoadAllHomestays());
  }

  void _reload() =>
      context.read<HomestayBloc>().add(const TouristLoadAllHomestays());

  List<Homestay> _filtered(List<Homestay> all) {
    var list = all;
    if (_filter == 'Active') list = list.where((h) => h.isVisible).toList();
    if (_filter == 'Paused') list = list.where((h) => !h.isVisible).toList();
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list
          .where((h) =>
      h.name.toLowerCase().contains(q) ||
          h.location.toLowerCase().contains(q) ||
          (h.nearCulturalSite?.name.toLowerCase().contains(q) ?? false))
          .toList();
    }
    return list;
  }

  Color _chipBg(String label) => switch (label) {
    'Active' => Colors.green[600]!,
    'Paused' => Colors.grey[700]!,
    _ => _slate,
  };

  void _pushDetail(Homestay h) => Navigator.push(
    context,
    MaterialPageRoute(
        builder: (_) => AdminHomestayDetailPage(homestay: h)),
  ).then((_) => _reload());

  void _confirmToggle(Homestay h) {
    final on = h.isVisible;
    _dialog(
      icon: on
          ? Icons.pause_circle_outline_rounded
          : Icons.play_circle_outline_rounded,
      iconColor: on ? Colors.grey[700]! : Colors.green[600]!,
      title: on ? 'Pause Homestay?' : 'Activate Homestay?',
      body: on
          ? '"${h.name}" will be hidden from tourists.'
          : '"${h.name}" will become visible to tourists.',
      confirmLabel: on ? 'Pause' : 'Activate',
      confirmColor: on ? Colors.grey[700]! : Colors.green[600]!,
      onConfirm: () => context
          .read<HomestayBloc>()
          .add(AdminToggleHomestayVisibility(h.id, !on)),
    );
  }

  void _confirmDelete(Homestay h) {
    _dialog(
      icon: Icons.delete_outline_rounded,
      iconColor: Colors.red[600]!,
      title: 'Delete Homestay?',
      body: 'Permanently delete "${h.name}"? This cannot be undone.',
      confirmLabel: 'Delete',
      confirmColor: Colors.red[600]!,
      onConfirm: () =>
          context.read<HomestayBloc>().add(AdminDeleteHomestay(h.id)),
    );
  }

  void _dialog({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String body,
    required String confirmLabel,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) => _ConfirmDialog(
        icon: icon,
        iconColor: iconColor,
        title: title,
        body: body,
        confirmLabel: confirmLabel,
        confirmColor: confirmColor,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Container(
      color: _bg,
      child: Column(
        children: [
          // ── Toolbar ──
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 10.h),
            child: Column(
              children: [
                // Search
                Container(
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _search = v),
                    style: GoogleFonts.dmSans(fontSize: 14.sp),
                    decoration: InputDecoration(
                      hintText: 'Search by name, location...',
                      hintStyle: GoogleFonts.dmSans(
                          fontSize: 14.sp, color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search,
                          color: Colors.grey[400], size: 20.sp),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.refresh_rounded,
                            size: 20.sp, color: Colors.grey[500]),
                        onPressed: _reload,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 4.w, vertical: 13.h),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                // Filter chips
                Row(
                  children: ['All', 'Active', 'Paused']
                      .map((label) => Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: GestureDetector(
                      onTap: () => setState(() => _filter = label),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 7.h),
                        decoration: BoxDecoration(
                          color: _filter == label
                              ? _chipBg(label)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: _filter == label
                                ? _chipBg(label)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          label,
                          style: GoogleFonts.dmSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: _filter == label
                                ? Colors.white
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ))
                      .toList(),
                ),
              ],
            ),
          ),

          // ── Body ──
          Expanded(
            child: BlocBuilder<HomestayBloc, HomestayState>(
              builder: (context, state) {
                if (state is HomestayLoading) {
                  return const Center(
                      child: CircularProgressIndicator(color: _slate));
                }
                if (state is HomestayError) {
                  return _ErrorView(message: state.message, onRetry: _reload);
                }
                if (state is TouristAllHomestaysLoaded) {
                  final list = _filtered(state.homestays);
                  final activeN =
                      state.homestays.where((h) => h.isVisible).length;
                  final pausedN =
                      state.homestays.where((h) => !h.isVisible).length;

                  return Column(
                    children: [
                      // Stats bar
                      Container(
                        color: Colors.white,
                        padding:
                        EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 10.h),
                        child: Row(children: [
                          _StatPill(
                              label: 'Total',
                              count: state.homestays.length,
                              color: _slate),
                          SizedBox(width: 8.w),
                          _StatPill(
                              label: 'Active',
                              count: activeN,
                              color: Colors.green[600]!),
                          SizedBox(width: 8.w),
                          _StatPill(
                              label: 'Paused',
                              count: pausedN,
                              color: Colors.grey[600]!),
                        ]),
                      ),
                      const Divider(height: 1),

                      Expanded(
                        child: list.isEmpty
                            ? _EmptyView(filter: _filter)
                            : isWide
                            ? _WebGrid(
                          list: list,
                          onView: _pushDetail,
                          onToggle: _confirmToggle,
                          onDelete: _confirmDelete,
                        )
                            : _MobileList(
                          list: list,
                          onView: _pushDetail,
                          onToggle: _confirmToggle,
                          onDelete: _confirmDelete,
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mobile list ───────────────────────────────────────────────────────────────

class _MobileList extends StatelessWidget {
  final List<Homestay> list;
  final void Function(Homestay) onView;
  final void Function(Homestay) onToggle;
  final void Function(Homestay) onDelete;

  const _MobileList({
    required this.list,
    required this.onView,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 24.h),
      itemCount: list.length,
      itemBuilder: (_, i) => _MobileCard(
        homestay: list[i],
        onView: () => onView(list[i]),
        onToggle: () => onToggle(list[i]),
        onDelete: () => onDelete(list[i]),
      ),
    );
  }
}

// ── Web grid ──────────────────────────────────────────────────────────────────

class _WebGrid extends StatelessWidget {
  final List<Homestay> list;
  final void Function(Homestay) onView;
  final void Function(Homestay) onToggle;
  final void Function(Homestay) onDelete;

  const _WebGrid({
    required this.list,
    required this.onView,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.55,
      ),
      itemCount: list.length,
      itemBuilder: (_, i) => _WebCard(
        homestay: list[i],
        onView: () => onView(list[i]),
        onToggle: () => onToggle(list[i]),
        onDelete: () => onDelete(list[i]),
      ),
    );
  }
}

// ── Mobile card — overflow-safe ───────────────────────────────────────────────

class _MobileCard extends StatelessWidget {
  final Homestay homestay;
  final VoidCallback onView;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  static const _slate = Color(0xFF3D5A80);
  static const _dark = Color(0xFF1A1A2E);

  const _MobileCard({
    required this.homestay,
    required this.onView,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final h = homestay;
    final img = h.imageUrls.isNotEmpty ? h.imageUrls.first : null;
    final on = h.isVisible;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      // ── Use Column so image + bottom row are stacked ──
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(14.r)),
                child: ProxyImage(
                  imageUrl: img,
                  width: double.infinity,
                  height: 130.h,
                  borderRadiusValue: 0,
                  thumb: true,
                ),
              ),
              if (!on)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(14.r)),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.pause_circle_rounded,
                                color: Colors.white, size: 18.sp),
                            SizedBox(width: 4.w),
                            Text('Paused',
                                style: GoogleFonts.dmSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12.sp)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              // Status badge
              Positioned(
                top: 8.h,
                left: 8.w,
                child: _Badge(isActive: on),
              ),
              // Category badge
              if (h.category != null && h.category!.isNotEmpty)
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                        color: _slate,
                        borderRadius: BorderRadius.circular(6.r)),
                    child: Text(h.category!,
                        style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
            ],
          ),

          // ── Bottom: info on left, actions on right ──
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 10.h, 8.w, 10.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Info — takes all remaining space
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        h.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: _dark),
                      ),
                      SizedBox(height: 3.h),
                      Row(children: [
                        Icon(Icons.location_on_outlined,
                            size: 12.sp, color: Colors.grey[500]),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(h.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.dmSans(
                                  fontSize: 11.sp,
                                  color: Colors.grey[500])),
                        ),
                      ]),
                      SizedBox(height: 6.h),
                      // Chips + price — all in a Wrap so they never overflow
                      Wrap(
                        spacing: 5.w,
                        runSpacing: 4.h,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _Chip(
                              icon: Icons.bed_outlined,
                              label: '${h.numberOfRooms}R'),
                          _Chip(
                              icon: Icons.people_outline,
                              label: '${h.maxGuests}G'),
                          Text(
                            'Rs. ${h.pricePerNight.toStringAsFixed(0)}/N',
                            style: GoogleFonts.dmSans(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: _slate),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions — fixed 36px wide column, never expands
                SizedBox(
                  width: 36.w,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Btn(
                          icon: Icons.remove_red_eye_outlined,
                          color: _slate,
                          onTap: onView),
                      _Btn(
                          icon: on
                              ? Icons.pause_circle_outline_rounded
                              : Icons.play_circle_outline_rounded,
                          color: on
                              ? Colors.grey[600]!
                              : Colors.green[600]!,
                          onTap: onToggle),
                      _Btn(
                          icon: Icons.delete_outline_rounded,
                          color: Colors.red[400]!,
                          onTap: onDelete),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Web card ──────────────────────────────────────────────────────────────────

class _WebCard extends StatelessWidget {
  final Homestay homestay;
  final VoidCallback onView;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  static const _slate = Color(0xFF3D5A80);
  static const _dark = Color(0xFF1A1A2E);

  const _WebCard({
    required this.homestay,
    required this.onView,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final h = homestay;
    final img = h.imageUrls.isNotEmpty ? h.imageUrls.first : null;
    final on = h.isVisible;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
                  child: ProxyImage(
                    imageUrl: img,
                    width: double.infinity,
                    height: double.infinity,
                    borderRadiusValue: 0,
                    thumb: true,
                  ),
                ),
                if (!on)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(14)),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.45),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.pause_circle_rounded,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: 6),
                              Text('Paused',
                                  style: GoogleFonts.dmSans(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                    top: 8,
                    left: 8,
                    child: _Badge(isActive: on)),
              ],
            ),
          ),

          // Bottom row
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(h.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.playfairDisplay(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _dark)),
                      Text(h.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.dmSans(
                              fontSize: 11, color: Colors.grey[500])),
                      Text(
                          'Rs. ${h.pricePerNight.toStringAsFixed(0)}/night',
                          style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _slate)),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Btn(
                        icon: Icons.remove_red_eye_outlined,
                        color: _slate,
                        onTap: onView),
                    _Btn(
                        icon: on
                            ? Icons.pause_circle_outline_rounded
                            : Icons.play_circle_outline_rounded,
                        color:
                        on ? Colors.grey[600]! : Colors.green[600]!,
                        onTap: onToggle),
                    _Btn(
                        icon: Icons.delete_outline_rounded,
                        color: Colors.red[400]!,
                        onTap: onDelete),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared small widgets ──────────────────────────────────────────────────────

class _Btn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _Btn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: EdgeInsets.all(5.w),
        child: Icon(icon, size: 20.sp, color: color),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final bool isActive;
  const _Badge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isActive ? Colors.green[600] : Colors.grey[700],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(isActive ? 'Active' : 'Paused',
              style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 9.sp, color: Colors.grey[600]),
        SizedBox(width: 2.w),
        Text(label,
            style: GoogleFonts.dmSans(
                fontSize: 9.sp, color: Colors.grey[700])),
      ]),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatPill(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('$count',
            style: GoogleFonts.dmSans(
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
                color: color)),
        SizedBox(width: 5.w),
        Text(label,
            style: GoogleFonts.dmSans(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: color)),
      ]),
    );
  }
}

class _ConfirmDialog extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final String confirmLabel;
  final Color confirmColor;
  final VoidCallback onConfirm;

  const _ConfirmDialog({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.confirmColor,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      title: Row(children: [
        Icon(icon, color: iconColor, size: 26.sp),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(title,
              style: GoogleFonts.playfairDisplay(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                  color: const Color(0xFF1A1A2E))),
        ),
      ]),
      content: Text(body,
          style: GoogleFonts.dmSans(
              fontSize: 13.sp, color: Colors.grey[700], height: 1.5)),
      actionsPadding:
      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel',
              style: GoogleFonts.dmSans(
                  color: Colors.grey[600], fontWeight: FontWeight.w600)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r))),
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: Text(confirmLabel,
              style: GoogleFonts.dmSans(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 48.sp, color: Colors.redAccent),
            SizedBox(height: 16.h),
            Text('Something went wrong',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E))),
            SizedBox(height: 8.h),
            Text(message,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                    fontSize: 13.sp, color: Colors.grey[600])),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3D5A80),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r))),
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: Text('Retry',
                  style: GoogleFonts.dmSans(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String filter;
  const _EmptyView({required this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_work_outlined,
              size: 56.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
              filter == 'All'
                  ? 'No homestays found'
                  : 'No $filter homestays',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 18.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          Text(
              filter == 'Paused'
                  ? 'All homestays are currently active'
                  : 'No homestays match your search',
              style: GoogleFonts.dmSans(
                  fontSize: 13.sp, color: Colors.grey[400])),
        ],
      ),
    );
  }
}