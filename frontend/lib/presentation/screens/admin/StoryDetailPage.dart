import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/image_proxy.dart';

class StoryDetailPage extends StatelessWidget {
  final Map<String, dynamic> story;
  const StoryDetailPage({super.key, required this.story});

  static const _dark   = Color(0xFF1A1A2E);
  static const _accent = Color(0xFF3D5A80);
  static const _bg     = Color(0xFFF8F8F8);

  String _formatDate(dynamic date) {
    if (date == null) return '—';
    final str = date.toString().trim();
    if (str.isEmpty) return '—';

    debugPrint('=== DATE RAW: "$str"');

    // DateTime.parse handles ISO 8601 with +00:00 offset natively
    DateTime? parsed = DateTime.tryParse(str);

    // Fallback: strip timezone suffix and retry
    if (parsed == null) {
      final cleaned = str
          .replaceAll(RegExp(r'\+\d{2}:\d{2}$'), '')
          .replaceAll(RegExp(r'Z$'), '')
          .trim();
      parsed = DateTime.tryParse(cleaned);
    }

    if (parsed == null) return str; // show raw string if all fails

    final local = parsed.toLocal();
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '${local.day} ${months[local.month - 1]} ${local.year}  $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final List<String> imageUrls = [];
    if (story['imageUrls'] is List) {
      for (final u in story['imageUrls']) {
        if (u != null && u.toString().isNotEmpty) imageUrls.add(u.toString());
      }
    }

    final title      = (story['title']                   ?? '').toString();
    final storyType  = (story['storyType']               ?? '').toString();
    final readTime   = story['estimatedReadTimeMinutes'] ?? 0;
    final content    = (story['fullContent']             ?? '').toString();
    final historical = (story['historicalContext']       ?? '').toString();
    final cultural   = (story['culturalSignificance']    ?? '').toString();

    // Try both camelCase and PascalCase keys — .NET APIs sometimes differ
    final createdRaw = story['createdAt'] ?? story['CreatedAt'];
    final updatedRaw = story['updatedAt'] ?? story['UpdatedAt'];

    debugPrint('=== STORY KEYS: ${story.keys.toList()}');
    debugPrint('=== createdAt raw: $createdRaw');
    debugPrint('=== updatedAt raw: $updatedRaw');

    final createdAt = _formatDate(createdRaw);
    final updatedAt = _formatDate(updatedRaw);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18.sp, color: _dark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Story Detail',
            style: GoogleFonts.playfairDisplay(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: _dark)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [

          // ── Cover image ───────────────────────────────────────────
          if (imageUrls.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: ProxyImage(
                imageUrl: imageUrls.first,
                width: double.infinity,
                height: 220.h,
                borderRadiusValue: 0,
              ),
            ),

          SizedBox(height: 16.h),

          // ── Title + meta card ─────────────────────────────────────
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: _dark)),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 6.h,
                  children: [
                    if (storyType.isNotEmpty)
                      _Pill(
                          icon: Icons.auto_stories_outlined,
                          label: storyType,
                          color: _accent),
                    _Pill(
                        icon: Icons.timer_outlined,
                        label: '$readTime min read',
                        color: Colors.grey[600]!),
                  ],
                ),
                SizedBox(height: 14.h),
                Divider(color: Colors.grey.shade100),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                      child: _MetaRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Created',
                          value: createdAt),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _MetaRow(
                          icon: Icons.edit_calendar_outlined,
                          label: 'Updated',
                          value: updatedAt),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 12.h),

          // ── Full story ────────────────────────────────────────────
          _Section(
            icon: Icons.menu_book_outlined,
            title: 'Full Story',
            child: Text(content,
                style: GoogleFonts.dmSans(
                    fontSize: 14.sp, height: 1.7, color: Colors.grey[800])),
          ),

          // ── Historical context ─────────────────────────────────────
          if (historical.isNotEmpty) ...[
            SizedBox(height: 12.h),
            _Section(
              icon: Icons.history_edu_outlined,
              title: 'Historical Context',
              child: Text(historical,
                  style: GoogleFonts.dmSans(
                      fontSize: 13.sp,
                      height: 1.6,
                      color: Colors.grey[700])),
            ),
          ],

          // ── Cultural significance ──────────────────────────────────
          if (cultural.isNotEmpty) ...[
            SizedBox(height: 12.h),
            _Section(
              icon: Icons.language_outlined,
              title: 'Cultural Significance',
              child: Text(cultural,
                  style: GoogleFonts.dmSans(
                      fontSize: 13.sp,
                      height: 1.6,
                      color: Colors.grey[700])),
            ),
          ],

          // ── Gallery ───────────────────────────────────────────────
          if (imageUrls.length > 1) ...[
            SizedBox(height: 12.h),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                      icon: Icons.photo_library_outlined,
                      title: 'Gallery'),
                  SizedBox(height: 12.h),
                  SizedBox(
                    height: 100.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: imageUrls.length,
                      separatorBuilder: (_, __) =>
                          SizedBox(width: 8.w),
                      itemBuilder: (_, i) => ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: ProxyImage(
                          imageUrl: imageUrls[i],
                          width: 150.w,
                          height: 100.h,
                          borderRadiusValue: 0,
                          thumb: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: 32.h),
        ],
      ),
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: child,
  );
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _Section(
      {required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(icon: icon, title: title),
        SizedBox(height: 12.h),
        child,
      ],
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: const Color(0xFF3D5A80).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Icon(icon, size: 16.sp, color: const Color(0xFF3D5A80)),
      ),
      SizedBox(width: 8.w),
      Text(title,
          style: GoogleFonts.dmSans(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E))),
      SizedBox(width: 8.w),
      Expanded(child: Divider(color: Colors.grey.shade200)),
    ],
  );
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Pill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(color: color.withValues(alpha: 0.2)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13.sp, color: color),
        SizedBox(width: 5.w),
        Text(label,
            style: GoogleFonts.dmSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: color)),
      ],
    ),
  );
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _MetaRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 13.sp, color: Colors.grey[400]),
      SizedBox(width: 5.w),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.dmSans(
                    fontSize: 10.sp, color: Colors.grey[400])),
            Text(value,
                style: GoogleFonts.dmSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700])),
          ],
        ),
      ),
    ],
  );
}