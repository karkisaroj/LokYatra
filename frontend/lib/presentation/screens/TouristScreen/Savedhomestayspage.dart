import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/services/image_proxy.dart';
import '../../../data/datasources/saved_remote_datasource.dart';
import '../../../data/models/Homestay.dart';
import 'TouristHomestayDetailPage.dart';

class SavedHomestaysPage extends StatefulWidget {
  const SavedHomestaysPage({super.key});

  @override
  State<SavedHomestaysPage> createState() => _SavedHomestaysPageState();
}

class _SavedHomestaysPageState extends State<SavedHomestaysPage> {
  static const _dark       = Color(0xFF2D1B10);
  static const _cream      = Color(0xFFFAF7F2);
  static const _terracotta = Color(0xFFCD6E4E);

  List<Map<String, dynamic>> _saved = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final resp = await SavedRemoteDatasource().getSaved();
      if (resp.statusCode == 200) {
        final raw = resp.data as List<dynamic>;
        setState(() {
          _saved = raw.cast<Map<String, dynamic>>();
          _loading = false;
        });
      } else {
        setState(() { _error = 'Failed to load (${resp.statusCode})'; _loading = false; });
      }
    } catch (e) {
      setState(() { _error = 'Network error: $e'; _loading = false; });
    }
  }

  Future<void> _unsave(int savedId, int homestayId) async {
    try {
      await SavedRemoteDatasource().toggleSaved(homestayId);
      setState(() => _saved.removeWhere((s) => s['savedId'] == savedId));
    } catch (_) {}
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
        title: Text('Your Saved',
            style: GoogleFonts.playfairDisplay(
                fontSize: 20.sp, fontWeight: FontWeight.bold, color: _dark)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _ErrorView(message: _error!, onRetry: _load)
          : _saved.isEmpty
          ? _EmptyState()
          : RefreshIndicator(
        color: _terracotta,
        onRefresh: _load,
        child: ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: _saved.length,
          itemBuilder: (_, i) {
            final item = _saved[i];
            final savedId    = item['savedId'] as int? ?? 0;
            final homestayJson = item['homestay'] as Map<String, dynamic>? ?? {};
            final homestay   = Homestay.fromJson(homestayJson);
            return _SavedCard(
              homestay: homestay,
              onUnsave: () => _unsave(savedId, homestay.id),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TouristHomestayDetailPage(
                    homestay: homestay.toJson(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


class _SavedCard extends StatelessWidget {
  final Homestay homestay;
  final VoidCallback onUnsave;
  final VoidCallback onTap;

  const _SavedCard({
    required this.homestay,
    required this.onUnsave,
    required this.onTap,
  });

  static const _dark       = Color(0xFF2D1B10);
  static const _terracotta = Color(0xFFCD6E4E);

  @override
  Widget build(BuildContext context) {
    final imageUrl = homestay.imageUrls.isNotEmpty
        ? homestay.imageUrls.first : null;
    final nearSite = homestay.nearCulturalSite?.name;
    final location = nearSite != null && nearSite.isNotEmpty
        ? 'Near $nearSite' : homestay.location;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14, offset: const Offset(0, 6))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            child: Stack(children: [
              SizedBox(
                width: double.infinity,
                height: 190.h,
                child: imageUrl != null
                    ? ProxyImage(imageUrl: imageUrl, width: double.infinity, height: double.infinity, fit: BoxFit.cover, borderRadiusValue: 0, thumb: true)
                    : _placeholder(),
              ),
              Positioned(
                top: 12.h, left: 12.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(homestay.category ?? 'Homestay',
                      style: GoogleFonts.dmSans(fontSize: 11.sp,
                          color: Colors.white, fontWeight: FontWeight.w500)),
                ),
              ),
              Positioned(
                top: 10.h, right: 10.w,
                child: GestureDetector(
                  onTap: () => _confirmUnsave(context),
                  child: Container(
                    width: 36.w, height: 36.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 6)],
                    ),
                    child: Icon(Icons.favorite_rounded,
                        size: 18.sp, color: Colors.redAccent),
                  ),
                ),
              ),
            ]),
          ),

          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Text(homestay.name,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.playfairDisplay(fontSize: 17.sp,
                        fontWeight: FontWeight.bold, color: _dark))),
                Row(children: [
                  Icon(Icons.star_rounded, color: Colors.amber[600], size: 16.sp),
                  SizedBox(width: 3.w),
                  Text('4.8', style: GoogleFonts.dmSans(
                      fontSize: 13.sp, fontWeight: FontWeight.bold, color: _dark)),
                ]),
              ]),

              SizedBox(height: 5.h),
              Row(children: [
                Icon(Icons.location_on_outlined, size: 13.sp, color: Colors.grey[500]),
                SizedBox(width: 3.w),
                Expanded(child: Text(location, maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.grey[500]))),
              ]),

              SizedBox(height: 12.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(children: [
                    _Chip('${homestay.numberOfRooms} rooms',
                        Icons.king_bed_outlined),
                    SizedBox(width: 8.w),
                    _Chip('${homestay.maxGuests} guests',
                        Icons.people_outline_rounded),
                  ]),
                  RichText(text: TextSpan(children: [
                    TextSpan(text: 'Rs. ${homestay.pricePerNight.toStringAsFixed(0)}',
                        style: GoogleFonts.dmSans(fontSize: 17.sp,
                            color: _terracotta, fontWeight: FontWeight.w800)),
                    TextSpan(text: '/night',
                        style: GoogleFonts.dmSans(fontSize: 11.sp,
                            color: Colors.grey[500])),
                  ])),
                ],
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: Colors.grey.shade200,
    child: Center(child: Icon(Icons.hotel_outlined,
        size: 48.sp, color: Colors.grey[400])),
  );

  void _confirmUnsave(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Remove from Saved?',
            style: GoogleFonts.playfairDisplay(
                fontSize: 18.sp, fontWeight: FontWeight.bold)),
        content: Text('This homestay will be removed from your saved list.',
            style: GoogleFonts.dmSans(fontSize: 13.sp, color: Colors.grey[600])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Keep', style: GoogleFonts.dmSans(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); onUnsave(); },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            child: Text('Remove',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _Chip(this.label, this.icon);

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 13.sp, color: Colors.grey[500]),
    SizedBox(width: 3.w),
    Text(label, style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.grey[500])),
  ]);
}


class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.favorite_outline_rounded, size: 64.sp, color: Colors.grey[300]),
      SizedBox(height: 16.h),
      Text('No saved homestays',
          style: GoogleFonts.playfairDisplay(fontSize: 20.sp,
              fontWeight: FontWeight.bold, color: const Color(0xFF2D1B10))),
      SizedBox(height: 8.h),
      Text('Tap the ♡ on any homestay to save it here.',
          style: GoogleFonts.dmSans(fontSize: 13.sp, color: Colors.grey[500])),
    ]),
  );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.wifi_off_rounded, size: 48.sp, color: Colors.grey[300]),
      SizedBox(height: 12.h),
      Text(message, textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(fontSize: 13.sp, color: Colors.grey[500])),
      SizedBox(height: 16.h),
      ElevatedButton(
        onPressed: onRetry,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFCD6E4E),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        ),
        child: Text('Retry',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
      ),
    ]),
  );
}