import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/services/image_proxy.dart';

class StoryDetailPage extends StatefulWidget {
  final Map<String, dynamic> story;
  const StoryDetailPage({super.key, required this.story});

  @override
  State<StoryDetailPage> createState() => _StoryDetailPageState();
}

class _StoryDetailPageState extends State<StoryDetailPage> {
  int _currentPage = 0;
  final PageController _pageCtrl  = PageController();
  final PageController _mobileCtrl = PageController();

  static const _dark   = Color(0xFF1A1A2E);
  static const _accent = Color(0xFF3D5A80);

  int _mobilePage = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    _mobileCtrl.dispose();
    super.dispose();
  }

  String _fmt(dynamic date) {
    if (date == null) return '—';
    final str = date.toString().trim();
    if (str.isEmpty) return '—';
    DateTime? d = DateTime.tryParse(str);
    d ??= DateTime.tryParse(str.replaceAll(RegExp(r'[Z+].*$'), '').trim());
    if (d == null) return str;
    final l = d.toLocal();
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${l.day} ${m[l.month-1]} ${l.year}  ${l.hour.toString().padLeft(2,'0')}:${l.minute.toString().padLeft(2,'0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb || MediaQuery.of(context).size.width > 800;
    final List<String> imgs = [];
    if (widget.story['imageUrls'] is List) {
      for (final u in widget.story['imageUrls']) {
        if (u != null && u.toString().isNotEmpty) imgs.add(u.toString());
      }
    }
    final title     = (widget.story['title'] ?? '').toString();
    final type      = (widget.story['storyType'] ?? '').toString();
    final readTime  = widget.story['estimatedReadTimeMinutes'] ?? 0;
    final content   = (widget.story['fullContent'] ?? '').toString();
    final hist      = (widget.story['historicalContext'] ?? '').toString();
    final cultural  = (widget.story['culturalSignificance'] ?? '').toString();
    final created   = _fmt(widget.story['createdAt'] ?? widget.story['CreatedAt']);
    final updated   = _fmt(widget.story['updatedAt'] ?? widget.story['UpdatedAt']);

    return Scaffold(
      backgroundColor: isWeb ? const Color(0xFFF4F6F9) : const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _dark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Story Detail',
            style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold, color: _dark)),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(height: 1, color: Colors.grey.shade200)),
      ),
      body: isWeb
          ? _web(imgs, title, type, readTime, content, hist, cultural, created, updated)
          : _mobile(imgs, title, type, readTime, content, hist, cultural, created, updated),
    );
  }

  Widget _web(List<String> imgs, String title, String type, dynamic readTime,
      String content, String hist, String cultural, String created, String updated) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        width: 480,
        child: Container(
          color: _dark,
          child: Column(children: [
            Expanded(
              child: imgs.isEmpty
                  ? Container(color: const Color(0xFF2A2A42),
                  child: const Center(child: Icon(Icons.menu_book_outlined, size: 64, color: Colors.white24)))
                  : Stack(fit: StackFit.expand, children: [
                PageView.builder(
                  controller: _pageCtrl,
                  itemCount: imgs.length,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (_, i) => Container(
                    color: const Color(0xFF2A2A42),
                    child: ProxyImage(
                      imageUrl: imgs[i],
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.contain,
                      borderRadiusValue: 0,
                    ),
                  ),
                ),
                if (imgs.length > 1) ...[
                  Positioned(left: 8, top: 0, bottom: 0, child: Center(child: _Arr(
                    icon: Icons.chevron_left_rounded,
                    onTap: _currentPage > 0 ? () => _pageCtrl.previousPage(
                        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut) : null,
                  ))),
                  Positioned(right: 8, top: 0, bottom: 0, child: Center(child: _Arr(
                    icon: Icons.chevron_right_rounded,
                    onTap: _currentPage < imgs.length - 1 ? () => _pageCtrl.nextPage(
                        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut) : null,
                  ))),
                  Positioned(top: 12, right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                      child: Text('${_currentPage + 1}/${imgs.length}',
                          style: GoogleFonts.dmSans(color: Colors.white, fontSize: 11)),
                    ),
                  ),
                ],
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (type.isNotEmpty) _Pill(icon: Icons.auto_stories_outlined, label: type, color: _accent),
                const SizedBox(height: 12),
                Text(title, style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2)),
                const SizedBox(height: 10),
                Row(children: [
                  const Icon(Icons.timer_outlined, size: 14, color: Colors.white54),
                  const SizedBox(width: 5),
                  Text('$readTime min read', style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white54)),
                ]),
                const SizedBox(height: 10),
                const Divider(color: Colors.white12),
                const SizedBox(height: 10),
                _MRow(label: 'Created', value: created),
                const SizedBox(height: 6),
                _MRow(label: 'Updated', value: updated),
                const SizedBox(height: 16),
              ]),
            ),
          ]),
        ),
      ),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _Sec(icon: Icons.menu_book_outlined, title: 'Full Story',
                child: Text(content, style: GoogleFonts.dmSans(fontSize: 15, height: 1.75, color: Colors.grey[700]))),
            if (hist.isNotEmpty) ...[
              const SizedBox(height: 28),
              _Sec(icon: Icons.history_edu_outlined, title: 'Historical Context',
                  child: Text(hist, style: GoogleFonts.dmSans(fontSize: 14, height: 1.65, color: Colors.grey[700]))),
            ],
            if (cultural.isNotEmpty) ...[
              const SizedBox(height: 28),
              _Sec(icon: Icons.language_outlined, title: 'Cultural Significance',
                  child: Text(cultural, style: GoogleFonts.dmSans(fontSize: 14, height: 1.65, color: Colors.grey[700]))),
            ],
            if (imgs.length > 1) ...[
              const SizedBox(height: 28),
              _Sec(icon: Icons.photo_library_outlined, title: 'Gallery',
                child: SizedBox(height: 100, child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: imgs.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () {
                      _pageCtrl.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      setState(() => _currentPage = i);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _currentPage == i ? _accent : Colors.transparent, width: 2.5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: ProxyImage(
                          imageUrl: imgs[i],
                          width: 150, height: 100,
                          thumb: true,
                          fit: BoxFit.cover,
                          borderRadiusValue: 0,
                        ),
                      ),
                    ),
                  ),
                )),
              ),
            ],
            const SizedBox(height: 40),
          ]),
        ),
      ),
    ]);
  }

  Widget _mobile(List<String> images, String title, String type, dynamic readTime,
      String content, String hist, String cultural, String created, String updated) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (images.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 220,
              child: PageView.builder(
                controller: _mobileCtrl,
                itemCount: images.length,
                onPageChanged: (i) => setState(() => _mobilePage = i),
                itemBuilder: (_, i) => ProxyImage(
                  imageUrl: images[i],
                  width: double.infinity, height: 220,
                  fit: BoxFit.contain,
                  borderRadiusValue: 0,
                ),
              ),
            ),
          ),
          if (images.length > 1) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width:  _mobilePage == i ? 18 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: _mobilePage == i ? _accent : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
          ],
        ],
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold, color: _dark)),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 6, children: [
              if (type.isNotEmpty) _Pill(icon: Icons.auto_stories_outlined, label: type, color: _accent),
              _Pill(icon: Icons.timer_outlined, label: '$readTime min read', color: Colors.grey[600]!),
            ]),
            const SizedBox(height: 14),
            Divider(color: Colors.grey.shade100),
            const SizedBox(height: 10),
            _MRow(label: 'Created', value: created),
            const SizedBox(height: 4),
            _MRow(label: 'Updated', value: updated),
          ]),
        ),
        const SizedBox(height: 12),
        _MSec(icon: Icons.menu_book_outlined, title: 'Full Story',
            child: Text(content, style: GoogleFonts.dmSans(fontSize: 14, height: 1.7, color: Colors.grey[800]))),
        if (hist.isNotEmpty) ...[
          const SizedBox(height: 12),
          _MSec(icon: Icons.history_edu_outlined, title: 'Historical Context',
              child: Text(hist, style: GoogleFonts.dmSans(fontSize: 13, height: 1.6, color: Colors.grey[700]))),
        ],
        if (cultural.isNotEmpty) ...[
          const SizedBox(height: 12),
          _MSec(icon: Icons.language_outlined, title: 'Cultural Significance',
              child: Text(cultural, style: GoogleFonts.dmSans(fontSize: 13, height: 1.6, color: Colors.grey[700]))),
        ],
        const SizedBox(height: 32),
      ],
    );
  }
}

class _Arr extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _Arr({required this.icon, this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedOpacity(
      opacity: onTap != null ? 1.0 : 0.25,
      duration: const Duration(milliseconds: 200),
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    ),
  );
}

class _Sec extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _Sec({required this.icon, required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Container(padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: const Color(0xFF3D5A80).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6)),
          child: Icon(icon, size: 16, color: const Color(0xFF3D5A80))),
      const SizedBox(width: 10),
      Text(title, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
      const SizedBox(width: 12),
      Expanded(child: Divider(color: Colors.grey.shade300)),
    ]),
    const SizedBox(height: 14),
    child,
  ]);
}

class _MSec extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _MSec({required this.icon, required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: const Color(0xFF3D5A80).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6)),
            child: Icon(icon, size: 16, color: const Color(0xFF3D5A80))),
        const SizedBox(width: 8),
        Text(title, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: Colors.grey.shade200)),
      ]),
      const SizedBox(height: 12),
      child,
    ]),
  );
}

class _MRow extends StatelessWidget {
  final String label, value;
  const _MRow({required this.label, required this.value});
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
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: color),
      const SizedBox(width: 5),
      Text(label, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    ]),
  );
}