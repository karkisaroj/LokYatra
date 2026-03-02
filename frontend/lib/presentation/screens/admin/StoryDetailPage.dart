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
    DateTime? parsed = DateTime.tryParse(str);
    if (parsed == null) {
      final cleaned = str.replaceAll(RegExp(r'\+\d{2}:\d{2}$'), '').replaceAll(RegExp(r'Z$'), '').trim();
      parsed = DateTime.tryParse(cleaned);
    }
    if (parsed == null) return str;
    final local = parsed.toLocal();
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '${local.day} ${months[local.month - 1]} ${local.year}  $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb || MediaQuery.of(context).size.width > 800;
    final List<String> imageUrls = [];
    if (story['imageUrls'] is List) {
      for (final u in story['imageUrls']) {
        if (u != null && u.toString().isNotEmpty) imageUrls.add(u.toString());
      }
    }

    final title      = (story['title']?? '').toString();
    final storyType  = (story['storyType']?? '').toString();
    final readTime   = story['estimatedReadTimeMinutes']  ?? 0;
    final content    = (story['fullContent']?? '').toString();
    final historical = (story['historicalContext'] ?? '').toString();
    final cultural   = (story['culturalSignificance']?? '').toString();
    final createdAt  = _formatDate(story['createdAt']?? story['CreatedAt']);
    final updatedAt  = _formatDate(story['updatedAt']?? story['UpdatedAt']);

    return Scaffold(
      backgroundColor: isWeb ? const Color(0xFFF4F6F9) : _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: isWeb ? 18 : 18.sp, color: _dark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Story Detail', style: GoogleFonts.playfairDisplay(fontSize: isWeb ? 18 : 18.sp, fontWeight: FontWeight.bold, color: _dark)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Divider(height: 1, color: Colors.grey.shade200)),
      ),
      body: isWeb ? _webLayout(context, imageUrls, title, storyType, readTime, content, historical, cultural, createdAt, updatedAt)
          : _mobileLayout(imageUrls, title, storyType, readTime, content, historical, cultural, createdAt, updatedAt),
    );
  }

  Widget _webLayout(BuildContext context, List<String> imageUrls, String title, String storyType, dynamic readTime, String content, String historical, String cultural, String createdAt, String updatedAt) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        width: 560,
        child: Container(
          color: _dark,
          child: Column(children: [
            if (imageUrls.isNotEmpty)
              Expanded(child: PageView.builder(
                itemCount: imageUrls.length,
                itemBuilder: (_, i) => ProxyImage(imageUrl: imageUrls[i], width: double.infinity, height: double.infinity, borderRadiusValue: 0),
              ))
            else
              Expanded(child: Container(color: const Color(0xFF2A2A42), child: Center(child: Icon(Icons.menu_book_outlined, size: 14, color: Colors.white24)))),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (storyType.isNotEmpty) _Pill(icon: Icons.auto_stories_outlined, label: storyType, color: _accent),
                const SizedBox(height: 12),
                Text(title, style: GoogleFonts.playfairDisplay(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, height: 1.15)),
                const SizedBox(height: 12),
                Row(children: [
                  Icon(Icons.timer_outlined, size: 14, color: Colors.white54),
                  const SizedBox(width: 5),
                  Text('$readTime min read', style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white54)),
                ]),
                const SizedBox(height: 10),
                const Divider(color: Colors.white12),
                const SizedBox(height: 10),
                _WebMetaRow(label: 'Created', value: createdAt),
                const SizedBox(height: 8),
                _WebMetaRow(label: 'Updated', value: updatedAt),
                const SizedBox(height: 24),
              ]),
            ),
          ]),
        ),
      ),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _WebSection(icon: Icons.menu_book_outlined, title: 'Full Story', child: Text(content,
                style: GoogleFonts.dmSans(fontSize: 15, height: 1.75, color: Colors.grey[700]))),
            if (historical.isNotEmpty) ...[
              const SizedBox(height: 24),
              _WebSection(icon: Icons.history_edu_outlined, title: 'Historical Context', child: Text(historical,
                  style: GoogleFonts.dmSans(fontSize: 14, height: 1.65, color: Colors.grey[700]))),
            ],
            if (cultural.isNotEmpty) ...[
              const SizedBox(height: 24),
              _WebSection(icon: Icons.language_outlined, title: 'Cultural Significance', child: Text(cultural,
                  style: GoogleFonts.dmSans(fontSize: 14, height: 1.65, color: Colors.grey[700]))),
            ],
            if (imageUrls.length > 1) ...[
              const SizedBox(height: 24),
              _WebSection(icon: Icons.photo_library_outlined, title: 'Gallery',
                child: SizedBox(height: 100, child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: imageUrls.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => ClipRRect(borderRadius: BorderRadius.circular(8),
                      child: ProxyImage(imageUrl: imageUrls[i], width: 150, height: 100, borderRadiusValue: 0, thumb: true)),
                )),
              ),
            ],
          ]),
        ),
      ),
    ]);
  }

  Widget _mobileLayout(List<String> imageUrls, String title, String storyType, dynamic readTime, String content, String historical, String cultural, String createdAt, String updatedAt) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        if (imageUrls.isNotEmpty)
          ClipRRect(borderRadius: BorderRadius.circular(14.r),
              child: ProxyImage(imageUrl: imageUrls.first, width: double.infinity, height: 220.h, borderRadiusValue: 0)),
        SizedBox(height: 16.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14.r), border: Border.all(color: Colors.grey.shade200)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.playfairDisplay(fontSize: 22.sp, fontWeight: FontWeight.bold, color: _dark)),
            SizedBox(height: 10.h),
            Wrap(spacing: 8.w, runSpacing: 6.h, children: [
              if (storyType.isNotEmpty) _Pill(icon: Icons.auto_stories_outlined, label: storyType, color: _accent),
              _Pill(icon: Icons.timer_outlined, label: '$readTime min read', color: Colors.grey[600]!),
            ]),
            SizedBox(height: 14.h),
            Divider(color: Colors.grey.shade100),
            SizedBox(height: 10.h),
            Row(children: [
              Expanded(child: _MetaRow(icon: Icons.calendar_today_outlined, label: 'Created', value: createdAt)),
              SizedBox(width: 12.w),
              Expanded(child: _MetaRow(icon: Icons.edit_calendar_outlined, label: 'Updated', value: updatedAt)),
            ]),
          ]),
        ),
        SizedBox(height: 12.h),
        _MobileSection(icon: Icons.menu_book_outlined, title: 'Full Story',
            child: Text(content, style: GoogleFonts.dmSans(fontSize: 14.sp, height: 1.7, color: Colors.grey[800]))),
        if (historical.isNotEmpty) ...[
          SizedBox(height: 12.h),
          _MobileSection(icon: Icons.history_edu_outlined, title: 'Historical Context',
              child: Text(historical, style: GoogleFonts.dmSans(fontSize: 13.sp, height: 1.6, color: Colors.grey[700]))),
        ],
        if (cultural.isNotEmpty) ...[
          SizedBox(height: 12.h),
          _MobileSection(icon: Icons.language_outlined, title: 'Cultural Significance',
              child: Text(cultural, style: GoogleFonts.dmSans(fontSize: 13.sp, height: 1.6, color: Colors.grey[700]))),
        ],
        if (imageUrls.length > 1) ...[
          SizedBox(height: 12.h),
          _MobileSection(icon: Icons.photo_library_outlined, title: 'Gallery',
            child: SizedBox(height: 100.h, child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: imageUrls.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => ClipRRect(borderRadius: BorderRadius.circular(8),
                  child: ProxyImage(imageUrl: imageUrls[i], width: 150.w, height: 100.h, borderRadiusValue: 0, thumb: true)),
            )),
          ),
        ],
        SizedBox(height: 32.h),
      ],
    );
  }
}

class _WebSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _WebSection({required this.icon, required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: const Color(0xFF3D5A80).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6)),
          child: Icon(icon, size: 16, color: const Color(0xFF3D5A80))),
      const SizedBox(width: 10),
      Text(title, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
      const SizedBox(width: 12),
      Expanded(child: Divider(color: Colors.grey.shade300)),
    ]),
    const SizedBox(height: 16),
    child,
  ]);
}

class _MobileSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _MobileSection({required this.icon, required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14.r), border: Border.all(color: Colors.grey.shade200)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(padding: EdgeInsets.all(6.w), decoration: BoxDecoration(color: const Color(0xFF3D5A80).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6.r)),
            child: Icon(icon, size: 16.sp, color: const Color(0xFF3D5A80))),
        SizedBox(width: 8.w),
        Text(title, style: GoogleFonts.dmSans(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
        SizedBox(width: 8.w),
        Expanded(child: Divider(color: Colors.grey.shade200)),
      ]),
      SizedBox(height: 12.h),
      child,
    ]),
  );
}

class _WebMetaRow extends StatelessWidget {
  final String label, value;
  const _WebMetaRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('$label: ', style: GoogleFonts.dmSans(fontSize: 11, color: Colors.white38, fontWeight: FontWeight.w600)),
    Expanded(child: Text(value, style: GoogleFonts.dmSans(fontSize: 11, color: Colors.white54))),
  ]);
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Pill({required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10.r), border: Border.all(color: color.withValues(alpha: 0.2))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13.sp, color: color),
      SizedBox(width: 5.w),
      Text(label, style: GoogleFonts.dmSans(fontSize: 12.sp, fontWeight: FontWeight.w600, color: color)),
    ]),
  );
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _MetaRow({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, size: 13.sp, color: Colors.grey[400]),
    SizedBox(width: 5.w),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.dmSans(fontSize: 10.sp, color: Colors.grey[400])),
      Text(value, style: GoogleFonts.dmSans(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.grey[700])),
    ])),
  ]);
}