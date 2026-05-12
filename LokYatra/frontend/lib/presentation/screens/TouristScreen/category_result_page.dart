import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/services/image_proxy.dart';
import '../../../data/models/site.dart';
import '../../../data/models/homestay.dart';
import '../../state_management/Bloc/homestays/homestay_bloc.dart';
import '../../state_management/Bloc/homestays/homestay_state.dart';
import '../../state_management/Bloc/sites/sites_bloc.dart';
import '../../state_management/Bloc/sites/sites_state.dart';
import '../../widgets/Helpers/favourite_button.dart';
import 'tourist_homestay_detail_page.dart';
import 'tourist_sites_details.dart';

class CategoryResultsPage extends StatelessWidget {
  final String category;
  final String type;

  const CategoryResultsPage({super.key, required this.category, this.type = 'All'});

  static const _dark  = Color(0xFF2D1B10);
  static const _bg    = Color(0xFFF4F6F9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: EdgeInsets.all(8.w),
                decoration: const BoxDecoration(color: Color(0xFFF0F0F0), shape: BoxShape.circle),
                child: Icon(Icons.arrow_back_ios_new_rounded, size: 16.sp, color: _dark),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(category,
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 18.sp, fontWeight: FontWeight.bold, color: _dark)),
                Text(
                  type == 'Site' ? 'Cultural Sites' : type == 'Stay' ? 'Homestays' : 'Sites & Stays',
                  style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.grey[500]),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(height: 1, color: Colors.grey.shade200),
            ),
          ),

          if (type == 'All' || type == 'Site')
            BlocBuilder<SitesBloc, SitesState>(
              builder: (context, state) {
                if (state is! SitesLoaded) return const SliverToBoxAdapter(child: SizedBox.shrink());
                final sites = state.sites
                    .where((s) => (s.category ?? '').toLowerCase() == category.toLowerCase())
                    .toList();
                if (sites.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, i) {
                      if (i == 0) return _ListHeader(label: 'Cultural Sites', count: sites.length, icon: Icons.map_outlined);
                      final site = sites[i - 1];
                      return Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 14.h),
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
                    childCount: sites.length + 1,
                  ),
                );
              },
            ),

          if (type == 'All' || type == 'Stay')
            BlocBuilder<HomestayBloc, HomestayState>(
              builder: (context, state) {
                if (state is! TouristAllHomestaysLoaded) return const SliverToBoxAdapter(child: SizedBox.shrink());
                final stays = state.homestays.where((h) {
                  if (!h.isVisible) return false;
                  return (h.category ?? '').toLowerCase() == category.toLowerCase();
                }).toList();
                if (stays.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, i) {
                      if (i == 0) return _ListHeader(label: 'Homestays', count: stays.length, icon: Icons.hotel_outlined);
                      final h = stays[i - 1];
                      return Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 14.h),
                        child: _HomestayCard(
                          homestay: h,
                          onTap: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => TouristHomestayDetailPage(homestay: h.toJson()),
                          )),
                        ),
                      );
                    },
                    childCount: stays.length + 1,
                  ),
                );
              },
            ),

          SliverToBoxAdapter(
            child: BlocBuilder<SitesBloc, SitesState>(
              builder: (context, sitesState) => BlocBuilder<HomestayBloc, HomestayState>(
                builder: (context, stayState) {
                  final noSites = sitesState is SitesLoaded &&
                      sitesState.sites.where((s) =>
                      (s.category ?? '').toLowerCase() == category.toLowerCase()).isEmpty;
                  final noStays = stayState is! TouristAllHomestaysLoaded ||
                      stayState.homestays.where((h) =>
                      h.isVisible && (h.category ?? '').toLowerCase() == category.toLowerCase()).isEmpty;

                  if (!noSites || !noStays) return const SizedBox.shrink();

                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 80.h, horizontal: 40.w),
                    child: Column(children: [
                      Icon(Icons.search_off_rounded, size: 56.sp, color: Colors.grey[300]),
                      SizedBox(height: 16.h),
                      Text('Nothing found',
                          style: GoogleFonts.playfairDisplay(fontSize: 20.sp, color: Colors.grey[500])),
                      SizedBox(height: 8.h),
                      Text('No $category listings available yet.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(fontSize: 13.sp, color: Colors.grey[400])),
                    ]),
                  );
                },
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 40.h)),
        ],
      ),
    );
  }
}

class _ListHeader extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  const _ListHeader({required this.label, required this.count, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 12.h),
      child: Row(children: [
        Icon(icon, size: 18.sp, color: const Color(0xFF2D1B10)),
        SizedBox(width: 8.w),
        Text(label,
            style: GoogleFonts.playfairDisplay(
                fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(0xFF2D1B10))),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: const Color(0xFFCD6E4E).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text('$count',
              style: GoogleFonts.dmSans(
                  fontSize: 12.sp, color: const Color(0xFFCD6E4E), fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }
}

class _SiteCard extends StatelessWidget {
  final CulturalSite site;
  final VoidCallback onTap;
  const _SiteCard({required this.site, required this.onTap});

  static const _dark  = Color(0xFF2D1B10);

  @override
  Widget build(BuildContext context) {
    final image    = site.imageUrls.isNotEmpty ? site.imageUrls.first : '';
    final name     = site.name     ?? 'Unknown';
    final district = site.district ?? '';
    final category = site.category ?? '';
    final isUnesco = site.isUNESCO == true;
    final feeNpr   = site.entryFeeNPR;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              child: ProxyImage(imageUrl: image, width: double.infinity, height: 170.h, borderRadiusValue: 0, thumb: true),
            ),
            if (isUnesco)
              Positioned(
                top: 10.h, left: 10.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D6A6A),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text('UNESCO',
                      style: GoogleFonts.dmSans(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                ),
              ),
            if (category.isNotEmpty)
              Positioned(
                top: 10.h, right: 10.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(category,
                      style: GoogleFonts.dmSans(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w600)),
                ),
              ),
          ]),
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _dark)),
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
                    Icon(Icons.star_rounded, color: Colors.amber[600], size: 13.sp),
                    SizedBox(width: 3.w),
                    Text('4.5', style: GoogleFonts.dmSans(fontSize: 12.sp, fontWeight: FontWeight.w600, color: _dark)),
                  ]),
                ]),
              ),
              if (feeNpr != null) ...[
                SizedBox(width: 10.w),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('Rs. ${feeNpr.toStringAsFixed(0)}',
                      style: GoogleFonts.dmSans(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFFCD6E4E))),
                  Text('Entry fee',
                      style: GoogleFonts.dmSans(fontSize: 10.sp, color: Colors.grey[400])),
                ]),
              ],
            ]),
          ),
        ]),
      ),
    );
  }
}

class _HomestayCard extends StatelessWidget {
  final Homestay homestay;
  final VoidCallback onTap;
  const _HomestayCard({required this.homestay, required this.onTap});

  static const _dark  = Color(0xFF2D1B10);

  @override
  Widget build(BuildContext context) {
    final image    = homestay.imageUrls.isNotEmpty ? homestay.imageUrls.first : null;
    final location = (homestay.nearCulturalSite?.name ?? '').isNotEmpty
        ? 'Near ${homestay.nearCulturalSite!.name}'
        : homestay.location;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              child: ProxyImage(imageUrl: image, width: double.infinity, height: 170.h, borderRadiusValue: 0, thumb: true),
            ),
            Positioned(
              top: 10.h, right: 10.w,
              child: FavouriteButton(homestayId: homestay.id),
            ),
          ]),
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text(homestay.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _dark)),
                ),
                Row(children: [
                  Icon(Icons.star_rounded, color: Colors.amber[600], size: 14.sp),
                  SizedBox(width: 3.w),
                  Text('4.7', style: GoogleFonts.dmSans(fontSize: 12.sp, fontWeight: FontWeight.bold, color: _dark)),
                ]),
              ]),
              SizedBox(height: 5.h),
              if (location.isNotEmpty)
                Row(children: [
                  Icon(Icons.location_on_outlined, size: 13.sp, color: Colors.grey[500]),
                  SizedBox(width: 3.w),
                  Flexible(child: Text(location, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.grey[500]))),
                ]),
              SizedBox(height: 12.h),
              Divider(color: Colors.grey.shade100),
              SizedBox(height: 10.h),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${homestay.numberOfRooms} rooms · ${homestay.maxGuests} guests',
                      style: GoogleFonts.dmSans(fontSize: 11.sp, color: Colors.grey[500])),
                  SizedBox(height: 3.h),
                  RichText(text: TextSpan(children: [
                    TextSpan(
                      text: 'Rs. ${homestay.pricePerNight.toStringAsFixed(0)}',
                      style: GoogleFonts.dmSans(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFFCD6E4E)),
                    ),
                    TextSpan(
                      text: ' / night',
                      style: GoogleFonts.dmSans(fontSize: 11.sp, color: Colors.grey[500]),
                    ),
                  ])),
                ]),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
                  decoration: BoxDecoration(
                    color: _dark,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text('Book Now',
                      style: GoogleFonts.dmSans(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}



