import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/services/image_proxy.dart';
import '../../../data/models/site.dart';

class SiteDetailPage extends StatefulWidget {
  final CulturalSite site;
  const SiteDetailPage({super.key, required this.site});

  @override
  State<SiteDetailPage> createState() => _SiteDetailPageState();
}

class _SiteDetailPageState extends State<SiteDetailPage> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  static const _terracotta = Color(0xFFCD6E4E);
  static const _dark       = Color(0xFF2D1B10);
  static const _cream      = Color(0xFFFAF7F2);
  static const _warmGrey   = Color(0xFF8B8B8B);
  static const _teal       = Color(0xFF4A707A);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    final dt = date.toLocal();
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final min = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} · $h:$min $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final site = widget.site;
    final images = site.imageUrls.isNotEmpty ? site.imageUrls : <String>[];

    return Scaffold(
      backgroundColor: _cream,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 340,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      images.isEmpty
                          ? Container(color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported, size: 60, color: Colors.grey))
                          : PageView.builder(
                        controller: _pageController,
                        itemCount: images.length,
                        physics: const BouncingScrollPhysics(),
                        onPageChanged: (i) => setState(() => _currentImageIndex = i),
                        itemBuilder: (_, i) => ProxyImage(
                          imageUrl: images[i],
                          width: double.infinity,
                          height: 340,
                          fit: BoxFit.contain,
                          borderRadiusValue: 0,
                        ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.35),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.72),
                              ],
                              stops: const [0, 0.38, 1],
                            ),
                          ),
                        ),
                      ),
                      if (images.length > 1) ...[
                        Positioned(left: 8, top: 0, bottom: 0,
                          child: Center(child: _Arrow(
                            icon: Icons.chevron_left_rounded,
                            onTap: _currentImageIndex > 0 ? () => _pageController.previousPage(
                                duration: const Duration(milliseconds: 300), curve: Curves.easeInOut) : null,
                          )),
                        ),
                        Positioned(right: 8, top: 0, bottom: 0,
                          child: Center(child: _Arrow(
                            icon: Icons.chevron_right_rounded,
                            onTap: _currentImageIndex < images.length - 1 ? () => _pageController.nextPage(
                                duration: const Duration(milliseconds: 300), curve: Curves.easeInOut) : null,
                          )),
                        ),
                        Positioned(top: 52, right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.photo_library_outlined, size: 12, color: Colors.white),
                              const SizedBox(width: 4),
                              Text('${_currentImageIndex + 1}/${images.length}',
                                  style: GoogleFonts.dmSans(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                            ]),
                          ),
                        ),
                        Positioned(bottom: 70, left: 0, right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(images.length, (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              height: 6,
                              width: _currentImageIndex == i ? 20 : 6,
                              decoration: BoxDecoration(
                                color: _currentImageIndex == i ? Colors.white : Colors.white54,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            )),
                          ),
                        ),
                      ],
                      Positioned(bottom: 16, left: 20, right: 60,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          if (site.isUNESCO)
                            Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: _terracotta, borderRadius: BorderRadius.circular(4)),
                              child: Text('🏛 UNESCO World Heritage',
                                  style: GoogleFonts.dmSans(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          Text(site.name ?? '',
                              style: GoogleFonts.playfairDisplay(
                                  color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold,
                                  shadows: [const Shadow(blurRadius: 8, color: Colors.black45)])),
                          const SizedBox(height: 4),
                          Row(children: [
                            const Icon(Icons.location_on, color: Colors.white70, size: 13),
                            const SizedBox(width: 3),
                            Text(site.district ?? '', style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 13)),
                            if ((site.category ?? '').isNotEmpty) ...[
                              Text('  ·  ', style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 13)),
                              Text(site.category!, style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 13)),
                            ],
                          ]),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: [
                        if ((site.openingTime ?? '').isNotEmpty || (site.closingTime ?? '').isNotEmpty)
                          _InfoChip(Icons.access_time_rounded, 'Hours', '${site.openingTime ?? '?'} – ${site.closingTime ?? '?'}'),
                        if (site.entryFeeNPR != null) ...[
                          const SizedBox(width: 10),
                          _InfoChip(Icons.payments_outlined, 'Entry (NPR)', 'Rs. ${site.entryFeeNPR!.toStringAsFixed(0)}'),
                        ],
                        if ((site.bestTimeToVisit ?? '').isNotEmpty) ...[
                          const SizedBox(width: 10),
                          _InfoChip(Icons.wb_sunny_outlined, 'Best Time', site.bestTimeToVisit!),
                        ],
                        if (site.entryFeeSAARC != null) ...[
                          const SizedBox(width: 10),
                          _InfoChip(Icons.people_outline, 'SAARC', 'Rs. ${site.entryFeeSAARC!.toStringAsFixed(0)}'),
                        ],
                      ]),
                    ),
                    const SizedBox(height: 24),
                    if ((site.shortDescription ?? '').isNotEmpty) ...[
                      Text(site.shortDescription!,
                          style: GoogleFonts.dmSans(fontSize: 15, height: 1.65, color: _dark.withValues(alpha: 0.85))),
                      const SizedBox(height: 24),
                    ],
                    if ((site.historicalSignificance ?? '').isNotEmpty) ...[
                      _SectionHeader('Historical Significance', Icons.history_edu_outlined, _teal),
                      const SizedBox(height: 10),
                      _ContentCard(child: Text(site.historicalSignificance!,
                          style: GoogleFonts.dmSans(fontSize: 14, height: 1.65, color: _warmGrey))),
                      const SizedBox(height: 20),
                    ],
                    if ((site.culturalImportance ?? '').isNotEmpty) ...[
                      _SectionHeader('Cultural Importance', Icons.temple_hindu_outlined, _terracotta),
                      const SizedBox(height: 10),
                      _ContentCard(child: Text(site.culturalImportance!,
                          style: GoogleFonts.dmSans(fontSize: 14, height: 1.65, color: _warmGrey))),
                      const SizedBox(height: 20),
                    ],
                    if (images.isNotEmpty) ...[
                      _SectionHeader('Photo Gallery', Icons.photo_library_outlined, _dark),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 90,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: images.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 10),
                          itemBuilder: (_, i) {
                            final isActive = i == _currentImageIndex;
                            return GestureDetector(
                              onTap: () {
                                _pageController.animateToPage(i,
                                    duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                                setState(() => _currentImageIndex = i);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 90,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: isActive ? _terracotta : Colors.transparent, width: 2.5),
                                ),
                                child: ProxyImage(
                                  imageUrl: images[i],
                                  width: 90,
                                  height: 90,
                                  thumb: true,
                                  fit: BoxFit.cover,
                                  borderRadiusValue: 8,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    _SectionHeader('Site Details', Icons.info_outline_rounded, _dark),
                    const SizedBox(height: 10),
                    _ContentCard(
                      child: Column(children: [
                        _DetailRow(Icons.calendar_today_outlined, 'Added On', _formatDate(site.createdAt)),
                        Divider(height: 20, color: Colors.grey.shade100),
                        _DetailRow(Icons.update_rounded, 'Last Updated', _formatDate(site.updatedAt)),
                        if (site.address != null) ...[
                          Divider(height: 20, color: Colors.grey.shade100),
                          _DetailRow(Icons.map_outlined, 'Address', site.address!),
                        ],
                      ]),
                    ),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38, height: 38,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, size: 20, color: _dark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _Arrow({required this.icon, this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedOpacity(
      opacity: onTap != null ? 1.0 : 0.3,
      duration: const Duration(milliseconds: 200),
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const _SectionHeader(this.title, this.icon, this.color);
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 18, color: color),
    const SizedBox(width: 8),
    Text(title, style: GoogleFonts.playfairDisplay(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF2D1B10))),
  ]);
}

class _ContentCard extends StatelessWidget {
  final Widget child;
  const _ContentCard({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.grey.shade100),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: child,
  );
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoChip(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 13, color: const Color(0xFFCD6E4E)),
        const SizedBox(width: 5),
        Text(label, style: GoogleFonts.dmSans(fontSize: 11, color: Colors.grey[500])),
      ]),
      const SizedBox(height: 4),
      Text(value, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF2D1B10))),
    ]),
  );
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _DetailRow(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, size: 15, color: Colors.grey[400]),
    const SizedBox(width: 10),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.dmSans(fontSize: 11, color: Colors.grey[500])),
      const SizedBox(height: 2),
      Text(value, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF2D1B10))),
    ])),
  ]);
}
