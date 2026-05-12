import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/datasources/review_remote_datasource.dart';
import '../../../data/models/review.dart';
import '../../widgets/Helpers/review_dialog.dart';

class MyReviewsPage extends StatefulWidget {
  const MyReviewsPage({super.key});

  @override
  State<MyReviewsPage> createState() => _MyReviewsPageState();
}

class _MyReviewsPageState extends State<MyReviewsPage> {
  static const _terracotta = Color(0xFFCD6E4E);
  static const _dark       = Color(0xFF2D1B10);
  static const _cream      = Color(0xFFFAF7F2);

  final _ds = ReviewRemoteDatasource();
  List<Review> _reviews = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await _ds.getMyReviews();
      if (res.statusCode == 200 && mounted) {
        setState(() {
          _reviews = (res.data as List<dynamic>)
              .map((j) => Review.fromJson(j as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('MyReviewsPage error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18.sp, color: _dark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('My Reviews',
            style: GoogleFonts.playfairDisplay(
                fontSize: 18.sp, fontWeight: FontWeight.bold, color: _dark)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _reviews.isEmpty
          ? _buildEmpty()
          : RefreshIndicator(
        color: _terracotta,
        onRefresh: _load,
        child: ListView.separated(
          padding: EdgeInsets.all(16.w),
          itemCount: _reviews.length,
          separatorBuilder: (_, _) => SizedBox(height: 12.h),
          itemBuilder: (_, i) => _MyReviewCard(
            review: _reviews[i],
            onChanged: _load,
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rate_review_outlined, size: 64.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text("No reviews yet",
              style: GoogleFonts.playfairDisplay(
                  fontSize: 18.sp, color: Colors.grey[400])),
          SizedBox(height: 8.h),
          Text("Reviews you write will appear here.",
              style: GoogleFonts.dmSans(
                  fontSize: 13.sp, color: Colors.grey[400])),
        ],
      ),
    );
  }
}


class _MyReviewCard extends StatelessWidget {
  final Review review;
  final VoidCallback onChanged;

  const _MyReviewCard({required this.review, required this.onChanged});

  static const _dark       = Color(0xFF2D1B10);
  static const _terracotta = Color(0xFFCD6E4E);
  static const _gold       = Color(0xFFC7A26B);

  @override
  Widget build(BuildContext context) {
    final isHomestay = review.homestayId != null;
    final targetName = isHomestay
        ? (review.homestayName ?? 'Homestay')
        : (review.siteName ?? 'Cultural Site');

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(targetName,
                style: GoogleFonts.playfairDisplay(
                    fontSize: 15.sp, fontWeight: FontWeight.bold, color: _dark)),
            SizedBox(height: 4.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: (isHomestay ? _terracotta : const Color(0xFF2D6A6A))
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                isHomestay ? 'Homestay' : 'Cultural Site',
                style: GoogleFonts.dmSans(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: isHomestay ? _terracotta : const Color(0xFF2D6A6A)),
              ),
            ),
          ])),

          // Edit button
          GestureDetector(
            onTap: () async {
              final changed = await showReviewDialog(
                context,
                bookingId:  review.bookingId,
                homestayId: review.homestayId,
                siteId:     review.siteId,
                targetName: targetName,
              );
              if (changed) onChanged();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: _terracotta.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: _terracotta.withValues(alpha: 0.25)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.edit_outlined, size: 13.sp, color: _terracotta),
                SizedBox(width: 4.w),
                Text('Edit',
                    style: GoogleFonts.dmSans(
                        fontSize: 12.sp,
                        color: _terracotta,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ]),

        SizedBox(height: 14.h),

        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: List.generate(5, (i) => Icon(
            i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 18.sp,
            color: _gold,
          ))),
          Text(_formatDate(review.createdAt),
              style: GoogleFonts.dmSans(fontSize: 11.sp, color: Colors.grey[400])),
        ]),

        if (review.comment != null && review.comment!.isNotEmpty) ...[
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF7F2),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(review.comment!,
                style: GoogleFonts.dmSans(
                    fontSize: 13.sp,
                    color: Colors.grey[700],
                    height: 1.5)),
          ),
        ] else ...[
          SizedBox(height: 10.h),
          Text('No comment added.',
              style: GoogleFonts.dmSans(
                  fontSize: 12.sp,
                  color: Colors.grey[400],
                  fontStyle: FontStyle.italic)),
        ],

        if (review.updatedAt.isAfter(
            review.createdAt.add(const Duration(minutes: 1)))) ...[
          SizedBox(height: 8.h),
          Row(children: [
            Icon(Icons.edit_note_rounded, size: 12.sp, color: Colors.grey[400]),
            SizedBox(width: 4.w),
            Text('Edited ${_formatDate(review.updatedAt)}',
                style: GoogleFonts.dmSans(
                    fontSize: 11.sp, color: Colors.grey[400])),
          ]),
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

