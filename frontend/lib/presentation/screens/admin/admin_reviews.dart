import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/review.dart';
import '../../../core/services/image_proxy.dart';
import '../../state_management/Bloc/review/review_bloc.dart';
import '../../state_management/Bloc/review/review_event.dart';
import '../../state_management/Bloc/review/review_state.dart';

const _ink    = Color(0xFF0F172A);
const _muted  = Color(0xFF64748B);
const _accent = Color(0xFF334155);
const _bg     = Color(0xFFF8FAFC);
const _border = Color(0xFFE2E8F0);
const _gold   = Color(0xFFF59E0B);

class AdminReviews extends StatelessWidget {
  const AdminReviews({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReviewBloc()..add(const LoadAllReviews()),
      child: const _ReviewsContent(),
    );
  }
}

class _ReviewsContent extends StatefulWidget {
  const _ReviewsContent();

  @override
  State<_ReviewsContent> createState() => _ReviewsContentState();
}

class _ReviewsContentState extends State<_ReviewsContent> {

  String _typeFilter  = 'all';
  int?   _ratingFilter;

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 700;

    return BlocConsumer<ReviewBloc, ReviewState>(
      listener: (context, state) {
        if (state is ReviewError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message, style: GoogleFonts.inter()),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      builder: (context, state) {
        final reviews = state is AllReviewsLoaded ? state.reviews : <Review>[];

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Container(
            color: _bg,
            padding: isWeb
                ? const EdgeInsets.fromLTRB(24, 20, 24, 16)
                : EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
            child: isWeb
                ? Row(children: [
              Text('Reviews',
                  style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _ink)),
              const Spacer(),
              _TypeFilter(
                value: _typeFilter,
                onChanged: (v) {
                  setState(() => _typeFilter = v);
                  context.read<ReviewBloc>().add(LoadAllReviews(
                    type: v == 'all' ? null : v,
                    rating: _ratingFilter,
                  ));
                },
              ),
              const SizedBox(width: 12),
              _RatingFilter(
                value: _ratingFilter,
                onChanged: (v) {
                  setState(() => _ratingFilter = v);
                  context.read<ReviewBloc>().add(LoadAllReviews(
                    type: _typeFilter == 'all' ? null : _typeFilter,
                    rating: v,
                  ));
                },
              ),
            ])
                : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Reviews',
                  style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: _ink)),
              SizedBox(height: 12.h),
              Row(children: [
                Expanded(
                  child: _TypeFilter(
                    value: _typeFilter,
                    onChanged: (v) {
                      setState(() => _typeFilter = v);
                      context.read<ReviewBloc>().add(LoadAllReviews(
                        type: v == 'all' ? null : v,
                        rating: _ratingFilter,
                      ));
                    },
                  ),
                ),
                SizedBox(width: 10.w),
                _RatingFilter(
                  value: _ratingFilter,
                  onChanged: (v) {
                    setState(() => _ratingFilter = v);
                    context.read<ReviewBloc>().add(LoadAllReviews(
                      type: _typeFilter == 'all' ? null : _typeFilter,
                      rating: v,
                    ));
                  },
                ),
              ]),
            ]),
          ),

          Divider(height: 1, color: _border),

          if (state is AllReviewsLoaded) ...[
            Container(
              color: _bg,
              padding: isWeb
                  ? const EdgeInsets.fromLTRB(24, 12, 1195, 16)
                  : EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 14.h),
              child: Wrap(spacing: 16, runSpacing: 10, children: [
                _StatChip('Total', '${reviews.length}',
                    Icons.rate_review_outlined, Colors.blue[700]!),
                _StatChip(
                    'Homestay',
                    '${reviews.where((r) => r.homestayId != null).length}',
                    Icons.home_outlined,
                    _accent),
                if (reviews.isNotEmpty)
                  _StatChip(
                      'Avg Rating',
                      (reviews.fold(0.0, (s, r) => s + r.rating) /
                          reviews.length)
                          .toStringAsFixed(1),
                      Icons.star_rounded,
                      _gold),
              ]),
            ),
            Divider(height: 1, color: _border),
          ],

          Expanded(
            child: state is ReviewLoading
                ? const Center(child: CircularProgressIndicator())
                : reviews.isEmpty
                ? Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.rate_review_outlined,
                          size: 48, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Text('No reviews found',
                          style: GoogleFonts.inter(
                              color: _muted, fontSize: 15)),
                    ]))
                : isWeb
                ? _WebTable(reviews: reviews)
                : _MobileList(reviews: reviews),
          ),
        ]);
      },
    );
  }
}

class _WebTable extends StatelessWidget {
  final List<Review> reviews;
  const _WebTable({required this.reviews});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width - 48,
              ),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(_bg),
                dataRowMinHeight: 60,
                dataRowMaxHeight: 80,
                columns: [
                  'Tourist',
                  'Target',
                  'Type',
                  'Rating',
                  'Comment',
                  'Date',
                  'Action'
                ]
                    .map((h) => DataColumn(
                  label: Text(h,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _muted)),
                ))
                    .toList(),
                rows: reviews.map((r) {
                  final isHomestay = r.homestayId != null;
                  return DataRow(cells: [
                    DataCell(_TouristCell(review: r)),
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 160),
                        child: Text(
                          isHomestay
                              ? (r.homestayName ?? '—')
                              : (r.siteName ?? '—'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              color: _ink,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isHomestay ? _accent : _muted)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isHomestay ? 'Homestay' : 'Site',
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isHomestay ? _accent : _muted),
                        ),
                      ),
                    ),
                    DataCell(_StarRating(rating: r.rating)),
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 200),
                        child: Text(
                          r.comment ?? '—',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                              fontSize: 12, color: _muted),
                        ),
                      ),
                    ),
                    DataCell(Text(
                      _fmtDate(r.createdAt),
                      style: GoogleFonts.inter(
                          fontSize: 12, color: _muted),
                    )),
                    DataCell(_DeleteButton(review: r)),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }
}

class _MobileList extends StatelessWidget {
  final List<Review> reviews;
  const _MobileList({required this.reviews});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
      itemCount: reviews.length,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (context, i) => _MobileReviewCard(review: reviews[i]),
    );
  }
}

class _MobileReviewCard extends StatelessWidget {
  final Review review;
  const _MobileReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final isHomestay = review.homestayId != null;
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _TouristCell(review: review),
          const Spacer(),
          _DeleteButton(review: review),
        ]),
        SizedBox(height: 10.h),
        Row(children: [
          _StarRating(rating: review.rating),
          SizedBox(width: 10.w),
          Container(
            padding:
            EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: (isHomestay ? _accent : _muted)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              isHomestay ? 'Homestay' : 'Site',
              style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: isHomestay ? _accent : _muted),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              isHomestay
                  ? (review.homestayName ?? '')
                  : (review.siteName ?? ''),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                  fontSize: 12.sp, color: _muted),
            ),
          ),
        ]),
        if (review.comment != null && review.comment!.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Text(
            review.comment!,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: _muted,
                height: 1.5),
          ),
        ],
      ]),
    );
  }
}

class _TouristCell extends StatelessWidget {
  final Review review;
  const _TouristCell({required this.review});

  @override
  Widget build(BuildContext context) {
    final hasImage = review.touristImage.isNotEmpty;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Stack(
        children: [
          ProxyImage(
            imageUrl: review.touristImage,
            width: 32,
            height: 32,
            borderRadiusValue: 16,
            fit: BoxFit.cover,
          ),
          if (!hasImage)
            Positioned.fill(
              child: Center(
                child: Text(
                  review.touristName.isNotEmpty
                      ? review.touristName[0].toUpperCase()
                      : '?',
                   style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _ink),
                ),
              ),
            ),
        ],
      ),
      const SizedBox(width: 8),
      Flexible(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 120),
          child: Text(
            review.touristName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _ink),
          ),
        ),
      ),
    ]);
  }
}

class _StarRating extends StatelessWidget {
  final int rating;
  const _StarRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
            (i) => Icon(
          i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 14,
          color: _gold,
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final Review review;
  const _DeleteButton({required this.review});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete_outline_rounded,
          color: Colors.red, size: 20),
      tooltip: 'Delete review',
      onPressed: () => _confirmDelete(context),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Delete Review?',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w800, color: _ink)),
        content: Text('This cannot be undone.',
            style: GoogleFonts.inter(color: _muted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: _muted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ReviewBloc>().add(DeleteReview(review.id));
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700], elevation: 0),
            child: Text('Delete',
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _TypeFilter extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _TypeFilter({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          style: GoogleFonts.inter(
              fontSize: 13, color: _ink),
          items: const [
            DropdownMenuItem(value: 'all', child: Text('All Types')),
            DropdownMenuItem(
                value: 'homestay', child: Text('Homestay')),
            DropdownMenuItem(value: 'site', child: Text('Site')),
          ],
          onChanged: (v) => v != null ? onChanged(v) : null,
        ),
      ),
    );
  }
}

class _RatingFilter extends StatelessWidget {
  final int? value;
  final ValueChanged<int?> onChanged;
  const _RatingFilter(
      {required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: value,
          isDense: true,
          style: GoogleFonts.dmSans(
              fontSize: 13, color: const Color(0xFF2D1B10)),
          items: [
            const DropdownMenuItem(
                value: null, child: Text('All Ratings')),
            ...List.generate(
              5,
                  (i) => DropdownMenuItem(
                value: 5 - i,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.star_rounded,
                      size: 14, color: Colors.amber[600]),
                  const SizedBox(width: 4),
                  Text('${5 - i} Star'),
                ]),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatChip(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Text('$label: ',
            style: GoogleFonts.inter(
                fontSize: 12, color: _muted)),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color)),
      ]),
    );
  }
}
