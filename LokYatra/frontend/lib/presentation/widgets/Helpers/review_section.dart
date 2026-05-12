import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/datasources/review_remote_datasource.dart';
import '../../../data/models/review.dart';
import 'review_dialog.dart';

class ReviewsSection extends StatefulWidget {
  final int? homestayId;
  final int? siteId;
  final int? completedBookingId;   // non-null = tourist has a completed booking here
  final bool canReviewSite;

  const ReviewsSection({
    super.key,
    this.homestayId,
    this.siteId,
    this.completedBookingId,
    this.canReviewSite = false,
  });

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  static const _terracotta = Color(0xFFCD6E4E);
  static const _dark       = Color(0xFF2D1B10);
  static const _gold       = Color(0xFFC7A26B);

  final _datasource = ReviewRemoteDatasource();
  List<Review> _reviews = [];
  bool _loading = true;
  bool _showAll = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final resp = widget.homestayId != null
          ? await _datasource.getHomestayReviews(widget.homestayId!)
          : await _datasource.getSiteReviews(widget.siteId!);
      if (resp.statusCode == 200 && mounted) {
        setState(() {
          _reviews = (resp.data as List<dynamic>).map((j) => Review.fromJson(j as Map<String, dynamic>)).toList();
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  double get _average => _reviews.isEmpty ? 0.0 : _reviews.fold(0.0, (s, r) => s + r.rating) / _reviews.length;

  Widget _stars(double avg, {double size = 16}) {
    return Row(mainAxisSize: MainAxisSize.min, children: List.generate(5, (i) {
      final full = i + 1 <= avg.floor();
      final half = !full && (avg - i) >= 0.5;
      return Icon(
        full ? Icons.star_rounded : half ? Icons.star_half_rounded : Icons.star_outline_rounded,
        size: size,
        color: _gold,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    final canWrite = widget.completedBookingId != null || widget.canReviewSite;
    final displayed = _showAll ? _reviews : _reviews.take(3).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Reviews',
            style: GoogleFonts.playfairDisplay(
                fontSize: 18.sp, fontWeight: FontWeight.bold,
                color: const Color(0xFF958A8A))),
        if (canWrite)
          GestureDetector(
            onTap: () async {
              final changed = await showReviewDialog(
                context,
                bookingId: widget.completedBookingId,
                homestayId: widget.homestayId,
                siteId: widget.siteId,
                targetName: '',
              );
              if (changed) _load();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: _terracotta.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: _terracotta.withValues(alpha: 0.3)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.rate_review_outlined, size: 14.sp, color: _terracotta),
                SizedBox(width: 5.w),
                Text('Write Review', style: GoogleFonts.dmSans(
                    fontSize: 12.sp, color: _terracotta, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
      ]),

      SizedBox(height: 10.h),

      if (_reviews.isNotEmpty) ...[
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Row(children: [
            Column(children: [
              Text(_average.toStringAsFixed(1),
                  style: GoogleFonts.dmSans(
                      fontSize: 36.sp, fontWeight: FontWeight.w800, color: _dark)),
              _stars(_average, size: 18),
              SizedBox(height: 4.h),
              Text('${_reviews.length} review${_reviews.length != 1 ? 's' : ''}',
                  style: GoogleFonts.dmSans(fontSize: 11.sp, color: Colors.grey[500])),
            ]),
            SizedBox(width: 20.w),
            // Rating bars
            Expanded(child: Column(
              children: List.generate(5, (i) {
                final star = 5 - i;
                final count = _reviews.where((r) => r.rating == star).length;
                final fraction = _reviews.isEmpty ? 0.0 : count / _reviews.length;
                return Padding(
                  padding: EdgeInsets.only(bottom: 5.h),
                  child: Row(children: [
                    Text('$star', style: GoogleFonts.dmSans(
                        fontSize: 11.sp, color: Colors.grey[500])),
                    SizedBox(width: 6.w),
                    Icon(Icons.star_rounded, size: 11.sp, color: _gold),
                    SizedBox(width: 6.w),
                    Expanded(child: ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: LinearProgressIndicator(
                        value: fraction,
                        backgroundColor: Colors.grey[100],
                        color: _gold,
                        minHeight: 6,
                      ),
                    )),
                    SizedBox(width: 6.w),
                    SizedBox(
                      width: 20.w,
                      child: Text('$count', style: GoogleFonts.dmSans(
                          fontSize: 11.sp, color: Colors.grey[500])),
                    ),
                  ]),
                );
              }),
            )),
          ]),
        ),
        SizedBox(height: 14.h),
      ],

      if (_loading)
        const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))

      else if (_reviews.isEmpty)
        Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Center(child: Column(children: [
            Icon(Icons.rate_review_outlined, size: 40.sp, color: Colors.grey[300]),
            SizedBox(height: 10.h),
            Text('No reviews yet', style: GoogleFonts.dmSans(
                fontSize: 14.sp, color: Colors.grey[400])),
            if (canWrite) ...[
              SizedBox(height: 6.h),
              Text('Be the first to share your experience!',
                  style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.grey[400])),
            ],
          ])),
        )

      else
        Column(children: [
          ...displayed.map((r) => _ReviewCard(review: r)),
          if (_reviews.length > 3) ...[
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: () => setState(() => _showAll = !_showAll),
              child: Center(child: Text(
                _showAll
                    ? 'Show less'
                    : 'Show all ${_reviews.length} reviews',
                style: GoogleFonts.dmSans(
                    fontSize: 13.sp, color: _terracotta, fontWeight: FontWeight.w600),
              )),
            ),
          ],
        ]),
    ]);
  }
}


class _ReviewCard extends StatelessWidget {
  final Review review;
  const _ReviewCard({required this.review});

  static const _gold = Color(0xFFC7A26B);
  static const _dark = Color(0xFF2D1B10);

  @override
  Widget build(BuildContext context) {
    final hasImage = review.touristImage.isNotEmpty;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: const Color(0xFFE8DCCD),
            backgroundImage: hasImage ? NetworkImage(review.touristImage) : null,
            child: !hasImage
                ? Text(
              review.touristName.isNotEmpty ? review.touristName[0].toUpperCase() : '?',
              style: GoogleFonts.dmSans(
                  fontSize: 14.sp, fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D1B10)),
            )
                : null,
          ),
          SizedBox(width: 10.w),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(review.touristName,
                style: GoogleFonts.dmSans(
                    fontSize: 13.sp, fontWeight: FontWeight.w600, color: _dark)),
            Text(_formatDate(review.createdAt),
                style: GoogleFonts.dmSans(fontSize: 11.sp, color: Colors.grey[500])),
          ])),
          // Stars
          Row(children: List.generate(5, (i) => Icon(
            i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 14.sp, color: _gold,
          ))),
        ]),
        if (review.comment != null && review.comment!.isNotEmpty) ...[
          SizedBox(height: 10.h),
          Text(review.comment!,
              style: GoogleFonts.dmSans(
                  fontSize: 13.sp, height: 1.55, color: Colors.grey[700])),
        ],
      ]),
    );
  }

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

