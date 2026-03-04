import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/services/image_proxy.dart';
import '../../../data/models/Site.dart';

class OwnerSiteDetailPage extends StatefulWidget {
  final CulturalSite site;
  const OwnerSiteDetailPage({super.key, required this.site});

  @override
  State<OwnerSiteDetailPage> createState() => _OwnerSiteDetailPageState();
}

class _OwnerSiteDetailPageState extends State<OwnerSiteDetailPage> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  static const _terracotta = Color(0xFFCD6E4E);
  static const _dark       = Color(0xFF2D1B10);
  static const _cream      = Color(0xFFFAF7F2);
  static const _warmGrey   = Color(0xFF8B8B8B);
  static const _teal       = Color(0xFF4A707A);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
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
    final site   = widget.site;
    final images = site.imageUrls.isNotEmpty ? site.imageUrls : <String>[];

    return Scaffold(
      backgroundColor: _cream,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [

              SliverToBoxAdapter(
                child: SizedBox(
                  height: 340.h,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      images.isEmpty
                          ? Container(color: Colors.grey[300],
                          child: Icon(Icons.image_not_supported, size: 60.sp, color: Colors.grey[400]))
                          : PageView.builder(
                        controller: _pageController,
                        itemCount: images.length,
                        onPageChanged: (i) => setState(() => _currentImageIndex = i),
                        itemBuilder: (_, i) => ProxyImage(
                          imageUrl: images[i],
                          width: double.infinity,
                          height: 340.h,
                          borderRadiusValue: 0,
                        ),
                      ),

                      Positioned.fill(
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
                                  style: GoogleFonts.dmSans(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w600)),
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
                          if (site.isUNESCO)
                            Container(
                              margin: EdgeInsets.only(bottom: 6.h),
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: _terracotta,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text('🏛 UNESCO World Heritage',
                                  style: GoogleFonts.dmSans(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                            ),
                          Text(site.name ?? '',
                              style: GoogleFonts.playfairDisplay(
                                  color: Colors.white, fontSize: 26.sp, fontWeight: FontWeight.bold,
                                  shadows: [const Shadow(blurRadius: 8, color: Colors.black45)])),
                          SizedBox(height: 4.h),
                          Row(children: [
                            Icon(Icons.location_on, color: Colors.white70, size: 13.sp),
                            SizedBox(width: 3.w),
                            Text(site.district ?? '', style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 13.sp)),
                            if ((site.category ?? '').isNotEmpty) ...[
                              Text('  ·  ', style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 13.sp)),
                              Text(site.category!, style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 13.sp)),
                            ],
                          ]),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: [
                        if ((site.openingTime ?? '').isNotEmpty || (site.closingTime ?? '').isNotEmpty)
                          _InfoChip(Icons.access_time_rounded, 'Hours', '${site.openingTime ?? '?'} – ${site.closingTime ?? '?'}'),
                        if (site.entryFeeNPR != null) ...[
                          SizedBox(width: 10.w),
                          _InfoChip(Icons.payments_outlined, 'Entry (NPR)', 'Rs. ${site.entryFeeNPR!.toStringAsFixed(0)}'),
                        ],
                        if ((site.bestTimeToVisit ?? '').isNotEmpty) ...[
                          SizedBox(width: 10.w),
                          _InfoChip(Icons.wb_sunny_outlined, 'Best Time', site.bestTimeToVisit!),
                        ],
                        if (site.entryFeeSAARC != null) ...[
                          SizedBox(width: 10.w),
                          _InfoChip(Icons.people_outline, 'SAARC', 'Rs. ${site.entryFeeSAARC!.toStringAsFixed(0)}'),
                        ],
                      ]),
                    ),
                    SizedBox(height: 24.h),

                    if ((site.shortDescription ?? '').isNotEmpty) ...[
                      Text(site.shortDescription!,
                          style: GoogleFonts.dmSans(fontSize: 15.sp, height: 1.65,
                              color: _dark.withValues(alpha: 0.85))),
                      SizedBox(height: 24.h),
                    ],

                    if ((site.historicalSignificance ?? '').isNotEmpty) ...[
                      _SectionHeader('Historical Significance', Icons.history_edu_outlined, _teal),
                      SizedBox(height: 10.h),
                      _ContentCard(child: Text(site.historicalSignificance!,
                          style: GoogleFonts.dmSans(fontSize: 14.sp, height: 1.65, color: _warmGrey))),
                      SizedBox(height: 20.h),
                    ],

                    if ((site.culturalImportance ?? '').isNotEmpty) ...[
                      _SectionHeader('Cultural Importance', Icons.temple_hindu_outlined, _terracotta),
                      SizedBox(height: 10.h),
                      _ContentCard(child: Text(site.culturalImportance!,
                          style: GoogleFonts.dmSans(fontSize: 14.sp, height: 1.65, color: _warmGrey))),
                      SizedBox(height: 20.h),
                    ],

                    if (images.length > 1) ...[
                      _SectionHeader('Photo Gallery', Icons.photo_library_outlined, _dark),
                      SizedBox(height: 12.h),
                      SizedBox(
                        height: 100.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: images.length,
                          separatorBuilder: (_, __) => SizedBox(width: 10.w),
                          itemBuilder: (_, i) {
                            final isActive = i == _currentImageIndex;
                            return GestureDetector(
                              onTap: () {
                                _pageController.animateToPage(i,
                                    duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                                setState(() => _currentImageIndex = i);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 100.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                      color: isActive ? _terracotta : Colors.transparent, width: 2.5),
                                  boxShadow: isActive
                                      ? [BoxShadow(color: _terracotta.withValues(alpha: 0.3), blurRadius: 6)]
                                      : null,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: ProxyImage(imageUrl: images[i], width: 100.w, height: 100.h,
                                      borderRadiusValue: 0, thumb: true),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],

                    _SectionHeader('Site Details', Icons.info_outline_rounded, _dark),
                    SizedBox(height: 10.h),
                    _ContentCard(
                      child: Column(children: [
                        _DetailRow(Icons.calendar_today_outlined, 'Added On',     _formatDate(site.createdAt)),
                        Divider(height: 20.h, color: Colors.grey.shade100),
                        _DetailRow(Icons.update_rounded,          'Last Updated', _formatDate(site.updatedAt)),
                        if (site.address != null) ...[
                          Divider(height: 20.h, color: Colors.grey.shade100),
                          _DetailRow(Icons.map_outlined, 'Address', site.address!),
                        ],
                      ]),
                    ),
                    SizedBox(height: 32.h),
                  ]),
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
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(Icons.arrow_back, size: 20.sp, color: _dark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const _SectionHeader(this.title, this.icon, this.color);

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 18.sp, color: color),
    SizedBox(width: 8.w),
    Text(title, style: GoogleFonts.playfairDisplay(
        fontSize: 17.sp, fontWeight: FontWeight.bold, color: const Color(0xFF2D1B10))),
  ]);
}

class _ContentCard extends StatelessWidget {
  final Widget child;
  const _ContentCard({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: Colors.grey.shade100),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: child,
  );
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoChip(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 13.sp, color: const Color(0xFFCD6E4E)),
        SizedBox(width: 5.w),
        Text(label, style: GoogleFonts.dmSans(fontSize: 11.sp, color: Colors.grey[500])),
      ]),
      SizedBox(height: 4.h),
      Text(value, style: GoogleFonts.dmSans(fontSize: 13.sp, fontWeight: FontWeight.bold, color: const Color(0xFF2D1B10))),
    ]),
  );
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _DetailRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, size: 15.sp, color: Colors.grey[400]),
    SizedBox(width: 10.w),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.dmSans(fontSize: 11.sp, color: Colors.grey[500])),
      SizedBox(height: 2.h),
      Text(value, style: GoogleFonts.dmSans(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xFF2D1B10))),
    ])),
  ]);
}