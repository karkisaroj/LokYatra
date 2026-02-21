import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/image_proxy.dart';
import 'package:lokyatra_frontend/data/models/TouristSite.dart';
import 'package:lokyatra_frontend/data/models/Story.dart';
import '../../state_management/Bloc/stories/story_bloc.dart';
import '../../state_management/Bloc/stories/story_event.dart';
import '../../state_management/Bloc/stories/story_state.dart';
import '../../state_management/Bloc/homestays/HomestayBloc.dart';
import '../../state_management/Bloc/homestays/HomestayEvent.dart';
import '../../state_management/Bloc/homestays/HomestayState.dart';
import 'TouristHomestayDetailPage.dart';

class TouristSiteDetailPage extends StatefulWidget {
  final TouristSite site;
  const TouristSiteDetailPage({super.key, required this.site});

  @override
  State<TouristSiteDetailPage> createState() => _TouristSiteDetailPageState();
}

class _TouristSiteDetailPageState extends State<TouristSiteDetailPage> {
  static const _terracotta = Color(0xFFCD6E4E);
  static const _darkTeal = Color(0xFF4A707A);
  static const _dark = Color(0xFF2D1B10);
  static const _cream = Color(0xFFFAF7F2);
  static const _warmGrey = Color(0xFF8B8B8B);

  int _currentImageIndex = 0;
  int _selectedTabIndex = 2; // Default to Stories

  final List<String> _tabs = ['About', 'History', 'Stories', 'Reviews'];

  @override
  void initState() {
    super.initState();
    final siteName = widget.site.name ?? '';
    context.read<HomestayBloc>().add(TouristLoadHomestaysNearSite(siteName));
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.site.name ?? 'Unnamed Site';
    final location = widget.site.address ?? 'Unknown Location';
    final district = widget.site.district ?? '';
    final entryFee = widget.site.entryFeeNPR?.toDouble() ?? 0.0;
    final isUNESCO = widget.site.isUNESCO ?? false;

    // NEW: Get category from site model
    final category = widget.site.category;

    final List<String> imageUrls = (widget.site.imageUrls as List?)
        ?.map((e) => e.toString())
        .toList() ??
        [];

    final displayImages = imageUrls.isNotEmpty ? imageUrls : [''];

    return BlocProvider(
      create: (context) => StoryBloc()..add(LoadStories(siteId: widget.site.id)),
      child: Scaffold(
        backgroundColor: _cream,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 350.h,
              pinned: true,
              backgroundColor: _cream,
              elevation: 0,
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  margin: EdgeInsets.all(8.w),
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: Icon(Icons.arrow_back, size: 20.sp, color: _dark),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    PageView.builder(
                      itemCount: displayImages.length,
                      onPageChanged: (index) =>
                          setState(() => _currentImageIndex = index),
                      itemBuilder: (context, index) {
                        return displayImages[index].isNotEmpty
                            ? ProxyImage(
                          imageUrl: displayImages[index],
                          width: double.infinity,
                          height: 350.h,
                          borderRadiusValue: 0,
                        )
                            : Container(color: Colors.grey[300]);
                      },
                    ),
                    Positioned(
                      bottom: 50.h,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(displayImages.length, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            height: 8.h,
                            width: _currentImageIndex == index ? 24.w : 8.w,
                            decoration: BoxDecoration(
                              color: _currentImageIndex == index
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: Offset(0, -30.h),
                child: Container(
                  decoration: BoxDecoration(
                    color: _cream,
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(30.r)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 24.h),
                        Container(
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8))
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: GoogleFonts.playfairDisplay(
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.bold,
                                      color: _dark)),
                              SizedBox(height: 10.h),

                              // Rating and UNESCO Row
                              Row(
                                children: [
                                  Icon(Icons.star_rounded,
                                      color: const Color(0xFFC7A26B),
                                      size: 18.sp),
                                  SizedBox(width: 4.w),
                                  Text('4.8',
                                      style: GoogleFonts.dmSans(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          color: _dark)),
                                  Text(' (245 reviews)',
                                      style: GoogleFonts.dmSans(
                                          fontSize: 13.sp,
                                          color: _warmGrey)),
                                  SizedBox(width: 12.w),
                                  if (isUNESCO)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.w, vertical: 4.h),
                                      decoration: BoxDecoration(
                                        color: _terracotta,
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      child: Text('UNESCO Site',
                                          style: GoogleFonts.dmSans(
                                              fontSize: 10.sp,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                ],
                              ),

                              SizedBox(height: 12.h),

                              // NEW: Category Row
                              if (category != null && category.isNotEmpty) ...[
                                Row(
                                  children: [
                                    Icon(Icons.category_outlined,
                                        size: 16.sp,
                                        color: _warmGrey),
                                    SizedBox(width: 8.w),
                                    Text(category,
                                        style: GoogleFonts.dmSans(
                                            fontSize: 13.sp,
                                            color: _warmGrey,
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                              ],

                              // Opening Hours
                              Row(
                                children: [
                                  Icon(Icons.access_time_rounded,
                                      size: 16.sp, color: _warmGrey),
                                  SizedBox(width: 8.w),
                                  Text('6AM - 7PM Opening',
                                      style: GoogleFonts.dmSans(
                                          fontSize: 13.sp, color: _dark)),
                                ],
                              ),
                              SizedBox(height: 12.h),

                              // Location
                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined,
                                      size: 16.sp, color: _warmGrey),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text('$location, $district',
                                        style: GoogleFonts.dmSans(
                                            fontSize: 13.sp, color: _dark)),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),
                              Divider(color: Colors.grey[200]),
                              SizedBox(height: 16.h),

                              // Entry Fee and Map Button
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Entry Fee',
                                          style: GoogleFonts.dmSans(
                                              fontSize: 12.sp,
                                              color: _warmGrey)),
                                      Text(entryFee > 0
                                          ? 'Rs. ${entryFee.toStringAsFixed(0)}'
                                          : 'Free',
                                          style: GoogleFonts.dmSans(
                                              fontSize: 18.sp,
                                              color: _terracotta,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {},
                                    icon: Icon(Icons.location_on, size: 16.sp),
                                    label: Text('MAP VIEW',
                                        style: GoogleFonts.dmSans(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _darkTeal,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(8.r)),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.w, vertical: 10.h),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // Tabs
                        Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFE8DB),
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(_tabs.length, (index) {
                              final isSelected = _selectedTabIndex == index;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedTabIndex = index),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 18.w, vertical: 10.h),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20.r),
                                    boxShadow: isSelected
                                        ? [
                                      BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2))
                                    ]
                                        : [],
                                  ),
                                  child: Text(
                                    _tabs[index],
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13.sp,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color:
                                      isSelected ? _dark : _warmGrey,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        SizedBox(height: 24.h),
                        _buildTabContent(),
                        SizedBox(height: 32.h),

                        // Nearby Homestays Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Nearby Homestays',
                                style: GoogleFonts.dmSans(
                                    fontSize: 18.sp,
                                    color: _dark,
                                    fontWeight: FontWeight.bold)),
                            Icon(Icons.favorite_border_rounded,
                                color: _warmGrey),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        _buildNearbyHomestays(),
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return Text(widget.site.shortDescription ?? 'No description available.',
            style: GoogleFonts.dmSans(
                fontSize: 14.sp, height: 1.6, color: Colors.grey[800]));
      case 1:
        return Text(
            widget.site.historicalSignificance ??
                'No historical context available.',
            style: GoogleFonts.dmSans(
                fontSize: 14.sp, height: 1.6, color: Colors.grey[800]));
      case 2:
        return _buildStoriesTab();
      case 3:
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: Text("Reviews coming soon.",
                style: GoogleFonts.dmSans(fontSize: 14.sp, color: _warmGrey)),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStoriesTab() {
    return BlocBuilder<StoryBloc, StoryState>(
      builder: (context, state) {
        if (state is StoryLoading) {
          return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(color: _terracotta),
              ));
        }

        if (state is StoryError) {
          return Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(state.message,
                    style: GoogleFonts.dmSans(color: Colors.red)),
              ));
        }

        if (state is StoriesLoaded) {
          if (state.stories.isEmpty) {
            return Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(Icons.auto_stories_outlined,
                          size: 48.sp,
                          color: _warmGrey.withValues(alpha: 0.5)),
                      SizedBox(height: 12.h),
                      Text("No stories available yet.",
                          style: GoogleFonts.dmSans(
                              fontSize: 14.sp,
                              color: _warmGrey)),
                    ],
                  ),
                ));
          }

          return Column(
            children: state.stories.map((story) {
              final imageUrl = story.imageUrls.isNotEmpty
                  ? story.imageUrls.first
                  : 'https://res.cloudinary.com/doanvrjez/image/upload/v1771594793/profile_images/IMG_20260212_121753_998_ipsgtx.jpg';

              return Container(
                margin: EdgeInsets.only(bottom: 20.h),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16.r)),
                            child: ProxyImage(
                                imageUrl: imageUrl,
                                width: double.infinity,
                                height: 160.h,
                                borderRadiusValue: 0,
                                thumb: true)),
                        Positioned(
                            top: 12.h,
                            left: 12.w,
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
                                        fontWeight: FontWeight.bold)))),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(story.title,
                              style: GoogleFonts.playfairDisplay(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: _dark)),
                          SizedBox(height: 6.h),
                          Row(children: [
                            Icon(Icons.access_time_rounded,
                                size: 14.sp, color: _warmGrey),
                            SizedBox(width: 6.w),
                            Text('${story.estimatedReadTimeMinutes} min read',
                                style: GoogleFonts.dmSans(
                                    fontSize: 12.sp, color: _warmGrey))
                          ]),
                          SizedBox(height: 10.h),
                          Text(story.fullContent,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.dmSans(
                                  fontSize: 13.sp,
                                  height: 1.5,
                                  color: Colors.grey[700])),
                          SizedBox(height: 12.h),
                          GestureDetector(
                            onTap: () {
                              // Navigate to full story view
                            },
                            child: Text('Read Story →',
                                style: GoogleFonts.dmSans(
                                    fontSize: 13.sp,
                                    color: _terracotta,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            }).toList(),
          );
        }
        return const SizedBox.shrink();
      },
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
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Text("No homestays found near this site.",
                    style: GoogleFonts.dmSans(color: _warmGrey)),
              ),
            );
          }
          return Column(
            children: state.homestays.map((h) {
              final imageUrl =
              h.imageUrls.isNotEmpty ? h.imageUrls.first : null;
              return GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            TouristHomestayDetailPage(homestay: h.toJson()))),
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
                      ]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                          borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16.r)),
                          child: ProxyImage(
                              imageUrl: imageUrl,
                              width: double.infinity,
                              height: 180.h,
                              borderRadiusValue: 0,
                              thumb: true)),
                      Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(h.name,
                                          style: GoogleFonts.dmSans(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                              color: _dark)),
                                      SizedBox(height: 8.h),
                                      Row(children: [
                                        Icon(Icons.star_rounded,
                                            color: const Color(0xFFC7A26B),
                                            size: 16.sp),
                                        SizedBox(width: 4.w),
                                        Text('4.7',
                                            style: GoogleFonts.dmSans(
                                                fontSize: 13.sp,
                                                color: _warmGrey))
                                      ]),
                                    ])),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                      'Rs. ${h.pricePerNight.toStringAsFixed(0)}/N',
                                      style: GoogleFonts.dmSans(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                          color: _dark)),
                                  Text('+13% VAT',
                                      style: GoogleFonts.dmSans(
                                          fontSize: 11.sp,
                                          color: _warmGrey)),
                                ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }
        return const SizedBox();
      },
    );
  }
}