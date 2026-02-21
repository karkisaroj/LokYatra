import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/image_proxy.dart';
import 'package:lokyatra_frontend/data/models/Homestay.dart';
import '../../state_management/Bloc/homestays/HomestayBloc.dart';
import '../../state_management/Bloc/homestays/HomestayEvent.dart';

class AdminHomestayDetailPage extends StatefulWidget {
  final Homestay homestay;

  const AdminHomestayDetailPage({super.key, required this.homestay});

  @override
  State<AdminHomestayDetailPage> createState() =>
      _AdminHomestayDetailPageState();
}

class _AdminHomestayDetailPageState extends State<AdminHomestayDetailPage> {
  static const _slate = Color(0xFF3D5A80);
  static const _dark = Color(0xFF1A1A2E);
  static const _bg = Color(0xFFF4F6F9);

  late bool _isVisible;
  int _imageIndex = 0;
  final _pageCtrl = PageController();

  @override
  void initState() {
    super.initState();
    _isVisible = widget.homestay.isVisible;
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  // ── Actions ──────────────────────────────────────────────────────────────────

  void _onToggle() {
    final next = !_isVisible;
    _showConfirm(
      icon: next
          ? Icons.play_circle_outline_rounded
          : Icons.pause_circle_outline_rounded,
      iconColor: next ? Colors.green[600]! : Colors.grey[700]!,
      title: next ? 'Activate Homestay?' : 'Pause Homestay?',
      body: next
          ? '"${widget.homestay.name}" will become visible to all tourists.'
          : '"${widget.homestay.name}" will be hidden from all tourists.',
      confirmLabel: next ? 'Activate' : 'Pause',
      confirmColor: next ? Colors.green[600]! : Colors.grey[700]!,
      onConfirm: () {
        setState(() => _isVisible = next);
        context
            .read<HomestayBloc>()
            .add(AdminToggleHomestayVisibility(widget.homestay.id, next));
      },
    );
  }

  void _onDelete() {
    _showConfirm(
      icon: Icons.delete_outline_rounded,
      iconColor: Colors.red[600]!,
      title: 'Delete Homestay?',
      body: 'Permanently delete "${widget.homestay.name}"? This cannot be undone.',
      confirmLabel: 'Delete',
      confirmColor: Colors.red[600]!,
      onConfirm: () {
        context
            .read<HomestayBloc>()
            .add(AdminDeleteHomestay(widget.homestay.id));
        Navigator.pop(context);
      },
    );
  }

  void _showConfirm({
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
      builder: (_) => _Dialog(
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

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    return isWide ? _wide() : _narrow();
  }

  // ── Mobile / narrow layout ────────────────────────────────────────────────────

  Widget _narrow() {
    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260.h,
            pinned: true,
            backgroundColor: _dark,
            leading: _BackBtn(),
            actions: _actions(),
            flexibleSpace: FlexibleSpaceBar(
              background: _hero(height: 260.h),
            ),
          ),
          SliverToBoxAdapter(child: _body()),
        ],
      ),
    );
  }

  // ── Web / wide layout ─────────────────────────────────────────────────────────

  Widget _wide() {
    final h = widget.homestay;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _BackBtn(dark: true),
        title: Text(h.name,
            style: GoogleFonts.playfairDisplay(
                fontSize: 18, fontWeight: FontWeight.bold, color: _dark)),
        actions: _actions(),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left panel — images
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.38,
            child: _hero(isWide: true),
          ),
          // Right panel — scrollable detail
          Expanded(
            child: SingleChildScrollView(child: _body(isWide: true)),
          ),
        ],
      ),
    );
  }

  // ── Hero image(s) ─────────────────────────────────────────────────────────────

  Widget _hero({double? height, bool isWide = false}) {
    final h = widget.homestay;
    if (h.imageUrls.isEmpty) {
      return Container(
        height: height,
        color: Colors.grey[300],
        child: Icon(Icons.home_outlined, size: 48, color: Colors.grey[400]),
      );
    }

    Widget pageView = PageView.builder(
      controller: _pageCtrl,
      itemCount: h.imageUrls.length,
      onPageChanged: (i) => setState(() => _imageIndex = i),
      itemBuilder: (_, i) => ProxyImage(
        imageUrl: h.imageUrls[i],
        width: double.infinity,
        height: isWide ? double.infinity : 350,
        borderRadiusValue: 0,
      ),
    );

    return SizedBox(
      height: isWide ? double.infinity : height,
      child: Stack(
        children: [
          pageView,

          // Paused overlay
          if (!_isVisible)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.45),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.pause_circle_rounded,
                            color: Colors.white, size: 16.sp),
                        SizedBox(width: 6.w),
                        Text('Hidden from tourists',
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

          // Image counter
          if (h.imageUrls.length > 1)
            Positioned(
              bottom: 10.h,
              right: 12.w,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20.r)),
                child: Text(
                    '${_imageIndex + 1} / ${h.imageUrls.length}',
                    style: GoogleFonts.dmSans(
                        color: Colors.white, fontSize: 11.sp)),
              ),
            ),
        ],
      ),
    );
  }

  // ── App bar actions ───────────────────────────────────────────────────────────

  List<Widget> _actions() => [
    GestureDetector(
      onTap: _onToggle,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        padding:
        EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: _isVisible ? Colors.green[600] : Colors.grey[600],
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
                _isVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.white,
                size: 13.sp),
            SizedBox(width: 4.w),
            Text(_isVisible ? 'Active' : 'Paused',
                style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    ),
    SizedBox(width: 6.w),
    GestureDetector(
      onTap: _onDelete,
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 8.h, 10.w, 8.h),
        padding: EdgeInsets.all(7.w),
        decoration: const BoxDecoration(
            color: Colors.white, shape: BoxShape.circle),
        child:
        Icon(Icons.delete_outline_rounded, size: 19.sp, color: Colors.red[500]),
      ),
    ),
  ];

  // ── Scrollable detail body ────────────────────────────────────────────────────

  Widget _body({bool isWide = false}) {
    final h = widget.homestay;
    final pad = isWide ? const EdgeInsets.all(28.0) : EdgeInsets.all(18.w);

    return Padding(
      padding: pad,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + category
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(h.name,
                    style: GoogleFonts.playfairDisplay(
                        fontSize: isWide ? 24 : 22.sp,
                        fontWeight: FontWeight.bold,
                        color: _dark)),
              ),
              if (h.category != null && h.category!.isNotEmpty) ...[
                SizedBox(width: 8.w),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _slate.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border:
                    Border.all(color: _slate.withValues(alpha: 0.3)),
                  ),
                  child: Text(h.category!,
                      style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: _slate,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ],
          ),

          const SizedBox(height: 6),

          Row(children: [
            Icon(Icons.location_on_outlined,
                size: 14, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Expanded(
              child: Text(h.location,
                  style: GoogleFonts.dmSans(
                      fontSize: 13, color: Colors.grey[600])),
            ),
          ]),

          if (h.nearCulturalSite != null) ...[
            const SizedBox(height: 3),
            Row(children: [
              Icon(Icons.temple_hindu_outlined,
                  size: 13, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text('Near ${h.nearCulturalSite!.name}',
                  style: GoogleFonts.dmSans(
                      fontSize: 12, color: Colors.grey[500])),
            ]),
          ],

          const SizedBox(height: 18),

          // Stat cards
          Row(children: [
            Expanded(
                child: _StatCard(
                    label: 'Price/Night',
                    value: 'Rs. ${h.pricePerNight.toStringAsFixed(0)}',
                    icon: Icons.payments_outlined)),
            const SizedBox(width: 8),
            Expanded(
                child: _StatCard(
                    label: 'Rooms',
                    value: '${h.numberOfRooms}',
                    icon: Icons.bed_outlined)),
            const SizedBox(width: 8),
            Expanded(
                child: _StatCard(
                    label: 'Guests',
                    value: '${h.maxGuests}',
                    icon: Icons.people_outline)),
            const SizedBox(width: 8),
            Expanded(
                child: _StatCard(
                    label: 'Baths',
                    value: '${h.bathrooms}',
                    icon: Icons.bathtub_outlined)),
          ]),

          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 14),

          if (h.description.isNotEmpty)
            _Section(
              title: 'About',
              child: Text(h.description,
                  style: GoogleFonts.dmSans(
                      fontSize: 13, height: 1.6, color: Colors.grey[700])),
            ),

          if (_notEmpty(h.culturalSignificance)) ...[
            const SizedBox(height: 16),
            _Section(
              title: 'Cultural Significance',
              child: Text(h.culturalSignificance!,
                  style: GoogleFonts.dmSans(
                      fontSize: 13, height: 1.6, color: Colors.grey[700])),
            ),
          ],

          if (_notEmpty(h.buildingHistory)) ...[
            const SizedBox(height: 16),
            _Section(
              title: 'Building History',
              child: Text(h.buildingHistory!,
                  style: GoogleFonts.dmSans(
                      fontSize: 13, height: 1.6, color: Colors.grey[700])),
            ),
          ],

          if (_notEmpty(h.traditionalFeatures)) ...[
            const SizedBox(height: 16),
            _Section(
              title: 'Traditional Features',
              child: Text(h.traditionalFeatures!,
                  style: GoogleFonts.dmSans(
                      fontSize: 13, height: 1.6, color: Colors.grey[700])),
            ),
          ],

          if (h.amenities.isNotEmpty) ...[
            const SizedBox(height: 16),
            _Section(
              title: 'Amenities',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: h.amenities
                    .map((a) => Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _slate.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: _slate.withValues(alpha: 0.2)),
                  ),
                  child: Text(a,
                      style: GoogleFonts.dmSans(
                          fontSize: 12, color: _dark)),
                ))
                    .toList(),
              ),
            ),
          ],

          if (h.culturalExperiences.isNotEmpty) ...[
            const SizedBox(height: 16),
            _Section(
              title: 'Cultural Experiences',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: h.culturalExperiences
                    .map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                                color: _slate,
                                shape: BoxShape.circle)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(e,
                            style: GoogleFonts.dmSans(
                                fontSize: 13,
                                height: 1.5,
                                color: Colors.grey[700])),
                      ),
                    ],
                  ),
                ))
                    .toList(),
              ),
            ),
          ],

          // Photo gallery — only on mobile; web sees images in left panel
          if (!isWide && h.imageUrls.length > 1) ...[
            const SizedBox(height: 16),
            _Section(
              title: 'All Photos (${h.imageUrls.length})',
              child: SizedBox(
                height: 80.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: h.imageUrls.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () => _pageCtrl.animateToPage(i,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: ProxyImage(
                        imageUrl: h.imageUrls[i],
                        width: 110.w,
                        height: 80.h,
                        borderRadiusValue: 0,
                        thumb: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 10),

          if (h.createdAt != null)
            Text('Listed on ${_fmt(h.createdAt!)}',
                style: GoogleFonts.dmSans(
                    fontSize: 11, color: Colors.grey[400])),
          if (h.updatedAt != null)
            Text('Last updated ${_fmt(h.updatedAt!)}',
                style: GoogleFonts.dmSans(
                    fontSize: 11, color: Colors.grey[400])),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  bool _notEmpty(String? s) => s != null && s.isNotEmpty;

  String _fmt(DateTime d) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

// ── Back button ───────────────────────────────────────────────────────────────

class _BackBtn extends StatelessWidget {
  final bool dark;
  const _BackBtn({this.dark = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        margin: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
            color: dark ? Colors.transparent : Colors.white,
            shape: BoxShape.circle),
        child: Icon(Icons.arrow_back_ios_new_rounded,
            size: 18.sp,
            color: dark ? const Color(0xFF1A1A2E) : const Color(0xFF1A1A2E)),
      ),
    );
  }
}

// ── Stat card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  static const _slate = Color(0xFF3D5A80);

  const _StatCard(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(children: [
        Icon(icon, size: 18, color: _slate),
        const SizedBox(height: 5),
        Text(value,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E))),
        const SizedBox(height: 2),
        Text(label,
            textAlign: TextAlign.center,
            style:
            GoogleFonts.dmSans(fontSize: 9, color: Colors.grey[500])),
      ]),
    );
  }
}

// ── Section ───────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A2E))),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

// ── Confirm dialog ────────────────────────────────────────────────────────────

class _Dialog extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final String confirmLabel;
  final Color confirmColor;
  final VoidCallback onConfirm;

  const _Dialog({
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
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Text(title,
              style: GoogleFonts.playfairDisplay(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: const Color(0xFF1A1A2E))),
        ),
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
}