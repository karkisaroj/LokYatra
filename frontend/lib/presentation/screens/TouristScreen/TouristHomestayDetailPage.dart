import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/image_proxy.dart';
import 'package:lokyatra_frontend/data/models/Homestay.dart';
import 'Bookingformpage.dart';

class TouristHomestayDetailPage extends StatefulWidget {
  final Map<String, dynamic> homestay;
  const TouristHomestayDetailPage({super.key, required this.homestay});

  @override
  State<TouristHomestayDetailPage> createState() => _TouristHomestayDetailPageState();
}

class _TouristHomestayDetailPageState extends State<TouristHomestayDetailPage> {
  static const _cream = Color(0xFFFAF7F2);
  static const _dark = Color(0xFF2D1B10);
  static const _terracotta = Color(0xFFCD6E4E);
  static const _warmGrey = Color(0xFF8B8B8B);

  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final Homestay model = Homestay.fromJson(widget.homestay);
    final images = model.imageUrls.isNotEmpty ? model.imageUrls : [''];
    final nearSite = model.nearCulturalSite?.name ?? model.location;

    return Scaffold(
      backgroundColor: _cream,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.h,
            pinned: true,
            backgroundColor: _cream,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: EdgeInsets.all(8.w),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(Icons.arrow_back, size: 20.sp, color: _dark),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  margin: EdgeInsets.all(8.w),
                  padding: EdgeInsets.all(8.w),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Icon(Icons.favorite_border_rounded, size: 20.sp, color: _dark),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    itemCount: images.length,
                    onPageChanged: (index) => setState(() => _currentImageIndex = index),
                    itemBuilder: (context, index) {
                      return images[index].isNotEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(24.r), bottomRight: Radius.circular(24.r)),
                        child: ProxyImage(
                          imageUrl: images[index], width: double.infinity, height: 300.h, borderRadiusValue: 0,
                        ),
                      )
                          : Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(24.r), bottomRight: Radius.circular(24.r)),
                        ),
                      );
                    },
                  ),
                  if (images.length > 1)
                    Positioned(
                      bottom: 20.h, left: 0, right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(images.length, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            height: 8.h, width: _currentImageIndex == index ? 24.w : 8.w,
                            decoration: BoxDecoration(
                              color: _currentImageIndex == index ? Colors.white : Colors.white.withValues(alpha: 0.5),
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
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(model.name,
                      style: GoogleFonts.playfairDisplay(fontSize: 24.sp, fontWeight: FontWeight.bold, color: _dark)),
                  SizedBox(height: 6.h),

                  // Location Row
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16.sp, color: _warmGrey),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text('Near $nearSite',
                            style: GoogleFonts.dmSans(fontSize: 14.sp, color: _warmGrey)),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // Category Row
                  if (model.category != null && model.category!.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.category_outlined, size: 16.sp, color: _warmGrey),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(model.category!,
                              style: GoogleFonts.dmSans(fontSize: 14.sp, color: _warmGrey)),
                        ),
                      ],
                    ),
                  ],

                  SizedBox(height: 8.h),

                  // Rating Row
                  Row(
                    children: [
                      Icon(Icons.star_rounded, color: const Color(0xFFC7A26B), size: 18.sp),
                      SizedBox(width: 4.w),
                      Text('4.7', style: GoogleFonts.dmSans(fontSize: 14.sp, fontWeight: FontWeight.bold, color: _dark)),
                      Text(' (45 reviews)', style: GoogleFonts.dmSans(fontSize: 13.sp, color: _warmGrey)),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Info Tiles Row
                  Row(
                    children: [
                      Expanded(child: _InfoTile(icon: Icons.home_outlined, label: '${model.numberOfRooms} Rooms')),
                      SizedBox(width: 12.w),
                      Expanded(child: _InfoTile(icon: Icons.people_outline_rounded, label: '${model.maxGuests} Guests')),
                      SizedBox(width: 12.w),
                      Expanded(child: _InfoTile(icon: Icons.location_on_outlined, label: 'View Map', onTap: () {})),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Price Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Rs. ${model.pricePerNight.toStringAsFixed(0)}',
                          style: GoogleFonts.dmSans(fontSize: 24.sp, color: _terracotta, fontWeight: FontWeight.w800)),
                      Padding(
                        padding: EdgeInsets.only(bottom: 3.h, left: 4.w),
                        child: Text('/ night', style: GoogleFonts.dmSans(fontSize: 14.sp, color: _warmGrey)),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // Availability Row
                  Row(
                    children: [
                      Icon(Icons.check_box_rounded, color: _dark.withValues(alpha: 0.7), size: 18.sp),
                      SizedBox(width: 6.w),
                      Text('Available', style: GoogleFonts.dmSans(fontSize: 14.sp, color: _dark, fontWeight: FontWeight.w600)),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // About Section
                  _WhiteCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('About', style: GoogleFonts.dmSans(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _dark)),
                        SizedBox(height: 12.h),
                        Text(
                          model.description.isNotEmpty ? model.description
                              : 'Experience authentic Nepali hospitality at our traditional home. Just minutes away from local heritage sites.',
                          style: GoogleFonts.dmSans(fontSize: 14.sp, height: 1.6, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Nearby Heritage Site Section
                  if (model.nearCulturalSite != null)
                    _WhiteCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nearby Heritage Site',
                              style: GoogleFonts.dmSans(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _dark)),
                          SizedBox(height: 16.h),
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(color: _cream, borderRadius: BorderRadius.circular(12.r)),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.w),
                                  decoration: BoxDecoration(
                                      color: _terracotta.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10.r)),
                                  child: Icon(Icons.location_on, color: _terracotta, size: 20.sp),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(model.nearCulturalSite!.name,
                                          style: GoogleFonts.dmSans(
                                              fontSize: 14.sp, fontWeight: FontWeight.bold, color: _dark)),
                                      SizedBox(height: 4.h),
                                      Text('4.8 • 5 min away',
                                          style: GoogleFonts.dmSans(fontSize: 12.sp, color: _warmGrey)),
                                    ],
                                  ),
                                ),
                                Text('View Site →',
                                    style: GoogleFonts.dmSans(
                                        fontSize: 13.sp, fontWeight: FontWeight.w600, color: _terracotta)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (model.nearCulturalSite != null) SizedBox(height: 16.h),

                  // Host Section
                  _WhiteCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your Host',
                            style: GoogleFonts.dmSans(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _dark)),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            // Profile Picture or Initials
                            CircleAvatar(
                              radius: 26.r,
                              backgroundColor: const Color(0xFFE8DCCD),
                              backgroundImage: (model.owner?.profileImage != null && model.owner!.profileImage!.isNotEmpty)
                                  ? NetworkImage(model.owner!.profileImage!)
                                  : null,
                              child: (model.owner?.profileImage == null || model.owner!.profileImage!.isEmpty)
                                  ? Text(
                                model.owner?.initials ?? 'H',
                                style: GoogleFonts.dmSans(
                                    fontSize: 18.sp, color: _dark, fontWeight: FontWeight.w600),
                              )
                                  : null,
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    model.owner?.name ?? 'Unknown Host',
                                    style: GoogleFonts.dmSans(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _dark),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    'Host since ${model.owner?.createdAt?.year ?? '...'}',
                                    style: GoogleFonts.dmSans(fontSize: 12.sp, color: _warmGrey),
                                  ),
                                  SizedBox(height: 4.h),
                                  if (model.owner?.phoneNumber != null && model.owner!.phoneNumber!.isNotEmpty)
                                    Row(
                                      children: [
                                        Icon(Icons.phone_outlined, size: 14.sp, color: _terracotta),
                                        SizedBox(width: 4.w),
                                        Text(
                                          model.owner!.phoneNumber!,
                                          style: GoogleFonts.dmSans(fontSize: 13.sp, color: _terracotta),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () {
                                // Implement call functionality here
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                              ),
                              child: Text('Contact',
                                  style: GoogleFonts.dmSans(fontSize: 13.sp, fontWeight: FontWeight.w600, color: _dark)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // Book Now Button
                  SizedBox(
                    width: double.infinity, height: 54.h,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => BookingFormPage(homestay: widget.homestay)),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _terracotta, foregroundColor: Colors.white, elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                      child: Text('Book Now', style: GoogleFonts.dmSans(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _InfoTile({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.shade200)),
        child: Column(
          children: [
            Icon(icon, size: 24.sp, color: const Color(0xFF2D1B10)),
            SizedBox(height: 8.h),
            Text(label,
                style: GoogleFonts.dmSans(
                    fontSize: 13.sp,
                    color: const Color(0xFF2D1B10),
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  final Widget child;
  const _WhiteCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200, width: 0.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4)
          )
        ],
      ),
      child: child,
    );
  }
}