import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/services/image_proxy.dart';
import 'package:lokyatra_frontend/data/models/story.dart';

class StoryDetailPage extends StatelessWidget {
  final Story story;
  const StoryDetailPage({super.key, required this.story});

  static const _dark      = Color(0xFF2D1B10);
  static const _cream     = Color(0xFFFAF7F2);
  static const _terracotta = Color(0xFFCD6E4E);
  static const _warmGrey  = Color(0xFF8B8B8B);

  @override
  Widget build(BuildContext context) {
    final hasImage = story.imageUrls.isNotEmpty;

    return Scaffold(
      backgroundColor: _cream,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: hasImage ? 280.h : 0,
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
            flexibleSpace: hasImage
                ? FlexibleSpaceBar(
              background: Stack(fit: StackFit.expand, children: [
                ProxyImage(
                  imageUrl: story.imageUrls.first,
                  width: double.infinity,
                  height: double.infinity,
                  borderRadiusValue: 0,
                ),
                // Gradient overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black26, Colors.transparent, Colors.black],
                        stops: const [0, 0.4, 1],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20.h, left: 20.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: _terracotta,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(story.storyType,
                        style: GoogleFonts.dmSans(
                            color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                  ),
                ),
              ]),
            )
                : null,
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!hasImage) ...[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: _terracotta,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(story.storyType,
                          style: GoogleFonts.dmSans(
                              color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(height: 14.h),
                  ],

                  // Title
                  Text(story.title,
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 26.sp, fontWeight: FontWeight.bold, color: _dark, height: 1.3)),
                  SizedBox(height: 12.h),

                  // Meta row
                  Row(children: [
                    Icon(Icons.access_time_rounded, size: 14.sp, color: _warmGrey),
                    SizedBox(width: 5.w),
                    Text('${story.estimatedReadTimeMinutes} min read',
                        style: GoogleFonts.dmSans(fontSize: 13.sp, color: _warmGrey)),
                    if (story.createdAt != null) ...[
                      SizedBox(width: 16.w),
                      Icon(Icons.calendar_today_outlined, size: 13.sp, color: _warmGrey),
                      SizedBox(width: 5.w),
                      Text(_formatDate(story.createdAt!),
                          style: GoogleFonts.dmSans(fontSize: 13.sp, color: _warmGrey)),
                    ],
                  ]),

                  SizedBox(height: 20.h),
                  Divider(color: Colors.grey.shade200),
                  SizedBox(height: 20.h),

                  // Full content
                  Text(story.fullContent,
                      style: GoogleFonts.dmSans(
                          fontSize: 15.sp, height: 1.75, color: Colors.grey[800])),

                  // Historical context section
                  if (story.historicalContext != null && story.historicalContext!.isNotEmpty) ...[
                    SizedBox(height: 28.h),
                    _InfoSection(
                      icon: Icons.history_edu_outlined,
                      title: 'Historical Context',
                      content: story.historicalContext!,
                    ),
                  ],

                  // Cultural significance section
                  if (story.culturalSignificance != null && story.culturalSignificance!.isNotEmpty) ...[
                    SizedBox(height: 20.h),
                    _InfoSection(
                      icon: Icons.auto_awesome_outlined,
                      title: 'Cultural Significance',
                      content: story.culturalSignificance!,
                    ),
                  ],

                  // Additional images gallery
                  if (story.imageUrls.length > 1) ...[
                    SizedBox(height: 28.h),
                    Text('Gallery',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 18.sp, fontWeight: FontWeight.bold, color: _dark)),
                    SizedBox(height: 12.h),
                    SizedBox(
                      height: 160.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: story.imageUrls.length,
                        separatorBuilder: (_, _) => SizedBox(width: 10.w),
                        itemBuilder: (_, i) => ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: ProxyImage(
                            imageUrl: story.imageUrls[i],
                            width: 200.w, height: 160.h,
                            borderRadiusValue: 0, thumb: true,
                          ),
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  const _InfoSection({required this.icon, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 18.sp, color: const Color(0xFFCD6E4E)),
          SizedBox(width: 8.w),
          Text(title,
              style: GoogleFonts.dmSans(fontSize: 15.sp,
                  fontWeight: FontWeight.bold, color: const Color(0xFF2D1B10))),
        ]),
        SizedBox(height: 10.h),
        Text(content,
            style: GoogleFonts.dmSans(fontSize: 14.sp, height: 1.65, color: Colors.grey[700])),
      ]),
    );
  }
}
