import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/services/image_proxy.dart';
import 'package:lokyatra_frontend/data/models/Homestay.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/review/review_event.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/datasources/booking_remote_datasource.dart';
import '../../../data/datasources/sites_remote_datasource.dart';
import '../../../data/models/Site.dart';
import '../../state_management/Bloc/review/review_bloc.dart';
import '../../state_management/Bloc/review/review_state.dart';
import '../../widgets/Helpers/Favouritebutton.dart';
import '../../widgets/Helpers/ReviewSection.dart';
import 'Bookingformpage.dart';
import 'TouristSitesDetails.dart';

class TouristHomestayDetailPage extends StatefulWidget {
  final Map<String, dynamic> homestay;
  const TouristHomestayDetailPage({super.key, required this.homestay});

  @override
  State<TouristHomestayDetailPage> createState() => _TouristHomestayDetailPageState();
}

class _TouristHomestayDetailPageState extends State<TouristHomestayDetailPage> {
  static const _cream      = Color(0xFFFAF7F2);
  static const _dark       = Color(0xFF2D1B10);
  static const _terracotta = Color(0xFFCD6E4E);
  static const _warmGrey   = Color(0xFF8B8B8B);
  static const _teal       = Color(0xFF4A707A);

  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  late Homestay _model;
  CulturalSite? _nearbySite;
  bool _isLoadingSite = false;
  int? _completedBookingId;

  @override
  void initState() {
    super.initState();
    _model = Homestay.fromJson(widget.homestay);
    if (_model.nearCulturalSite != null) {
      _fetchNearbySite(_model.nearCulturalSite!.id);
    }
    _fetchCompletedBookingId();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchNearbySite(int id) async {
    setState(() => _isLoadingSite = true);
    try {
      final res = await SitesRemoteDatasource().getSite(id);
      if (res.statusCode == 200 && mounted) {
        setState(() => _nearbySite = CulturalSite.fromJson(res.data as Map<String, dynamic>));
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoadingSite = false);
    }
  }

  Future<void> _openMap() async {
    final parts = [
      if (_model.name.isNotEmpty) _model.name,
      if (_model.location.isNotEmpty) _model.location,
      'Nepal',
    ];
    final query = Uri.encodeComponent(parts.join(', '));
    final geoUri = Uri.parse('geo:0,0?q=$query');
    try {
      await launchUrl(geoUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      final webUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
      try {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open Maps. Please install Google Maps.')),
          );
        }
      }
    }
  }
  Future<void> _fetchCompletedBookingId() async {
    try {
      final resp = await BookingRemoteDatasource().getMyBookings();
      if (resp.statusCode == 200) {
        final list = resp.data as List<dynamic>;
        for (final item in list) {
          final b = item['booking'] as Map<String, dynamic>?;
          if (b == null) continue;
          if (b['homestayId'] == _model.id && b['status'] == 'Completed') {
            if (mounted) setState(() => _completedBookingId = b['id'] as int?);
            break;
          }
        }
      }
    } catch (_) {}
  }
  @override
  Widget build(BuildContext context) {
    final images = _model.imageUrls.isNotEmpty ? _model.imageUrls : <String>[];

    return BlocProvider(
      create: (_)=>ReviewBloc()..add(LoadHomestayReviews(_model.id)),
      child: Scaffold(
        backgroundColor: _cream,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [

                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 380.h,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        images.isEmpty
                            ? Container(color: Colors.grey[300],
                            child: Icon(Icons.home, size: 60.sp, color: Colors.grey[400]))
                            : PageView.builder(
                          controller: _pageController,
                          itemCount: images.length,
                          onPageChanged: (i) => setState(() => _currentImageIndex = i),
                          itemBuilder: (_, i) => ProxyImage(
                            imageUrl: images[i],
                            width: double.infinity,
                            height: 380.h,
                            borderRadiusValue: 0,
                          ),
                        ),

                        Positioned.fill(
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.3),
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.55),
                                  ],
                                  stops: const [0, 0.4, 1],
                                ),
                              ),
                            ),
                          ),
                        ),

                        if (images.length > 1)
                          Positioned(
                            top: 52.h, right: 56.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text('${_currentImageIndex + 1}/${images.length}',
                                  style: GoogleFonts.dmSans(color: Colors.white,
                                      fontSize: 12.sp, fontWeight: FontWeight.w600)),
                            ),
                          ),

                        if (images.length > 1)
                          Positioned(
                            bottom: 20.h, left: 0, right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(images.length, (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: EdgeInsets.symmetric(horizontal: 3.w),
                                height: 6.h,
                                width: _currentImageIndex == i ? 20.w : 6.w,
                                decoration: BoxDecoration(
                                  color: _currentImageIndex == i ? Colors.white : Colors.white54,
                                  borderRadius: BorderRadius.circular(3.r),
                                ),
                              )),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // ── Detail Body ───────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      // Name + Available badge
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(child: Text(_model.name,
                            style: GoogleFonts.playfairDisplay(
                                fontSize: 24.sp, fontWeight: FontWeight.bold, color: _dark))),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Container(width: 6.w, height: 6.h,
                                decoration: BoxDecoration(
                                    color: Colors.green.shade600, shape: BoxShape.circle)),
                            SizedBox(width: 5.w),
                            Text('Available', style: GoogleFonts.dmSans(
                                fontSize: 11.sp, color: Colors.green.shade700,
                                fontWeight: FontWeight.w600)),
                          ]),
                        ),
                      ]),

                      if (_model.category != null && _model.category!.isNotEmpty) ...[
                        SizedBox(height: 6.h),
                        Row(children: [
                          Icon(Icons.category_outlined, size: 15.sp, color: _warmGrey),
                          SizedBox(width: 4.w),
                          Text(_model.category!, style: GoogleFonts.dmSans(
                              fontSize: 13.sp, color: _warmGrey)),
                        ]),
                      ],

                      SizedBox(height: 6.h),
                      BlocBuilder<ReviewBloc, ReviewState>(
                        builder: (context, state) {
                          if (state is ReviewsLoaded && state.reviewCount > 0) {
                            return Row(children: [
                              Icon(Icons.star_rounded, color: const Color(0xFFC7A26B), size: 16.sp),
                              SizedBox(width: 4.w),
                              Text(state.averageRating.toString(),
                                  style: GoogleFonts.dmSans(
                                      fontSize: 13.sp, fontWeight: FontWeight.bold, color: _dark)),
                              Text(' (${state.reviewCount} review${state.reviewCount != 1 ? 's' : ''})',
                                  style: GoogleFonts.dmSans(fontSize: 12.sp, color: _warmGrey)),
                            ]);
                          }
                          return Row(children: [
                            Icon(Icons.star_outline_rounded, color: Colors.grey[300], size: 16.sp),
                            SizedBox(width: 4.w),
                            Text('No reviews yet', style: GoogleFonts.dmSans(fontSize: 12.sp, color: _warmGrey)),
                          ]);
                        },
                      ),

                      SizedBox(height: 14.h),

                      // ── Location + Map button card ─────────────────────
                      Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: Colors.grey.shade100),
                          boxShadow: [BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 8, offset: const Offset(0, 3))],
                        ),
                        child: Row(children: [
                          // Location icon + text
                          Expanded(child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(7.w),
                                decoration: BoxDecoration(
                                  color: _teal.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Icon(Icons.location_on_outlined, size: 16.sp, color: _teal),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Location', style: GoogleFonts.dmSans(
                                      fontSize: 11.sp, color: Colors.grey[500])),
                                  SizedBox(height: 2.h),
                                  Text(_model.location, style: GoogleFonts.dmSans(
                                      fontSize: 13.sp, color: _dark,
                                      fontWeight: FontWeight.w500)),
                                ],
                              )),
                            ],
                          )),
                          SizedBox(width: 10.w),
                          // Map button
                          GestureDetector(
                            onTap: _openMap,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: _teal,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.map_outlined, size: 15.sp, color: Colors.white),
                                SizedBox(width: 5.w),
                                Text('Map', style: GoogleFonts.dmSans(
                                    fontSize: 12.sp, color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                              ]),
                            ),
                          ),
                        ]),
                      ),

                      SizedBox(height: 20.h),

                      // Price
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: _terracotta.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: _terracotta.withValues(alpha: 0.2)),
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Price per night', style: GoogleFonts.dmSans(
                                fontSize: 12.sp, color: _warmGrey)),
                            SizedBox(height: 2.h),
                            Text('Rs. ${_model.pricePerNight.toStringAsFixed(0)}',
                                style: GoogleFonts.dmSans(
                                    fontSize: 26.sp, color: _terracotta,
                                    fontWeight: FontWeight.w800)),
                          ]),
                          Text('+13% VAT', style: GoogleFonts.dmSans(
                              fontSize: 12.sp, color: _warmGrey)),
                        ]),
                      ),

                      SizedBox(height: 20.h),

                      // Quick stats
                      Row(children: [
                        Expanded(child: _StatTile(
                            icon: Icons.king_bed_outlined,
                            value: '${_model.numberOfRooms}', label: 'Rooms')),
                        SizedBox(width: 10.w),
                        Expanded(child: _StatTile(
                            icon: Icons.people_outline_rounded,
                            value: '${_model.maxGuests}', label: 'Guests')),
                        SizedBox(width: 10.w),
                        Expanded(child: _StatTile(
                            icon: Icons.bathtub_outlined,
                            value: '${_model.bathrooms}', label: 'Baths')),
                      ]),

                      SizedBox(height: 24.h),

                      _SectionHeader('About this Homestay'),
                      SizedBox(height: 10.h),
                      _InfoCard(child: Text(
                        _model.description.isNotEmpty
                            ? _model.description
                            : 'Experience authentic Nepali hospitality at this traditional home.',
                        style: GoogleFonts.dmSans(
                            fontSize: 14.sp, height: 1.65, color: Colors.grey[700]),
                      )),

                      if (_model.amenities.isNotEmpty) ...[
                        SizedBox(height: 20.h),
                        _SectionHeader('Amenities'),
                        SizedBox(height: 10.h),
                        _InfoCard(child: Wrap(
                          spacing: 8.w, runSpacing: 8.h,
                          children: _model.amenities.map((a) => Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: _cream,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Text(a, style: GoogleFonts.dmSans(
                                fontSize: 12.sp, color: _dark)),
                          )).toList(),
                        )),
                      ],

                      if (_model.culturalExperiences.isNotEmpty) ...[
                        SizedBox(height: 20.h),
                        _SectionHeader('Cultural Experiences'),
                        SizedBox(height: 10.h),
                        _InfoCard(child: Column(
                          children: _model.culturalExperiences.map((e) => Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Icon(Icons.emoji_events_outlined, size: 16.sp, color: _terracotta),
                              SizedBox(width: 8.w),
                              Expanded(child: Text(e, style: GoogleFonts.dmSans(
                                  fontSize: 14.sp, color: Colors.grey[700]))),
                            ]),
                          )).toList(),
                        )),
                      ],

                      // Nearby Heritage Site
                      if (_model.nearCulturalSite != null) ...[
                        SizedBox(height: 20.h),
                        _SectionHeader('Nearby Heritage Site'),
                        SizedBox(height: 10.h),
                        if (_isLoadingSite)
                          const Center(child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator()))
                        else if (_nearbySite != null)
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(
                                builder: (_) => TouristSiteDetailPage(site: _nearbySite!))),
                            child: Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18.r),
                                boxShadow: [BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 12, offset: const Offset(0, 6))],
                              ),
                              child: Row(children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: _nearbySite!.imageUrls.isNotEmpty
                                      ? ProxyImage(imageUrl: _nearbySite!.imageUrls.first,
                                      width: 90.w, height: 90.h, borderRadiusValue: 0)
                                      : Container(width: 90.w, height: 90.h,
                                      color: _terracotta.withValues(alpha: 0.08),
                                      child: Icon(Icons.temple_hindu,
                                          color: _terracotta, size: 32.sp)),
                                ),
                                SizedBox(width: 14.w),
                                Expanded(child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_nearbySite!.isUNESCO)
                                      Container(
                                        margin: EdgeInsets.only(bottom: 4.h),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.w, vertical: 2.h),
                                        decoration: BoxDecoration(
                                            color: _terracotta,
                                            borderRadius: BorderRadius.circular(4.r)),
                                        child: Text('UNESCO', style: GoogleFonts.dmSans(
                                            color: Colors.white, fontSize: 9.sp,
                                            fontWeight: FontWeight.bold)),
                                      ),
                                    Text(_nearbySite!.name ?? '',
                                        style: GoogleFonts.playfairDisplay(
                                            fontSize: 16.sp, fontWeight: FontWeight.bold,
                                            color: _dark)),
                                    SizedBox(height: 6.h),
                                    if (_nearbySite!.district != null)
                                      Text(_nearbySite!.district ?? '',
                                          style: GoogleFonts.dmSans(
                                              fontSize: 13.sp, color: Colors.grey[600])),
                                    if (_nearbySite!.category != null) ...[
                                      SizedBox(height: 2.h),
                                      Text(_nearbySite!.category!,
                                          style: GoogleFonts.dmSans(
                                              fontSize: 11.sp, color: _teal)),
                                    ],
                                    SizedBox(height: 8.h),
                                    Row(children: [
                                      Icon(Icons.arrow_forward_ios_rounded,
                                          size: 14.sp, color: Colors.grey[400]),
                                      SizedBox(width: 4.w),
                                      Text('View Heritage Site', style: GoogleFonts.dmSans(
                                          fontSize: 13.sp, fontWeight: FontWeight.w600,
                                          color: _terracotta)),
                                    ]),
                                  ],
                                )),
                              ]),
                            ),
                          )
                        else
                          _InfoCard(child: Row(children: [
                            Container(
                              width: 48.w, height: 48.h,
                              decoration: BoxDecoration(
                                color: _terracotta.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(Icons.temple_hindu, color: _terracotta, size: 24.sp),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(child: Text(_model.nearCulturalSite!.name,
                                style: GoogleFonts.dmSans(
                                    fontSize: 14.sp, fontWeight: FontWeight.bold,
                                    color: _dark))),
                          ])),
                      ],

                      SizedBox(height: 20.h),
                      _SectionHeader('Your Host'),
                      SizedBox(height: 10.h),
                      _buildHostCard(),

                      SizedBox(height: 28.h),
                      SizedBox(height: 20.h),
                      ReviewsSection(
                        homestayId: _model.id,
                        completedBookingId: _completedBookingId,
                      ),
                      SizedBox(height: 28.h),
                      SizedBox(
                        width: double.infinity, height: 54.h,
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(
                              builder: (_) => BookingFormPage(homestay: _model))),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _terracotta, foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r)),
                          ),
                          child: Text('Book Now', style: GoogleFonts.dmSans(
                              fontSize: 16.sp, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      SizedBox(height: 40.h),
                    ]),
                  ),
                ),
              ],
            ),

            // Back button
            Positioned(
              top: MediaQuery.of(context).padding.top + 8.h,
              left: 8.w,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38.w, height: 38.h,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Icon(Icons.arrow_back, size: 20.sp, color: _dark),
                ),
              ),
            ),

            // Favourite button
            Positioned(
              top: MediaQuery.of(context).padding.top + 8.h,
              right: 8.w,
              child: FavouriteButton(homestayId: _model.id, size: 20, showBackground: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHostCard() {
    final owner = _model.owner;
    if (owner == null) {
      return _InfoCard(child: Row(children: [
        CircleAvatar(radius: 26.r, backgroundColor: Colors.grey[100],
            child: Icon(Icons.person_off_outlined, color: Colors.grey[400], size: 26.sp)),
        SizedBox(width: 14.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Host unavailable', style: GoogleFonts.dmSans(
              fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.grey[600])),
          SizedBox(height: 4.h),
          Text('The host account for this homestay has been removed.',
              style: GoogleFonts.dmSans(
                  fontSize: 12.sp, color: Colors.grey[400], height: 1.4)),
        ])),
      ]));
    }

    final hasPhone  = owner.phoneNumber != null && owner.phoneNumber!.isNotEmpty;
    final hostSince = owner.createdAt?.year.toString();
    final hasImage  = owner.profileImage != null && owner.profileImage!.isNotEmpty;

    return _InfoCard(child: Column(children: [
      Row(children: [
        CircleAvatar(
          radius: 28.r,
          backgroundColor: const Color(0xFFE8DCCD),
          backgroundImage: hasImage ? NetworkImage(owner.profileImage!) : null,
          child: !hasImage
              ? Text(owner.initials, style: GoogleFonts.dmSans(
              fontSize: 20.sp, color: const Color(0xFF2D1B10),
              fontWeight: FontWeight.w600))
              : null,
        ),
        SizedBox(width: 14.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(owner.name, style: GoogleFonts.dmSans(
              fontSize: 16.sp, fontWeight: FontWeight.bold,
              color: const Color(0xFF2D1B10))),
          if (hostSince != null) ...[
            SizedBox(height: 3.h),
            Text('Host since $hostSince',
                style: GoogleFonts.dmSans(fontSize: 12.sp, color: _warmGrey)),
          ],
          if (hasPhone) ...[
            SizedBox(height: 5.h),
            Row(children: [
              Icon(Icons.phone_outlined, size: 13.sp, color: _terracotta),
              SizedBox(width: 4.w),
              Text(owner.phoneNumber!, style: GoogleFonts.dmSans(
                  fontSize: 13.sp, color: _terracotta)),
            ]),
          ],
        ])),
        if (hasPhone)
          OutlinedButton.icon(
            onPressed: () async {
              final uri = Uri(scheme: 'tel', path: owner.phoneNumber);
              if (await canLaunchUrl(uri)) await launchUrl(uri);
            },
            icon: Icon(Icons.phone_rounded, size: 14.sp, color: _terracotta),
            label: Text('Call Host', style: GoogleFonts.dmSans(
                fontSize: 13.sp, fontWeight: FontWeight.w600, color: _terracotta)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: _terracotta.withValues(alpha: 0.4)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            ),
          ),
      ]),
      if (!hasPhone) ...[
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Row(children: [
            Icon(Icons.info_outline, size: 14.sp, color: Colors.amber[700]),
            SizedBox(width: 8.w),
            Expanded(child: Text('Contact details not available for this host.',
                style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.amber[800]))),
          ]),
        ),
      ],
    ]));
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) => Text(title,
      style: GoogleFonts.playfairDisplay(
          fontSize: 18.sp, fontWeight: FontWeight.bold,
          color: const Color(0xFF958A8A)));
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  const _InfoCard({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: Colors.grey.shade100),
      boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 8, offset: const Offset(0, 3))],
    ),
    child: child,
  );
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value, label;
  const _StatTile({required this.icon, required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(vertical: 14.h),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: Colors.grey.shade100),
    ),
    child: Column(children: [
      Icon(icon, size: 22.sp, color: const Color(0xFFCD6E4E)),
      SizedBox(height: 6.h),
      Text(value, style: GoogleFonts.dmSans(
          fontSize: 15.sp, fontWeight: FontWeight.bold,
          color: const Color(0xFF2D1B10))),
      Text(label, style: GoogleFonts.dmSans(
          fontSize: 11.sp, color: const Color(0xFF8B8B8B))),
    ]),
  );
}