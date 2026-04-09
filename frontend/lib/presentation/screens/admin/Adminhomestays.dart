import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/services/image_proxy.dart';
import '../../../data/models/Homestay.dart';
import '../../state_management/Bloc/homestays/HomestayBloc.dart';
import '../../state_management/Bloc/homestays/HomestayEvent.dart';
import '../../state_management/Bloc/homestays/HomestayState.dart';
import 'Adminhomestaydetailpage.dart';

class Homestays extends StatefulWidget {
  final ValueNotifier subtitleNotifier;
  const Homestays({super.key, required this.subtitleNotifier});

  @override
  State<Homestays> createState() => HomestaysState();
}

class HomestaysState extends State<Homestays> {
  static const slate = Color(0xFF3D5A80);
  static const bg    = Color(0xFFF4F6F9);

  String search = '';
  String filter = 'All';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => widget.subtitleNotifier.value = 'Manage Homestays');
    context.read<HomestayBloc>().add(const TouristLoadAllHomestays());
  }

  void reload() => context.read<HomestayBloc>().add(const TouristLoadAllHomestays());

  List<Homestay> filtered(List<Homestay> all) {
    var list = all;
    if (filter == 'Active') list = list.where((h) => h.isVisible).toList();
    if (filter == 'Paused') list = list.where((h) => !h.isVisible).toList();
    if (search.isNotEmpty) {
      final q = search.toLowerCase();
      list = list.where((h) =>
      h.name.toLowerCase().contains(q) ||
          h.location.toLowerCase().contains(q) ||
          (h.nearCulturalSite?.name.toLowerCase().contains(q) ?? false)
      ).toList();
    }
    return list;
  }

  Color chipColor(String label) => switch (label) {
    'Active' => Colors.green[600]!,
    'Paused' => Colors.grey[700]!,
    _        => slate,
  };

  void pushDetail(Homestay h) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => AdminHomestayDetailPage(homestay: h)),
  ).then((_) => reload());

  void confirmToggle(Homestay h) {
    final on = h.isVisible;
    showConfirmDialog(
      icon: on ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
      iconColor: on ? Colors.grey[700]! : Colors.green[600]!,
      title: on ? 'Pause Homestay?' : 'Activate Homestay?',
      body: on
          ? '"${h.name}" will be hidden from tourists.'
          : '"${h.name}" will become visible to tourists.',
      confirmLabel: on ? 'Pause' : 'Activate',
      confirmColor: on ? Colors.grey[700]! : Colors.green[600]!,
      onConfirm: () =>
          context.read<HomestayBloc>().add(AdminToggleHomestayVisibility(h.id, !on)),
    );
  }

  void confirmDelete(Homestay h) {
    showConfirmDialog(
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

  void showConfirmDialog({
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
      builder: (_) => ConfirmDialog(
        icon: icon, iconColor: iconColor, title: title,
        body: body, confirmLabel: confirmLabel,
        confirmColor: confirmColor, onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb || MediaQuery.of(context).size.width > 700;

    return Container(
      color: bg,
      child: Column(children: [
        buildToolbar(isWeb),
        Expanded(
          child: BlocBuilder<HomestayBloc, HomestayState>(
            builder: (context, state) {
              if (state is HomestayLoading) {
                return const Center(child: CircularProgressIndicator(color: slate));
              }
              if (state is HomestayError) {
                return ErrorView(message: state.message, onRetry: reload);
              }
              if (state is TouristAllHomestaysLoaded) {
                final list    = filtered(state.homestays);
                final activeN = state.homestays.where((h) => h.isVisible).length;
                final pausedN = state.homestays.where((h) => !h.isVisible).length;

                return Column(children: [
                  isWeb
                      ? webStatsBar(state.homestays.length, activeN, pausedN)
                      : mobileStatsBar(state.homestays.length, activeN, pausedN),
                  const Divider(height: 1),
                  Expanded(
                    child: list.isEmpty
                        ? EmptyView(filter: filter)
                        : isWeb
                        ? WebGrid(
                      list: list,
                      onView: pushDetail,
                      onToggle: confirmToggle,
                      onDelete: confirmDelete,
                    )
                        : MobileList(
                      list: list,
                      onView: pushDetail,
                      onToggle: confirmToggle,
                      onDelete: confirmDelete,
                    ),
                  ),
                ]);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ]),
    );
  }

  Widget buildToolbar(bool isWeb) {
    if (isWeb) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Homestays',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A2E))),
              const SizedBox(height: 2),
              Text('Manage all homestay listings',
                  style: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey[500])),
            ]),
            const Spacer(),
            ...['All', 'Active', 'Paused'].map((label) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: GestureDetector(
                onTap: () => setState(() => filter = label),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: filter == label ? chipColor(label) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: filter == label
                            ? chipColor(label)
                            : Colors.grey.shade300),
                  ),
                  child: Text(label,
                      style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: filter == label ? Colors.white : Colors.grey[600])),
                ),
              ),
            )),
          ]),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: TextField(
              onChanged: (v) => setState(() => search = v),
              style: GoogleFonts.dmSans(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search by name, location...',
                hintStyle: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 18),
                suffixIcon: IconButton(
                  icon: Icon(Icons.refresh_rounded, size: 18, color: Colors.grey[500]),
                  onPressed: reload,
                ),
                filled: true,
                fillColor: bg,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ]),
      );
    }

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 10.h),
      child: Column(children: [
        Container(
          decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200)),
          child: TextField(
            onChanged: (v) => setState(() => search = v),
            style: GoogleFonts.dmSans(fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: 'Search by name, location...',
              hintStyle: GoogleFonts.dmSans(fontSize: 14.sp, color: Colors.grey[400]),
              prefixIcon:
              Icon(Icons.search, color: Colors.grey[400], size: 20.sp),
              suffixIcon: IconButton(
                  icon: Icon(Icons.refresh_rounded,
                      size: 20.sp, color: Colors.grey[500]),
                  onPressed: reload),
              border: InputBorder.none,
              contentPadding:
              EdgeInsets.symmetric(horizontal: 4.w, vertical: 13.h),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          children: ['All', 'Active', 'Paused'].map((label) => Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: GestureDetector(
              onTap: () => setState(() => filter = label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: filter == label
                      ? chipColor(label)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                      color: filter == label
                          ? chipColor(label)
                          : Colors.grey.shade300),
                ),
                child: Text(label,
                    style: GoogleFonts.dmSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color:
                        filter == label ? Colors.white : Colors.grey[600])),
              ),
            ),
          )).toList(),
        ),
      ]),
    );
  }

  Widget webStatsBar(int total, int activeN, int pausedN) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 12),
      child: Row(children: [
        WebStatPill(label: 'Total',  count: total,   color: slate),
        const SizedBox(width: 8),
        WebStatPill(label: 'Active', count: activeN, color: Colors.green[600]!),
        const SizedBox(width: 8),
        WebStatPill(label: 'Paused', count: pausedN, color: Colors.grey[600]!),
      ]),
    );
  }

  Widget mobileStatsBar(int total, int activeN, int pausedN) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 10.h),
      child: Row(children: [
        StatPill(label: 'Total',  count: total,   color: slate),
        SizedBox(width: 8.w),
        StatPill(label: 'Active', count: activeN, color: Colors.green[600]!),
        SizedBox(width: 8.w),
        StatPill(label: 'Paused', count: pausedN, color: Colors.grey[600]!),
      ]),
    );
  }
}

class WebGrid extends StatelessWidget {
  final List<Homestay> list;
  final void Function(Homestay) onView;
  final void Function(Homestay) onToggle;
  final void Function(Homestay) onDelete;

  const WebGrid({
    super.key,
    required this.list,
    required this.onView,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 320,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        childAspectRatio: 0.95,
      ),
      itemCount: list.length,
      itemBuilder: (_, i) => WebCard(
        homestay: list[i],
        onView:   () => onView(list[i]),
        onToggle: () => onToggle(list[i]),
        onDelete: () => onDelete(list[i]),
      ),
    );
  }
}

class MobileList extends StatelessWidget {
  final List<Homestay> list;
  final void Function(Homestay) onView;
  final void Function(Homestay) onToggle;
  final void Function(Homestay) onDelete;

  const MobileList({
    super.key,
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
      itemBuilder: (_, i) => MobileCard(
        homestay: list[i],
        onView:   () => onView(list[i]),
        onToggle: () => onToggle(list[i]),
        onDelete: () => onDelete(list[i]),
      ),
    );
  }
}

class WebCard extends StatelessWidget {
  final Homestay homestay;
  final VoidCallback onView;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  static const slate = Color(0xFF3D5A80);
  static const dark  = Color(0xFF1A1A2E);

  const WebCard({
    super.key,
    required this.homestay,
    required this.onView,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final h   = homestay;
    final img = h.imageUrls.isNotEmpty ? h.imageUrls.first : null;
    final on  = h.isVisible;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 180,
            child: Stack(children: [
              ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(14)),
                child: ProxyImage(
                  imageUrl: img,
                  width: double.infinity,
                  height: 180,
                  borderRadiusValue: 0,
                  thumb: false,
                  fit: BoxFit.cover,
                ),
              ),
              if (!on)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.45),
                      child: Center(
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.pause_circle_rounded,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 6),
                          Text('Paused',
                              style: GoogleFonts.dmSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13)),
                        ]),
                      ),
                    ),
                  ),
                ),
              Positioned(top: 10, left: 10, child: CardBadge(isActive: on)),
              if (h.category != null && h.category!.isNotEmpty)
                Positioned(
                  top: 10, right: 10,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: slate,
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(h.category!,
                        style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
            ]),
          ),

          // Info + actions
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(h.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.playfairDisplay(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: dark)),
                      const SizedBox(height: 4),
                      Row(children: [
                        Icon(Icons.location_on_outlined,
                            size: 12, color: Colors.grey[400]),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(h.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.dmSans(
                                  fontSize: 12, color: Colors.grey[500])),
                        ),
                      ]),
                      const SizedBox(height: 6),
                      Row(children: [
                        Icon(Icons.bed_outlined,
                            size: 12, color: Colors.grey[500]),
                        const SizedBox(width: 3),
                        Text('${h.numberOfRooms} rooms · ${h.maxGuests} guests',
                            style: GoogleFonts.dmSans(
                                fontSize: 11, color: Colors.grey[500])),
                      ]),
                      const SizedBox(height: 6),
                      Text('Rs. ${h.pricePerNight.toStringAsFixed(0)} / night',
                          style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: slate)),
                    ],
                  ),
                ),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  WebBtn(
                      icon: Icons.remove_red_eye_outlined,
                      color: slate,
                      onTap: onView),
                  WebBtn(
                      icon: on
                          ? Icons.pause_circle_outline_rounded
                          : Icons.play_circle_outline_rounded,
                      color: on ? Colors.grey[600]! : Colors.green[600]!,
                      onTap: onToggle),
                  WebBtn(
                      icon: Icons.delete_outline_rounded,
                      color: Colors.red[400]!,
                      onTap: onDelete),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MobileCard extends StatelessWidget {
  final Homestay homestay;
  final VoidCallback onView;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  static const slate = Color(0xFF3D5A80);
  static const dark  = Color(0xFF1A1A2E);

  const MobileCard({
    super.key,
    required this.homestay,
    required this.onView,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final h   = homestay;
    final img = h.imageUrls.isNotEmpty ? h.imageUrls.first : null;
    final on  = h.isVisible;

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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Stack(children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
            child: ProxyImage(
                imageUrl: img,
                width: double.infinity,
                height: 130.h,
                borderRadiusValue: 0,
                thumb: true),
          ),
          if (!on)
            Positioned.fill(
              child: ClipRRect(
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(14.r)),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: Center(
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.pause_circle_rounded,
                          color: Colors.white, size: 18.sp),
                      SizedBox(width: 4.w),
                      Text('Paused',
                          style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12.sp)),
                    ]),
                  ),
                ),
              ),
            ),
          Positioned(
              top: 8.h, left: 8.w, child: CardBadge(isActive: on)),
          if (h.category != null && h.category!.isNotEmpty)
            Positioned(
              top: 8.h, right: 8.w,
              child: Container(
                padding:
                EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                    color: slate,
                    borderRadius: BorderRadius.circular(6.r)),
                child: Text(h.category!,
                    style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600)),
              ),
            ),
        ]),
        Padding(
          padding: EdgeInsets.fromLTRB(12.w, 10.h, 8.w, 10.h),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(h.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: dark)),
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
                                fontSize: 11.sp, color: Colors.grey[500])),
                      ),
                    ]),
                    SizedBox(height: 6.h),
                    Wrap(
                      spacing: 5.w,
                      runSpacing: 4.h,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        HomestayChip(
                            icon: Icons.bed_outlined,
                            label: '${h.numberOfRooms}R'),
                        HomestayChip(
                            icon: Icons.people_outline,
                            label: '${h.maxGuests}G'),
                        Text('Rs. ${h.pricePerNight.toStringAsFixed(0)}/N',
                            style: GoogleFonts.dmSans(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: slate)),
                      ],
                    ),
                  ]),
            ),
            SizedBox(
              width: 36.w,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                MobileBtn(
                    icon: Icons.remove_red_eye_outlined,
                    color: slate,
                    onTap: onView),
                MobileBtn(
                    icon: on
                        ? Icons.pause_circle_outline_rounded
                        : Icons.play_circle_outline_rounded,
                    color: on ? Colors.grey[600]! : Colors.green[600]!,
                    onTap: onToggle),
                MobileBtn(
                    icon: Icons.delete_outline_rounded,
                    color: Colors.red[400]!,
                    onTap: onDelete),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }
}

class WebBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const WebBtn({super.key, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(6),
    child: Padding(
        padding: const EdgeInsets.all(5),
        child: Icon(icon, size: 20, color: color)),
  );
}

class MobileBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const MobileBtn({super.key, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(6),
    child: Padding(
        padding: EdgeInsets.all(5.w),
        child: Icon(icon, size: 20.sp, color: color)),
  );
}

class CardBadge extends StatelessWidget {
  final bool isActive;
  const CardBadge({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: isActive ? Colors.green[600] : Colors.grey[700],
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
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
    ]),
  );
}

class HomestayChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const HomestayChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
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
          style: GoogleFonts.dmSans(fontSize: 9.sp, color: Colors.grey[700])),
    ]),
  );
}

class WebStatPill extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const WebStatPill(
      {super.key, required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.25)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text('$count',
          style: GoogleFonts.dmSans(
              fontSize: 14, fontWeight: FontWeight.w800, color: color)),
      const SizedBox(width: 5),
      Text(label,
          style: GoogleFonts.dmSans(
              fontSize: 12, fontWeight: FontWeight.w500, color: color)),
    ]),
  );
}

class StatPill extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const StatPill(
      {super.key, required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text('$count',
          style: GoogleFonts.dmSans(
              fontSize: 13.sp, fontWeight: FontWeight.w800, color: color)),
      SizedBox(width: 5.w),
      Text(label,
          style: GoogleFonts.dmSans(
              fontSize: 11.sp, fontWeight: FontWeight.w500, color: color)),
    ]),
  );
}

class ConfirmDialog extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, body, confirmLabel;
  final Color confirmColor;
  final VoidCallback onConfirm;

  const ConfirmDialog({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.confirmColor,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    title: Row(children: [
      Icon(icon, color: iconColor, size: 24),
      const SizedBox(width: 10),
      Expanded(
          child: Text(title,
              style: GoogleFonts.playfairDisplay(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: const Color(0xFF1A1A2E)))),
    ]),
    content: Text(body,
        style: GoogleFonts.dmSans(
            fontSize: 13, color: Colors.grey[700], height: 1.5)),
    actionsPadding:
    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                borderRadius: BorderRadius.circular(8))),
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

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.all(32.w),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.error_outline_rounded, size: 48.sp, color: Colors.redAccent),
        SizedBox(height: 16.h),
        Text('Something went wrong',
            style: GoogleFonts.playfairDisplay(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A2E))),
        SizedBox(height: 8.h),
        Text(message,
            textAlign: TextAlign.center,
            style:
            GoogleFonts.dmSans(fontSize: 13.sp, color: Colors.grey[600])),
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
      ]),
    ),
  );
}

class EmptyView extends StatelessWidget {
  final String filter;
  const EmptyView({super.key, required this.filter});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.home_work_outlined, size: 56, color: Colors.grey[300]),
      const SizedBox(height: 16),
      Text(
          filter == 'All'
              ? 'No homestays found'
              : 'No $filter homestays',
          style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text(
          filter == 'Paused'
              ? 'All homestays are currently active'
              : 'No homestays match your search',
          style: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey[400])),
    ]),
  );
}