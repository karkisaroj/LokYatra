import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/services/image_proxy.dart';
import 'package:lokyatra_frontend/data/models/Homestay.dart';
import '../../state_management/Bloc/homestays/HomestayBloc.dart';
import '../../state_management/Bloc/homestays/HomestayEvent.dart';

class AdminHomestayDetailPage extends StatefulWidget {
  final Homestay homestay;
  const AdminHomestayDetailPage({super.key, required this.homestay});

  @override
  State<AdminHomestayDetailPage> createState() => _AdminHomestayDetailPageState();
}

class _AdminHomestayDetailPageState extends State<AdminHomestayDetailPage> {
  static const _slate = Color(0xFF3D5A80);
  static const _dark  = Color(0xFF1A1A2E);
  static const _bg    = Color(0xFFF4F6F9);

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

  void _onToggle() {
    final next = !_isVisible;
    _showConfirm(
      icon: next ? Icons.play_circle_outline_rounded : Icons.pause_circle_outline_rounded,
      iconColor: next ? Colors.green[600]! : Colors.grey[700]!,
      title: next ? 'Activate Homestay?' : 'Pause Homestay?',
      body: next
          ? '"${widget.homestay.name}" will become visible to all tourists.'
          : '"${widget.homestay.name}" will be hidden from all tourists.',
      confirmLabel: next ? 'Activate' : 'Pause',
      confirmColor: next ? Colors.green[600]! : Colors.grey[700]!,
      onConfirm: () {
        setState(() => _isVisible = next);
        context.read<HomestayBloc>().add(AdminToggleHomestayVisibility(widget.homestay.id, next));
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
        context.read<HomestayBloc>().add(AdminDeleteHomestay(widget.homestay.id));
        Navigator.pop(context);
      },
    );
  }

  void _showConfirm({
    required IconData icon, required Color iconColor,
    required String title, required String body,
    required String confirmLabel, required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    showDialog(context: context, builder: (_) => _Dialog(
      icon: icon, iconColor: iconColor, title: title,
      body: body, confirmLabel: confirmLabel,
      confirmColor: confirmColor, onConfirm: onConfirm,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    return isWide ? _wide() : _narrow();
  }

  Widget _narrow() {
    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 260.h,
          pinned: true,
          backgroundColor: _dark,
          leading: _BackBtn(),
          actions: _mobileActions(),
          flexibleSpace: FlexibleSpaceBar(background: _mobileHero()),
        ),
        SliverToBoxAdapter(child: _mobileBody()),
      ]),
    );
  }

  Widget _wide() {
    final h = widget.homestay;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _BackBtn(dark: true),
        title: Text(h.name,
            style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold, color: _dark)),
        actions: _webActions(),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final imageWidth = constraints.maxWidth * 0.48;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: imageWidth,
                child: _wideHero(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: _webBody(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _mobileHero() {
    final h = widget.homestay;
    if (h.imageUrls.isEmpty) {
      return Container(color: Colors.grey[300],
          child: Icon(Icons.home_outlined, size: 48, color: Colors.grey[400]));
    }
    return Stack(fit: StackFit.expand, children: [
      PageView.builder(
        controller: _pageCtrl,
        itemCount: h.imageUrls.length,
        onPageChanged: (i) => setState(() => _imageIndex = i),
        itemBuilder: (_, i) => CachedNetworkImage(
          imageUrl: getProxyImageUrl(h.imageUrls[i]),
          cacheKey: 'full_${h.imageUrls[i]}',
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          placeholder: (_, _) => Container(color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
          errorWidget: (_, _, _) => Container(color: Colors.grey[200],
              child: const Icon(Icons.broken_image, color: Colors.grey)),
        ),
      ),
      if (!_isVisible) _pausedOverlay(),
      if (h.imageUrls.length > 1) _counter(h.imageUrls.length),
    ]);
  }

  Widget _wideHero() {
    final h = widget.homestay;
    if (h.imageUrls.isEmpty) {
      return Container(color: Colors.grey[300],
          child: Icon(Icons.home_outlined, size: 48, color: Colors.grey[400]));
    }
    return Stack(fit: StackFit.expand, children: [
      PageView.builder(
        controller: _pageCtrl,
        itemCount: h.imageUrls.length,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (i) => setState(() => _imageIndex = i),
        itemBuilder: (_, i) => CachedNetworkImage(
          imageUrl: getProxyImageUrl(h.imageUrls[i]),
          cacheKey: 'full_${h.imageUrls[i]}',
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          placeholder: (_, _) => Container(color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
          errorWidget: (_, _, _) => Container(color: Colors.grey[200],
              child: const Icon(Icons.broken_image, color: Colors.grey)),
        ),
      ),
      if (!_isVisible) _pausedOverlay(),
      if (h.imageUrls.length > 1) ...[
        _counter(h.imageUrls.length),
        Positioned(left: 8, top: 0, bottom: 0, child: Center(child: _Arrow(
          icon: Icons.chevron_left_rounded,
          onTap: _imageIndex > 0 ? () => _pageCtrl.previousPage(
              duration: const Duration(milliseconds: 300), curve: Curves.easeInOut) : null,
        ))),
        Positioned(right: 8, top: 0, bottom: 0, child: Center(child: _Arrow(
          icon: Icons.chevron_right_rounded,
          onTap: _imageIndex < h.imageUrls.length - 1 ? () => _pageCtrl.nextPage(
              duration: const Duration(milliseconds: 300), curve: Curves.easeInOut) : null,
        ))),
      ],
    ]);
  }

  Widget _pausedOverlay() => Positioned.fill(
    child: Container(
      color: Colors.black.withValues(alpha: 0.45),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.pause_circle_rounded, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text('Hidden from tourists',
                style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
          ]),
        ),
      ),
    ),
  );

  Widget _counter(int total) => Positioned(
    bottom: 10, right: 12,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
      child: Text('${_imageIndex + 1} / $total',
          style: GoogleFonts.dmSans(color: Colors.white, fontSize: 11)),
    ),
  );

  List<Widget> _webActions() => [
    GestureDetector(
      onTap: _onToggle,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: _isVisible ? Colors.green[600] : Colors.grey[600],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(_isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(_isVisible ? 'Active' : 'Paused',
              style: GoogleFonts.dmSans(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
        ]),
      ),
    ),
    const SizedBox(width: 6),
    GestureDetector(
      onTap: _onDelete,
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 8, 12, 8),
        padding: const EdgeInsets.all(7),
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(Icons.delete_outline_rounded, size: 19, color: Colors.red[500]),
      ),
    ),
  ];

  List<Widget> _mobileActions() => [
    GestureDetector(
      onTap: _onToggle,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: _isVisible ? Colors.green[600] : Colors.grey[600],
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(_isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: Colors.white, size: 13.sp),
          SizedBox(width: 4.w),
          Text(_isVisible ? 'Active' : 'Paused',
              style: GoogleFonts.dmSans(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w700)),
        ]),
      ),
    ),
    SizedBox(width: 6.w),
    GestureDetector(
      onTap: _onDelete,
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 8.h, 10.w, 8.h),
        padding: EdgeInsets.all(7.w),
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(Icons.delete_outline_rounded, size: 19.sp, color: Colors.red[500]),
      ),
    ),
  ];

  Widget _webBody() {
    final h = widget.homestay;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Text(h.name,
              style: GoogleFonts.playfairDisplay(fontSize: 26, fontWeight: FontWeight.bold, color: _dark))),
          if (h.category != null && h.category!.isNotEmpty) ...[
            const SizedBox(width: 12),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _slate.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _slate.withValues(alpha: 0.3)),
              ),
              child: Text(h.category!,
                  style: GoogleFonts.dmSans(fontSize: 12, color: _slate, fontWeight: FontWeight.w600)),
            ),
          ],
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 4),
          Expanded(child: Text(h.location, style: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey[600]))),
        ]),
        if (h.nearCulturalSite != null) ...[
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.temple_hindu_outlined, size: 13, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text('Near ${h.nearCulturalSite!.name}',
                style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey[500])),
          ]),
        ],
        const SizedBox(height: 24),
        Row(children: [
          Expanded(child: _StatCard(label: 'Price/Night', value: 'Rs. ${h.pricePerNight.toStringAsFixed(0)}', icon: Icons.payments_outlined)),
          const SizedBox(width: 10),
          Expanded(child: _StatCard(label: 'Rooms', value: '${h.numberOfRooms}', icon: Icons.bed_outlined)),
          const SizedBox(width: 10),
          Expanded(child: _StatCard(label: 'Guests', value: '${h.maxGuests}', icon: Icons.people_outline)),
          const SizedBox(width: 10),
          Expanded(child: _StatCard(label: 'Baths', value: '${h.bathrooms}', icon: Icons.bathtub_outlined)),
        ]),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        if (h.description.isNotEmpty)
          _Section(title: 'About',
              child: Text(h.description, style: GoogleFonts.dmSans(fontSize: 14, height: 1.65, color: Colors.grey[700]))),
        if (_notEmpty(h.culturalSignificance)) ...[
          const SizedBox(height: 18),
          _Section(title: 'Cultural Significance',
              child: Text(h.culturalSignificance!, style: GoogleFonts.dmSans(fontSize: 14, height: 1.65, color: Colors.grey[700]))),
        ],
        if (_notEmpty(h.buildingHistory)) ...[
          const SizedBox(height: 18),
          _Section(title: 'Building History',
              child: Text(h.buildingHistory!, style: GoogleFonts.dmSans(fontSize: 14, height: 1.65, color: Colors.grey[700]))),
        ],
        if (_notEmpty(h.traditionalFeatures)) ...[
          const SizedBox(height: 18),
          _Section(title: 'Traditional Features',
              child: Text(h.traditionalFeatures!, style: GoogleFonts.dmSans(fontSize: 14, height: 1.65, color: Colors.grey[700]))),
        ],
        if (h.amenities.isNotEmpty) ...[
          const SizedBox(height: 18),
          _Section(title: 'Amenities', child: Wrap(
            spacing: 8, runSpacing: 8,
            children: h.amenities.map((a) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _slate.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _slate.withValues(alpha: 0.2)),
              ),
              child: Text(a, style: GoogleFonts.dmSans(fontSize: 13, color: _dark)),
            )).toList(),
          )),
        ],
        if (h.culturalExperiences.isNotEmpty) ...[
          const SizedBox(height: 18),
          _Section(title: 'Cultural Experiences', child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: h.culturalExperiences.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Container(width: 5, height: 5,
                      decoration: const BoxDecoration(color: _slate, shape: BoxShape.circle)),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(e, style: GoogleFonts.dmSans(fontSize: 13, height: 1.5, color: Colors.grey[700]))),
              ]),
            )).toList(),
          )),
        ],
        if (h.imageUrls.length > 1) ...[
          const SizedBox(height: 18),
          _Section(title: 'All Photos (${h.imageUrls.length})',
            child: SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: h.imageUrls.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => _pageCtrl.animateToPage(i,
                      duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: getProxyImageUrl(cloudinaryThumb(h.imageUrls[i], w: 180, h: 180)),
                      cacheKey: 'thumb_${h.imageUrls[i]}',
                      width: 110, height: 80,
                      fit: BoxFit.cover, filterQuality: FilterQuality.medium,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 18),
        const Divider(),
        const SizedBox(height: 10),
        if (h.createdAt != null)
          Text('Listed on ${_fmt(h.createdAt!)}', style: GoogleFonts.dmSans(fontSize: 11, color: Colors.grey[400])),
        if (h.updatedAt != null)
          Text('Last updated ${_fmt(h.updatedAt!)}', style: GoogleFonts.dmSans(fontSize: 11, color: Colors.grey[400])),
        const SizedBox(height: 40),
      ]),
    );
  }

  Widget _mobileBody() {
    final h = widget.homestay;
    return Padding(
      padding: EdgeInsets.all(18.w),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Text(h.name,
              style: GoogleFonts.playfairDisplay(fontSize: 22.sp, fontWeight: FontWeight.bold, color: _dark))),
          if (h.category != null && h.category!.isNotEmpty) ...[
            SizedBox(width: 8.w),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _slate.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _slate.withValues(alpha: 0.3)),
              ),
              child: Text(h.category!,
                  style: GoogleFonts.dmSans(fontSize: 11, color: _slate, fontWeight: FontWeight.w600)),
            ),
          ],
        ]),
        const SizedBox(height: 6),
        Row(children: [
          Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 4),
          Expanded(child: Text(h.location, style: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey[600]))),
        ]),
        if (h.nearCulturalSite != null) ...[
          const SizedBox(height: 3),
          Row(children: [
            Icon(Icons.temple_hindu_outlined, size: 13, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text('Near ${h.nearCulturalSite!.name}',
                style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey[500])),
          ]),
        ],
        SizedBox(height: 18.h),
        Row(children: [
          Expanded(child: _StatCard(label: 'Price/Night', value: 'Rs. ${h.pricePerNight.toStringAsFixed(0)}', icon: Icons.payments_outlined)),
          const SizedBox(width: 8),
          Expanded(child: _StatCard(label: 'Rooms', value: '${h.numberOfRooms}', icon: Icons.bed_outlined)),
          const SizedBox(width: 8),
          Expanded(child: _StatCard(label: 'Guests', value: '${h.maxGuests}', icon: Icons.people_outline)),
          const SizedBox(width: 8),
          Expanded(child: _StatCard(label: 'Baths', value: '${h.bathrooms}', icon: Icons.bathtub_outlined)),
        ]),
        SizedBox(height: 18.h),
        const Divider(),
        SizedBox(height: 14.h),
        if (h.description.isNotEmpty)
          _Section(title: 'About',
              child: Text(h.description, style: GoogleFonts.dmSans(fontSize: 13, height: 1.6, color: Colors.grey[700]))),
        if (_notEmpty(h.culturalSignificance)) ...[
          SizedBox(height: 16.h),
          _Section(title: 'Cultural Significance',
              child: Text(h.culturalSignificance!, style: GoogleFonts.dmSans(fontSize: 13, height: 1.6, color: Colors.grey[700]))),
        ],
        if (_notEmpty(h.buildingHistory)) ...[
          SizedBox(height: 16.h),
          _Section(title: 'Building History',
              child: Text(h.buildingHistory!, style: GoogleFonts.dmSans(fontSize: 13, height: 1.6, color: Colors.grey[700]))),
        ],
        if (_notEmpty(h.traditionalFeatures)) ...[
          SizedBox(height: 16.h),
          _Section(title: 'Traditional Features',
              child: Text(h.traditionalFeatures!, style: GoogleFonts.dmSans(fontSize: 13, height: 1.6, color: Colors.grey[700]))),
        ],
        if (h.amenities.isNotEmpty) ...[
          SizedBox(height: 16.h),
          _Section(title: 'Amenities', child: Wrap(
            spacing: 8, runSpacing: 8,
            children: h.amenities.map((a) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _slate.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _slate.withValues(alpha: 0.2)),
              ),
              child: Text(a, style: GoogleFonts.dmSans(fontSize: 12, color: _dark)),
            )).toList(),
          )),
        ],
        if (h.culturalExperiences.isNotEmpty) ...[
          SizedBox(height: 16.h),
          _Section(title: 'Cultural Experiences', child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: h.culturalExperiences.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Container(width: 5, height: 5,
                      decoration: const BoxDecoration(color: _slate, shape: BoxShape.circle)),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(e, style: GoogleFonts.dmSans(fontSize: 13, height: 1.5, color: Colors.grey[700]))),
              ]),
            )).toList(),
          )),
        ],
        if (h.imageUrls.length > 1) ...[
          SizedBox(height: 16.h),
          _Section(title: 'All Photos (${h.imageUrls.length})',
            child: SizedBox(
              height: 80.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: h.imageUrls.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => _pageCtrl.animateToPage(i,
                      duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: getProxyImageUrl(cloudinaryThumb(h.imageUrls[i], w: 180, h: 180)),
                      cacheKey: 'thumb_${h.imageUrls[i]}',
                      width: 110.w, height: 80.h,
                      fit: BoxFit.cover, filterQuality: FilterQuality.medium,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        SizedBox(height: 16.h),
        const Divider(),
        SizedBox(height: 10.h),
        if (h.createdAt != null)
          Text('Listed on ${_fmt(h.createdAt!)}',
              style: GoogleFonts.dmSans(fontSize: 11, color: Colors.grey[400])),
        if (h.updatedAt != null)
          Text('Last updated ${_fmt(h.updatedAt!)}',
              style: GoogleFonts.dmSans(fontSize: 11, color: Colors.grey[400])),
        SizedBox(height: 40.h),
      ]),
    );
  }

  bool _notEmpty(String? s) => s != null && s.isNotEmpty;

  String _fmt(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class _Arrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _Arrow({required this.icon, this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedOpacity(
      opacity: onTap != null ? 1.0 : 0.3,
      duration: const Duration(milliseconds: 200),
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    ),
  );
}

class _BackBtn extends StatelessWidget {
  final bool dark;
  const _BackBtn({this.dark = false});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.pop(context),
    child: Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: dark ? Colors.transparent : Colors.white, shape: BoxShape.circle),
      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF1A1A2E)),
    ),
  );
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  static const _slate = Color(0xFF3D5A80);
  const _StatCard({required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Column(children: [
      Icon(icon, size: 18, color: _slate),
      const SizedBox(height: 5),
      Text(value, textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
      const SizedBox(height: 2),
      Text(label, textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(fontSize: 9, color: Colors.grey[500])),
    ]),
  );
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A2E))),
    const SizedBox(height: 8),
    child,
  ]);
}

class _Dialog extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, body, confirmLabel;
  final Color confirmColor;
  final VoidCallback onConfirm;
  const _Dialog({required this.icon, required this.iconColor, required this.title,
    required this.body, required this.confirmLabel, required this.confirmColor, required this.onConfirm});
  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    title: Row(children: [
      Icon(icon, color: iconColor, size: 24),
      const SizedBox(width: 10),
      Expanded(child: Text(title,
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, fontSize: 17, color: const Color(0xFF1A1A2E)))),
    ]),
    content: Text(body, style: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey[700], height: 1.5)),
    actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('Cancel', style: GoogleFonts.dmSans(color: Colors.grey[600], fontWeight: FontWeight.w600)),
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: confirmColor, elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        onPressed: () { Navigator.pop(context); onConfirm(); },
        child: Text(confirmLabel, style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    ],
  );
}