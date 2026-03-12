import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/services/image_proxy.dart';
import '../../../data/models/Site.dart';

double sdFs(double v, bool wide) => wide ? v : v.sp;
double sdW(double v, bool wide)  => wide ? v : v.w;
double sdH(double v, bool wide)  => wide ? v : v.h;
double sdR(double v, bool wide)  => wide ? v : v.r;

class OwnerSiteDetailPage extends StatefulWidget {
  final CulturalSite site;
  const OwnerSiteDetailPage({super.key, required this.site});

  @override
  State<OwnerSiteDetailPage> createState() => OwnerSiteDetailPageState();
}

class OwnerSiteDetailPageState extends State<OwnerSiteDetailPage> {
  int currentImageIndex = 0;
  final pageController  = PageController();

  static const terracotta = Color(0xFFCD6E4E);
  static const dark       = Color(0xFF2D1B10);
  static const cream      = Color(0xFFFAF7F2);
  static const warmGrey   = Color(0xFF8B8B8B);
  static const teal       = Color(0xFF4A707A);

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void prevImage(List<String> images) {
    if (currentImageIndex > 0) {
      pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void nextImage(List<String> images) {
    if (currentImageIndex < images.length - 1) {
      pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return '—';
    final dt = date.toLocal();
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final h    = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final min  = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} · $h:$min $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final wide   = MediaQuery.of(context).size.width > 700;
    final site   = widget.site;
    final images = site.imageUrls.isNotEmpty ? site.imageUrls : <String>[];

    if (wide) return buildWebLayout(context, site, images);
    return buildMobileLayout(context, site, images);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WEB LAYOUT
  // ═══════════════════════════════════════════════════════════════════════════
  Widget buildWebLayout(BuildContext context, CulturalSite site, List<String> images) {
    return Scaffold(
      backgroundColor: cream,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Full-width hero ──────────────────────────────────────────────
            webHero(context, site, images),

            // ── Main body: full width two-column ────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: main content
                  Expanded(
                    flex: 5,
                    child: webLeftColumn(site, images),
                  ),
                  const SizedBox(width: 40),
                  // Right: sidebar
                  SizedBox(
                    width: 320,
                    child: webRightSidebar(site, images),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget webHero(BuildContext context, CulturalSite site, List<String> images) {
    const heroH = 580.0;
    return SizedBox(
      height: heroH,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Dark bg for contain mode
          Container(color: const Color(0xFF111111)),

          // PageView — physics adjusted for web mouse drag
          images.isEmpty
              ? Container(
              color: Colors.grey[300],
              child: const Icon(Icons.image_not_supported,
                  size: 60, color: Colors.grey))
              : PageView.builder(
            controller: pageController,
            itemCount: images.length,
            physics: const ClampingScrollPhysics(),
            onPageChanged: (i) => setState(() => currentImageIndex = i),
            itemBuilder: (_, i) => ProxyImage(
              imageUrl: images[i],
              width: double.infinity,
              height: heroH,
              borderRadiusValue: 0,
              thumb: false,
              fit: BoxFit.contain,
            ),
          ),

          // Gradient — only bottom portion for title
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
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    stops: const [0, 0.5, 1],
                  ),
                ),
              ),
            ),
          ),

          // Left arrow
          if (images.length > 1)
            Positioned(
              left: 20, top: 0, bottom: 0,
              child: Center(
                child: _NavArrow(
                  icon: Icons.chevron_left_rounded,
                  onTap: () => prevImage(images),
                  enabled: currentImageIndex > 0,
                ),
              ),
            ),

          // Right arrow
          if (images.length > 1)
            Positioned(
              right: 20, top: 0, bottom: 0,
              child: Center(
                child: _NavArrow(
                  icon: Icons.chevron_right_rounded,
                  onTap: () => nextImage(images),
                  enabled: currentImageIndex < images.length - 1,
                ),
              ),
            ),

          // UNESCO badge
          if (site.isUNESCO)
            Positioned(
              top: 24, left: 72,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: terracotta,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text('🏛 ', style: TextStyle(fontSize: 13)),
                  Text('UNESCO World Heritage',
                      style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ]),
              ),
            ),

          // Counter top right
          if (images.length > 1)
            Positioned(
              top: 24, right: 72,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.photo_library_outlined,
                      size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                  Text('${currentImageIndex + 1} / ${images.length}',
                      style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ]),
              ),
            ),

          // Dot indicators
          if (images.length > 1)
            Positioned(
              bottom: 90, left: 0, right: 0,
              child: IgnorePointer(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (i) =>
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        height: 6, width: currentImageIndex == i ? 22 : 6,
                        decoration: BoxDecoration(
                          color: currentImageIndex == i
                              ? Colors.white : Colors.white54,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                  ),
                ),
              ),
            ),

          // Title block bottom left
          Positioned(
            bottom: 32, left: 56, right: 160,
            child: IgnorePointer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(site.name ?? '',
                      style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          shadows: const [
                            Shadow(blurRadius: 12, color: Colors.black54)
                          ])),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.location_on, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(site.district ?? '',
                        style: GoogleFonts.dmSans(
                            color: Colors.white70, fontSize: 16)),
                    if ((site.category ?? '').isNotEmpty) ...[
                      Text('  ·  ',
                          style: GoogleFonts.dmSans(
                              color: Colors.white38, fontSize: 16)),
                      Text(site.category!,
                          style: GoogleFonts.dmSans(
                              color: Colors.white70, fontSize: 16)),
                    ],
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
                width: 40, height: 40,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, size: 20, color: dark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget webLeftColumn(CulturalSite site, List<String> images) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info chips full row
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            if ((site.openingTime ?? '').isNotEmpty ||
                (site.closingTime ?? '').isNotEmpty)
              SiteInfoChip(Icons.access_time_rounded, 'Hours',
                  '${site.openingTime ?? '?'} – ${site.closingTime ?? '?'}', true),
            if (site.entryFeeNPR != null)
              SiteInfoChip(Icons.payments_outlined, 'Entry (NPR)',
                  'Rs. ${site.entryFeeNPR!.toStringAsFixed(0)}', true),
            if ((site.bestTimeToVisit ?? '').isNotEmpty)
              SiteInfoChip(Icons.wb_sunny_outlined, 'Best Time',
                  site.bestTimeToVisit!, true),
            if (site.entryFeeSAARC != null)
              SiteInfoChip(Icons.people_outline, 'SAARC',
                  'Rs. ${site.entryFeeSAARC!.toStringAsFixed(0)}', true),
          ],
        ),
        const SizedBox(height: 36),

        if ((site.shortDescription ?? '').isNotEmpty) ...[
          Text(site.shortDescription!,
              style: GoogleFonts.dmSans(
                  fontSize: 16, height: 1.8,
                  color: dark.withValues(alpha: 0.85))),
          const SizedBox(height: 36),
        ],

        if ((site.historicalSignificance ?? '').isNotEmpty) ...[
          SiteSecHeader('Historical Significance',
              Icons.history_edu_outlined, teal, true),
          const SizedBox(height: 14),
          SiteContentCard(
            wide: true,
            child: Text(site.historicalSignificance!,
                style: GoogleFonts.dmSans(
                    fontSize: 15, height: 1.75, color: warmGrey)),
          ),
          const SizedBox(height: 32),
        ],

        if ((site.culturalImportance ?? '').isNotEmpty) ...[
          SiteSecHeader('Cultural Importance',
              Icons.temple_hindu_outlined, terracotta, true),
          const SizedBox(height: 14),
          SiteContentCard(
            wide: true,
            child: Text(site.culturalImportance!,
                style: GoogleFonts.dmSans(
                    fontSize: 15, height: 1.75, color: warmGrey)),
          ),
          const SizedBox(height: 32),
        ],

        // Gallery full width in left column if multiple images
        if (images.length > 1) ...[
          SiteSecHeader('Photo Gallery',
              Icons.photo_library_outlined, dark, true),
          const SizedBox(height: 16),
          webGalleryGrid(images),
          const SizedBox(height: 32),
        ],
      ],
    );
  }

  Widget webGalleryGrid(List<String> images) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: images.length,
      itemBuilder: (_, i) {
        final isActive = i == currentImageIndex;
        return GestureDetector(
          onTap: () {
            pageController.animateToPage(i,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut);
            setState(() => currentImageIndex = i);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: isActive ? terracotta : Colors.transparent,
                  width: 3),
              boxShadow: isActive
                  ? [BoxShadow(
                  color: terracotta.withValues(alpha: 0.35),
                  blurRadius: 8)]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ProxyImage(
                imageUrl: images[i],
                width: 200,
                height: 200,
                borderRadiusValue: 0,
                thumb: true,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget webRightSidebar(CulturalSite site, List<String> images) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Site details card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.info_outline_rounded,
                    size: 18, color: dark),
                const SizedBox(width: 8),
                Text('Site Details',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: dark)),
              ]),
              const SizedBox(height: 20),
              _SidebarDetailRow(Icons.calendar_today_outlined,
                  'Added On', formatDate(site.createdAt)),
              const Divider(height: 24, color: Color(0xFFF0F0F0)),
              _SidebarDetailRow(Icons.update_rounded,
                  'Last Updated', formatDate(site.updatedAt)),
              if (site.address != null) ...[
                const Divider(height: 24, color: Color(0xFFF0F0F0)),
                _SidebarDetailRow(
                    Icons.map_outlined, 'Address', site.address!),
              ],
              if (site.isUNESCO) ...[
                const Divider(height: 24, color: Color(0xFFF0F0F0)),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: terracotta.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: terracotta.withValues(alpha: 0.2)),
                  ),
                  child: Row(children: [
                    const Text('🏛', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('UNESCO World Heritage Site',
                          style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: terracotta)),
                    ),
                  ]),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Quick stats card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.receipt_long_outlined,
                    size: 18, color: dark),
                const SizedBox(width: 8),
                Text('Visitor Info',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: dark)),
              ]),
              const SizedBox(height: 20),
              if (site.entryFeeNPR != null) ...[
                _SidebarDetailRow(Icons.payments_outlined, 'Entry Fee (NPR)',
                    'Rs. ${site.entryFeeNPR!.toStringAsFixed(0)}'),
                const Divider(height: 24, color: Color(0xFFF0F0F0)),
              ],
              if (site.entryFeeSAARC != null) ...[
                _SidebarDetailRow(Icons.people_outline, 'SAARC Fee',
                    'Rs. ${site.entryFeeSAARC!.toStringAsFixed(0)}'),
                const Divider(height: 24, color: Color(0xFFF0F0F0)),
              ],
              if ((site.openingTime ?? '').isNotEmpty ||
                  (site.closingTime ?? '').isNotEmpty)
                _SidebarDetailRow(Icons.access_time_rounded, 'Hours',
                    '${site.openingTime ?? '?'} – ${site.closingTime ?? '?'}'),
              if ((site.bestTimeToVisit ?? '').isNotEmpty) ...[
                const Divider(height: 24, color: Color(0xFFF0F0F0)),
                _SidebarDetailRow(Icons.wb_sunny_outlined,
                    'Best Time', site.bestTimeToVisit!),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MOBILE LAYOUT — unchanged
  // ═══════════════════════════════════════════════════════════════════════════
  Widget buildMobileLayout(BuildContext context, CulturalSite site, List<String> images) {
    final double headerHeight = 340.h;

    return Scaffold(
      backgroundColor: cream,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: headerHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(color: const Color(0xFF111111)),
                      images.isEmpty
                          ? Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.image_not_supported,
                              size: 60.sp, color: Colors.grey[400]))
                          : PageView.builder(
                        controller: pageController,
                        itemCount: images.length,
                        physics: const ClampingScrollPhysics(),
                        onPageChanged: (i) =>
                            setState(() => currentImageIndex = i),
                        itemBuilder: (_, i) => ProxyImage(
                          imageUrl: images[i],
                          width: double.infinity,
                          height: headerHeight,
                          borderRadiusValue: 0,
                          thumb: false,
                          fit: BoxFit.cover,
                        ),
                      ),

                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.35),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.75),
                                ],
                                stops: const [0, 0.4, 1],
                              ),
                            ),
                          ),
                        ),
                      ),

                      if (site.isUNESCO)
                        Positioned(
                          top: 52.h, left: 16.w,
                          child: IgnorePointer(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 5.h),
                              decoration: BoxDecoration(
                                color: terracotta,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                const Text('🏛 ', style: TextStyle(fontSize: 13)),
                                Text('UNESCO World Heritage',
                                    style: GoogleFonts.dmSans(
                                        color: Colors.white,
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.bold)),
                              ]),
                            ),
                          ),
                        ),

                      if (images.length > 1)
                        Positioned(
                          top: 52.h, right: 16.w,
                          child: IgnorePointer(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.photo_library_outlined,
                                    size: 12.sp, color: Colors.white),
                                SizedBox(width: 4.w),
                                Text('${currentImageIndex + 1}/${images.length}',
                                    style: GoogleFonts.dmSans(
                                        color: Colors.white,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600)),
                              ]),
                            ),
                          ),
                        ),

                      if (images.length > 1)
                        Positioned(
                          bottom: 80.h, left: 0, right: 0,
                          child: IgnorePointer(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(images.length, (i) =>
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                                    height: 6.h,
                                    width: currentImageIndex == i ? 20.w : 6.w,
                                    decoration: BoxDecoration(
                                      color: currentImageIndex == i
                                          ? Colors.white : Colors.white54,
                                      borderRadius: BorderRadius.circular(3.r),
                                    ),
                                  ),
                              ),
                            ),
                          ),
                        ),

                      Positioned(
                        bottom: 20.h, left: 20.w, right: 20.w,
                        child: IgnorePointer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(site.name ?? '',
                                  style: GoogleFonts.playfairDisplay(
                                      color: Colors.white,
                                      fontSize: 28.sp,
                                      fontWeight: FontWeight.bold,
                                      shadows: const [
                                        Shadow(blurRadius: 8, color: Colors.black45)
                                      ])),
                              SizedBox(height: 4.h),
                              Row(children: [
                                Icon(Icons.location_on,
                                    color: Colors.white70, size: 14.sp),
                                SizedBox(width: 4.w),
                                Text(site.district ?? '',
                                    style: GoogleFonts.dmSans(
                                        color: Colors.white70, fontSize: 14.sp)),
                                if ((site.category ?? '').isNotEmpty) ...[
                                  Text('  ·  ',
                                      style: GoogleFonts.dmSans(
                                          color: Colors.white38, fontSize: 14.sp)),
                                  Text(site.category!,
                                      style: GoogleFonts.dmSans(
                                          color: Colors.white70, fontSize: 14.sp)),
                                ],
                              ]),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                  child: narrowBody(site, images),
                ),
              ),
            ],
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 8.h,
            left: 8.w,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38.w, height: 38.h,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: Icon(Icons.arrow_back, size: 20.sp, color: dark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget narrowBody(CulturalSite site, List<String> images) {
    const wide = false;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          if ((site.openingTime ?? '').isNotEmpty ||
              (site.closingTime ?? '').isNotEmpty)
            SiteInfoChip(Icons.access_time_rounded, 'Hours',
                '${site.openingTime ?? '?'} – ${site.closingTime ?? '?'}', wide),
          if (site.entryFeeNPR != null) ...[
            SizedBox(width: 10.w),
            SiteInfoChip(Icons.payments_outlined, 'Entry (NPR)',
                'Rs. ${site.entryFeeNPR!.toStringAsFixed(0)}', wide),
          ],
          if ((site.bestTimeToVisit ?? '').isNotEmpty) ...[
            SizedBox(width: 10.w),
            SiteInfoChip(Icons.wb_sunny_outlined, 'Best Time',
                site.bestTimeToVisit!, wide),
          ],
          if (site.entryFeeSAARC != null) ...[
            SizedBox(width: 10.w),
            SiteInfoChip(Icons.people_outline, 'SAARC',
                'Rs. ${site.entryFeeSAARC!.toStringAsFixed(0)}', wide),
          ],
        ]),
      ),
      SizedBox(height: 24.h),
      if ((site.shortDescription ?? '').isNotEmpty) ...[
        Text(site.shortDescription!,
            style: GoogleFonts.dmSans(
                fontSize: 15.sp, height: 1.65,
                color: dark.withValues(alpha: 0.85))),
        SizedBox(height: 24.h),
      ],
      if ((site.historicalSignificance ?? '').isNotEmpty) ...[
        SiteSecHeader('Historical Significance',
            Icons.history_edu_outlined, teal, wide),
        SizedBox(height: 10.h),
        SiteContentCard(
            child: Text(site.historicalSignificance!,
                style: GoogleFonts.dmSans(
                    fontSize: 14.sp, height: 1.65, color: warmGrey)),
            wide: wide),
        SizedBox(height: 20.h),
      ],
      if ((site.culturalImportance ?? '').isNotEmpty) ...[
        SiteSecHeader('Cultural Importance',
            Icons.temple_hindu_outlined, terracotta, wide),
        SizedBox(height: 10.h),
        SiteContentCard(
            child: Text(site.culturalImportance!,
                style: GoogleFonts.dmSans(
                    fontSize: 14.sp, height: 1.65, color: warmGrey)),
            wide: wide),
        SizedBox(height: 20.h),
      ],
      if (images.length > 1) ...[
        SiteSecHeader('Photo Gallery',
            Icons.photo_library_outlined, dark, wide),
        SizedBox(height: 12.h),
        SizedBox(
          height: 100.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            separatorBuilder: (_, __) => SizedBox(width: 10.w),
            itemBuilder: (_, i) {
              final isActive = i == currentImageIndex;
              return GestureDetector(
                onTap: () {
                  pageController.animateToPage(i,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut);
                  setState(() => currentImageIndex = i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 100.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                        color: isActive ? terracotta : Colors.transparent,
                        width: 2.5),
                    boxShadow: isActive
                        ? [BoxShadow(
                        color: terracotta.withValues(alpha: 0.3),
                        blurRadius: 6)]
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: ProxyImage(
                      imageUrl: images[i],
                      width: 100.w,
                      height: 100.h,
                      borderRadiusValue: 0,
                      thumb: true,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 20.h),
      ],
      SiteSecHeader('Site Details', Icons.info_outline_rounded, dark, wide),
      SizedBox(height: 10.h),
      SiteContentCard(
        child: Column(children: [
          SiteDetailRow(Icons.calendar_today_outlined, 'Added On',
              formatDate(site.createdAt), wide),
          Divider(height: 20.h, color: Colors.grey.shade100),
          SiteDetailRow(Icons.update_rounded, 'Last Updated',
              formatDate(site.updatedAt), wide),
          if (site.address != null) ...[
            Divider(height: 20.h, color: Colors.grey.shade100),
            SiteDetailRow(Icons.map_outlined, 'Address', site.address!, wide),
          ],
        ]),
        wide: wide,
      ),
      SizedBox(height: 32.h),
    ]);
  }
}

// ── Nav arrow button (web only) ─────────────────────────────────────────────
class _NavArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  const _NavArrow({required this.icon, required this.onTap, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.3,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24),
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

class _SidebarDetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _SidebarDetailRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: GoogleFonts.dmSans(fontSize: 11, color: Colors.grey[500])),
            const SizedBox(height: 3),
            Text(value,
                style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D1B10))),
          ]),
        ),
      ]);
}

// ── Shared helpers ──────────────────────────────────────────────────────────

class SiteSecHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool wide;
  const SiteSecHeader(this.title, this.icon, this.color, this.wide);

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: sdFs(18, wide), color: color),
    SizedBox(width: sdW(8, wide)),
    Text(title,
        style: GoogleFonts.playfairDisplay(
            fontSize: sdFs(17, wide),
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D1B10))),
  ]);
}

class SiteContentCard extends StatelessWidget {
  final Widget child;
  final bool wide;
  const SiteContentCard({required this.child, required this.wide});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(sdW(16, wide)),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(sdR(14, wide)),
      border: Border.all(color: Colors.grey.shade100),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2))
      ],
    ),
    child: child,
  );
}

class SiteInfoChip extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final bool wide;
  const SiteInfoChip(this.icon, this.label, this.value, this.wide);

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
        horizontal: sdW(14, wide), vertical: sdH(10, wide)),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(sdR(12, wide)),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2))
      ],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: sdFs(13, wide), color: const Color(0xFFCD6E4E)),
        SizedBox(width: sdW(5, wide)),
        Text(label,
            style: GoogleFonts.dmSans(
                fontSize: sdFs(11, wide), color: Colors.grey[500])),
      ]),
      SizedBox(height: sdH(4, wide)),
      Text(value,
          style: GoogleFonts.dmSans(
              fontSize: sdFs(13, wide),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D1B10))),
    ]),
  );
}

class SiteDetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final bool wide;
  const SiteDetailRow(this.icon, this.label, this.value, this.wide, {super.key});

  @override
  Widget build(BuildContext context) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: sdFs(15, wide), color: Colors.grey[400]),
        SizedBox(width: sdW(10, wide)),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: GoogleFonts.dmSans(
                    fontSize: sdFs(11, wide), color: Colors.grey[500])),
            SizedBox(height: sdH(2, wide)),
            Text(value,
                style: GoogleFonts.dmSans(
                    fontSize: sdFs(13, wide),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D1B10))),
          ]),
        ),
      ]);
}