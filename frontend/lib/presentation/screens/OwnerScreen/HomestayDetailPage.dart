import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/image_proxy.dart';
import 'package:lokyatra_frontend/data/datasources/homestays_remote_datasource.dart';
import 'package:lokyatra_frontend/data/models/Homestay.dart';

class HomestayDetailPage extends StatefulWidget {
  final Homestay homestay;
  const HomestayDetailPage({super.key, required this.homestay});

  @override
  State<HomestayDetailPage> createState() => _HomestayDetailPageState();
}

class _HomestayDetailPageState extends State<HomestayDetailPage> {
  final PageController _pageController = PageController();
  int _currentImage = 0;
  bool _isVisible = false;
  bool _toggling = false;

  static const _brown = Color(0xFF5C4033);

  @override
  void initState() {
    super.initState();
    _isVisible = widget.homestay.isVisible;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _toggleVisibility() async {
    final newVal = !_isVisible;
    setState(() { _isVisible = newVal; _toggling = true; });
    try {
      final res = await HomestaysRemoteDatasource()
          .toggleVisibility(widget.homestay.id, newVal);
      if (res.statusCode != 200 && res.statusCode != 204) {
        if (mounted) setState(() => _isVisible = !newVal);
        _snack('Failed to update visibility');
      } else {
        _snack(newVal ? 'Homestay is now Active' : 'Homestay is now Inactive',
            isError: false);
      }
    } catch (_) {
      if (mounted) setState(() => _isVisible = !newVal);
      _snack('Connection error. Try again.');
    } finally {
      if (mounted) setState(() => _toggling = false);
    }
  }

  void _snack(String msg, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.dmSans()),
      backgroundColor: isError ? Colors.red[700] : Colors.green[600],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      margin: EdgeInsets.all(12.w),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.homestay;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Homestay Details',
            style: GoogleFonts.dmSans(color: Colors.white, fontSize: 16.sp)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carousel
            SizedBox(
              height: 260.h,
              child: h.imageUrls.isEmpty
                  ? Container(
                  color: Colors.grey[200],
                  child: Icon(Icons.image_not_supported,
                      size: 60.sp, color: Colors.grey))
                  : Stack(children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: h.imageUrls.length,
                  onPageChanged: (i) =>
                      setState(() => _currentImage = i),
                  itemBuilder: (_, i) => ProxyImage(
                    imageUrl: h.imageUrls[i],
                    width: double.infinity,
                    height: 260.h,
                    borderRadiusValue: 0,
                  ),
                ),
                Positioned(
                  right: 12.w,
                  bottom: 12.h,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20.r)),
                    child: Text(
                        '${_currentImage + 1} / ${h.imageUrls.length}',
                        style: GoogleFonts.dmSans(
                            color: Colors.white, fontSize: 12.sp)),
                  ),
                ),
              ]),
            ),

            // Thumbnails
            if (h.imageUrls.length > 1)
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
                child: SizedBox(
                  height: 64.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: h.imageUrls.length,
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () => _pageController.animateToPage(i,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut),
                      child: Container(
                        margin: EdgeInsets.only(right: 8.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: _currentImage == i
                                ? _brown
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6.r),
                          child: ProxyImage(
                              imageUrl: h.imageUrls[i],
                              width: 60.w,
                              height: 60.h,
                              borderRadiusValue: 0),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            SizedBox(height: 14.h),

            // Name + visibility badge
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(h.name,
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 22.sp, fontWeight: FontWeight.bold)),
                  ),
                  GestureDetector(
                    onTap: _toggling ? null : _toggleVisibility,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: _isVisible ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: _toggling
                          ? SizedBox(
                          width: 14.w,
                          height: 14.h,
                          child: const CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                          : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white,
                            size: 13.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            _isVisible ? 'Active' : 'Inactive',
                            style: GoogleFonts.dmSans(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Visibility card
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: _isVisible
                      ? Colors.green.withValues(alpha: 0.07)
                      : Colors.grey.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: _isVisible
                        ? Colors.green.withValues(alpha: 0.3)
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isVisible
                          ? Icons.check_circle_outline
                          : Icons.pause_circle_outline,
                      color: _isVisible ? Colors.green : Colors.grey,
                      size: 22.sp,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isVisible ? 'Listing is Active' : 'Listing is Inactive',
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.sp,
                              color: _isVisible ? Colors.green : Colors.grey[600],
                            ),
                          ),
                          Text(
                            _isVisible
                                ? 'Guests can find and book this homestay'
                                : 'Hidden from guests — no new bookings',
                            style: GoogleFonts.dmSans(
                                fontSize: 11.sp, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    _toggling
                        ? SizedBox(
                        width: 24.w,
                        height: 24.h,
                        child: const CircularProgressIndicator(strokeWidth: 2))
                        : Switch(
                      value: _isVisible,
                      activeThumbColor: Colors.green,
                      onChanged: (_) => _toggleVisibility(),
                    ),
                  ],
                ),
              ),
            ),

            // Category
            if (h.category != null && h.category!.isNotEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _brown.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: _brown.withValues(alpha: 0.3)),
                  ),
                  child: Text(h.category!,
                      style: GoogleFonts.dmSans(
                          fontSize: 12.sp,
                          color: _brown,
                          fontWeight: FontWeight.w600)),
                ),
              ),

            // Location
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
              child: Row(
                children: [
                  Icon(Icons.location_on, size: 15.sp, color: Colors.grey),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(h.location,
                        style: GoogleFonts.dmSans(
                            fontSize: 13.sp, color: Colors.grey[700])),
                  ),
                ],
              ),
            ),

            if (h.nearCulturalSite != null &&
                h.nearCulturalSite!.name.isNotEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0),
                child: Row(
                  children: [
                    Icon(Icons.temple_hindu, size: 15.sp, color: Colors.grey),
                    SizedBox(width: 4.w),
                    Text('Near ${h.nearCulturalSite!.name}',
                        style: GoogleFonts.dmSans(
                            fontSize: 13.sp, color: Colors.grey[700])),
                  ],
                ),
              ),

            // Price
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('Rs. ${h.pricePerNight.toStringAsFixed(0)}',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.bold,
                          color: _brown)),
                  SizedBox(width: 4.w),
                  Text('/ night',
                      style:
                      GoogleFonts.dmSans(fontSize: 14.sp, color: Colors.grey)),
                ],
              ),
            ),

            // Capacity
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 0),
              child: Row(
                children: [
                  _chip(Icons.bed_outlined, '${h.numberOfRooms} Rooms'),
                  SizedBox(width: 8.w),
                  _chip(Icons.people_outline, '${h.maxGuests} Guests'),
                  SizedBox(width: 8.w),
                  _chip(Icons.bathtub_outlined, '${h.bathrooms} Baths'),
                ],
              ),
            ),

            _divider(),
            _heading('Performance'),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  _stat('12', 'Total\nBookings'),
                  SizedBox(width: 8.w),
                  _stat('3', 'This\nMonth'),
                  SizedBox(width: 8.w),
                  _stat('4.8 ★', 'Avg.\nRating'),
                  SizedBox(width: 8.w),
                  _stat('67%', 'Occupancy'),
                ],
              ),
            ),

            _divider(),
            _heading('About This Homestay'),
            _bodyText(h.description),

            if (h.culturalSignificance != null && h.culturalSignificance!.isNotEmpty) ...[
              SizedBox(height: 16.h),
              _heading('Cultural Significance'),
              _bodyText(h.culturalSignificance!),
            ],
            if (h.buildingHistory != null && h.buildingHistory!.isNotEmpty) ...[
              SizedBox(height: 16.h),
              _heading('Building History'),
              _bodyText(h.buildingHistory!),
            ],
            if (h.traditionalFeatures != null && h.traditionalFeatures!.isNotEmpty) ...[
              SizedBox(height: 16.h),
              _heading('Traditional Features'),
              _bodyText(h.traditionalFeatures!),
            ],

            _divider(),
            _heading('Cultural Experiences'),
            h.culturalExperiences.isEmpty
                ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text('No cultural experiences listed.',
                  style: GoogleFonts.dmSans(
                      fontSize: 13.sp, color: Colors.grey)),
            )
                : Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: h.culturalExperiences
                    .map((e) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🎭  ',
                          style: TextStyle(fontSize: 14.sp)),
                      Expanded(
                        child: Text(e,
                            style: GoogleFonts.dmSans(
                                fontSize: 13.sp, height: 1.5)),
                      ),
                    ],
                  ),
                ))
                    .toList(),
              ),
            ),

            _divider(),
            _heading('Amenities'),
            h.amenities.isEmpty
                ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text('No amenities listed.',
                  style: GoogleFonts.dmSans(
                      fontSize: 13.sp, color: Colors.grey)),
            )
                : Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: h.amenities
                    .map((a) => Chip(
                  avatar: Icon(Icons.check_circle_outline,
                      size: 15.sp, color: _brown),
                  label: Text(a,
                      style: GoogleFonts.dmSans(fontSize: 12.sp)),
                  backgroundColor: _brown.withValues(alpha: 0.07),
                  side: BorderSide(
                      color: _brown.withValues(alpha: 0.3), width: 0.5),
                ))
                    .toList(),
              ),
            ),

            if (h.createdAt != null || h.updatedAt != null) ...[
              _divider(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (h.createdAt != null)
                      Text('Listed on ${_fmt(h.createdAt!)}',
                          style: GoogleFonts.dmSans(
                              fontSize: 11.sp, color: Colors.grey)),
                    if (h.updatedAt != null)
                      Text('Last updated ${_fmt(h.updatedAt!)}',
                          style: GoogleFonts.dmSans(
                              fontSize: 11.sp, color: Colors.grey)),
                  ],
                ),
              ),
            ],

            SizedBox(height: 80.h),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';

  Widget _divider() => Divider(height: 32.h, indent: 16.w, endIndent: 16.w);

  Widget _heading(String t) => Padding(
    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
    child: Text(t,
        style: GoogleFonts.playfairDisplay(
            fontSize: 17.sp, fontWeight: FontWeight.bold)),
  );

  Widget _bodyText(String t) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.w),
    child: Text(t,
        style: GoogleFonts.dmSans(fontSize: 13.sp, height: 1.6)),
  );

  Widget _chip(IconData icon, String label) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13.sp, color: Colors.grey[600]),
        SizedBox(width: 4.w),
        Text(label,
            style: GoogleFonts.dmSans(
                fontSize: 11.sp, color: Colors.grey[700])),
      ],
    ),
  );

  Widget _stat(String val, String label) => Expanded(
    child: Card(
      elevation: 0,
      color: Colors.grey.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
        child: Column(
          children: [
            Text(val,
                style: GoogleFonts.dmSans(
                    fontSize: 15.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 4.h),
            Text(label,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                    fontSize: 9.sp, color: Colors.grey)),
          ],
        ),
      ),
    ),
  );
}