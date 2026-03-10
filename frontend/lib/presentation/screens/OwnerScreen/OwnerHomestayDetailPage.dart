import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/services/image_proxy.dart';
import 'package:lokyatra_frontend/data/models/Homestay.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/homestays/HomestayBloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/homestays/HomestayEvent.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/datasources/sites_remote_datasource.dart';
import '../../../data/models/Site.dart';
import 'Ownersitedetailpage.dart';

const ink    = Color(0xFF2D1B10);
const accent = Color(0xFFCD6E4E);
const cream  = Color(0xFFFAF7F2);
const teal   = Color(0xFF4A707A);

double fs(double v, bool wide) => wide ? v : v.sp;
double sw(double v, bool wide) => wide ? v : v.w;
double sh(double v, bool wide) => wide ? v : v.h;
double sr(double v, bool wide) => wide ? v : v.r;

class OwnerHomestayDetailPage extends StatefulWidget {
  final Homestay homestay;
  const OwnerHomestayDetailPage({super.key, required this.homestay});
  @override
  State<OwnerHomestayDetailPage> createState() => OwnerHomestayDetailPageState();
}

class OwnerHomestayDetailPageState extends State<OwnerHomestayDetailPage> {
  final pageCtrl   = PageController();
  int imgIdx       = 0;
  CulturalSite? nearbySite;
  bool siteLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.homestay.nearCulturalSite != null) {
      fetchSite(widget.homestay.nearCulturalSite!.id);
    }
  }

  @override
  void dispose() { pageCtrl.dispose(); super.dispose(); }

  Future<void> fetchSite(int id) async {
    setState(() => siteLoading = true);
    try {
      final res = await SitesRemoteDatasource().getSite(id);
      if (res.statusCode == 200 && mounted) {
        setState(() => nearbySite = CulturalSite.fromJson(res.data as Map<String, dynamic>));
      }
    } catch (e) {
    } finally {
      if (mounted) setState(() => siteLoading = false);
    }
  }

  Future<void> openMap() async {
    final h = widget.homestay;
    final q = Uri.encodeComponent(
        [h.name, h.location, 'Nepal'].where((s) => s.isNotEmpty).join(', '));
    try {
      await launchUrl(Uri.parse('geo:0,0?q=$q'), mode: LaunchMode.externalApplication);
    } catch (e) {
      try {
        await launchUrl(
            Uri.parse('https://www.google.com/maps/search/?api=1&query=$q'),
            mode: LaunchMode.externalApplication);
      } catch (e2) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Could not open Maps.')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final h     = widget.homestay;
    final imgs  = h.imageUrls;
    final wide  = MediaQuery.of(context).size.width > 700;
    final heroH = wide ? 480.0 : 360.h;

    return Scaffold(
      backgroundColor: cream,
      body: Stack(children: [

        // ── Main scroll content ─────────────────────────────────────────────
        Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: wide ? 860 : double.infinity),
            child: CustomScrollView(slivers: [

              // Hero image
              SliverToBoxAdapter(
                child: SizedBox(
                  height: heroH,
                  child: Stack(fit: StackFit.expand, children: [

                    imgs.isEmpty
                        ? Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.home, size: fs(60, wide), color: Colors.grey[400]))
                        : PageView.builder(
                      controller: pageCtrl,
                      itemCount: imgs.length,
                      onPageChanged: (i) => setState(() => imgIdx = i),
                      itemBuilder: (_, i) => ProxyImage(
                          imageUrl: imgs[i],
                          width: double.infinity,
                          height: heroH,
                          borderRadiusValue: 0),
                    ),

                    // Gradient overlay
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.3),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.6),
                              ],
                              stops: const [0, 0.4, 1],
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (imgs.length > 1)
                      Positioned(
                        top: sh(52, wide), right: sw(16, wide),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: sw(10, wide), vertical: sh(4, wide)),
                          decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(sr(20, wide))),
                          child: Text('${imgIdx + 1}/${imgs.length}',
                              style: GoogleFonts.dmSans(
                                  color: Colors.white,
                                  fontSize: fs(12, wide),
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),

                    if (imgs.length > 1)
                      Positioned(
                        bottom: sh(70, wide), left: 0, right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            imgs.length,
                                (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: EdgeInsets.symmetric(horizontal: sw(3, wide)),
                              height: sh(6, wide),
                              width: imgIdx == i ? sw(20, wide) : sw(6, wide),
                              decoration: BoxDecoration(
                                color: imgIdx == i ? Colors.white : Colors.white54,
                                borderRadius: BorderRadius.circular(sr(3, wide)),
                              ),
                            ),
                          ),
                        ),
                      ),

                    if (wide && imgs.length > 1)
                      Positioned(
                        left: 12, top: 0, bottom: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              final prev = (imgIdx - 1 + imgs.length) % imgs.length;
                              pageCtrl.animateToPage(prev,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut);
                            },
                            child: Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.45),
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.chevron_left_rounded,
                                  color: Colors.white, size: 26),
                            ),
                          ),
                        ),
                      ),

                    if (wide && imgs.length > 1)
                      Positioned(
                        right: 12, top: 0, bottom: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              final next = (imgIdx + 1) % imgs.length;
                              pageCtrl.animateToPage(next,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut);
                            },
                            child: Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.45),
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.chevron_right_rounded,
                                  color: Colors.white, size: 26),
                            ),
                          ),
                        ),
                      ),

                    Positioned(
                      bottom: sh(20, wide), left: sw(20, wide), right: sw(20, wide),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(h.name,
                            style: GoogleFonts.playfairDisplay(
                                color: Colors.white,
                                fontSize: fs(26, wide),
                                fontWeight: FontWeight.bold,
                                shadows: const [Shadow(blurRadius: 8, color: Colors.black45)])),
                        SizedBox(height: sh(4, wide)),
                        Row(children: [
                          Icon(Icons.location_on, color: Colors.white70, size: fs(13, wide)),
                          SizedBox(width: sw(3, wide)),
                          Expanded(child: Text(h.location,
                              style: GoogleFonts.dmSans(
                                  color: Colors.white70, fontSize: fs(13, wide)))),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: sw(10, wide), vertical: sh(4, wide)),
                            decoration: BoxDecoration(
                              color: h.isVisible
                                  ? Colors.green.withValues(alpha: 0.85)
                                  : Colors.orange.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(sr(20, wide)),
                            ),
                            child: Text(h.isVisible ? 'Active' : 'Paused',
                                style: GoogleFonts.dmSans(
                                    fontSize: fs(11, wide),
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ]),
                      ]),
                    ),
                  ]),
                ),
              ),

              // Body content
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: cream,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(sr(24, wide))),
                  ),
                  transform: Matrix4.translationValues(0, -20, 0),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        sw(20, wide), sh(20, wide), sw(20, wide), 0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      // Category + price
                      Row(children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: sw(12, wide), vertical: sh(4, wide)),
                          decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(sr(20, wide))),
                          child: Text(h.category ?? 'Homestay',
                              style: GoogleFonts.dmSans(
                                  fontSize: fs(12, wide),
                                  color: accent,
                                  fontWeight: FontWeight.w600)),
                        ),
                        const Spacer(),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text('Rs. ${h.pricePerNight.toStringAsFixed(0)}',
                              style: GoogleFonts.dmSans(
                                  fontSize: fs(24, wide),
                                  color: accent,
                                  fontWeight: FontWeight.w800)),
                          Text('/ night',
                              style: GoogleFonts.dmSans(
                                  fontSize: fs(12, wide), color: Colors.grey[500])),
                        ]),
                      ]),

                      SizedBox(height: sh(16, wide)),

                      // Location + map
                      Container(
                        padding: EdgeInsets.all(sw(14, wide)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(sr(14, wide)),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Row(children: [
                          Expanded(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Container(
                              padding: EdgeInsets.all(sw(7, wide)),
                              decoration: BoxDecoration(
                                  color: teal.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(sr(8, wide))),
                              child: Icon(Icons.location_on_outlined,
                                  size: fs(16, wide), color: teal),
                            ),
                            SizedBox(width: sw(10, wide)),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Location',
                                  style: GoogleFonts.dmSans(
                                      fontSize: fs(11, wide), color: Colors.grey[500])),
                              SizedBox(height: sh(2, wide)),
                              Text(h.location,
                                  style: GoogleFonts.dmSans(
                                      fontSize: fs(13, wide),
                                      color: ink,
                                      fontWeight: FontWeight.w500)),
                            ])),
                          ])),
                          SizedBox(width: sw(10, wide)),
                          GestureDetector(
                            onTap: openMap,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: sw(12, wide), vertical: sh(8, wide)),
                              decoration: BoxDecoration(
                                  color: teal,
                                  borderRadius: BorderRadius.circular(sr(10, wide))),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.map_outlined, size: fs(15, wide), color: Colors.white),
                                SizedBox(width: sw(5, wide)),
                                Text('Map',
                                    style: GoogleFonts.dmSans(
                                        fontSize: fs(12, wide),
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ]),
                            ),
                          ),
                        ]),
                      ),

                      SizedBox(height: sh(20, wide)),

                      // Stats
                      Container(
                        padding: EdgeInsets.all(sw(16, wide)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(sr(16, wide)),
                          boxShadow: [BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4))],
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                          StatCell(wide: wide, icon: Icons.king_bed_outlined,
                              val: '${h.numberOfRooms}', label: 'Rooms'),
                          StatCell(wide: wide, icon: Icons.people_outline_rounded,
                              val: '${h.maxGuests}', label: 'Guests'),
                          StatCell(wide: wide, icon: Icons.bathtub_outlined,
                              val: '${h.bathrooms}', label: 'Bathrooms'),
                        ]),
                      ),

                      SizedBox(height: sh(24, wide)),

                      SectionTitle(wide: wide, text: 'Description'),
                      SizedBox(height: sh(8, wide)),
                      Text(h.description,
                          style: GoogleFonts.dmSans(
                              fontSize: fs(14, wide), height: 1.6, color: Colors.grey[700])),

                      SizedBox(height: sh(24, wide)),

                      if (h.amenities.isNotEmpty) ...[
                        SectionTitle(wide: wide, text: 'Amenities'),
                        SizedBox(height: sh(12, wide)),
                        Wrap(
                          spacing: sw(8, wide),
                          runSpacing: sh(8, wide),
                          children: h.amenities.map((a) => Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: sw(12, wide), vertical: sh(6, wide)),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(sr(20, wide)),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Text(a,
                                style: GoogleFonts.dmSans(
                                    fontSize: fs(12, wide), color: ink)),
                          )).toList(),
                        ),
                        SizedBox(height: sh(24, wide)),
                      ],

                      if ((h.culturalSignificance ?? '').isNotEmpty) ...[
                        SectionTitle(wide: wide, text: 'Cultural Significance'),
                        SizedBox(height: sh(8, wide)),
                        Container(
                          padding: EdgeInsets.all(sw(16, wide)),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(sr(16, wide)),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(h.culturalSignificance!,
                              style: GoogleFonts.dmSans(
                                  fontSize: fs(14, wide), height: 1.6, color: Colors.grey[700])),
                        ),
                        SizedBox(height: sh(24, wide)),
                      ],

                      if ((h.traditionalFeatures ?? '').isNotEmpty) ...[
                        SectionTitle(wide: wide, text: 'Traditional Features'),
                        SizedBox(height: sh(8, wide)),
                        Text(h.traditionalFeatures!,
                            style: GoogleFonts.dmSans(
                                fontSize: fs(14, wide), height: 1.6, color: Colors.grey[700])),
                        SizedBox(height: sh(24, wide)),
                      ],

                      if (h.culturalExperiences.isNotEmpty) ...[
                        SectionTitle(wide: wide, text: 'Cultural Experiences'),
                        SizedBox(height: sh(12, wide)),
                        ...h.culturalExperiences.map((e) => Padding(
                          padding: EdgeInsets.only(bottom: sh(8, wide)),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Icon(Icons.emoji_events_outlined, size: fs(16, wide), color: accent),
                            SizedBox(width: sw(8, wide)),
                            Expanded(child: Text(e,
                                style: GoogleFonts.dmSans(
                                    fontSize: fs(14, wide), color: Colors.grey[700]))),
                          ]),
                        )),
                        SizedBox(height: sh(24, wide)),
                      ],

                      if (h.nearCulturalSite != null) ...[
                        SectionTitle(wide: wide, text: 'Nearby Heritage Site'),
                        SizedBox(height: sh(8, wide)),
                        if (siteLoading)
                          const Center(
                              child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(color: accent)))
                        else if (nearbySite != null)
                          GestureDetector(
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (ctx) => OwnerSiteDetailPage(site: nearbySite!))),
                            child: Container(
                              padding: EdgeInsets.all(sw(10, wide)),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(sr(12, wide)),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(sr(8, wide)),
                                  child: nearbySite!.imageUrls.isNotEmpty
                                      ? ProxyImage(
                                      imageUrl: nearbySite!.imageUrls.first,
                                      width: sw(70, wide),
                                      height: sh(70, wide),
                                      borderRadiusValue: 0,
                                      thumb: true)
                                      : Container(
                                      width: sw(70, wide),
                                      height: sh(70, wide),
                                      color: Colors.grey[100],
                                      child: Icon(Icons.temple_hindu,
                                          color: Colors.grey[400], size: fs(30, wide))),
                                ),
                                SizedBox(width: sw(12, wide)),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(nearbySite!.name ?? '',
                                      maxLines: 2, overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.dmSans(
                                          fontSize: fs(14, wide),
                                          fontWeight: FontWeight.bold,
                                          color: ink)),
                                  if (nearbySite!.district != null) ...[
                                    SizedBox(height: sh(4, wide)),
                                    Text(nearbySite!.district!,
                                        style: GoogleFonts.dmSans(
                                            fontSize: fs(12, wide), color: Colors.grey[600])),
                                  ],
                                ])),
                                Icon(Icons.arrow_forward_ios_rounded,
                                    size: fs(14, wide), color: Colors.grey[400]),
                              ]),
                            ),
                          ),
                        SizedBox(height: sh(24, wide)),
                      ],

                      // Pause / Delete
                      Row(children: [
                        Expanded(child: OutlinedButton.icon(
                          onPressed: () => showVisibilityDialog(wide),
                          icon: Icon(
                              h.isVisible
                                  ? Icons.pause_circle_outline
                                  : Icons.play_circle_outline,
                              size: fs(18, wide)),
                          label: Text(h.isVisible ? 'Pause' : 'Activate'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: h.isVisible
                                ? Colors.orange[800] : Colors.green[800],
                            side: BorderSide(
                                color: h.isVisible
                                    ? Colors.orange.shade200 : Colors.green.shade200),
                            padding: EdgeInsets.symmetric(vertical: sh(12, wide)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(sr(12, wide))),
                          ),
                        )),
                        SizedBox(width: sw(12, wide)),
                        Expanded(child: ElevatedButton.icon(
                          onPressed: () => showDeleteDialog(wide),
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: const Text('Delete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: sh(12, wide)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(sr(12, wide))),
                          ),
                        )),
                      ]),

                      SizedBox(height: sh(32, wide)),
                    ]),
                  ),
                ),
              ),
            ]),
          ),
        ),

        // Back button
        Positioned(
          top: MediaQuery.of(context).padding.top + sh(8, wide),
          left: sw(8, wide),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: sw(38, wide), height: sh(38, wide),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(Icons.arrow_back, size: fs(20, wide), color: ink),
            ),
          ),
        ),

        // Visibility toggle button
        Positioned(
          top: MediaQuery.of(context).padding.top + sh(8, wide),
          right: sw(8, wide),
          child: GestureDetector(
            onTap: () => showVisibilityDialog(MediaQuery.of(context).size.width > 700),
            child: Container(
              width: sw(38, wide), height: sh(38, wide),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(
                widget.homestay.isVisible ? Icons.visibility : Icons.visibility_off,
                size: fs(20, wide),
                color: widget.homestay.isVisible ? accent : Colors.grey[500],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  void showVisibilityDialog(bool wide) {
    final h = widget.homestay;
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(sr(20, wide))),
      title: Text(h.isVisible ? 'Pause Homestay?' : 'Activate Homestay?',
          style: GoogleFonts.playfairDisplay(
              fontWeight: FontWeight.bold, fontSize: fs(18, wide), color: ink)),
      content: Text(
          h.isVisible
              ? 'Pausing "${h.name}" will hide it from tourists until you activate it again.'
              : 'Activating "${h.name}" will make it visible to all tourists for booking.',
          style: GoogleFonts.dmSans(
              fontSize: fs(14, wide), color: Colors.grey[700], height: 1.5)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Cancel',
              style: GoogleFonts.dmSans(
                  color: Colors.grey[600], fontWeight: FontWeight.bold)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: h.isVisible ? Colors.orange[700] : Colors.green[600],
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(sr(8, wide)))),
          onPressed: () {
            Navigator.pop(ctx);
            context.read<HomestayBloc>().add(
                AdminToggleHomestayVisibility(h.id, !h.isVisible));
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    'Homestay ${h.isVisible ? 'paused' : 'activated'} successfully'),
                backgroundColor:
                h.isVisible ? Colors.orange[700] : Colors.green[600],
                behavior: SnackBarBehavior.floating));
            Navigator.pop(context);
          },
          child: Text(h.isVisible ? 'Pause' : 'Activate',
              style: GoogleFonts.dmSans(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    ));
  }

  void showDeleteDialog(bool wide) {
    final h = widget.homestay;
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(sr(20, wide))),
      title: Row(children: [
        Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: fs(28, wide)),
        SizedBox(width: sw(10, wide)),
        Expanded(child: Text('Delete Homestay?',
            style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold, fontSize: fs(18, wide), color: ink))),
      ]),
      content: Text(
          'Are you sure you want to permanently delete "${h.name}"? This action cannot be undone.',
          style: GoogleFonts.dmSans(
              fontSize: fs(14, wide), color: Colors.grey[700], height: 1.5)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Cancel',
              style: GoogleFonts.dmSans(
                  color: Colors.grey[600], fontWeight: FontWeight.bold)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(sr(8, wide)))),
          onPressed: () {
            Navigator.pop(ctx);
            context.read<HomestayBloc>().add(AdminDeleteHomestay(h.id));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Homestay deleted successfully'),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating));
            Navigator.pop(context);
          },
          child: Text('Delete',
              style: GoogleFonts.dmSans(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    ));
  }
}

class StatCell extends StatelessWidget {
  final bool wide;
  final IconData icon;
  final String val, label;
  const StatCell({super.key, required this.wide, required this.icon,
    required this.val, required this.label});

  @override
  Widget build(BuildContext context) => Column(children: [
    Icon(icon, size: fs(24, wide), color: accent),
    SizedBox(height: sh(4, wide)),
    Text(val, style: GoogleFonts.dmSans(
        fontSize: fs(16, wide), fontWeight: FontWeight.bold, color: ink)),
    Text(label, style: GoogleFonts.dmSans(
        fontSize: fs(12, wide), color: Colors.grey[500])),
  ]);
}

class SectionTitle extends StatelessWidget {
  final bool wide;
  final String text;
  const SectionTitle({super.key, required this.wide, required this.text});

  @override
  Widget build(BuildContext context) => Text(text,
      style: GoogleFonts.playfairDisplay(
          fontSize: fs(18, wide), fontWeight: FontWeight.bold, color: ink));
}