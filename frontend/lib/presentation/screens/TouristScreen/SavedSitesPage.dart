import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/datasources/saved_sites_remote_datasource.dart';
import '../../../data/models/Site.dart';
import 'TouristSitesDetails.dart';

class SavedSitesPage extends StatefulWidget {
  const SavedSitesPage({super.key});

  @override
  State<SavedSitesPage> createState() => _SavedSitesPageState();
}

class _SavedSitesPageState extends State<SavedSitesPage> {
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
      final resp = await SavedSitesRemoteDatasource().getSaved();
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

  Future<void> _unsave(int savedId, int siteId) async {
    try {
      await SavedSitesRemoteDatasource().toggleSaved(siteId);
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
        title: Text('Saved Sites',
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
                          final item    = _saved[i];
                          final savedId = item['savedId'] as int? ?? 0;
                          final siteJson = item['site'] as Map<String, dynamic>? ?? {};
                          final site    = CulturalSite.fromJson(siteJson);
                          return _SavedSiteCard(
                            site: site,
                            onUnsave: () => _unsave(savedId, site.id),
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (_) => TouristSiteDetailPage(site: site))),
                          );
                        },
                      ),
                    ),
    );
  }
}

class _SavedSiteCard extends StatelessWidget {
  final CulturalSite site;
  final VoidCallback onUnsave;
  final VoidCallback onTap;

  const _SavedSiteCard({
    required this.site,
    required this.onUnsave,
    required this.onTap,
  });

  static const _dark       = Color(0xFF2D1B10);
  static const _terracotta = Color(0xFFCD6E4E);
  static const _teal       = Color(0xFF2D6A6A);

  @override
  Widget build(BuildContext context) {
    final imageUrl = site.imageUrls.isNotEmpty ? site.imageUrls.first : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
                    ? Image.network(imageUrl, fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _placeholder())
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
                  child: Text(site.category ?? 'Heritage',
                      style: GoogleFonts.dmSans(fontSize: 11.sp,
                          color: Colors.white, fontWeight: FontWeight.w500)),
                ),
              ),
              if (site.isUNESCO)
                Positioned(
                  top: 12.h, left: 12.w + 80.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: _teal,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text('UNESCO',
                        style: GoogleFonts.dmSans(fontSize: 10.sp,
                            color: Colors.white, fontWeight: FontWeight.w600)),
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
                      boxShadow: [BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
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
              Text(site.name ?? 'Unknown Site',
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.playfairDisplay(fontSize: 17.sp,
                      fontWeight: FontWeight.bold, color: _dark)),
              SizedBox(height: 5.h),
              Row(children: [
                Icon(Icons.location_on_outlined, size: 13.sp, color: Colors.grey[500]),
                SizedBox(width: 3.w),
                Expanded(child: Text(
                    [site.address, site.district]
                        .where((s) => s != null && s.isNotEmpty)
                        .join(', '),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.grey[500]))),
              ]),
              SizedBox(height: 10.h),
              if (site.shortDescription != null && site.shortDescription!.isNotEmpty)
                Text(site.shortDescription!,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.grey[600])),
              SizedBox(height: 10.h),
              Row(children: [
                if (site.entryFeeNPR != null && site.entryFeeNPR! > 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: _terracotta.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text('Rs. ${site.entryFeeNPR!.toStringAsFixed(0)} entry',
                        style: GoogleFonts.dmSans(fontSize: 11.sp,
                            color: _terracotta, fontWeight: FontWeight.w600)),
                  )
                else
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text('Free Entry',
                        style: GoogleFonts.dmSans(fontSize: 11.sp,
                            color: Colors.green[700], fontWeight: FontWeight.w600)),
                  ),
                if (site.openingTime != null && site.openingTime!.isNotEmpty) ...[
                  SizedBox(width: 8.w),
                  Icon(Icons.access_time_rounded, size: 13.sp, color: Colors.grey[500]),
                  SizedBox(width: 3.w),
                  Text('${site.openingTime} – ${site.closingTime ?? '?'}',
                      style: GoogleFonts.dmSans(fontSize: 11.sp, color: Colors.grey[500])),
                ],
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: Colors.grey.shade200,
    child: Center(child: Icon(Icons.temple_hindu_outlined,
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
        content: Text('This site will be removed from your saved list.',
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

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.temple_hindu_outlined, size: 64.sp, color: Colors.grey[300]),
      SizedBox(height: 16.h),
      Text('No saved sites',
          style: GoogleFonts.playfairDisplay(fontSize: 20.sp,
              fontWeight: FontWeight.bold, color: const Color(0xFF2D1B10))),
      SizedBox(height: 8.h),
      Text('Tap the ♡ on any heritage site to save it here.',
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
        child: Text('Retry', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
      ),
    ]),
  );
}
