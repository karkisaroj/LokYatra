import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/image_proxy.dart';
import '../../../data/models/Site.dart';
import '../../state_management/Bloc/homestays/HomestayBloc.dart';
import '../../state_management/Bloc/homestays/HomestayState.dart';
import '../../state_management/Bloc/sites/sites_bloc.dart';
import '../../state_management/Bloc/sites/sites_state.dart';
import 'TouristHomestayDetailPage.dart';
import 'TouristSitesDetails.dart';

class CategoryResultsPage extends StatelessWidget {
  final String category;
  final String type;

  const CategoryResultsPage({super.key, required this.category, this.type = 'All'});

  static const _dark       = Color(0xFF2D1B10);
  static const _cream      = Color(0xFFFAF7F2);
  static const _terracotta = Color(0xFFCD6E4E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: CustomScrollView(
        slivers: [
          // ── Header ────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 150.h,
            pinned: true,
            backgroundColor: _dark,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: EdgeInsets.all(8.w),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(Icons.arrow_back, size: 20.sp, color: _dark),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2D1B10), Color(0xFF5C3A28)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 48.h, 20.w, 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(_categoryIcon(category), color: Colors.white60, size: 26.sp),
                        SizedBox(height: 6.h),
                        Text(category,
                            style: GoogleFonts.playfairDisplay(
                                color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold)),
                        Text(
                          type == 'Site' ? 'Cultural Sites'
                              : type == 'Stay' ? 'Homestays'
                              : 'Sites & Stays',
                          style: GoogleFonts.dmSans(color: Colors.white60, fontSize: 13.sp),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Sites
          if (type == 'All' || type == 'Site')
            BlocBuilder<SitesBloc, SitesState>(
              builder: (context, state) {
                if (state is! SitesLoaded) return const SliverToBoxAdapter(child: SizedBox.shrink());
                final results = state.sites.where((s) =>
                (s.category?? '').toString().toLowerCase() == category.toLowerCase()
                ).toList();
                if (results.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
                          child: _SubHeader(
                              icon: Icons.map_outlined, title: 'Cultural Sites', count: results.length),
                        );
                      }
                      final site = results[index - 1];
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: _SiteCard(
                          site: site,
                          onTap: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<HomestayBloc>(),
                              child: TouristSiteDetailPage(site: site),
                            ),
                          )),
                        ),
                      );
                    },
                    childCount: results.length + 1,
                  ),
                );
              },
            ),

          // ── Homestays ─────────────────────────────────────────────
          if (type == 'All' || type == 'Stay')
            BlocBuilder<HomestayBloc, HomestayState>(
              builder: (context, state) {
                if (state is! TouristAllHomestaysLoaded) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
                final results = state.homestays.where((h) {
                  if (!h.isVisible) return false;
                  return (h.category ?? '').toLowerCase() == category.toLowerCase();
                }).toList();
                if (results.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
                          child: _SubHeader(
                              icon: Icons.hotel_outlined, title: 'Homestays', count: results.length),
                        );
                      }
                      final h = results[index - 1];
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: _HomestayCard(
                          homestay: h,
                          onTap: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => TouristHomestayDetailPage(homestay: h.toJson()),
                          )),
                        ),
                      );
                    },
                    childCount: results.length + 1,
                  ),
                );
              },
            ),

          // ── Empty state ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: BlocBuilder<SitesBloc, SitesState>(
              builder: (context, sitesState) => BlocBuilder<HomestayBloc, HomestayState>(
                builder: (context, stayState) {
                  final noSites = sitesState is SitesLoaded &&
                      sitesState.sites.where((s) =>
                      (s.category ?? '').toString().toLowerCase() == category.toLowerCase()
                      ).isEmpty;
                  final noStays = stayState is! TouristAllHomestaysLoaded ||
                      stayState.homestays.where((h) =>
                      h.isVisible &&
                          (h.category ?? '').toLowerCase() == category.toLowerCase()
                      ).isEmpty;

                  if (noSites && noStays) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 60.h, horizontal: 40.w),
                      child: Column(children: [
                        Icon(Icons.search_off_rounded, size: 56.sp, color: Colors.grey[300]),
                        SizedBox(height: 16.h),
                        Text('No results found',
                            style: GoogleFonts.playfairDisplay(
                                fontSize: 20.sp, color: Colors.grey[500])),
                        SizedBox(height: 8.h),
                        Text('No $category listings available yet.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(fontSize: 13.sp, color: Colors.grey[400])),
                      ]),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 40.h)),
        ],
      ),
    );
  }

  IconData _categoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'temple': return Icons.temple_hindu_outlined;
      case 'palace': return Icons.account_balance_outlined;
      case 'stupa':  return Icons.landscape_outlined;
      case 'museum': return Icons.museum_outlined;
      case 'homestay': return Icons.home_work_outlined;
      case 'traditional': return Icons.cottage_outlined;
      default: return Icons.place_outlined;
    }
  }
}

class _SubHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  const _SubHeader({required this.icon, required this.title, required this.count});

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 18.sp, color: const Color(0xFF2D1B10)),
    SizedBox(width: 8.w),
    Text(title, style: GoogleFonts.playfairDisplay(
        fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(0xFF2D1B10))),
    SizedBox(width: 8.w),
    Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: const Color(0xFFCD6E4E).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text('$count', style: GoogleFonts.dmSans(
          fontSize: 12.sp, color: const Color(0xFFCD6E4E), fontWeight: FontWeight.bold)),
    ),
  ]);
}

class _SiteCard extends StatelessWidget {
  final CulturalSite site;
  final VoidCallback onTap;
  const _SiteCard({required this.site, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imageUrl  = getFirstImageUrl(site.imageUrls);
    final name      = (site.name ?? 'Unknown').toString();
    final district  = (site.district ?? '').toString();
    final category  = (site.category ?? '').toString();
    final isUnesco  = site.isUNESCO == true;
    final feeNpr    = site.entryFeeNPR;
    final feeSaarc=site.entryFeeSAARC;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
              blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
              child: ProxyImage(imageUrl: imageUrl, width: double.infinity,
                  height: 175.h, borderRadiusValue: 0, thumb: true),
            ),
            if (isUnesco)
              Positioned(
                top: 12.h, left: 12.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A707A),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text('UNESCO', style: GoogleFonts.dmSans(
                      color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.bold)),
                ),
              ),
            Positioned(
              top: 12.h, right: 12.w,
              child: Container(
                padding: EdgeInsets.all(7.w),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(Icons.favorite_border_rounded, size: 17.sp, color: Colors.grey[600]),
              ),
            ),
          ]),
          Padding(
            padding: EdgeInsets.all(14.w),
            // ── FIX: Use IntrinsicHeight + constrained right column ──────
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: name, district, rating — takes available space
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(name, maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 16.sp, fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D1B10))),
                    SizedBox(height: 5.h),
                    if (district.isNotEmpty)
                      Row(children: [
                        Icon(Icons.location_on_outlined, size: 13.sp, color: Colors.grey[500]),
                        SizedBox(width: 3.w),
                        Flexible(child: Text(district, overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.grey[500]))),
                      ]),
                    SizedBox(height: 4.h),
                    Row(children: [
                      Icon(Icons.star_rounded, color: Colors.amber[600], size: 14.sp),
                      SizedBox(width: 3.w),
                      Text('4.5', style: GoogleFonts.dmSans(fontSize: 12.sp,
                          fontWeight: FontWeight.w600, color: const Color(0xFF2D1B10))),
                    ]),
                  ]),
                ),
                SizedBox(width: 10.w),
                // Right: category chip + fee — fixed max width to prevent overflow
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 100.w),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    if (category.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCD6E4E).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(category,
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.dmSans(fontSize: 11.sp,
                                color: const Color(0xFFCD6E4E), fontWeight: FontWeight.w600)),
                      ),
                    if (feeNpr != null) ...[
                      SizedBox(height: 6.h),
                      Text('Rs. ${feeNpr.toString()}',
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.grey[600])),
                      Text('Entry fee',
                          style: GoogleFonts.dmSans(fontSize: 10.sp, color: Colors.grey[400])),
                    ],
                    if (feeSaarc != null) ...[
                      SizedBox(height: 6.h),
                      Text('Rs. ${feeSaarc.toString()}',
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.grey[600])),
                      Text('SAARC Entry fee',
                          style: GoogleFonts.dmSans(fontSize: 10.sp, color: Colors.grey[400])),
                    ],
                  ]),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _HomestayCard extends StatelessWidget {
  final dynamic homestay;
  final VoidCallback onTap;
  const _HomestayCard({required this.homestay, required this.onTap});

  static const _terracotta = Color(0xFFCD6E4E);

  @override
  Widget build(BuildContext context) {
    final imageUrl = (homestay.imageUrls?.isNotEmpty == true)
        ? homestay.imageUrls!.first as String? : null;
    final nearSite = homestay.nearCulturalSite != null
        ? 'Near ${homestay.nearCulturalSite!.name}'
        : (homestay.location ?? '').toString();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
              blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
              child: ProxyImage(imageUrl: imageUrl, width: double.infinity,
                  height: 175.h, borderRadiusValue: 0, thumb: true),
            ),
            Positioned(
              top: 12.h, right: 12.w,
              child: Container(
                padding: EdgeInsets.all(7.w),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(Icons.favorite_border_rounded, size: 17.sp, color: Colors.grey[600]),
              ),
            ),
          ]),
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text((homestay.name ?? '').toString(),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(fontSize: 16.sp,
                          fontWeight: FontWeight.bold, color: const Color(0xFF2D1B10))),
                ),
                Row(children: [
                  Icon(Icons.star_rounded, color: Colors.amber[600], size: 14.sp),
                  SizedBox(width: 3.w),
                  Text('4.7', style: GoogleFonts.dmSans(fontSize: 12.sp,
                      fontWeight: FontWeight.bold, color: const Color(0xFF2D1B10))),
                ]),
              ]),
              SizedBox(height: 5.h),
              if (nearSite.isNotEmpty)
                Row(children: [
                  Icon(Icons.location_on_outlined, size: 13.sp, color: Colors.grey[500]),
                  SizedBox(width: 3.w),
                  Flexible(child: Text(nearSite, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.grey[500]))),
                ]),
              SizedBox(height: 10.h),
              Divider(color: Colors.grey.shade100),
              SizedBox(height: 10.h),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('From', style: GoogleFonts.dmSans(fontSize: 11.sp, color: Colors.grey[400])),
                  Text('Rs. ${homestay.pricePerNight?.toStringAsFixed(0) ?? "0"}/night',
                      style: GoogleFonts.dmSans(fontSize: 15.sp,
                          color: _terracotta, fontWeight: FontWeight.w700)),
                ]),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    color: _terracotta,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text('Book Now', style: GoogleFonts.dmSans(
                      fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}