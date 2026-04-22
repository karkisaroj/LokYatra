import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/services/image_proxy.dart';
import 'package:lokyatra_frontend/presentation/screens/TouristScreen/tourist_sites_details.dart';
import 'package:lokyatra_frontend/presentation/widgets/Helpers/site_fav_button.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/homestays/homestay_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_event.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_state.dart';

// ── Shared palette ────────────────────────────────────────────
const _ink    = Color(0xFF2D1B10);
const _accent = Color(0xFFCD6E4E);
const _teal   = Color(0xFF2D6A6A);
const _border = Color(0xFFE8DDD5);

class TouristSitesPage extends StatefulWidget {
  const TouristSitesPage({super.key});
  @override
  State<TouristSitesPage> createState() => _TouristSitesPageState();
}

class _TouristSitesPageState extends State<TouristSitesPage> {
  String  _search     = '';
  String? _category;
  String? _district;
  bool    _unescoOnly = false;
  String  _sortBy     = 'default';

  int get _activeFilters =>
      (_category != null ? 1 : 0) +
      (_district != null ? 1 : 0) +
      (_unescoOnly ? 1 : 0) +
      (_sortBy != 'default' ? 1 : 0);

  @override
  void initState() {
    super.initState();
    context.read<SitesBloc>().add(LoadSites());
  }

  void _openFilters(List<dynamic> sites) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        sites: sites,
        category: _category,
        district: _district,
        unescoOnly: _unescoOnly,
        sortBy: _sortBy,
        onApply: (cat, dist, unesco, sort) => setState(() {
          _category   = cat;
          _district   = dist;
          _unescoOnly = unesco;
          _sortBy     = sort;
        }),
      ),
    );
  }

  List<dynamic> _applyFilters(List<dynamic> raw) {
    var list = raw.where((s) {
      final name     = (s.name ?? '').toString().toLowerCase();
      final cat      = (s.category ?? '').toString();
      final dist     = (s.district ?? '').toString();
      final isUnesco = cat.toLowerCase().contains('unesco') || s.isUNESCO == true;
      if (_search.isNotEmpty && !name.contains(_search.toLowerCase())) return false;
      if (_category != null && cat != _category) return false;
      if (_district != null && dist != _district) return false;
      if (_unescoOnly && !isUnesco) return false;
      return true;
    }).toList();

    if (_sortBy == 'fee_asc') {
      list.sort((a, b) =>
          (a.entryFeeNPR ?? 0).toString().compareTo((b.entryFeeNPR ?? 0).toString()));
    } else if (_sortBy == 'fee_desc') {
      list.sort((a, b) =>
          (b.entryFeeNPR ?? 0).toString().compareTo((a.entryFeeNPR ?? 0).toString()));
    }
    return list;
  }

  void _clearAll() => setState(() {
    _search     = '';
    _category   = null;
    _district   = null;
    _unescoOnly = false;
    _sortBy     = 'default';
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Header ────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Cultural Sites',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.bold,
                          color: _ink)),
                  SizedBox(height: 2.h),
                  Text('Heritage & history across Nepal',
                      style: GoogleFonts.dmSans(
                          fontSize: 13.sp, color: Colors.grey[500])),
                ]),
              ],
            ),
            SizedBox(height: 14.h),

            // Search + Filter row
            Row(children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: _border),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _search = v),
                    style: GoogleFonts.dmSans(fontSize: 14.sp, color: _ink),
                    decoration: InputDecoration(
                      hintText: 'Search sites…',
                      hintStyle: GoogleFonts.dmSans(
                          fontSize: 14.sp, color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search_rounded,
                          color: Colors.grey[400], size: 20.sp),
                      suffixIcon: _search.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.close_rounded,
                                  size: 18.sp, color: Colors.grey[400]),
                              onPressed: () => setState(() => _search = ''),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 14.h),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),

              BlocBuilder<SitesBloc, SitesState>(
                builder: (context, state) {
                  final sites =
                      state is SitesLoaded ? state.sites : <dynamic>[];
                  final active = _activeFilters > 0;
                  return GestureDetector(
                    onTap: () => _openFilters(sites),
                    child: Stack(clipBehavior: Clip.none, children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: active ? _accent : Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                              color: active ? _accent : _border),
                        ),
                        child: Icon(Icons.tune_rounded,
                            size: 20.sp,
                            color: active ? Colors.white : Colors.grey[600]),
                      ),
                      if (active)
                        Positioned(
                          top: -5.h, right: -5.w,
                          child: Container(
                            width: 18.w, height: 18.h,
                            decoration: BoxDecoration(
                              color: _ink,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: Center(
                              child: Text('$_activeFilters',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                    ]),
                  );
                },
              ),
            ]),
          ]),
        ),

        // ── Active filter chips ───────────────────────────────
        if (_activeFilters > 0)
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
            child: Wrap(spacing: 8.w, runSpacing: 6.h, children: [
              if (_category != null)
                _ActiveChip(label: _category!,
                    onRemove: () => setState(() => _category = null)),
              if (_district != null)
                _ActiveChip(label: _district!,
                    onRemove: () => setState(() => _district = null)),
              if (_unescoOnly)
                _ActiveChip(label: 'UNESCO only',
                    onRemove: () => setState(() => _unescoOnly = false)),
              if (_sortBy == 'fee_asc')
                _ActiveChip(label: 'Fee: Low → High',
                    onRemove: () => setState(() => _sortBy = 'default')),
              if (_sortBy == 'fee_desc')
                _ActiveChip(label: 'Fee: High → Low',
                    onRemove: () => setState(() => _sortBy = 'default')),
            ]),
          ),

        // ── List ─────────────────────────────────────────────
        Expanded(
          child: RefreshIndicator(
            color: _accent,
            onRefresh: () async {
              context.read<SitesBloc>().add(LoadSites());
            },
            child: BlocBuilder<SitesBloc, SitesState>(
            builder: (context, state) {
              if (state is SitesLoading) {
                return Center(
                    child: CircularProgressIndicator(
                        color: _accent, strokeWidth: 2));
              }
              if (state is SitesLoaded) {
                final filtered = _applyFilters(state.sites);

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.temple_hindu_outlined,
                              size: 48.sp, color: Colors.grey[300]),
                          SizedBox(height: 12.h),
                          Text('No sites match your filters',
                              style: GoogleFonts.dmSans(
                                  color: Colors.grey[400], fontSize: 14.sp)),
                          SizedBox(height: 8.h),
                          TextButton(
                            onPressed: _clearAll,
                            child: Text('Clear all filters',
                                style: GoogleFonts.dmSans(
                                    color: _accent,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ]),
                  );
                }

                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
                        child: Text(
                            '${filtered.length} site${filtered.length == 1 ? '' : 's'} found',
                            style: GoogleFonts.dmSans(
                                fontSize: 13.sp, color: Colors.grey[500])),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final site     = filtered[i];
                            final imageUrl = getFirstImageUrl(site.imageUrls);
                            final name     = (site.name ?? '').toString();
                            final category = (site.category ?? '').toString();
                            final district = (site.district ?? '').toString();
                            final isUnesco =
                                category.toLowerCase().contains('unesco') ||
                                site.isUNESCO == true;
                            final feeNPR   = site.entryFeeNPR ?? '0';
                            final feeSAARC = site.entryFeeSAARC ?? '0';

                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<HomestayBloc>(),
                                    child: TouristSiteDetailPage(site: site),
                                  ),
                                ),
                              ),
                              child: _SiteCard(
                                siteId: site.id,
                                imageUrl: imageUrl,
                                name: name,
                                category: category,
                                district: district,
                                isUnesco: isUnesco,
                                feeNPR: feeNPR.toString(),
                                feeSAARC: feeSAARC.toString(),
                              ),
                            );
                          },
                        ),
                      ),
                    ]);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        ),
      ]),
    );
  }
}


// ── Site Card ─────────────────────────────────────────────────
class _SiteCard extends StatelessWidget {
  final int    siteId;
  final String imageUrl, name, category, district, feeNPR, feeSAARC;
  final bool   isUnesco;

  const _SiteCard({
    required this.siteId,
    required this.imageUrl,
    required this.name,
    required this.category,
    required this.district,
    required this.isUnesco,
    required this.feeNPR,
    required this.feeSAARC,
  });

  @override
  Widget build(BuildContext context) {
    final bool freeEntry = feeNPR == '0' || feeNPR.isEmpty;
    final String feeLabel =
        freeEntry ? 'Free entry' : 'Entry  Rs. $feeNPR';
    final String saarcLabel =
        (feeSAARC == '0' || feeSAARC.isEmpty) ? '' : '  ·  SAARC Rs. $feeSAARC';

    return Container(
      margin: EdgeInsets.only(bottom: 22.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Image with name overlaid ─────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
          child: SizedBox(
            height: 200.h,
            child: Stack(children: [
              ProxyImage(
                imageUrl: imageUrl,
                width: double.infinity,
                height: 200.h,
                borderRadiusValue: 0,
                thumb: true,
              ),

              // Gradient darkening towards bottom for text legibility
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.3, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.72),
                      ],
                    ),
                  ),
                ),
              ),

              // UNESCO badge — top left
              if (isUnesco)
                Positioned(
                  top: 12.h, left: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: _teal,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.verified_rounded,
                          color: Colors.white, size: 10.sp),
                      SizedBox(width: 3.w),
                      Text('UNESCO',
                          style: GoogleFonts.dmSans(
                              fontSize: 10.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5)),
                    ]),
                  ),
                ),

              // Category badge — top right
              if (category.isNotEmpty)
                Positioned(
                  top: 12.h, right: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(category,
                        style: GoogleFonts.dmSans(
                            fontSize: 10.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
                  ),
                ),

              // Name + district — bottom of image on gradient
              Positioned(
                left: 14.w, right: 14.w, bottom: 14.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 19.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2)),
                    if (district.isNotEmpty) ...[
                      SizedBox(height: 5.h),
                      Row(children: [
                        Icon(Icons.location_on_rounded,
                            color: Colors.white60, size: 12.sp),
                        SizedBox(width: 3.w),
                        Text(district,
                            style: GoogleFonts.dmSans(
                                fontSize: 12.sp,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500)),
                      ]),
                    ],
                  ],
                ),
              ),
            ]),
          ),
        ),

        // ── Bottom bar ────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  '$feeLabel$saarcLabel',
                  style: GoogleFonts.dmSans(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(mainAxisSize: MainAxisSize.min, children: [
                SiteFavButton(siteId: siteId, size: 20),
                SizedBox(width: 12.w),
                Text('Explore',
                    style: GoogleFonts.dmSans(
                        fontSize: 13.sp,
                        color: _accent,
                        fontWeight: FontWeight.w600)),
                SizedBox(width: 3.w),
                Icon(Icons.arrow_forward_rounded,
                    size: 14.sp, color: _accent),
              ]),
            ],
          ),
        ),
      ]),
    );
  }
}


// ── Active filter chip ────────────────────────────────────────
class _ActiveChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _ActiveChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _accent.withValues(alpha: 0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label,
            style: GoogleFonts.dmSans(
                fontSize: 12.sp,
                color: _accent,
                fontWeight: FontWeight.w600)),
        SizedBox(width: 4.w),
        GestureDetector(
          onTap: onRemove,
          child: Icon(Icons.close_rounded, size: 13.sp, color: _accent),
        ),
      ]),
    );
  }
}


// ── Filter bottom sheet ───────────────────────────────────────
class _FilterSheet extends StatefulWidget {
  final List<dynamic> sites;
  final String?       category;
  final String?       district;
  final bool          unescoOnly;
  final String        sortBy;
  final void Function(String?, String?, bool, String) onApply;

  const _FilterSheet({
    required this.sites,
    required this.category,
    required this.district,
    required this.unescoOnly,
    required this.sortBy,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String? _category;
  late String? _district;
  late bool    _unescoOnly;
  late String  _sortBy;

  List<String> _categories = [];
  List<String> _districts  = [];

  @override
  void initState() {
    super.initState();
    _category   = widget.category;
    _district   = widget.district;
    _unescoOnly = widget.unescoOnly;
    _sortBy     = widget.sortBy;
    _categories = widget.sites
        .map((s) => (s.category ?? '').toString())
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    _districts = widget.sites
        .map((s) => (s.district ?? '').toString())
        .where((d) => d.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  void _reset() => setState(() {
    _category   = null;
    _district   = null;
    _unescoOnly = false;
    _sortBy     = 'default';
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            // Handle
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 12.h, bottom: 4.h),
                width: 40.w, height: 4.h,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r)),
              ),
            ),

            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                    24.w, 12.h, 24.w, bottomPad + 16.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                      Text('Filter Sites',
                          style: GoogleFonts.playfairDisplay(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: _ink)),
                      TextButton(
                        onPressed: _reset,
                        child: Text('Reset all',
                            style: GoogleFonts.dmSans(
                                fontSize: 13.sp,
                                color: Colors.grey[500])),
                      ),
                    ]),

                    SizedBox(height: 20.h),

                    // UNESCO toggle
                    _SectionLabel('Special'),
                    SizedBox(height: 10.h),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _unescoOnly = !_unescoOnly),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: _unescoOnly
                              ? _teal.withValues(alpha: 0.08)
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                              color: _unescoOnly
                                  ? _teal
                                  : Colors.grey.shade300,
                              width: _unescoOnly ? 1.5 : 1),
                        ),
                        child: Row(children: [
                          Icon(Icons.verified_rounded,
                              size: 18.sp,
                              color: _unescoOnly
                                  ? _teal
                                  : Colors.grey[400]),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text('UNESCO World Heritage Sites only',
                                style: GoogleFonts.dmSans(
                                    fontSize: 13.sp,
                                    fontWeight: _unescoOnly
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: _unescoOnly
                                        ? _teal
                                        : Colors.grey[700])),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 22.w, height: 22.h,
                            decoration: BoxDecoration(
                              color: _unescoOnly
                                  ? _teal
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: _unescoOnly
                                      ? _teal
                                      : Colors.grey.shade400,
                                  width: 1.5),
                            ),
                            child: _unescoOnly
                                ? Icon(Icons.check,
                                    size: 14.sp, color: Colors.white)
                                : null,
                          ),
                        ]),
                      ),
                    ),

                    if (_categories.isNotEmpty) ...[
                      SizedBox(height: 24.h),
                      _SectionLabel('Category'),
                      SizedBox(height: 10.h),
                      Wrap(spacing: 8.w, runSpacing: 8.h, children: [
                        _SelectChip(
                            label: 'All',
                            selected: _category == null,
                            onTap: () => setState(() => _category = null)),
                        ..._categories.map((c) => _SelectChip(
                              label: c,
                              selected: _category == c,
                              onTap: () => setState(() =>
                                  _category = _category == c ? null : c),
                            )),
                      ]),
                    ],

                    if (_districts.isNotEmpty) ...[
                      SizedBox(height: 24.h),
                      _SectionLabel('District'),
                      SizedBox(height: 10.h),
                      Wrap(spacing: 8.w, runSpacing: 8.h, children: [
                        _SelectChip(
                            label: 'All',
                            selected: _district == null,
                            onTap: () => setState(() => _district = null)),
                        ..._districts.map((d) => _SelectChip(
                              label: d,
                              selected: _district == d,
                              onTap: () => setState(() =>
                                  _district = _district == d ? null : d),
                            )),
                      ]),
                    ],

                    SizedBox(height: 24.h),
                    _SectionLabel('Sort By Entry Fee'),
                    SizedBox(height: 10.h),
                    Wrap(spacing: 8.w, runSpacing: 8.h, children: [
                      _SelectChip(
                          label: 'Default',
                          selected: _sortBy == 'default',
                          onTap: () => setState(() => _sortBy = 'default')),
                      _SelectChip(
                          label: 'Fee ↑  Low first',
                          selected: _sortBy == 'fee_asc',
                          onTap: () => setState(() => _sortBy = 'fee_asc')),
                      _SelectChip(
                          label: 'Fee ↓  High first',
                          selected: _sortBy == 'fee_desc',
                          onTap: () => setState(() => _sortBy = 'fee_desc')),
                    ]),

                    SizedBox(height: 28.h),

                    SizedBox(
                      width: double.infinity, height: 52.h,
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onApply(
                              _category, _district, _unescoOnly, _sortBy);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: Text('Apply Filters',
                            style: GoogleFonts.dmSans(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}


// ── Shared small widgets ──────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: GoogleFonts.dmSans(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: _ink,
          letterSpacing: 0.2));
}

class _SelectChip extends StatelessWidget {
  final String       label;
  final bool         selected;
  final VoidCallback onTap;
  const _SelectChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: selected ? _accent : Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
            color: selected ? _accent : Colors.grey.shade300),
        boxShadow: selected
            ? [BoxShadow(
                color: _accent.withValues(alpha: 0.22),
                blurRadius: 6,
                offset: const Offset(0, 2))]
            : [],
      ),
      child: Text(label,
          style: GoogleFonts.dmSans(
              fontSize: 13.sp,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              color: selected ? Colors.white : Colors.grey[700])),
    ),
  );
}

String getFirstImageUrl(List<String> urls) =>
    urls.isNotEmpty ? urls.first : '';


