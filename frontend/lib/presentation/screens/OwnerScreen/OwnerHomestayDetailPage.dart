import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/image_proxy.dart';
import 'package:lokyatra_frontend/data/models/Homestay.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/homestays/HomestayBloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/homestays/HomestayEvent.dart';

class OwnerHomestayDetailPage extends StatefulWidget {
  final Homestay homestay;
  const OwnerHomestayDetailPage({super.key, required this.homestay});

  @override
  State<OwnerHomestayDetailPage> createState() => _OwnerHomestayDetailPageState();
}

class _OwnerHomestayDetailPageState extends State<OwnerHomestayDetailPage> {
  static const _terracotta = Color(0xFFCD6E4E);
  static const _darkTeal = Color(0xFF4A707A);
  static const _dark = Color(0xFF2D1B10);
  static const _cream = Color(0xFFFAF7F2);
  static const _warmGrey = Color(0xFF8B8B8B);

  int _currentImageIndex = 0;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final homestay = widget.homestay;
    final images = homestay.imageUrls.isNotEmpty ? homestay.imageUrls : [''];

    return Scaffold(
      backgroundColor: _cream,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image Gallery
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
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back, size: 20.sp, color: _dark),
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.all(8.w),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    homestay.isVisible ? Icons.visibility : Icons.visibility_off,
                    size: 20.sp,
                    color: homestay.isVisible ? _terracotta : _warmGrey,
                  ),
                  onPressed: _showVisibilityDialog,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image PageView
                  PageView.builder(
                    itemCount: images.length,
                    onPageChanged: (index) => setState(() => _currentImageIndex = index),
                    itemBuilder: (context, index) {
                      return images[index].isNotEmpty
                          ? ProxyImage(
                        imageUrl: images[index],
                        width: double.infinity,
                        height: 350.h,
                        borderRadiusValue: 0,
                      )
                          : Container(color: Colors.grey[300]);
                    },
                  ),

                  // Image Indicators
                  if (images.length > 1)
                    Positioned(
                      bottom: 50.h,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(images.length, (index) {
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

          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: _cream,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            homestay.name,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: _dark,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: homestay.isVisible
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: homestay.isVisible
                                  ? Colors.green.withValues(alpha: 0.3)
                                  : Colors.orange.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                homestay.isVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                size: 14.sp,
                                color: homestay.isVisible
                                    ? Colors.green[700]
                                    : Colors.orange[800],
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                homestay.isVisible ? 'Active' : 'Paused',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: homestay.isVisible
                                      ? Colors.green[700]
                                      : Colors.orange[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),

                    // Location
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 16.sp, color: _warmGrey),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            homestay.location,
                            style: GoogleFonts.dmSans(
                                fontSize: 14.sp, color: _warmGrey),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Category and Price
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: _terracotta.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            homestay.category ?? 'Homestay',
                            style: GoogleFonts.dmSans(
                              fontSize: 12.sp,
                              color: _terracotta,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Rs. ${homestay.pricePerNight.toStringAsFixed(0)}',
                              style: GoogleFonts.dmSans(
                                fontSize: 24.sp,
                                color: _terracotta,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '/ night',
                              style: GoogleFonts.dmSans(
                                fontSize: 12.sp,
                                color: _warmGrey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // Quick Stats
                    Container(
                      padding: EdgeInsets.all(16.w),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            icon: Icons.king_bed_outlined,
                            value: '${homestay.numberOfRooms}',
                            label: 'Rooms',
                          ),
                          _buildStatItem(
                            icon: Icons.people_outline_rounded,
                            value: '${homestay.maxGuests}',
                            label: 'Guests',
                          ),
                          _buildStatItem(
                            icon: Icons.bathtub_outlined,
                            value: '${homestay.bathrooms}',
                            label: 'Bathrooms',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Description
                    _buildSectionTitle('Description'),
                    SizedBox(height: 8.h),
                    Text(
                      homestay.description,
                      style: GoogleFonts.dmSans(
                        fontSize: 14.sp,
                        height: 1.6,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Amenities
                    if (homestay.amenities.isNotEmpty) ...[
                      _buildSectionTitle('Amenities'),
                      SizedBox(height: 12.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: homestay.amenities.map((amenity) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Text(
                              amenity,
                              style: GoogleFonts.dmSans(
                                fontSize: 12.sp,
                                color: _dark,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 24.h),
                    ],

                    // Cultural Significance
                    if (homestay.culturalSignificance != null &&
                        homestay.culturalSignificance!.isNotEmpty) ...[
                      _buildSectionTitle('Cultural Significance'),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          homestay.culturalSignificance!,
                          style: GoogleFonts.dmSans(
                            fontSize: 14.sp,
                            height: 1.6,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],

                    // Traditional Features
                    if (homestay.traditionalFeatures != null &&
                        homestay.traditionalFeatures!.isNotEmpty) ...[
                      _buildSectionTitle('Traditional Features'),
                      SizedBox(height: 8.h),
                      Text(
                        homestay.traditionalFeatures!,
                        style: GoogleFonts.dmSans(
                          fontSize: 14.sp,
                          height: 1.6,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],

                    // Cultural Experiences
                    if (homestay.culturalExperiences.isNotEmpty) ...[
                      _buildSectionTitle('Cultural Experiences'),
                      SizedBox(height: 12.h),
                      ...homestay.culturalExperiences.map((exp) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.emoji_events_outlined,
                                  size: 16.sp, color: _terracotta),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  exp,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14.sp,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      SizedBox(height: 24.h),
                    ],

                    // Near Cultural Site
                    if (homestay.nearCulturalSite != null) ...[
                      _buildSectionTitle('Nearby Heritage Site'),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.all(16.w),
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
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: _terracotta.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(Icons.location_on,
                                  color: _terracotta, size: 20.sp),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    homestay.nearCulturalSite!.name,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: _dark,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'Heritage Site',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12.sp,
                                      color: _warmGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _showVisibilityDialog,
                            icon: Icon(
                              homestay.isVisible
                                  ? Icons.pause_circle_outline
                                  : Icons.play_circle_outline,
                              size: 18.sp,
                            ),
                            label: Text(
                              homestay.isVisible ? 'Pause Homestay' : 'Activate Homestay',
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: homestay.isVisible
                                  ? Colors.orange[800]
                                  : Colors.green[800],
                              side: BorderSide(
                                color: homestay.isVisible
                                    ? Colors.orange.shade200
                                    : Colors.green.shade200,
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showDeleteDialog,
                            icon: const Icon(Icons.delete_outline_rounded),
                            label: const Text('Delete'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24.sp, color: _terracotta),
        SizedBox(height: 4.h),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: _dark,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12.sp,
            color: _warmGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.playfairDisplay(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: _dark,
      ),
    );
  }

  void _showVisibilityDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Icon(
              widget.homestay.isVisible
                  ? Icons.pause_circle_outline
                  : Icons.play_circle_outline,
              color: widget.homestay.isVisible ? Colors.orange[700] : Colors.green[600],
              size: 28.sp,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                widget.homestay.isVisible ? 'Pause Homestay?' : 'Activate Homestay?',
                style: GoogleFonts.playfairDisplay(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                  color: _dark,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          widget.homestay.isVisible
              ? 'Pausing "${widget.homestay.name}" will hide it from tourists. They will not be able to book it until you activate it again.'
              : 'Activating "${widget.homestay.name}" will make it immediately visible to all tourists for booking.',
          style: GoogleFonts.dmSans(
            fontSize: 14.sp,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
        actionsPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.dmSans(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.homestay.isVisible
                  ? Colors.orange[700]
                  : Colors.green[600],
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              context.read<HomestayBloc>().add(
                AdminToggleHomestayVisibility(
                  widget.homestay.id,
                  !widget.homestay.isVisible,
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Homestay ${widget.homestay.isVisible ? 'paused' : 'activated'} successfully',
                  ),
                  backgroundColor: widget.homestay.isVisible
                      ? Colors.orange[700]
                      : Colors.green[600],
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context); // Return to refresh list
            },
            child: Text(
              widget.homestay.isVisible ? 'Pause' : 'Activate',
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent,
              size: 28.sp,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'Delete Homestay?',
                style: GoogleFonts.playfairDisplay(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                  color: _dark,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete "${widget.homestay.name}"? This action cannot be undone.',
          style: GoogleFonts.dmSans(
            fontSize: 14.sp,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
        actionsPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.dmSans(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              context.read<HomestayBloc>().add(AdminDeleteHomestay(widget.homestay.id));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Homestay deleted successfully'),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context); // Return to refresh list
            },
            child: Text(
              'Delete',
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}