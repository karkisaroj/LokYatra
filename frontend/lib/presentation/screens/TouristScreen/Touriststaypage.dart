import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/image_proxy.dart';
import '../../state_management/Bloc/homestays/HomestayBloc.dart';
import '../../state_management/Bloc/homestays/HomestayEvent.dart';
import '../../state_management/Bloc/homestays/HomestayState.dart';
import 'TouristHomestayDetailPage.dart'; // Fixed import

class TouristStayPage extends StatefulWidget {
  const TouristStayPage({super.key});

  @override
  State<TouristStayPage> createState() => _TouristStayPageState();
}

class _TouristStayPageState extends State<TouristStayPage> {
  static const _terracotta = Color(0xFFCD6E4E);
  static const _dark  = Color(0xFF2D1B10);

  String _search = '';

  @override
  void initState() {
    super.initState();
    context.read<HomestayBloc>().add(const TouristLoadAllHomestays());
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
                Text('Find Your Stay',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: _dark)),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2))
                          ],
                        ),
                        child: TextField(
                          onChanged: (v) => setState(() => _search = v),
                          style: GoogleFonts.dmSans(fontSize: 14.sp),
                          decoration: InputDecoration(
                            hintText: 'Search homestays...',
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
                    ),
                    SizedBox(width: 10.w),
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: Icon(Icons.tune_rounded,
                          size: 20.sp, color: _dark),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<HomestayBloc, HomestayState>(
              builder: (context, state) {
                if (state is HomestayLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is TouristAllHomestaysLoaded) {
                  final filtered = state.homestays
                      .where((h) =>
                  h.isVisible &&
                      (_search.isEmpty ||
                          (h.name).toLowerCase().contains(_search.toLowerCase()) ||
                          (h.location).toLowerCase().contains(_search.toLowerCase())))
                      .toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Text(
                            '${filtered.length} homestay${filtered.length == 1 ? '' : 's'} found',
                            style: GoogleFonts.dmSans(
                                fontSize: 13.sp, color: Colors.grey[500])),
                      ),
                      SizedBox(height: 10.h),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final h = filtered[i];
                            return _StayCard(
                              homestay: h,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => TouristHomestayDetailPage(
                                        homestay: h.toJson())),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
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

class _StayCard extends StatelessWidget {
  final dynamic homestay;
  final VoidCallback onTap;
  const _StayCard({required this.homestay, required this.onTap});

  static const _terracotta = Color(0xFFCD6E4E);

  @override
  Widget build(BuildContext context) {
    final imageUrl = homestay.imageUrls?.isNotEmpty == true
        ? homestay.imageUrls!.first
        : null;
    final nearSite = homestay.nearCulturalSite != null
        ? 'Near ${homestay.nearCulturalSite!.name}'
        : homestay.location ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
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
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                  child: ProxyImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: 180.h,
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
                        color: Colors.white, shape: BoxShape.circle),
                    child: Icon(Icons.favorite_border_rounded,
                        size: 18.sp, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(homestay.name ?? '',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 13.sp, color: Colors.grey[500]),
                      SizedBox(width: 2.w),
                      Text(nearSite,
                          style: GoogleFonts.dmSans(
                              fontSize: 12.sp, color: Colors.grey[500])),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(Icons.star_rounded,
                          color: Colors.amber[600], size: 15.sp),
                      SizedBox(width: 3.w),
                      Text('4.7',
                          style: GoogleFonts.dmSans(
                              fontSize: 12.sp, fontWeight: FontWeight.w600)),
                      Text(' (45 reviews)',
                          style: GoogleFonts.dmSans(
                              fontSize: 12.sp, color: Colors.grey[500])),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Divider(color: Colors.grey.shade100),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('From',
                              style: GoogleFonts.dmSans(
                                  fontSize: 11.sp, color: Colors.grey[500])),
                          Text(
                              'Rs. ${homestay.pricePerNight?.toStringAsFixed(0) ?? "0"}/night',
                              style: GoogleFonts.dmSans(
                                  fontSize: 16.sp,
                                  color: _terracotta,
                                  fontWeight: FontWeight.w700)),
                          Text('+13% VAT',
                              style: GoogleFonts.dmSans(
                                  fontSize: 10.sp, color: Colors.grey[400])),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _terracotta,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 10.h),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r)),
                        ),
                        child: Text('Book Now',
                            style: GoogleFonts.dmSans(
                                fontSize: 13.sp, fontWeight: FontWeight.w600)),
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