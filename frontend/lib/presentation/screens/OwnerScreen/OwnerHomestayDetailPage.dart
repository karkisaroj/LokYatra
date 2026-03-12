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

const ink    = Color(0xFF2D1B10);
const accent = Color(0xFFCD6E4E);
const cream  = Color(0xFFFAF7F2);
const teal   = Color(0xFF4A707A);

double fs(double v, bool wide) => wide ? v : v.sp;
double sw(double v, bool wide) => wide ? v : v.w;
double sh(double v, bool wide) => wide ? v : v.h;
double sr(double v, bool wide) => wide ? v : v.r;

class OwnerHomestayDetailPage extends StatefulWidget {
  final Homestay homestay;
  const OwnerHomestayDetailPage({super.key, required this.homestay});
  @override
  State<OwnerHomestayDetailPage> createState() => OwnerHomestayDetailPageState();
}

class OwnerHomestayDetailPageState extends State<OwnerHomestayDetailPage> {
  final pageCtrl   = PageController();
  int imgIdx       = 0;
  CulturalSite? nearbySite;
  bool siteLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.homestay.nearCulturalSite != null) {
      fetchSite(widget.homestay.nearCulturalSite!.id);
    }
  }

  @override
  void dispose() { pageCtrl.dispose(); super.dispose(); }

  Future<void> fetchSite(int id) async {
    setState(() => siteLoading = true);
    try {
      final res = await SitesRemoteDatasource().getSite(id);
      if (res.statusCode == 200 && mounted) {
        setState(() => nearbySite =
            CulturalSite.fromJson(res.data as Map<String, dynamic>));
      }
    } catch (_) {}
    finally { if (mounted) setState(() => siteLoading = false); }
  }

  Future<void> openMap() async {
    final h = widget.homestay;
    final q = Uri.encodeComponent(
        [h.name, h.location, 'Nepal'].where((s) => s.isNotEmpty).join(', '));
    try {
      await launchUrl(Uri.parse('geo:0,0?q=$q'),
          mode: LaunchMode.externalApplication);
    } catch (_) {
      try {
        await launchUrl(
            Uri.parse('https://www.google.com/maps/search/?api=1&query=$q'),
            mode: LaunchMode.externalApplication);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open Maps.')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 700;
    if (wide) return buildWebLayout(context);
    return buildMobileLayout(context);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WEB LAYOUT — full width, two-column body, uncropped hero
  // ═══════════════════════════════════════════════════════════════════════════
  Widget buildWebLayout(BuildContext context) {
    final h    = widget.homestay;
    final imgs = h.imageUrls;

    return Scaffold(
      backgroundColor: cream,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Full-width hero: dark bg + BoxFit.contain = image never cropped
            SizedBox(
              height: 560,
              child: Stack(fit: StackFit.expand, children: [
                // Dark letterbox background
                Container(color: const Color(0xFF111111)),

                // PageView
                imgs.isEmpty
                    ? Container(
                    color: Colors.grey[200],
                    child: Icon(Icons.home, size: 64, color: Colors.grey[400]))
                    : PageView.builder(
                  controller: pageCtrl,
                  itemCount: imgs.length,
                  physics: const ClampingScrollPhysics(),
                  onPageChanged: (i) => setState(() => imgIdx = i),
                  itemBuilder: (_, i) => ProxyImage(
                    imageUrl: imgs[i],
                    width: double.infinity,
                    height: 560,
                    borderRadiusValue: 0,
                    thumb: false,
                    fit: BoxFit.contain, // full image, no crop
                  ),
                ),

                // Bottom gradient for title readability
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.75),
                          ],
                          stops: const [0, 0.5, 1],
                        ),
                      ),
                    ),
                  ),
                ),

                // Left arrow
                if (imgs.length > 1)
                  Positioned(
                    left: 20, top: 0, bottom: 0,
                    child: Center(
                      child: _NavBtn(
                        icon: Icons.chevron_left_rounded,
                        onTap: () {
                          final prev = (imgIdx - 1 + imgs.length) % imgs.length;
                          pageCtrl.animateToPage(prev,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut);
                        },
                      ),
                    ),
                  ),

                // Right arrow
                if (imgs.length > 1)
                  Positioned(
                    right: 20, top: 0, bottom: 0,
                    child: Center(
                      child: _NavBtn(
                        icon: Icons.chevron_right_rounded,
                        onTap: () {
                          final next = (imgIdx + 1) % imgs.length;
                          pageCtrl.animateToPage(next,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut);
                        },
                      ),
                    ),
                  ),

                // Counter
                if (imgs.length > 1)
                  Positioned(
                    top: 24, right: 64,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.photo_library_outlined,
                            size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        Text('${imgIdx + 1} / ${imgs.length}',
                            style: GoogleFonts.dmSans(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),

                // Dot indicators
                if (imgs.length > 1)
                  Positioned(
                    bottom: 88, left: 0, right: 0,
                    child: IgnorePointer(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(imgs.length,
                                (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              height: 6,
                              width: imgIdx == i ? 22 : 6,
                              decoration: BoxDecoration(
                                color: imgIdx == i
                                    ? Colors.white : Colors.white54,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            )),
                      ),
                    ),
                  ),

                // Title block
                Positioned(
                  bottom: 32, left: 56, right: 160,
                  child: IgnorePointer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(h.name,
                            style: GoogleFonts.playfairDisplay(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                shadows: const [
                                  Shadow(blurRadius: 12, color: Colors.black54)
                                ])),
                        const SizedBox(height: 8),
                        Row(children: [
                          const Icon(Icons.location_on,
                              color: Colors.white70, size: 16),
                          const SizedBox(width: 4),
                          Text(h.location,
                              style: GoogleFonts.dmSans(
                                  color: Colors.white70, fontSize: 16)),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: h.isVisible
                                  ? Colors.green.withValues(alpha: 0.85)
                                  : Colors.orange.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(h.isVisible ? 'Active' : 'Paused',
                                style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),

                // Back button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42, height: 42,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back, size: 20, color: ink),
                    ),
                  ),
                ),

                // Visibility toggle button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  right: 20,
                  child: GestureDetector(
                    onTap: () => showVisibilityDialog(true),
                    child: Container(
                      width: 42, height: 42,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: Icon(
                        h.isVisible
                            ? Icons.visibility : Icons.visibility_off,
                        size: 20,
                        color: h.isVisible ? accent : Colors.grey[500],
                      ),
                    ),
                  ),
                ),
              ]),
            ),

            // ── Two-column body — full width, 48px padding
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column — main content
                  Expanded(
                    flex: 5,
                    child: webLeftColumn(h),
                  ),
                  const SizedBox(width: 40),
                  // Right sidebar — fixed 320px
                  SizedBox(
                    width: 320,
                    child: webRightSidebar(h),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget webLeftColumn(Homestay h) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Price + category row
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20)),
            child: Text(h.category ?? 'Homestay',
                style: GoogleFonts.dmSans(
                    fontSize: 13, color: accent, fontWeight: FontWeight.w600)),
          ),
          const Spacer(),
          Text('Rs. ${h.pricePerNight.toStringAsFixed(0)}',
              style: GoogleFonts.dmSans(
                  fontSize: 28, color: accent, fontWeight: FontWeight.w800)),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('/ night',
                style: GoogleFonts.dmSans(
                    fontSize: 13, color: Colors.grey[500])),
          ),
        ]),

        const SizedBox(height: 24),

        // Stats bar
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            StatCell(wide: true, icon: Icons.king_bed_outlined,
                val: '${h.numberOfRooms}', label: 'Rooms'),
            const VerticalDivider(width: 1, color: Color(0xFFF0F0F0)),
            StatCell(wide: true, icon: Icons.people_outline_rounded,
                val: '${h.maxGuests}', label: 'Guests'),
            const VerticalDivider(width: 1, color: Color(0xFFF0F0F0)),
            StatCell(wide: true, icon: Icons.bathtub_outlined,
                val: '${h.bathrooms}', label: 'Bathrooms'),
          ]),
        ),

        const SizedBox(height: 28),

        // Description
        SectionTitle(wide: true, text: 'Description'),
        const SizedBox(height: 10),
        Text(h.description,
            style: GoogleFonts.dmSans(
                fontSize: 15, height: 1.7, color: Colors.grey[700])),

        const SizedBox(height: 28),

        // Amenities
        if (h.amenities.isNotEmpty) ...[
          SectionTitle(wide: true, text: 'Amenities'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: h.amenities.map((a) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(a,
                  style: GoogleFonts.dmSans(fontSize: 13, color: ink)),
            )).toList(),
          ),
          const SizedBox(height: 28),
        ],

        // Cultural significance
        if ((h.culturalSignificance ?? '').isNotEmpty) ...[
          SectionTitle(wide: true, text: 'Cultural Significance'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Text(h.culturalSignificance!,
                style: GoogleFonts.dmSans(
                    fontSize: 15, height: 1.7, color: Colors.grey[700])),
          ),
          const SizedBox(height: 28),
        ],

        // Traditional features
        if ((h.traditionalFeatures ?? '').isNotEmpty) ...[
          SectionTitle(wide: true, text: 'Traditional Features'),
          const SizedBox(height: 10),
          Text(h.traditionalFeatures!,
              style: GoogleFonts.dmSans(
                  fontSize: 15, height: 1.7, color: Colors.grey[700])),
          const SizedBox(height: 28),
        ],

        // Cultural experiences
        if (h.culturalExperiences.isNotEmpty) ...[
          SectionTitle(wide: true, text: 'Cultural Experiences'),
          const SizedBox(height: 12),
          ...h.culturalExperiences.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.emoji_events_outlined,
                  size: 18, color: accent),
              const SizedBox(width: 10),
              Expanded(child: Text(e,
                  style: GoogleFonts.dmSans(
                      fontSize: 15, color: Colors.grey[700]))),
            ]),
          )),
          const SizedBox(height: 28),
        ],

        // Nearby site
        if (h.nearCulturalSite != null) ...[
          SectionTitle(wide: true, text: 'Nearby Heritage Site'),
          const SizedBox(height: 12),
          if (siteLoading)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(color: accent)))
          else if (nearbySite != null)
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => OwnerSiteDetailPage(site: nearbySite!))),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: nearbySite!.imageUrls.isNotEmpty
                        ? ProxyImage(
                        imageUrl: nearbySite!.imageUrls.first,
                        width: 80, height: 80,
                        borderRadiusValue: 0,
                        thumb: true)
                        : Container(
                        width: 80, height: 80,
                        color: Colors.grey[100],
                        child: const Icon(Icons.temple_hindu,
                            color: Colors.grey, size: 32)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(nearbySite!.name ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: ink)),
                    if (nearbySite!.district != null) ...[
                      const SizedBox(height: 4),
                      Text(nearbySite!.district!,
                          style: GoogleFonts.dmSans(
                              fontSize: 13, color: Colors.grey[600])),
                    ],
                  ])),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: Colors.grey),
                ]),
              ),
            ),
          const SizedBox(height: 28),
        ],

        // Action buttons
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: () => showVisibilityDialog(true),
            icon: Icon(
                h.isVisible
                    ? Icons.pause_circle_outline
                    : Icons.play_circle_outline,
                size: 18),
            label: Text(h.isVisible ? 'Pause Listing' : 'Activate Listing'),
            style: OutlinedButton.styleFrom(
              foregroundColor: h.isVisible
                  ? Colors.orange[800] : Colors.green[800],
              side: BorderSide(
                  color: h.isVisible
                      ? Colors.orange.shade200 : Colors.green.shade200),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          )),
          const SizedBox(width: 16),
          Expanded(child: ElevatedButton.icon(
            onPressed: () => showDeleteDialog(true),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Delete Homestay'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          )),
        ]),

        const SizedBox(height: 48),
      ],
    );
  }

  Widget webRightSidebar(Homestay h) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Location card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 18, color: ink),
              const SizedBox(width: 8),
              Text('Location',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 18, fontWeight: FontWeight.bold, color: ink)),
            ]),
            const SizedBox(height: 14),
            Text(h.location,
                style: GoogleFonts.dmSans(
                    fontSize: 14, color: Colors.grey[700], height: 1.5)),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: openMap,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                    color: teal, borderRadius: BorderRadius.circular(10)),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.map_outlined, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text('Open in Maps',
                      style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ]),
              ),
            ),
          ]),
        ),

        const SizedBox(height: 20),

        // Building history
        if ((h.buildingHistory ?? '').isNotEmpty)
          _SideCard(
            title: 'Building History',
            icon: Icons.history_edu_outlined,
            child: Text(h.buildingHistory!,
                style: GoogleFonts.dmSans(
                    fontSize: 13, height: 1.65, color: Colors.grey[700])),
          ),

        if ((h.buildingHistory ?? '').isNotEmpty) const SizedBox(height: 20),

        // Photo strip if multiple images
        if (h.imageUrls.length > 1)
          _SideCard(
            title: 'All Photos',
            icon: Icons.photo_library_outlined,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: h.imageUrls.map((url) => GestureDetector(
                onTap: () {
                  final i = h.imageUrls.indexOf(url);
                  pageCtrl.animateToPage(i,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut);
                  setState(() => imgIdx = i);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ProxyImage(
                    imageUrl: url,
                    width: 80, height: 80,
                    borderRadiusValue: 0,
                    thumb: true,
                    fit: BoxFit.cover,
                  ),
                ),
              )).toList(),
            ),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MOBILE LAYOUT — unchanged
  // ═══════════════════════════════════════════════════════════════════════════
  Widget buildMobileLayout(BuildContext context) {
    final h     = widget.homestay;
    final imgs  = h.imageUrls;
    final heroH = 360.h;

    return Scaffold(
      backgroundColor: cream,
      body: Stack(children: [
        CustomScrollView(slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: heroH,
              child: Stack(fit: StackFit.expand, children: [
                imgs.isEmpty
                    ? Container(
                    color: Colors.grey[200],
                    child: Icon(Icons.home,
                        size: fs(60, false), color: Colors.grey[400]))
                    : PageView.builder(
                  controller: pageCtrl,
                  itemCount: imgs.length,
                  onPageChanged: (i) => setState(() => imgIdx = i),
                  itemBuilder: (_, i) => ProxyImage(
                      imageUrl: imgs[i],
                      width: double.infinity,
                      height: heroH,
                      borderRadiusValue: 0,
                      fit: BoxFit.cover),
                ),

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

                if (imgs.length > 1)
                  Positioned(
                    top: 52.h, right: 16.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20.r)),
                      child: Text('${imgIdx + 1}/${imgs.length}',
                          style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),

                if (imgs.length > 1)
                  Positioned(
                    bottom: 70.h, left: 0, right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        imgs.length,
                            (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: EdgeInsets.symmetric(horizontal: 3.w),
                          height: 6.h,
                          width: imgIdx == i ? 20.w : 6.w,
                          decoration: BoxDecoration(
                            color: imgIdx == i ? Colors.white : Colors.white54,
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                        ),
                      ),
                    ),
                  ),

                Positioned(
                  bottom: 20.h, left: 20.w, right: 20.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(h.name,
                          style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontSize: 26.sp,
                              fontWeight: FontWeight.bold,
                              shadows: const [
                                Shadow(blurRadius: 8, color: Colors.black45)
                              ])),
                      SizedBox(height: 4.h),
                      Row(children: [
                        Icon(Icons.location_on,
                            color: Colors.white70, size: 13.sp),
                        SizedBox(width: 3.w),
                        Expanded(child: Text(h.location,
                            style: GoogleFonts.dmSans(
                                color: Colors.white70, fontSize: 13.sp))),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: h.isVisible
                                ? Colors.green.withValues(alpha: 0.85)
                                : Colors.orange.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(h.isVisible ? 'Active' : 'Paused',
                              style: GoogleFonts.dmSans(
                                  fontSize: 11.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ]),
                    ],
                  ),
                ),
              ]),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: cream,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              transform: Matrix4.translationValues(0, -20, 0),
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                child: mobilebody(h),
              ),
            ),
          ),
        ]),

        Positioned(
          top: MediaQuery.of(context).padding.top + 8.h,
          left: 8.w,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38.w, height: 38.h,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              child: Icon(Icons.arrow_back, size: 20.sp, color: ink),
            ),
          ),
        ),

        Positioned(
          top: MediaQuery.of(context).padding.top + 8.h,
          right: 8.w,
          child: GestureDetector(
            onTap: () => showVisibilityDialog(false),
            child: Container(
              width: 38.w, height: 38.h,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              child: Icon(
                h.isVisible ? Icons.visibility : Icons.visibility_off,
                size: 20.sp,
                color: h.isVisible ? accent : Colors.grey[500],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget mobilebody(Homestay h) {
    const wide = false;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20.r)),
          child: Text(h.category ?? 'Homestay',
              style: GoogleFonts.dmSans(
                  fontSize: 12.sp, color: accent, fontWeight: FontWeight.w600)),
        ),
        const Spacer(),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('Rs. ${h.pricePerNight.toStringAsFixed(0)}',
              style: GoogleFonts.dmSans(
                  fontSize: 24.sp, color: accent, fontWeight: FontWeight.w800)),
          Text('/ night',
              style: GoogleFonts.dmSans(
                  fontSize: 12.sp, color: Colors.grey[500])),
        ]),
      ]),
      SizedBox(height: sh(16, wide)),
      Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(children: [
          Expanded(child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(7.w),
                decoration: BoxDecoration(
                    color: teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r)),
                child: Icon(Icons.location_on_outlined,
                    size: 16.sp, color: teal),
              ),
              SizedBox(width: 10.w),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Location',
                      style: GoogleFonts.dmSans(
                          fontSize: 11.sp, color: Colors.grey[500])),
                  SizedBox(height: 2.h),
                  Text(h.location,
                      style: GoogleFonts.dmSans(
                          fontSize: 13.sp, color: ink, fontWeight: FontWeight.w500)),
                ],
              )),
            ],
          )),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: openMap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                  color: teal, borderRadius: BorderRadius.circular(10.r)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.map_outlined, size: 15.sp, color: Colors.white),
                SizedBox(width: 5.w),
                Text('Map',
                    style: GoogleFonts.dmSans(
                        fontSize: 12.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ]),
            ),
          ),
        ]),
      ),
      SizedBox(height: sh(20, wide)),
      Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          StatCell(wide: wide, icon: Icons.king_bed_outlined,
              val: '${h.numberOfRooms}', label: 'Rooms'),
          StatCell(wide: wide, icon: Icons.people_outline_rounded,
              val: '${h.maxGuests}', label: 'Guests'),
          StatCell(wide: wide, icon: Icons.bathtub_outlined,
              val: '${h.bathrooms}', label: 'Bathrooms'),
        ]),
      ),
      SizedBox(height: sh(24, wide)),
      SectionTitle(wide: wide, text: 'Description'),
      SizedBox(height: sh(8, wide)),
      Text(h.description,
          style: GoogleFonts.dmSans(
              fontSize: 14.sp, height: 1.6, color: Colors.grey[700])),
      SizedBox(height: sh(24, wide)),
      if (h.amenities.isNotEmpty) ...[
        SectionTitle(wide: wide, text: 'Amenities'),
        SizedBox(height: sh(12, wide)),
        Wrap(
          spacing: 8.w, runSpacing: 8.h,
          children: h.amenities.map((a) => Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(a,
                style: GoogleFonts.dmSans(fontSize: 12.sp, color: ink)),
          )).toList(),
        ),
        SizedBox(height: sh(24, wide)),
      ],
      if ((h.culturalSignificance ?? '').isNotEmpty) ...[
        SectionTitle(wide: wide, text: 'Cultural Significance'),
        SizedBox(height: sh(8, wide)),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(h.culturalSignificance!,
              style: GoogleFonts.dmSans(
                  fontSize: 14.sp, height: 1.6, color: Colors.grey[700])),
        ),
        SizedBox(height: sh(24, wide)),
      ],
      if ((h.traditionalFeatures ?? '').isNotEmpty) ...[
        SectionTitle(wide: wide, text: 'Traditional Features'),
        SizedBox(height: sh(8, wide)),
        Text(h.traditionalFeatures!,
            style: GoogleFonts.dmSans(
                fontSize: 14.sp, height: 1.6, color: Colors.grey[700])),
        SizedBox(height: sh(24, wide)),
      ],
      if (h.culturalExperiences.isNotEmpty) ...[
        SectionTitle(wide: wide, text: 'Cultural Experiences'),
        SizedBox(height: sh(12, wide)),
        ...h.culturalExperiences.map((e) => Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.emoji_events_outlined, size: 16.sp, color: accent),
            SizedBox(width: 8.w),
            Expanded(child: Text(e,
                style: GoogleFonts.dmSans(
                    fontSize: 14.sp, color: Colors.grey[700]))),
          ]),
        )),
        SizedBox(height: sh(24, wide)),
      ],
      if (h.nearCulturalSite != null) ...[
        SectionTitle(wide: wide, text: 'Nearby Heritage Site'),
        SizedBox(height: sh(8, wide)),
        if (siteLoading)
          const Center(
              child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(color: accent)))
        else if (nearbySite != null)
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => OwnerSiteDetailPage(site: nearbySite!))),
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: nearbySite!.imageUrls.isNotEmpty
                      ? ProxyImage(
                      imageUrl: nearbySite!.imageUrls.first,
                      width: 70.w, height: 70.h,
                      borderRadiusValue: 0, thumb: true)
                      : Container(
                      width: 70.w, height: 70.h,
                      color: Colors.grey[100],
                      child: Icon(Icons.temple_hindu,
                          color: Colors.grey[400], size: 30.sp)),
                ),
                SizedBox(width: 12.w),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nearbySite!.name ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: ink)),
                    if (nearbySite!.district != null) ...[
                      SizedBox(height: 4.h),
                      Text(nearbySite!.district!,
                          style: GoogleFonts.dmSans(
                              fontSize: 12.sp, color: Colors.grey[600])),
                    ],
                  ],
                )),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 14.sp, color: Colors.grey[400]),
              ]),
            ),
          ),
        SizedBox(height: sh(24, wide)),
      ],
      Row(children: [
        Expanded(child: OutlinedButton.icon(
          onPressed: () => showVisibilityDialog(wide),
          icon: Icon(
              h.isVisible
                  ? Icons.pause_circle_outline
                  : Icons.play_circle_outline,
              size: 18.sp),
          label: Text(h.isVisible ? 'Pause' : 'Activate'),
          style: OutlinedButton.styleFrom(
            foregroundColor: h.isVisible
                ? Colors.orange[800] : Colors.green[800],
            side: BorderSide(
                color: h.isVisible
                    ? Colors.orange.shade200 : Colors.green.shade200),
            padding: EdgeInsets.symmetric(vertical: 12.h),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r)),
          ),
        )),
        SizedBox(width: 12.w),
        Expanded(child: ElevatedButton.icon(
          onPressed: () => showDeleteDialog(wide),
          icon: const Icon(Icons.delete_outline_rounded),
          label: const Text('Delete'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r)),
          ),
        )),
      ]),
      SizedBox(height: 32.h),
    ]);
  }

  void showVisibilityDialog(bool wide) {
    final h = widget.homestay;
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(sr(20, wide))),
      title: Text(h.isVisible ? 'Pause Homestay?' : 'Activate Homestay?',
          style: GoogleFonts.playfairDisplay(
              fontWeight: FontWeight.bold,
              fontSize: fs(18, wide),
              color: ink)),
      content: Text(
          h.isVisible
              ? 'Pausing "${h.name}" will hide it from tourists until you activate it again.'
              : 'Activating "${h.name}" will make it visible to all tourists for booking.',
          style: GoogleFonts.dmSans(
              fontSize: fs(14, wide), color: Colors.grey[700], height: 1.5)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Cancel',
              style: GoogleFonts.dmSans(
                  color: Colors.grey[600], fontWeight: FontWeight.bold)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: h.isVisible
                  ? Colors.orange[700] : Colors.green[600],
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(sr(8, wide)))),
          onPressed: () {
            Navigator.pop(ctx);
            context.read<HomestayBloc>().add(
                AdminToggleHomestayVisibility(h.id, !h.isVisible));
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    'Homestay ${h.isVisible ? 'paused' : 'activated'} successfully'),
                backgroundColor:
                h.isVisible ? Colors.orange[700] : Colors.green[600],
                behavior: SnackBarBehavior.floating));
            Navigator.pop(context);
          },
          child: Text(h.isVisible ? 'Pause' : 'Activate',
              style: GoogleFonts.dmSans(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    ));
  }

  void showDeleteDialog(bool wide) {
    final h = widget.homestay;
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(sr(20, wide))),
      title: Row(children: [
        Icon(Icons.warning_amber_rounded,
            color: Colors.redAccent, size: fs(28, wide)),
        SizedBox(width: sw(10, wide)),
        Expanded(child: Text('Delete Homestay?',
            style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold,
                fontSize: fs(18, wide),
                color: ink))),
      ]),
      content: Text(
          'Are you sure you want to permanently delete "${h.name}"? This action cannot be undone.',
          style: GoogleFonts.dmSans(
              fontSize: fs(14, wide), color: Colors.grey[700], height: 1.5)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Cancel',
              style: GoogleFonts.dmSans(
                  color: Colors.grey[600], fontWeight: FontWeight.bold)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(sr(8, wide)))),
          onPressed: () {
            Navigator.pop(ctx);
            context.read<HomestayBloc>().add(AdminDeleteHomestay(h.id));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Homestay deleted successfully'),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating));
            Navigator.pop(context);
          },
          child: Text('Delete',
              style: GoogleFonts.dmSans(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    ));
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 46, height: 46,
      decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24)),
      child: Icon(icon, color: Colors.white, size: 28),
    ),
  );
}

class _SideCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _SideCard(
      {required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade100),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4))
      ],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 18, color: ink),
        const SizedBox(width: 8),
        Text(title,
            style: GoogleFonts.playfairDisplay(
                fontSize: 18, fontWeight: FontWeight.bold, color: ink)),
      ]),
      const SizedBox(height: 14),
      child,
    ]),
  );
}

class StatCell extends StatelessWidget {
  final bool wide;
  final IconData icon;
  final String val, label;
  const StatCell(
      {super.key, required this.wide, required this.icon,
        required this.val, required this.label});

  @override
  Widget build(BuildContext context) => Column(children: [
    Icon(icon, size: fs(24, wide), color: accent),
    SizedBox(height: sh(4, wide)),
    Text(val,
        style: GoogleFonts.dmSans(
            fontSize: fs(16, wide),
            fontWeight: FontWeight.bold,
            color: ink)),
    Text(label,
        style: GoogleFonts.dmSans(
            fontSize: fs(12, wide), color: Colors.grey[500])),
  ]);
}

class SectionTitle extends StatelessWidget {
  final bool wide;
  final String text;
  const SectionTitle({super.key, required this.wide, required this.text});

  @override
  Widget build(BuildContext context) => Text(text,
      style: GoogleFonts.playfairDisplay(
          fontSize: fs(18, wide), fontWeight: FontWeight.bold, color: ink));
}