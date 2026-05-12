import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/datasources/review_remote_datasource.dart';
import '../../../data/models/review.dart';

class ReviewDialog extends StatefulWidget {
  final int? bookingId;
  final int? homestayId;
  final int? siteId;
  final String targetName;

  const ReviewDialog({
    super.key,
    this.bookingId,
    this.homestayId,
    this.siteId,
    required this.targetName,
  });

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  static const _terracotta = Color(0xFFCD6E4E);
  static const _dark       = Color(0xFF2D1B10);

  final _commentCtrl  = TextEditingController();
  final _datasource   = ReviewRemoteDatasource();

  Review? _existing;
  bool _checkingExisting = true;
  bool _submitting       = false;
  int  _rating           = 0;

  @override
  void initState() {
    super.initState();
    _checkExisting();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkExisting() async {
    try {
      Response resp;
      if (widget.bookingId != null) {
        resp = await _datasource.getMyBookingReview(widget.bookingId!);
      } else if (widget.siteId != null) {
        resp = await _datasource.getMySiteReview(widget.siteId!);
      } else {
        return;
      }

      if (resp.statusCode == 200 && resp.data != null) {
        final review = Review.fromJson(resp.data as Map<String, dynamic>);
        if (mounted) {
          setState(() {
          _existing = review;
          _rating   = review.rating;
          _commentCtrl.text = review.comment ?? '';
        });
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _checkingExisting = false);
    }
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      _showSnack('Please select a star rating', Colors.red[700]!);
      return;
    }
    setState(() => _submitting = true);
    try {
      final comment = _commentCtrl.text.trim().isEmpty ? null : _commentCtrl.text.trim();
      Response resp;

      if (_existing != null) {
        resp = await _datasource.updateReview(_existing!.id, rating: _rating, comment: comment);
      } else if (widget.bookingId != null && widget.homestayId != null) {
        resp = await _datasource.createHomestayReview(
          bookingId: widget.bookingId!,
          homestayId: widget.homestayId!,
          rating: _rating,
          comment: comment,
        );
      } else if (widget.siteId != null) {
        resp = await _datasource.createSiteReview(siteId: widget.siteId!, rating: _rating, comment: comment);
      } else {
        return;
      }

      if (!mounted) return;
      if (resp.statusCode == 200) {
        Navigator.pop(context, true);
        _showSnack(_existing != null ? 'Review updated!' : 'Review submitted!', const Color(0xFF2E9E6B));
      } else {
        final msg = (resp.data as Map<String, dynamic>?)?['message'] ?? 'Failed to submit';
        _showSnack(msg.toString(), Colors.red[700]!);
      }
    } catch (e) {
      if (mounted) _showSnack('Error: $e', Colors.red[700]!);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _delete() async {
    if (_existing == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Delete Review?', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: _dark)),
        content: Text('This cannot be undone.', style: GoogleFonts.dmSans(color: Colors.grey[600])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.dmSans(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700], elevation: 0),
            child: Text('Delete', style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _submitting = true);
    try {
      final resp = await _datasource.deleteReview(_existing!.id);
      if (!mounted) return;
      if (resp.statusCode == 200) {
        Navigator.pop(context, true);
        _showSnack('Review deleted', Colors.grey[700]!);
      }
    } catch (_) {
    } finally {
      if (mounted) setState; if (mounted) setState(() => _submitting = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.dmSans()),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: _checkingExisting
          ? const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()))
          : SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),) ),
                    const SizedBox(height: 20),
            Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                _existing != null ? 'Edit Your Review' : 'Leave a Review',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 20, fontWeight: FontWeight.bold, color: _dark),
              ),
              const SizedBox(height: 4),
              Text(widget.targetName,
                  style: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey[500])),
            ])),
            if (_existing != null)
              IconButton(
                onPressed: _submitting ? null : _delete,
                icon: Icon(Icons.delete_outline_rounded, color: Colors.red[400]),
                tooltip: 'Delete review',
              ),
                    ]),
              const SizedBox(height: 24),

              Text('Your Rating *',
              style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: _dark)),
              const SizedBox(height: 10),
              Row(children: List.generate(5, (i) {
                final star = i + 1;
                return GestureDetector(
                  onTap: () => setState(() => _rating = star),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      star <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 36,
                      color: star <= _rating ? const Color(0xFFC7A26B) : Colors.grey[300],
                ),
              ),
            );
                    })),
                    if (_rating > 0) ...[
            const SizedBox(height: 6),
            Text(
              ['', 'Poor', 'Fair', 'Good', 'Very Good', 'Excellent'][_rating],
              style: GoogleFonts.dmSans(
                  fontSize: 12, color: _terracotta, fontWeight: FontWeight.w600),
            ),],
              const SizedBox(height: 20),
              Text('Comment (optional)',
              style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: _dark)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF7F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: _commentCtrl,
              maxLines: 4,
              maxLength: 1000,
              style: GoogleFonts.dmSans(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Share your experience...',
                hintStyle: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
                counterStyle: GoogleFonts.dmSans(fontSize: 11, color: Colors.grey[400]),
              ),
            ),),
              const SizedBox(height: 20),
              SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _terracotta,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _submitting
                  ? const SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                _existing != null ? 'Update Review' : 'Submit Review',
                style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
              ),
            ]),
          ),
    );
  }
}


Future<bool> showReviewDialog(
    BuildContext context, {
      int? bookingId,
      int? homestayId,
      int? siteId,
      required String targetName,
    }) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ReviewDialog(
      bookingId: bookingId,
      homestayId: homestayId,
      siteId: siteId,
      targetName: targetName,
    ),
  );
  return result == true;
}
