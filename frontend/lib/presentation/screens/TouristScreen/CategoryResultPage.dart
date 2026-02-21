import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/image_proxy.dart';
import 'package:lokyatra_frontend/data/models/Homestay.dart';
import 'package:lokyatra_frontend/data/models/TouristSite.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/homestays/HomestayBloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/homestays/HomestayState.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_state.dart';
import 'TouristHomestayDetailPage.dart';
import 'TouristSitesDetails.dart';

class CategoryResultsPage extends StatelessWidget {
  final String category;
  final String type; // 'Site' or 'Stay' or 'All'

  const CategoryResultsPage({
    super.key,
    required this.category,
    this.type = 'All'
  });

  static const Color _dark = Color(0xFF2D1B10);
  static const Color _cream = Color(0xFFFAF7F2);
  static const Color _terracotta = Color(0xFFCD6E4E);
  static const Color _warmGrey = Color(0xFF8B8B8B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.only(left: 8.w),
          child: IconButton(
            icon: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                  Icons.arrow_back_rounded,
                  color: _dark,
                  size: 20.sp
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Column(
          children: [
            Text(
              category,
              style: GoogleFonts.playfairDisplay(
                color: _dark,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              type == 'All' ? 'Sites & Stays' : type,
              style: GoogleFonts.dmSans(
                color: _warmGrey,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.all(20.w),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (type == 'All' || type == 'Site')
                  _buildSitesSection(context),
                if (type == 'All' || type == 'Stay')
                  SizedBox(height: type == 'All' ? 24.h : 0),
                if (type == 'All' || type == 'Stay')
                  _buildHomestaysSection(context),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSitesSection(BuildContext context) {
    return BlocBuilder<SitesBloc, SitesState>(
      builder: (context, state) {
        if (state is SitesLoading) {
          return _buildLoadingShimmer(isSite: true);
        }

        if (state is SitesLoaded) {
          final results = state.sites.where((site) {
            final cat = (site['category'] ?? '').toString();
            return cat.toLowerCase() == category.toLowerCase();
          }).toList();

          if (results.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                title: 'Cultural Sites',
                icon: Icons.temple_hindu_rounded,
                count: results.length,
              ),
              SizedBox(height: 16.h),
              ...results.map((site) => Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: _SiteResultCard(
                  site: site,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<HomestayBloc>(),
                        child: TouristSiteDetailPage(
                          site: TouristSite.fromJson(site),
                        ),
                      ),
                    ),
                  ),
                ),
              )),
            ],
          );
        }

        if (state is SitesError) {
          return _buildErrorWidget('Failed to load sites');
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHomestaysSection(BuildContext context) {
    return BlocBuilder<HomestayBloc, HomestayState>(
      builder: (context, state) {
        if (state is HomestayLoading) {
          return _buildLoadingShimmer(isSite: false);
        }

        if (state is TouristAllHomestaysLoaded) {
          final results = state.homestays.where((h) {
            if (!h.isVisible) return false;
            final cat = h.category ?? '';
            return cat.toLowerCase() == category.toLowerCase();
          }).toList();

          if (results.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                title: 'Homestays',
                icon: Icons.hotel_rounded,
                count: results.length,
              ),
              SizedBox(height: 16.h),
              ...results.map((homestay) => Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: _HomestayResultCard(
                  homestay: homestay,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TouristHomestayDetailPage(
                          homestay: homestay.toJson()
                      ),
                    ),
                  ),
                ),
              )),
            ],
          );
        }

        if (state is HomestayError) {
          return _buildErrorWidget('Failed to load homestays');
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required int count,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: _terracotta.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            icon,
            color: _terracotta,
            size: 18.sp,
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          title,
          style: GoogleFonts.dmSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: _dark,
          ),
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            '$count items',
            style: GoogleFonts.dmSans(
              fontSize: 12.sp,
              color: _warmGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingShimmer({required bool isSite}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: isSite ? 'Cultural Sites' : 'Homestays',
          icon: isSite ? Icons.temple_hindu_rounded : Icons.hotel_rounded,
          count: 0,
        ),
        SizedBox(height: 16.h),
        ...List.generate(2, (index) => Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: _buildShimmerCard(),
        )),
      ],
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      height: 280.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48.sp,
              color: Colors.red.withValues(alpha: 0.5),
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              style: GoogleFonts.dmSans(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SiteResultCard extends StatelessWidget {
  final Map<String, dynamic> site;
  final VoidCallback onTap;

  const _SiteResultCard({
    required this.site,
    required this.onTap,
  });

  static const Color _dark = Color(0xFF2D1B10);
  static const Color _terracotta = Color(0xFFCD6E4E);
  static const Color _warmGrey = Color(0xFF8B8B8B);

  // Helper method to safely get numeric value
  num? _getSafeNumericValue(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    if (value is String) {
      return num.tryParse(value);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = getFirstImageUrl(site['imageUrls']);
    final name = site['name'] as String? ?? 'Unnamed Site';
    final location = site['address'] as String? ?? 'Unknown Location';
    final district = site['district'] as String? ?? '';

    // FIX: Handle both int and double types for entryFee
    final entryFeeValue = _getSafeNumericValue(site['entryFeeNPR']);
    final entryFee = entryFeeValue?.toDouble() ?? 0.0;

    final isUNESCO = site['isUNESCO'] as bool? ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20.r)
                  ),
                  child: ProxyImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: 200.h,
                    borderRadiusValue: 0,
                    thumb: true,
                  ),
                ),
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: const Color(0xFFC7A26B),
                          size: 16.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '4.8',
                          style: GoogleFonts.dmSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: _dark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isUNESCO)
                  Positioned(
                    top: 12.h,
                    left: 12.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: _terracotta,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: _terracotta.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'UNESCO',
                        style: GoogleFonts.dmSans(
                          fontSize: 10.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: _dark,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14.sp,
                        color: _warmGrey,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          '$location, $district',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.dmSans(
                            fontSize: 13.sp,
                            color: _warmGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: _terracotta.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          entryFee > 0 ? 'Rs. ${entryFee.toStringAsFixed(0)} entry' : 'Free entry',
                          style: GoogleFonts.dmSans(
                            fontSize: 12.sp,
                            color: _terracotta,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        'View details →',
                        style: GoogleFonts.dmSans(
                          fontSize: 12.sp,
                          color: _terracotta,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomestayResultCard extends StatelessWidget {
  final Homestay homestay;
  final VoidCallback onTap;

  const _HomestayResultCard({
    required this.homestay,
    required this.onTap,
  });

  static const Color _dark = Color(0xFF2D1B10);
  static const Color _terracotta = Color(0xFFCD6E4E);
  static const Color _warmGrey = Color(0xFF8B8B8B);

  @override
  Widget build(BuildContext context) {
    final imageUrl = homestay.imageUrls.isNotEmpty
        ? homestay.imageUrls.first
        : null;
    final nearSite = (homestay.nearCulturalSite?.name ?? '').isNotEmpty
        ? 'Near ${homestay.nearCulturalSite?.name}'
        : homestay.location ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20.r)
                  ),
                  child: ProxyImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: 200.h,
                    borderRadiusValue: 0,
                    thumb: true,
                  ),
                ),
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.favorite_border_rounded,
                      size: 18.sp,
                      color: _terracotta,
                    ),
                  ),
                ),
                Positioned(
                  top: 12.h,
                  left: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: const Color(0xFFC7A26B),
                          size: 14.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '4.8',
                          style: GoogleFonts.dmSans(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: _dark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          homestay.name,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: _dark,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Rs. ${homestay.pricePerNight}',
                            style: GoogleFonts.dmSans(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: _terracotta,
                            ),
                          ),
                          Text(
                            '/night',
                            style: GoogleFonts.dmSans(
                              fontSize: 11.sp,
                              color: _warmGrey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14.sp,
                        color: _warmGrey,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          nearSite,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.dmSans(
                            fontSize: 13.sp,
                            color: _warmGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          '${homestay.numberOfRooms} rooms',
                          style: GoogleFonts.dmSans(
                            fontSize: 11.sp,
                            color: _warmGrey,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          '${homestay.maxGuests} guests max',
                          style: GoogleFonts.dmSans(
                            fontSize: 11.sp,
                            color: _warmGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}