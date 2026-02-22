import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/image_proxy.dart';

import '../../../data/models/Site.dart';

class SiteDetailPage extends StatelessWidget {
  final CulturalSite site;
  const SiteDetailPage({super.key, required this.site});

  static const _terracotta = Color(0xFFCD6E4E);
  static const _dark = Color(0xFF2D1B10);
  static const _cream = Color(0xFFFAF7F2);
  static const _warmGrey = Color(0xFF8B8B8B);

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    try {
      final dt = date.toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final m = months[dt.month - 1];
      final d = dt.day;
      final y = dt.year;
      final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final min = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$m $d, $y at $h:$min $ampm';
    } catch (e) {
      return date.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract data safely
    final name = site.name ?? '';
    final category = site.category ?? '';
    final district = site.district ?? '';
    final shortDescription = site.shortDescription ?? '';
    final historicalSignificance = site.historicalSignificance ?? '';
    final culturalImportance = site.culturalImportance ?? '';
    final openingTime = site.openingTime ?? '';
    final closingTime = site.closingTime ?? '';
    final entryFeeNPR = site.entryFeeNPR?.toStringAsFixed(0) ?? '';
    final entryFeeSAARC = site.entryFeeSAARC?.toStringAsFixed(0) ?? '';
    final bestTimeToVisit = site.bestTimeToVisit ?? '';
    final isUNESCO = site.isUNESCO;
    final createdAt = site.createdAt;
    final updatedAt = site.updatedAt;

    // Images
    List<String> imageUrls = site.imageUrls.isNotEmpty ? site.imageUrls : [''];

    return Scaffold(
      backgroundColor: _cream,
      body: CustomScrollView(
        slivers: [
          // 1. App Bar with Hero Image
          SliverAppBar(
            expandedHeight: 300.h,
            pinned: true,
            backgroundColor: _cream,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: EdgeInsets.all(8.w),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back, size: 20.sp, color: _dark),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrls.first.isNotEmpty)
                    ProxyImage(
                      imageUrl: imageUrls.first,
                      width: double.infinity,
                      height: double.infinity,
                      borderRadiusValue: 0,
                    )
                  else
                    Container(
                      color: Colors.grey[300],
                      child: Icon(Icons.image_not_supported, size: 50.sp, color: Colors.grey[500]),
                    ),

                  // Gradient overlay for text readability
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Title on image
                  Positioned(
                    bottom: 20.h,
                    left: 20.w,
                    right: 20.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isUNESCO)
                          Container(
                            margin: EdgeInsets.only(bottom: 8.h),
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: _terracotta,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'UNESCO World Heritage Site',
                              style: GoogleFonts.dmSans(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        Text(
                          name,
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.white,
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.white70, size: 14.sp),
                            SizedBox(width: 4.w),
                            Text(
                              district,
                              style: GoogleFonts.dmSans(
                                color: Colors.white70,
                                fontSize: 14.sp,
                              ),
                            ),
                            if (category.isNotEmpty) ...[
                              SizedBox(width: 12.w),
                              Container(
                                width: 4.w,
                                height: 4.w,
                                decoration: const BoxDecoration(color: Colors.white70, shape: BoxShape.circle),
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                category,
                                style: GoogleFonts.dmSans(
                                  color: Colors.white70,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Content Body
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: _cream,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Info Cards
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _InfoCard(
                            icon: Icons.access_time,
                            label: 'Hours',
                            value: '$openingTime - $closingTime',
                          ),
                          SizedBox(width: 12.w),
                          _InfoCard(
                            icon: Icons.attach_money,
                            label: 'Entry (NPR)',
                            value: entryFeeNPR,
                          ),
                          SizedBox(width: 12.w),
                          _InfoCard(
                            icon: Icons.calendar_today,
                            label: 'Best Time',
                            value: bestTimeToVisit,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Description
                    Text(
                      shortDescription,
                      style: GoogleFonts.dmSans(
                        fontSize: 15.sp,
                        height: 1.6,
                        color: _dark.withOpacity(0.8),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Historical Significance
                    if (historicalSignificance.isNotEmpty) ...[
                      _SectionTitle(title: 'Historical Significance'),
                      SizedBox(height: 8.h),
                      Text(
                        historicalSignificance,
                        style: GoogleFonts.dmSans(
                          fontSize: 14.sp,
                          height: 1.6,
                          color: _warmGrey,
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],

                    // Cultural Importance
                    if (culturalImportance.isNotEmpty) ...[
                      _SectionTitle(title: 'Cultural Importance'),
                      SizedBox(height: 8.h),
                      Text(
                        culturalImportance,
                        style: GoogleFonts.dmSans(
                          fontSize: 14.sp,
                          height: 1.6,
                          color: _warmGrey,
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],

                    // Additional Details
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          _DetailRow(label: 'Entry Fee (SAARC)', value: 'NPR $entryFeeSAARC'),
                          const Divider(height: 24),
                          _DetailRow(label: 'Created At', value: _formatDate(createdAt)),
                          const Divider(height: 24),
                          _DetailRow(label: 'Last Updated', value: _formatDate(updatedAt)),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Gallery
                    if (imageUrls.length > 1) ...[
                      _SectionTitle(title: 'Gallery'),
                      SizedBox(height: 12.h),
                      SizedBox(
                        height: 120.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: imageUrls.length,
                          separatorBuilder: (_, __) => SizedBox(width: 12.w),
                          itemBuilder: (_, index) => ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: ProxyImage(
                              imageUrl: imageUrls[index],
                              width: 160.w,
                              height: 120.h,
                              borderRadiusValue: 0,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 32.h),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.playfairDisplay(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF2D1B10),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.sp, color: const Color(0xFFCD6E4E)),
              SizedBox(width: 6.w),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 14.sp,
              color: const Color(0xFF2D1B10),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 14.sp,
            color: const Color(0xFF2D1B10),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}