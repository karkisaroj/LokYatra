import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/image_proxy.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/homestays/HomestayBloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/homestays/HomestayState.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_state.dart';
import '../../../data/models/Site.dart';
import 'TouristHomestayDetailPage.dart';
import 'TouristSitesDetails.dart';

class CategoryResultsPage extends StatelessWidget {
  final String category;
  final String type; // 'Site' or 'Stay' or 'All'

  const CategoryResultsPage(
      {super.key, required this.category, this.type = 'All'});

  static const _dark = Color(0xFF2D1B10);
  static const _cream = Color(0xFFFAF7F2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _dark, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(category,
            style: GoogleFonts.playfairDisplay(
                color: _dark, fontSize: 20.sp, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          if (type == 'All' || type == 'Site')
            BlocBuilder<SitesBloc, SitesState>(
              builder: (context, state) {
                if (state is SitesLoaded) {
                  final results = state.sites.where((site) {
                    final cat = (site['category'] ?? '').toString();
                    return cat.toLowerCase() == category.toLowerCase();
                  }).toList();

                  if (results.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: Text('Sites',
                                style: GoogleFonts.dmSans(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: _dark)),
                          );
                        }
                        final site = results[index - 1];
                        return _ResultCard(
                          title: site['name'] ?? '',
                          subtitle: site['location'] ?? '',
                          imageUrl: getFirstImageUrl(site['imageUrls']),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<HomestayBloc>(),
                                child: TouristSiteDetailPage(
                                  site: CulturalSite.fromJson(site),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: results.length + 1,
                    ),
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),

          if (type == 'All' || type == 'Stay')
            BlocBuilder<HomestayBloc, HomestayState>(
              builder: (context, state) {
                if (state is TouristAllHomestaysLoaded) {
                  final results = state.homestays.where((h) {
                    if (!h.isVisible) return false;
                    final cat = h.category ?? '';
                    return cat.toLowerCase() == category.toLowerCase();
                  }).toList();

                  if (results.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: EdgeInsets.only(top: 20.h, bottom: 12.h),
                            child: Text('Homestays',
                                style: GoogleFonts.dmSans(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: _dark)),
                          );
                        }
                        final homestay = results[index - 1];
                        return _ResultCard(
                          title: homestay.name,
                          subtitle: homestay.location,
                          imageUrl: homestay.imageUrls.isNotEmpty
                              ? homestay.imageUrls.first
                              : null,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TouristHomestayDetailPage(
                                  homestay: homestay.toJson()),
                            ),
                          ),
                        );
                      },
                      childCount: results.length + 1,
                    ),
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final VoidCallback onTap;

  const _ResultCard({
    required this.title,
    required this.subtitle,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              child: ProxyImage(
                imageUrl: imageUrl,
                width: double.infinity,
                height: 180.h,
                borderRadiusValue: 0,
                thumb: true,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D1B10))),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 14.sp, color: Colors.grey[600]),
                      SizedBox(width: 4.w),
                      Text(subtitle,
                          style: GoogleFonts.dmSans(
                              fontSize: 13.sp, color: Colors.grey[600])),
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