import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/services/image_proxy.dart';
import 'package:lokyatra_frontend/data/models/Homestay.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/homestays/HomestayBloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/homestays/HomestayEvent.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/datasources/sites_remote_datasource.dart';
import '../../../data/models/Site.dart';
import 'Ownersitedetailpage.dart';

class OwnerHomestayDetailPage extends StatefulWidget {
  final Homestay homestay;
  const OwnerHomestayDetailPage({super.key, required this.homestay});

  @override
  State<OwnerHomestayDetailPage> createState() => _OwnerHomestayDetailPageState();
}

class _OwnerHomestayDetailPageState extends State<OwnerHomestayDetailPage> {
  static const _terracotta = Color(0xFFCD6E4E);
  static const _dark       = Color(0xFF2D1B10);
  static const _cream      = Color(0xFFFAF7F2);
  static const _warmGrey   = Color(0xFF8B8B8B);
  static const _teal       = Color(0xFF4A707A);

  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  CulturalSite? _nearbySite;
  bool _isLoadingSite = false;

  @override
  void initState() {
    super.initState();
    if (widget.homestay.nearCulturalSite != null) {
      _fetchNearbySite(widget.homestay.nearCulturalSite!.id);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchNearbySite(int id) async {
    setState(() => _isLoadingSite = true);
    try {
      final res = await SitesRemoteDatasource().getSite(id);
      if (res.statusCode == 200 && mounted) {
        setState(() => _nearbySite = CulturalSite.fromJson(res.data as Map<String, dynamic>));
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoadingSite = false);
    }
  }

  Future<void> _openMap() async {
    final homestay = widget.homestay;
    final parts = [
      if (homestay.name.isNotEmpty) homestay.name,
      if (homestay.location.isNotEmpty) homestay.location,
      'Nepal',
    ];
    final query = Uri.encodeComponent(parts.join(', '));
    final geoUri = Uri.parse('geo:0,0?q=$query');
    try {
      await launchUrl(geoUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      final webUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
      try {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open Maps. Please install Google Maps.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final homestay = widget.homestay;
    final images   = homestay.imageUrls.isNotEmpty ? homestay.imageUrls : <String>[];

    return Scaffold(
      backgroundColor: _cream,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [

              // ── Hero image with working PageView ──────────────────────
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 360.h,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      images.isEmpty
                          ? Container(color: Colors.grey[300],
                          child: Icon(Icons.home, size: 60.sp, color: Colors.grey[400]))
                          : PageView.builder(
                        controller: _pageController,
                        itemCount: images.length,
                        onPageChanged: (i) => setState(() => _currentImageIndex = i),
                        itemBuilder: (_, i) => ProxyImage(
                          imageUrl: images[i],
                          width: double.infinity,
                          height: 360.h,
                          borderRadiusValue: 0,
                        ),
                      ),

                      // IgnorePointer so gradient never blocks swipe
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.3),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.6),
                                ],
                                stops: const [0, 0.4, 1],
                              ),
                            ),
                          ),
                        ),
                      ),

                      if (images.length > 1)
                        Positioned(
                          top: 52.h, right: 16.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.photo_library_outlined, size: 12.sp, color: Colors.white),
                              SizedBox(width: 4.w),
                              Text('${_currentImageIndex + 1}/${images.length}',
                                  style: GoogleFonts.dmSans(color: Colors.white,
                                      fontSize: 12.sp, fontWeight: FontWeight.w600)),
                            ]),
                          ),
                        ),

                      if (images.length > 1)
                        Positioned(
                          bottom: 80.h, left: 0, right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(images.length, (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: EdgeInsets.symmetric(horizontal: 3.w),
                              height: 6.h,
                              width: _currentImageIndex == i ? 20.w : 6.w,
                              decoration: BoxDecoration(
                                color: _currentImageIndex == i ? Colors.white : Colors.white54,
                                borderRadius: BorderRadius.circular(3.r),
                              ),
                            )),
                          ),
                        ),

                      Positioned(
                        bottom: 20.h, left: 20.w, right: 20.w,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(homestay.name,
                              style: GoogleFonts.playfairDisplay(
                                  color: Colors.white, fontSize: 26.sp, fontWeight: FontWeight.bold,
                                  shadows: [const Shadow(blurRadius: 8, color: Colors.black45)])),
                          SizedBox(height: 4.h),
                          Row(children: [
                            Icon(Icons.location_on, color: Colors.white70, size: 13.sp),
                            SizedBox(width: 3.w),
                            Expanded(child: Text(homestay.location,
                                style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 13.sp))),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: homestay.isVisible
                                    ? Colors.green.withValues(alpha: 0.85)
                                    : Colors.orange.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(homestay.isVisible ? 'Active' : 'Paused',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 11.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ]),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Detail body ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: _cream,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                  ),
                  transform: Matrix4.translationValues(0, -20, 0),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      // Category + Price row
                      Row(children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: _terracotta.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(homestay.category ?? 'Homestay',
                              style: GoogleFonts.dmSans(
                                  fontSize: 12.sp, color: _terracotta, fontWeight: FontWeight.w600)),
                        ),
                        const Spacer(),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text('Rs. ${homestay.pricePerNight.toStringAsFixed(0)}',
                              style: GoogleFonts.dmSans(
                                  fontSize: 24.sp, color: _terracotta, fontWeight: FontWeight.w800)),
                          Text('/ night',
                              style: GoogleFonts.dmSans(fontSize: 12.sp, color: _warmGrey)),
                        ]),
                      ]),

                      SizedBox(height: 16.h),

                      // ── Location + Map button side by side ────────────
                      Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: Colors.grey.shade100),
                          boxShadow: [BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 8, offset: const Offset(0, 3))],
                        ),
                        child: Row(children: [
                          // Location icon + text
                          Expanded(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Container(
                              padding: EdgeInsets.all(7.w),
                              decoration: BoxDecoration(
                                color: _teal.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(Icons.location_on_outlined, size: 16.sp, color: _teal),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Location',
                                  style: GoogleFonts.dmSans(fontSize: 11.sp, color: Colors.grey[500])),
                              SizedBox(height: 2.h),
                              Text(homestay.location,
                                  style: GoogleFonts.dmSans(
                                      fontSize: 13.sp, color: _dark, fontWeight: FontWeight.w500)),
                            ])),
                          ])),
                          SizedBox(width: 10.w),
                          // Map button
                          GestureDetector(
                            onTap: _openMap,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: _teal,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.map_outlined, size: 15.sp, color: Colors.white),
                                SizedBox(width: 5.w),
                                Text('Map', style: GoogleFonts.dmSans(
                                    fontSize: 12.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                              ]),
                            ),
                          ),
                        ]),
                      ),

                      SizedBox(height: 20.h),

                      // Stats
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                          _statItem(Icons.king_bed_outlined,      '${homestay.numberOfRooms}', 'Rooms'),
                          _statItem(Icons.people_outline_rounded, '${homestay.maxGuests}',     'Guests'),
                          _statItem(Icons.bathtub_outlined,       '${homestay.bathrooms}',     'Bathrooms'),
                        ]),
                      ),
                      SizedBox(height: 24.h),

                      _sectionTitle('Description'),
                      SizedBox(height: 8.h),
                      Text(homestay.description,
                          style: GoogleFonts.dmSans(fontSize: 14.sp, height: 1.6, color: Colors.grey[700])),
                      SizedBox(height: 24.h),

                      if (homestay.amenities.isNotEmpty) ...[
                        _sectionTitle('Amenities'),
                        SizedBox(height: 12.h),
                        Wrap(
                          spacing: 8.w, runSpacing: 8.h,
                          children: homestay.amenities.map((a) => Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Text(a, style: GoogleFonts.dmSans(fontSize: 12.sp, color: _dark)),
                          )).toList(),
                        ),
                        SizedBox(height: 24.h),
                      ],

                      if (homestay.culturalSignificance != null &&
                          homestay.culturalSignificance!.isNotEmpty) ...[
                        _sectionTitle('Cultural Significance'),
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(homestay.culturalSignificance!,
                              style: GoogleFonts.dmSans(fontSize: 14.sp, height: 1.6, color: Colors.grey[700])),
                        ),
                        SizedBox(height: 24.h),
                      ],

                      if (homestay.traditionalFeatures != null &&
                          homestay.traditionalFeatures!.isNotEmpty) ...[
                        _sectionTitle('Traditional Features'),
                        SizedBox(height: 8.h),
                        Text(homestay.traditionalFeatures!,
                            style: GoogleFonts.dmSans(fontSize: 14.sp, height: 1.6, color: Colors.grey[700])),
                        SizedBox(height: 24.h),
                      ],

                      if (homestay.culturalExperiences.isNotEmpty) ...[
                        _sectionTitle('Cultural Experiences'),
                        SizedBox(height: 12.h),
                        ...homestay.culturalExperiences.map((exp) => Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Icon(Icons.emoji_events_outlined, size: 16.sp, color: _terracotta),
                            SizedBox(width: 8.w),
                            Expanded(child: Text(exp,
                                style: GoogleFonts.dmSans(fontSize: 14.sp, color: Colors.grey[700]))),
                          ]),
                        )),
                        SizedBox(height: 24.h),
                      ],

                      // Nearby Heritage Site
                      if (widget.homestay.nearCulturalSite != null) ...[
                        _sectionTitle('Nearby Heritage Site'),
                        SizedBox(height: 8.h),
                        if (_isLoadingSite)
                          const Center(child: Padding(
                              padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
                        else if (_nearbySite != null)
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(
                                builder: (_) => OwnerSiteDetailPage(site: _nearbySite!))),
                            child: Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: Colors.grey.shade200),
                                boxShadow: [BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 4, offset: const Offset(0, 2))],
                              ),
                              child: Row(children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: _nearbySite!.imageUrls.isNotEmpty
                                      ? ProxyImage(imageUrl: _nearbySite!.imageUrls.first,
                                      width: 70.w, height: 70.h, borderRadiusValue: 0, thumb: true)
                                      : Container(width: 70.w, height: 70.h, color: Colors.grey[100],
                                      child: Icon(Icons.temple_hindu,
                                          color: Colors.grey[400], size: 30.sp)),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(_nearbySite!.name ?? '',
                                      maxLines: 2, overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.dmSans(
                                          fontSize: 14.sp, fontWeight: FontWeight.bold, color: _dark)),
                                  if (_nearbySite!.district != null) ...[
                                    SizedBox(height: 4.h),
                                    Text(_nearbySite!.district!,
                                        style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.grey[600])),
                                  ],
                                  if (_nearbySite!.category != null)
                                    Text(_nearbySite!.category!,
                                        style: GoogleFonts.dmSans(fontSize: 11.sp, color: _teal)),
                                ])),
                                Icon(Icons.arrow_forward_ios_rounded,
                                    size: 14.sp, color: Colors.grey[400]),
                              ]),
                            ),
                          )
                        else
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(children: [
                              Container(
                                width: 48.w, height: 48.h,
                                decoration: BoxDecoration(
                                  color: _terracotta.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Icon(Icons.temple_hindu, color: _terracotta, size: 24.sp),
                              ),
                              SizedBox(width: 12.w),
                              Text(widget.homestay.nearCulturalSite!.name,
                                  style: GoogleFonts.dmSans(
                                      fontSize: 14.sp, fontWeight: FontWeight.bold, color: _dark)),
                            ]),
                          ),
                        SizedBox(height: 24.h),
                      ],

                      // Action buttons
                      Row(children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _showVisibilityDialog,
                            icon: Icon(
                              homestay.isVisible
                                  ? Icons.pause_circle_outline
                                  : Icons.play_circle_outline,
                              size: 18.sp,
                            ),
                            label: Text(homestay.isVisible ? 'Pause' : 'Activate'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: homestay.isVisible
                                  ? Colors.orange[800] : Colors.green[800],
                              side: BorderSide(color: homestay.isVisible
                                  ? Colors.orange.shade200 : Colors.green.shade200),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r)),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showDeleteDialog,
                            icon: const Icon(Icons.delete_outline_rounded),
                            label: const Text('Delete'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r)),
                            ),
                          ),
                        ),
                      ]),
                      SizedBox(height: 32.h),
                    ]),
                  ),
                ),
              ),
            ],
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8.h,
            left: 8.w,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38.w, height: 38.h,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(Icons.arrow_back, size: 20.sp, color: _dark),
              ),
            ),
          ),

          // Visibility toggle button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8.h,
            right: 8.w,
            child: GestureDetector(
              onTap: _showVisibilityDialog,
              child: Container(
                width: 38.w, height: 38.h,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(
                  homestay.isVisible ? Icons.visibility : Icons.visibility_off,
                  size: 20.sp,
                  color: homestay.isVisible ? _terracotta : _warmGrey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String value, String label) =>
      Column(children: [
        Icon(icon, size: 24.sp, color: _terracotta),
        SizedBox(height: 4.h),
        Text(value, style: GoogleFonts.dmSans(
            fontSize: 16.sp, fontWeight: FontWeight.bold, color: _dark)),
        Text(label, style: GoogleFonts.dmSans(fontSize: 12.sp, color: _warmGrey)),
      ]);

  Widget _sectionTitle(String title) => Text(title,
      style: GoogleFonts.playfairDisplay(
          fontSize: 18.sp, fontWeight: FontWeight.bold, color: _dark));

  void _showVisibilityDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(children: [
          Icon(
            widget.homestay.isVisible
                ? Icons.pause_circle_outline : Icons.play_circle_outline,
            color: widget.homestay.isVisible ? Colors.orange[700] : Colors.green[600],
            size: 28.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(child: Text(
            widget.homestay.isVisible ? 'Pause Homestay?' : 'Activate Homestay?',
            style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold, fontSize: 18.sp, color: _dark),
          )),
        ]),
        content: Text(
          widget.homestay.isVisible
              ? 'Pausing "${widget.homestay.name}" will hide it from tourists until you activate it again.'
              : 'Activating "${widget.homestay.name}" will make it visible to all tourists for booking.',
          style: GoogleFonts.dmSans(fontSize: 14.sp, color: Colors.grey[700], height: 1.5),
        ),
        actionsPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.dmSans(
                color: Colors.grey[600], fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.homestay.isVisible
                  ? Colors.orange[700] : Colors.green[600],
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<HomestayBloc>().add(
                  AdminToggleHomestayVisibility(widget.homestay.id, !widget.homestay.isVisible));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Homestay ${widget.homestay.isVisible ? 'paused' : 'activated'} successfully'),
                backgroundColor: widget.homestay.isVisible
                    ? Colors.orange[700] : Colors.green[600],
                behavior: SnackBarBehavior.floating,
              ));
              Navigator.pop(context);
            },
            child: Text(
              widget.homestay.isVisible ? 'Pause' : 'Activate',
              style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(children: [
          Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28.sp),
          SizedBox(width: 10.w),
          Expanded(child: Text('Delete Homestay?',
              style: GoogleFonts.playfairDisplay(
                  fontWeight: FontWeight.bold, fontSize: 18.sp, color: _dark))),
        ]),
        content: Text(
          'Are you sure you want to permanently delete "${widget.homestay.name}"? This action cannot be undone.',
          style: GoogleFonts.dmSans(fontSize: 14.sp, color: Colors.grey[700], height: 1.5),
        ),
        actionsPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.dmSans(
                color: Colors.grey[600], fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent, elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<HomestayBloc>().add(AdminDeleteHomestay(widget.homestay.id));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Homestay deleted successfully'),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ));
              Navigator.pop(context);
            },
            child: Text('Delete',
                style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}