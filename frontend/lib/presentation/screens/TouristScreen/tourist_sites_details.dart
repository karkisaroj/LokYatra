import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/services/image_proxy.dart';
import 'package:lokyatra_frontend/data/models/story.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/site.dart';
import '../../widgets/Helpers/site_fav_button.dart';
import '../../state_management/Bloc/review/review_bloc.dart';
import '../../state_management/Bloc/review/review_event.dart';
import '../../state_management/Bloc/review/review_state.dart';
import '../../state_management/Bloc/stories/story_bloc.dart';
import '../../state_management/Bloc/stories/story_event.dart';
import '../../state_management/Bloc/stories/story_state.dart';
import '../../state_management/Bloc/homestays/homestay_bloc.dart';
import '../../state_management/Bloc/homestays/homestay_event.dart';
import '../../state_management/Bloc/homestays/homestay_state.dart';
import '../../widgets/Helpers/review_section.dart';
import 'tourist_homestay_detail_page.dart';
import 'story_detail_page.dart';

class TouristSiteDetailPage extends StatefulWidget {
  final CulturalSite site;
  const TouristSiteDetailPage({super.key, required this.site});

  @override
  State<TouristSiteDetailPage> createState() => _TouristSiteDetailPageState();
}

class _TouristSiteDetailPageState extends State<TouristSiteDetailPage> {
  static const _terracotta = Color(0xFFCD6E4E);
  static const _darkTeal   = Color(0xFF2D6A6A);
  static const _dark       = Color(0xFF2D1B10);
  static const _cream      = Color(0xFFFAF7F2);

  int _currentImageIndex = 0;
  int _selectedTabIndex  = 0;
  final PageController _pageController = PageController();
  final List<String> _tabs = ['About', 'History', 'Stories', 'Reviews'];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final site     = widget.site;
    final width    = MediaQuery.of(context).size.width;
    final isWide   = width >= 1024;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => StoryBloc()..add(LoadStories(siteId: site.id))),
        BlocProvider(create: (_) => HomestayBloc()..add(TouristLoadHomestaysNearSite(site.name ?? ''))),
        BlocProvider(create: (_) => ReviewBloc()..add(LoadSiteReviews(site.id))),
      ],
      child: Scaffold(
        backgroundColor: _cream,
        extendBodyBehindAppBar: !isWide,
        appBar: isWide ? _buildWebAppBar() : null,
        body: isWide ? _buildWebLayout() : _buildMobileLayout(),
      ),
    );
  }

  PreferredSizeWidget _buildWebAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: Row(
        children: [
          Image.asset('assets/images/lokyatra_logo.png', height: 40),
          SizedBox(width: 12),
          Text(
            'LokYatra',
            style: GoogleFonts.playfairDisplay(
                color: _dark, fontWeight: FontWeight.bold, fontSize: 22),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('EXPLORE SITES',
                style: GoogleFonts.dmSans(
                    color: _terracotta,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2))),
        SizedBox(width: 24),
      ],
    );
  }
  Widget _buildMobileLayout() {
    final site = widget.site;
    final name = site.name ?? 'Detail';
    final address = site.address ?? '';
    final district = site.district ?? '';
    final isUNESCO = site.isUNESCO;
    final imageUrls = site.imageUrls;
    final opening = site.openingTime ?? 'N/A';
    final closing = site.closingTime ?? 'N/A';

    return RefreshIndicator(
      color: _terracotta,
      onRefresh: () async {
        final id = widget.site.id;
        context.read<StoryBloc>().add(LoadStories(siteId: id));
        context.read<ReviewBloc>().add(LoadSiteReviews(id));
        context.read<HomestayBloc>().add(TouristLoadHomestaysNearSite(widget.site.name ?? ''));
      },
      child: Stack(
        children: [
          CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
                    height: 380.h,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        imageUrls.isEmpty
                            ? Container(
                            color: Colors.grey[300],
                            child: Icon(Icons.temple_hindu,
                                size: 60.sp, color: Colors.grey[400]))
                            : PageView.builder(
                          controller: _pageController,
                          itemCount: imageUrls.length,
                          onPageChanged: (i) =>
                              setState(() => _currentImageIndex = i),
                          itemBuilder: (_, i) => ProxyImage(
                            imageUrl: imageUrls[i],
                            width: double.infinity,
                            height: 380.h,
                            borderRadiusValue: 0,
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
                                    Colors.black.withValues(alpha: 0.3),
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.75),
                                  ],
                                  stops: const [0, 0.35, 1],
                                ),
                              ),
                            ),
                          ),
                        ),

                        if (imageUrls.length > 1)
                          Positioned(
                            top: 52.h, right: 16.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.photo_library_outlined,
                                        size: 12.sp, color: Colors.white),
                                    SizedBox(width: 4.w),
                                    Text(
                                        '${_currentImageIndex + 1}/${imageUrls.length}',
                                        style: GoogleFonts.dmSans(
                                            color: Colors.white,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600)),
                                  ]),
                            ),
                          ),

                        if (imageUrls.length > 1)
                          Positioned(
                            bottom: 72.h, left: 0, right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                  imageUrls.length,
                                      (i) => AnimatedContainer(
                                    duration:
                                    const Duration(milliseconds: 250),
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 3.w),
                                    height: 6.h,
                                    width: _currentImageIndex == i
                                        ? 20.w
                                        : 6.w,
                                    decoration: BoxDecoration(
                                      color: _currentImageIndex == i
                                          ? Colors.white
                                          : Colors.white54,
                                      borderRadius:
                                      BorderRadius.circular(3.r),
                                    ),
                                  )),
                            ),
                          ),

                        Positioned(
                          bottom: 20.h, left: 20.w, right: 20.w,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isUNESCO)
                                  Container(
                                    margin: EdgeInsets.only(bottom: 6.h),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                        color: _darkTeal,
                                        borderRadius:
                                        BorderRadius.circular(4.r)),
                                    child: Text('UNESCO World Heritage',
                                        style: GoogleFonts.dmSans(
                                            color: Colors.white,
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                Text(name,
                                    style: GoogleFonts.playfairDisplay(
                                        color: Colors.white,
                                        fontSize: 26.sp,
                                        fontWeight: FontWeight.bold,
                                        shadows: const [
                                          Shadow(
                                              blurRadius: 8,
                                              color: Colors.black45)
                                        ])),
                                SizedBox(height: 4.h),
                                Row(children: [
                                  Icon(Icons.location_on_outlined,
                                      color: Colors.white70, size: 13.sp),
                                  SizedBox(width: 3.w),
                                  Flexible(
                                    child: Text(
                                        '$address${district.isNotEmpty ? ", $district" : ""}',
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.dmSans(
                                            color: Colors.white70,
                                            fontSize: 13.sp)),
                                  ),
                                ]),
                              ]),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.w, vertical: 20.h),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Info card — rating from ReviewBloc
                          BlocBuilder<ReviewBloc, ReviewState>(
                            builder: (context, reviewState) {
                              final avg = reviewState is ReviewsLoaded
                                  ? reviewState.averageRating
                                  : 0.0;
                              final count = reviewState is ReviewsLoaded
                                  ? reviewState.reviewCount
                                  : 0;

                              return Container(
                                padding: EdgeInsets.all(18.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                  BorderRadius.circular(20.r),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.04),
                                        blurRadius: 15,
                                        offset: const Offset(0, 6))
                                  ],
                                ),
                                child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        if (count > 0) ...[
                                          Icon(Icons.star_rounded,
                                              color:
                                              const Color(0xFFC7A26B),
                                              size: 18.sp),
                                          SizedBox(width: 4.w),
                                          Text(avg.toStringAsFixed(1),
                                              style: GoogleFonts.dmSans(
                                                  fontSize: 14.sp,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  color: _dark)),
                                          Text(' ($count reviews)',
                                              style: GoogleFonts.dmSans(
                                                  fontSize: 13.sp,
                                                  color: Colors.grey[500])),
                                        ] else
                                          Text('No reviews yet',
                                              style: GoogleFonts.dmSans(
                                                  fontSize: 13.sp,
                                                  color: Colors.grey[500])),
                                        const Spacer(),
                                        if (isUNESCO)
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10.w,
                                                vertical: 4.h),
                                            decoration: BoxDecoration(
                                                color: _darkTeal,
                                                borderRadius:
                                                BorderRadius.circular(
                                                    20.r)),
                                            child: Text('UNESCO',
                                                style: GoogleFonts.dmSans(
                                                    fontSize: 10.sp,
                                                    color: Colors.white,
                                                    fontWeight:
                                                    FontWeight.bold)),
                                          ),
                                        SizedBox(width: 12.w),
                                        SiteFavButton(
                                          siteId: site.id,
                                          size: 24,
                                        ),
                                      ]),
                                      SizedBox(height: 14.h),
                                      if (opening.isNotEmpty ||
                                          closing.isNotEmpty)
                                        _InfoRow(
                                            Icons.access_time_rounded,
                                            opening.isNotEmpty &&
                                                closing.isNotEmpty
                                                ? '$opening – $closing'
                                                : opening.isNotEmpty
                                                ? opening
                                                : closing),
                                      if (address.isNotEmpty) ...[
                                        SizedBox(height: 8.h),
                                        _InfoRow(
                                            Icons.location_on_outlined,
                                            '$address${district.isNotEmpty ? ", $district" : ""}'),
                                      ],
                                      SizedBox(height: 16.h),
                                      Divider(color: Colors.grey[100]),
                                      SizedBox(height: 14.h),
                                      Row(children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text('Entry Fee',
                                                  style: GoogleFonts.dmSans(
                                                      fontSize: 12.sp,
                                                      color:
                                                      Colors.grey[500])),
                                              SizedBox(height: 2.h),
                                              Text(
                                                (site.entryFeeNPR != null &&
                                                    site.entryFeeNPR! > 0)
                                                    ? 'NRP ${site.entryFeeNPR!.toStringAsFixed(0)} \nSAARC ${site.entryFeeSAARC!.toStringAsFixed(0)}'
                                                    : 'Free Entry',
                                                style: GoogleFonts.dmSans(
                                                  fontSize: 20.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: _terracotta,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 12.w),
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            final parts = [
                                              if (name.isNotEmpty) name,
                                              if (address.isNotEmpty)
                                                address,
                                              if (district.isNotEmpty)
                                                district,
                                              'Nepal',
                                            ];
                                            final query =
                                            Uri.encodeComponent(
                                                parts.join(', '));
                                            final mapsUrl = Uri.parse(
                                                'https://www.google.com/maps/search/?api=1&query=$query');

                                            if (kIsWeb) {
                                              try {
                                                await launchUrl(mapsUrl,
                                                    mode: LaunchMode
                                                        .platformDefault);
                                              } catch (_) {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(
                                                      context)
                                                      .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          'Could not open Maps.')));
                                                }
                                              }
                                              return;
                                            }

                                            final geoUri = Uri.parse(
                                                'geo:0,0?q=$query');
                                            try {
                                              await launchUrl(geoUri,
                                                  mode: LaunchMode
                                                      .externalApplication);
                                            } catch (_) {
                                              try {
                                                await launchUrl(mapsUrl,
                                                    mode: LaunchMode
                                                        .externalApplication);
                                              } catch (_) {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(
                                                      context)
                                                      .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          'Could not open Maps.')));
                                                }
                                              }
                                            }
                                          },
                                          icon: Icon(Icons.map_outlined,
                                              size: 16.sp),
                                          label: Text('Map',
                                              style: GoogleFonts.dmSans(
                                                  fontSize: 13.sp,
                                                  fontWeight:
                                                  FontWeight.bold)),
                                          style:
                                          ElevatedButton.styleFrom(
                                            backgroundColor: _darkTeal,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    10.r)),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16.w,
                                                vertical: 10.h),
                                          ),
                                        ),
                                      ]),
                                    ]),
                              );
                            },
                          ),

                          SizedBox(height: 24.h),

                          Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFE8DB),
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                            child: Row(
                              children: List.generate(_tabs.length, (i) {
                                final isSelected = _selectedTabIndex == i;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(
                                            () => _selectedTabIndex = i),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                          milliseconds: 200),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 9.h),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.transparent,
                                        borderRadius:
                                        BorderRadius.circular(20.r),
                                        boxShadow: isSelected
                                            ? [
                                          BoxShadow(
                                              color: Colors.black
                                                  .withValues(
                                                  alpha: 0.06),
                                              blurRadius: 4,
                                              offset:
                                              const Offset(0, 2))
                                        ]
                                            : [],
                                      ),
                                      child: Text(
                                        _tabs[i],
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12.sp,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? _dark
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),

                          SizedBox(height: 20.h),
                          _buildTabContent(),

                          SizedBox(height: 32.h),
                          Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Nearby Homestays',
                                    style: GoogleFonts.playfairDisplay(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                        color: _dark)),
                                Icon(Icons.hotel_outlined,
                                    color: Colors.grey[500], size: 20.sp),
                              ]),
                          SizedBox(height: 14.h),
                          _buildNearbyHomestays(),
                          SizedBox(height: 40.h),
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
                width: 38.w,
                height: 38.h,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: Icon(Icons.arrow_back, size: 20.sp, color: _dark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebLayout() {
    final site      = widget.site;
    final imageUrls = site.imageUrls;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBreadcrumbs(site.name ?? 'Detail'),
              const SizedBox(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Info & Tabs
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWebHeader(site),
                        const SizedBox(height: 48),
                        _buildWebTabs(),
                        const SizedBox(height: 24),
                        _buildTabContent(isWeb: true),
                      ],
                    ),
                  ),
                  const SizedBox(width: 80),
                  // Right: Gallery & Sidebar
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWebGallery(imageUrls),
                        const SizedBox(height: 40),
                        _buildWebEntryFee(site),
                        const SizedBox(height: 48),
                        const Text('Nearby Local Gems',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _dark)),
                        const SizedBox(height: 24),
                        _buildNearbyHomestays(),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreadcrumbs(String name) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text('All Sites', style: GoogleFonts.dmSans(color: Colors.grey[600])),
        ),
        Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
        Text(name, style: GoogleFonts.dmSans(color: _terracotta, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildWebHeader(CulturalSite site) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (site.isUNESCO)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFDE68A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('UNESCO WORLD HERITAGE SITE',
              style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.orange[900])),
          ),
        const SizedBox(height: 16),
        Text(site.name ?? 'Unnamed Site',
          style: GoogleFonts.playfairDisplay(fontSize: 48, fontWeight: FontWeight.w900, color: _dark)),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.location_on, color: _terracotta, size: 20),
            const SizedBox(width: 8),
            Text('${site.address ?? ""}, ${site.district ?? ""}',
              style: GoogleFonts.dmSans(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }

  Widget _buildWebTabs() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final isSelected = _selectedTabIndex == i;
          return Padding(
            padding: const EdgeInsets.only(right: 32),
            child: InkWell(
              onTap: () => setState(() => _selectedTabIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? _terracotta : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  _tabs[i].toUpperCase(),
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: isSelected ? _dark : Colors.grey[500],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWebGallery(List<String> imageUrls) {
    if (imageUrls.isEmpty) {
      return Container(
        height: 400,
        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(20)),
        child: const Center(child: Icon(Icons.image_not_supported, size: 48)),
      );
    }

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                height: 450,
                width: double.infinity,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: imageUrls.length,
                  onPageChanged: (i) => setState(() => _currentImageIndex = i),
                  itemBuilder: (_, i) => ProxyImage(
                    imageUrl: imageUrls[i],
                    width: double.infinity,
                    height: 450,
                    borderRadiusValue: 0,
                  ),
                ),
              ),
            ),
            if (imageUrls.length > 1) ...[
              Positioned(
                left: 16,
                child: _GalleryNavButton(
                  icon: Icons.chevron_left,
                  onPressed: () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                ),
              ),
              Positioned(
                right: 16,
                child: _GalleryNavButton(
                  icon: Icons.chevron_right,
                  onPressed: () => _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                ),
              ),
            ]
          ],
        ),
        if (imageUrls.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(imageUrls.length, (i) {
                return GestureDetector(
                  onTap: () => _pageController.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                  child: Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == i ? _terracotta : Colors.grey[300],
                    ),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildWebEntryFee(dynamic site) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payments_outlined, color: _terracotta, size: 24),
              const SizedBox(width: 12),
              Text('Entry Information', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.bold, color: _dark)),
            ],
          ),
          const SizedBox(height: 20),
          _WebInfoRow(Icons.schedule, 'Hours', '${site.openingTime ?? "N/A"} - ${site.closingTime ?? "N/A"}'),
          const Divider(height: 32),
          _WebInfoRow(Icons.local_activity_outlined, 'Indian Nationals', 'Rs. ${site.entryFeeNPR ?? 0}'),
          const SizedBox(height: 12),
          _WebInfoRow(Icons.public, 'Foreign Nationals', 'Rs. ${site.entryFeeSAARC ?? 0}'),
        ],
      ),
    );
  }

  Widget _buildTabContent({bool isWeb = false}) {
    switch (_selectedTabIndex) {
      case 0:
        return _TabText(
            widget.site.shortDescription ?? 'No description available.');
      case 1:
        return _TabText(widget.site.historicalSignificance ??
            'No historical context available.');
      case 2:
        return _buildStoriesTab();
      case 3:
        return BlocBuilder<ReviewBloc, ReviewState>(
          builder: (context, state) {
            if (state is ReviewLoading) {
              return const Center(
                  child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(
                          color: _terracotta)));
            }
            return ReviewsSection(
              siteId: widget.site.id,
              canReviewSite: true,
            );
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStoriesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (kIsWeb)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: IconButton(
                icon: Icon(Icons.refresh, color: _terracotta, size: 24.sp),
                onPressed: () => context.read<StoryBloc>().add(LoadStories(siteId: widget.site.id)),
              ),
            ),
          ),
        BlocBuilder<StoryBloc, StoryState>(
      builder: (context, state) {
        if (state is StoryLoading) {
          return const Center(
              child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: _terracotta)));
        }
        if (state is StoryError) {
          return Center(
              child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Text(state.message,
                      style: GoogleFonts.dmSans(color: Colors.red))));
        }
        if (state is StoriesLoaded) {
          if (state.stories.isEmpty) {
            return Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.grey.shade100)),
              child: Center(
                  child: Column(children: [
                    Icon(Icons.auto_stories_outlined,
                        size: 40.sp, color: Colors.grey[300]),
                    SizedBox(height: 12.h),
                    Text('No stories yet.',
                        style: GoogleFonts.dmSans(
                            color: Colors.grey[400], fontSize: 14.sp)),
                  ])),
            );
          }
          return Column(
              children: state.stories
                  .map((story) => _StoryCard(
                story: story,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            StoryDetailPage(story: story))),
              ))
                  .toList());
        }
        return const SizedBox.shrink();
      },
    ),
    ],
    );
  }

  Widget _buildNearbyHomestays() {
    return BlocBuilder<HomestayBloc, HomestayState>(
      builder: (context, state) {
        if (state is HomestayLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is TouristNearbyHomestaysLoaded) {
          if (state.homestays.isEmpty) {
            return Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: Colors.grey.shade100)),
              child: Center(
                  child: Text('No homestays found near this site.',
                      style: GoogleFonts.dmSans(
                          color: Colors.grey[400], fontSize: 13.sp))),
            );
          }
          return Column(
              children: state.homestays
                  .map((h) => _NearbyHomestayCard(
                homestay: h,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => TouristHomestayDetailPage(
                            homestay: h.toJson()))),
              ))
                  .toList());
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: kIsWeb ? 18 : 15.sp, color: Colors.grey[500]),
        SizedBox(width: kIsWeb ? 12 : 8.w),
        Flexible(
            child: Text(text,
                style: GoogleFonts.dmSans(
                    fontSize: kIsWeb ? 15 : 13.sp,
                    color: const Color(0xFF2D1B10),
                    height: 1.4))),
      ]);
}

class _TabText extends StatelessWidget {
  final String text;
  const _TabText(this.text);
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(kIsWeb ? 24 : 16.w),
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kIsWeb ? 16 : 16.r),
        border: Border.all(color: Colors.grey.shade100)),
    child: Text(text,
        style: GoogleFonts.dmSans(
            fontSize: kIsWeb ? 16 : 14.sp, height: 1.65, color: Colors.grey[700])),
  );
}

class _StoryCard extends StatelessWidget {
  final Story story;
  final VoidCallback onTap;
  const _StoryCard({required this.story, required this.onTap});

  static const _terracotta = Color(0xFFCD6E4E);
  static const _dark       = Color(0xFF2D1B10);

  @override
  Widget build(BuildContext context) {
    final imageUrl =
    story.imageUrls.isNotEmpty ? story.imageUrls.first : null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (imageUrl != null)
            Stack(children: [
              ClipRRect(
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(16.r)),
                child: ProxyImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: 150.h,
                    borderRadiusValue: 0,
                    thumb: true),
              ),
              Positioned(
                top: 12.h, left: 12.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                      color: _terracotta,
                      borderRadius: BorderRadius.circular(12.r)),
                  child: Text(story.storyType,
                      style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ]),
          Padding(
            padding: EdgeInsets.all(14.w),
            child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (imageUrl == null)
                Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                      color: _terracotta,
                      borderRadius: BorderRadius.circular(12.r)),
                  child: Text(story.storyType,
                      style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold)),
                ),
              Text(story.title,
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: _dark)),
              SizedBox(height: 6.h),
              Row(children: [
                Icon(Icons.access_time_rounded,
                    size: 13.sp, color: Colors.grey[500]),
                SizedBox(width: 5.w),
                Text('${story.estimatedReadTimeMinutes} min read',
                    style: GoogleFonts.dmSans(
                        fontSize: 12.sp, color: Colors.grey[500])),
              ]),
              SizedBox(height: 8.h),
              Text(story.fullContent,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                      fontSize: 13.sp,
                      height: 1.5,
                      color: Colors.grey[600])),
              SizedBox(height: 10.h),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Read Story →',
                        style: GoogleFonts.dmSans(
                            fontSize: 13.sp,
                            color: _terracotta,
                            fontWeight: FontWeight.bold)),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 12.sp, color: Colors.grey[400]),
                  ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _GalleryNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const _GalleryNavButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF2D1B10), size: 24),
        onPressed: onPressed,
      ),
    );
  }
}

class _WebInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _WebInfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[400]),
        const SizedBox(width: 12),
        Text(label, style: GoogleFonts.dmSans(fontSize: 15, color: Colors.grey[600])),
        const Spacer(),
        Text(value, style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF2D1B10))),
      ],
    );
  }
}

class _NearbyHomestayCard extends StatelessWidget {
  final dynamic homestay;
  final VoidCallback onTap;
  const _NearbyHomestayCard(
      {required this.homestay, required this.onTap});

  static const _dark = Color(0xFF2D1B10);

  @override
  Widget build(BuildContext context) {
    final imageUrl = (homestay.imageUrls?.isNotEmpty == true)
        ? homestay.imageUrls.first
        : null;
    final name     = homestay.name ?? 'Unnamed Homestay';
    final location = homestay.location ?? '';
    final price    = homestay.pricePerNight ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 6))
          ],
        ),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.r),
                bottomLeft: Radius.circular(18.r)),
            child: ProxyImage(
                imageUrl: imageUrl,
                width: 110.w,
                height: 110.h,
                borderRadiusValue: 0,
                thumb: true),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: _dark)),
                    SizedBox(height: 6.h),
                    if (location.isNotEmpty)
                      Row(children: [
                        Icon(Icons.location_on_outlined,
                            size: 13.sp, color: Colors.grey[500]),
                        SizedBox(width: 4.w),
                        Expanded(
                            child: Text(location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.dmSans(
                                    fontSize: 12.sp,
                                    color: Colors.grey[600]))),
                      ]),
                    SizedBox(height: 10.h),
                    Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                    text:
                                    'Rs. ${price.toStringAsFixed(0)}',
                                    style: GoogleFonts.dmSans(
                                        fontSize: 16.sp,
                                        color: Colors.deepOrangeAccent,
                                        fontWeight: FontWeight.w800)),
                                TextSpan(
                                    text: ' / night',
                                    style: GoogleFonts.dmSans(
                                        fontSize: 11.sp,
                                        color: Colors.grey[500])),
                              ])),
                          Icon(Icons.arrow_forward_ios_rounded,
                              size: 14.sp, color: Colors.grey[400]),
                        ]),
                  ]),
            ),
          ),
        ]),
      ),
    );
  }
}



