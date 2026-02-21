import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/image_proxy.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_event.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_state.dart';

class TouristSitesPage extends StatefulWidget {
  const TouristSitesPage({super.key});

  @override
  State<TouristSitesPage> createState() => _TouristSitesPageState();
}

class _TouristSitesPageState extends State<TouristSitesPage> {
  static const _dark  = Color(0xFF2D1B10);
  static const _teal  = Color(0xFF2D6A6A);
  static const _brown = Color(0xFF8B5E3C);

  String _search = '';

  @override
  void initState() {
    super.initState();
    context.read<SitesBloc>().add(LoadSites());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cultural Sites',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: _dark)),
                SizedBox(height: 12.h),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _search = v),
                    style: GoogleFonts.dmSans(fontSize: 14.sp),
                    decoration: InputDecoration(
                      hintText: 'Search sites...',
                      hintStyle: GoogleFonts.dmSans(
                          fontSize: 14.sp, color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search,
                          color: Colors.grey[400], size: 20.sp),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 14.h),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<SitesBloc, SitesState>(
              builder: (context, state) {
                if (state is SitesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is SitesLoaded) {
                  final filtered = state.sites.where((s) {
                    final name = (s['name'] ?? '').toString().toLowerCase();
                    return _search.isEmpty ||
                        name.contains(_search.toLowerCase());
                  }).toList();

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final site = filtered[i];
                      final imageUrl = getFirstImageUrl(site['imageUrls']);
                      final name     = (site['name'] ?? '').toString();
                      final category = (site['category'] ?? '').toString();
                      final isUnesco = category.toLowerCase().contains('unesco') ||
                          site['isUnesco'] == true;

                      return Container(
                        margin: EdgeInsets.only(bottom: 16.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 4))
                          ],
                        ),
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
                                    thumb: true,
                                  ),
                                ),
                                Positioned(
                                  top: 12.h,
                                  right: 12.w,
                                  child: Container(
                                    padding: EdgeInsets.all(8.w),
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle),
                                    child: Icon(Icons.favorite_border_rounded,
                                        size: 18.sp, color: Colors.grey[600]),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.all(14.w),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(name,
                                            style: GoogleFonts.playfairDisplay(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold)),
                                        SizedBox(height: 6.h),
                                        Row(
                                          children: [
                                            Icon(Icons.star_rounded,
                                                color: Colors.amber[600],
                                                size: 15.sp),
                                            SizedBox(width: 4.w),
                                            Text('4.5',
                                                style: GoogleFonts.dmSans(
                                                    fontSize: 13.sp,
                                                    fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      if (isUnesco)
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.w, vertical: 4.h),
                                          decoration: BoxDecoration(
                                            color: _teal,
                                            borderRadius: BorderRadius.circular(20.r),
                                          ),
                                          child: Text('UNESCO',
                                              style: GoogleFonts.dmSans(
                                                  fontSize: 11.sp,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700)),
                                        ),
                                      SizedBox(height: 6.h),
                                      Text('Rs. ${site['entryFee'] ?? '0'}',
                                          style: GoogleFonts.dmSans(
                                              fontSize: 13.sp,
                                              color: Colors.grey[600])),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}