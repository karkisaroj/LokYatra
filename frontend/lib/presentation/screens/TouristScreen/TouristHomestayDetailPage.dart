import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/image_proxy.dart';
import 'package:lokyatra_frontend/data/models/Homestay.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_event.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_state.dart';
import '../../../data/models/Site.dart';
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

  @override
  void initState() {
    super.initState();
    _model = Homestay.fromJson(widget.homestay);
    if (_model.nearCulturalSite != null) {
      _isLoadingSite = true;
      context.read<SitesBloc>().add(LoadSiteById(_model.nearCulturalSite!.id));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = _model.imageUrls.isNotEmpty ? _model.imageUrls : <String>[];

    return BlocListener<SitesBloc, SitesState>(
      listener: (context, state) {
        if (state is SiteDetailLoaded) {
          setState(() {
            _nearbySite = state.site;
            _isLoadingSite = false;
          });
        } else if (state is SiteDetailError) {
          setState(() {
            _isLoadingSite = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: _cream,
        body: CustomScrollView(
          slivers: [
            // ── Hero Image Gallery
            SliverAppBar(
              expandedHeight: 340.h,
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
              actions: [
                Container(
                  margin: EdgeInsets.all(8.w),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: IconButton(
                    icon: Icon(Icons.favorite_border_rounded, size: 20.sp, color: _dark),
                    onPressed: () {},
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
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
                        height: double.infinity,
                        borderRadiusValue: 0,
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black26, Colors.transparent, Colors.black54],
                            stops: const [0, 0.4, 1],
                          ),
                        ),
                      ),
                    ),
                    if (images.length > 1) ...[
                      Positioned(
                        top: 12.h, right: 60.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(color: Colors.black54,
                              borderRadius: BorderRadius.circular(20.r)),
                          child: Text('${_currentImageIndex + 1}/${images.length}',
                              style: GoogleFonts.dmSans(
                                  color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      Positioned(
                        bottom: 24.h, left: 0, right: 0,
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
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(
                        child: Text(_model.name,
                            style: GoogleFonts.playfairDisplay(
                                fontSize: 24.sp, fontWeight: FontWeight.bold, color: _dark)),
                      ),
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
                              decoration: BoxDecoration(color: Colors.green.shade600,
                                  shape: BoxShape.circle)),
                          SizedBox(width: 5.w),
                          Text('Available',
                              style: GoogleFonts.dmSans(fontSize: 11.sp,
                                  color: Colors.green.shade700, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ]),
                    SizedBox(height: 8.h),

                    Row(children: [
                      Icon(Icons.location_on_outlined, size: 15.sp, color: _warmGrey),
                      SizedBox(width: 4.w),
                      Expanded(child: Text(_model.location,
                          style: GoogleFonts.dmSans(fontSize: 13.sp, color: _warmGrey))),
                    ]),

                    if (_model.category != null && _model.category!.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Row(children: [
                        Icon(Icons.category_outlined, size: 15.sp, color: _warmGrey),
                        SizedBox(width: 4.w),
                        Text(_model.category!,
                            style: GoogleFonts.dmSans(fontSize: 13.sp, color: _warmGrey)),
                      ]),
                    ],

                    SizedBox(height: 6.h),
                    Row(children: [
                      Icon(Icons.star_rounded, color: const Color(0xFFC7A26B), size: 16.sp),
                      SizedBox(width: 4.w),
                      Text('4.7', style: GoogleFonts.dmSans(
                          fontSize: 13.sp, fontWeight: FontWeight.bold, color: _dark)),
                      Text(' (45 reviews)',
                          style: GoogleFonts.dmSans(fontSize: 12.sp, color: _warmGrey)),
                    ]),

                    SizedBox(height: 20.h),

                    // ── Price
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: _terracotta.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: _terracotta.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Price per night',
                                style: GoogleFonts.dmSans(fontSize: 12.sp, color: _warmGrey)),
                            SizedBox(height: 2.h),
                            Text('Rs. ${_model.pricePerNight.toStringAsFixed(0)}',
                                style: GoogleFonts.dmSans(fontSize: 26.sp,
                                    color: _terracotta, fontWeight: FontWeight.w800)),
                          ]),
                          Text('+13% VAT',
                              style: GoogleFonts.dmSans(fontSize: 12.sp, color: _warmGrey)),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // ── Quick Stats ──────────────────────────────────────
                    Row(children: [
                      Expanded(child: _StatTile(
                          icon: Icons.king_bed_outlined, value: '${_model.numberOfRooms}', label: 'Rooms')),
                      SizedBox(width: 10.w),
                      Expanded(child: _StatTile(
                          icon: Icons.people_outline_rounded, value: '${_model.maxGuests}', label: 'Guests')),
                      SizedBox(width: 10.w),
                      Expanded(child: _StatTile(
                          icon: Icons.bathtub_outlined, value: '${_model.bathrooms}', label: 'Baths')),
                    ]),

                    SizedBox(height: 24.h),

                    // ── About ────────────────────────────────────────────
                    _SectionHeader('About this Homestay'),
                    SizedBox(height: 10.h),
                    _InfoCard(child: Text(
                      _model.description.isNotEmpty
                          ? _model.description
                          : 'Experience authentic Nepali hospitality at this traditional home.',
                      style: GoogleFonts.dmSans(fontSize: 14.sp, height: 1.65, color: Colors.grey[700]),
                    )),

                    // ── Amenities
                    if (_model.amenities.isNotEmpty) ...[
                      SizedBox(height: 20.h),
                      _SectionHeader('Amenities'),
                      SizedBox(height: 10.h),
                      _InfoCard(child: Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: _model.amenities.map((a) => Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: _cream,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(a, style: GoogleFonts.dmSans(fontSize: 12.sp, color: _dark)),
                        )).toList(),
                      )),
                    ],

                    // ── Cultural Experiences
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
                            Expanded(child: Text(e,
                                style: GoogleFonts.dmSans(fontSize: 14.sp, color: Colors.grey[700]))),
                          ]),
                        )).toList(),
                      )),
                    ],

                    // ── Nearby Heritage Site (with image + tap)
                    if (_model.nearCulturalSite != null) ...[
                      SizedBox(height: 20.h),
                      _SectionHeader('Nearby Heritage Site'),
                      SizedBox(height: 10.h),
                      if (_isLoadingSite)
                        const Center(child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ))
                      else if (_nearbySite != null)
                        GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TouristSiteDetailPage(
                                    site: _nearbySite!,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Row(
                                    children: [
                                      if (_nearbySite!.imageUrls.isNotEmpty)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12.r),
                                          child: ProxyImage(
                                            imageUrl: _nearbySite!.imageUrls.first,
                                            width: 90.w,
                                            height: 90.h,
                                            borderRadiusValue: 0,
                                          ),
                                        )
                                      else
                                        Container(
                                          width: 90.w,
                                          height: 90.h,
                                          color: _terracotta.withValues(alpha: 0.08),
                                          child: Icon(Icons.temple_hindu,
                                              color: _terracotta, size: 32.sp),
                                        ),
                                      SizedBox(width: 14.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (_nearbySite!.isUNESCO)
                                              Container(
                                                margin: EdgeInsets.only(bottom: 4.h),
                                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                                decoration: BoxDecoration(
                                                  color: _terracotta,
                                                  borderRadius: BorderRadius.circular(4.r),
                                                ),
                                                child: Text('UNESCO',
                                                    style: GoogleFonts.dmSans(color: Colors.white,
                                                        fontSize: 9.sp, fontWeight: FontWeight.bold)),
                                              ),
                                            Text(
                                              _nearbySite!.name ?? '',
                                              style: GoogleFonts.playfairDisplay(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold,
                                                color: _dark,
                                              ),
                                            ),
                                            SizedBox(height: 6.h),
                                            if (_nearbySite!.district != null)
                                              Text(
                                                _nearbySite!.district ?? '',
                                                style: GoogleFonts.dmSans(
                                                  fontSize: 13.sp,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            if (_nearbySite!.category != null) ...[
                                              SizedBox(height: 2.h),
                                              Text(_nearbySite!.category!,
                                                  style: GoogleFonts.dmSans(fontSize: 11.sp, color: _teal)),
                                            ],
                                            SizedBox(height: 8.h),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.arrow_forward_ios_rounded,
                                                  size: 14.sp,
                                                  color: Colors.grey[400],
                                                ),
                                                SizedBox(width: 4.w),
                                                Text(
                                                  "View Heritage Site",
                                                  style: GoogleFonts.dmSans(
                                                    fontSize: 13.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: _terracotta,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]
                                )
                            )
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
                              style: GoogleFonts.dmSans(fontSize: 14.sp,
                                  fontWeight: FontWeight.bold, color: _dark))),
                        ])),
                    ],

                    // ── Host ─────────────────────────────────────────────
                    SizedBox(height: 20.h),
                    _SectionHeader('Your Host'),
                    SizedBox(height: 10.h),
                    _buildHostCard(),

                    SizedBox(height: 28.h),

                    // ── Book Now ─────────────────────────────────────────
                    SizedBox(
                      width: double.infinity, height: 54.h,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => BookingFormPage(homestay: widget.homestay))),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _terracotta,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                        ),
                        child: Text('Book Now',
                            style: GoogleFonts.dmSans(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHostCard() {
    final owner = _model.owner;

    // ── Deleted user / no owner ──────────────────────────────────────
    if (owner == null) {
      return _InfoCard(child: Row(children: [
        CircleAvatar(
          radius: 26.r,
          backgroundColor: Colors.grey[100],
          child: Icon(Icons.person_off_outlined, color: Colors.grey[400], size: 26.sp),
        ),
        SizedBox(width: 14.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Host unavailable',
              style: GoogleFonts.dmSans(fontSize: 15.sp,
                  fontWeight: FontWeight.bold, color: Colors.grey[600])),
          SizedBox(height: 4.h),
          Text('The host account for this homestay has been removed.',
              style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.grey[400], height: 1.4)),
        ])),
      ]));
    }

    final hasPhone = owner.phoneNumber != null && owner.phoneNumber!.isNotEmpty;
    final hostSince = owner.createdAt?.year.toString();
    final hasImage = owner.profileImage != null && owner.profileImage!.isNotEmpty;

    return _InfoCard(child: Column(children: [
      Row(children: [
        CircleAvatar(
          radius: 28.r,
          backgroundColor: const Color(0xFFE8DCCD),
          backgroundImage: hasImage ? NetworkImage(owner.profileImage!) : null,
          child: !hasImage
              ? Text(owner.initials,
              style: GoogleFonts.dmSans(fontSize: 20.sp,
                  color: const Color(0xFF2D1B10), fontWeight: FontWeight.w600))
              : null,
        ),
        SizedBox(width: 14.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(owner.name,
              style: GoogleFonts.dmSans(fontSize: 16.sp,
                  fontWeight: FontWeight.bold, color: const Color(0xFF2D1B10))),
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
              Text(owner.phoneNumber!,
                  style: GoogleFonts.dmSans(fontSize: 13.sp, color: _terracotta)),
            ]),
          ],
        ])),
        if (hasPhone)
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            ),
            child: Text('Contact',
                style: GoogleFonts.dmSans(fontSize: 13.sp,
                    fontWeight: FontWeight.w600, color: const Color(0xFF2D1B10))),
          ),
      ]),
      // Warn if no contact info
      if (!hasPhone) ...[
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(8.r),
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

// ── Shared widgets ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) => Text(title,
      style: GoogleFonts.playfairDisplay(
          fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(
          0xFF958A8A)));
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: Colors.grey.shade100),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 8, offset: const Offset(0, 3))],
    ),
    child: child,
  );
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatTile({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(vertical: 14.h),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: Colors.grey.shade100),
    ),
    child: Column(children: [
      Icon(icon, size: 22.sp, color: const Color(0xFFCD6E4E)),
      SizedBox(height: 6.h),
      Text(value, style: GoogleFonts.dmSans(fontSize: 15.sp,
          fontWeight: FontWeight.bold, color: const Color(0xFF2D1B10))),
      Text(label, style: GoogleFonts.dmSans(fontSize: 11.sp, color: const Color(0xFF8B8B8B))),
    ]),
  );
}