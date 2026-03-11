import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/services/image_proxy.dart';
import 'package:lokyatra_frontend/presentation/screens/TouristScreen/TouristSitesDetails.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/homestays/HomestayBloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_event.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_state.dart';

class TouristSitesPage extends StatefulWidget {
  const TouristSitesPage({super.key});

  @override
  State<TouristSitesPage> createState() => _TouristSitesPageState();
}

class _TouristSitesPageState extends State<TouristSitesPage> {
  static const ink    = Color(0xFF2D1B10);
  static const accent = Color(0xFFCD6E4E);

  String  _search       = '';
  String? _category;         // null = all
  String? _district;         // null = all
  bool    _unescoOnly   = false;
  String  _sortBy       = 'default'; // 'default' | 'fee_asc' | 'fee_desc'

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

        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Cultural Sites',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: ink)),
            SizedBox(height: 12.h),

            // Search + Filter row
            Row(children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _search = v),
                    style: GoogleFonts.dmSans(fontSize: 14.sp),
                    decoration: InputDecoration(
                      hintText: 'Search sites...',
                      hintStyle: GoogleFonts.dmSans(
                          fontSize: 14.sp, color: Colors.grey[400]),
                      prefixIcon:
                      Icon(Icons.search, color: accent, size: 20.sp),
                      suffixIcon: _search.isNotEmpty
                          ? IconButton(
                        icon: Icon(Icons.close,
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

              // Filter button + badge
              BlocBuilder<SitesBloc, SitesState>(
                builder: (context, state) {
                  final sites =
                  state is SitesLoaded ? state.sites : <dynamic>[];
                  return GestureDetector(
                    onTap: () => _openFilters(sites),
                    child: Stack(clipBehavior: Clip.none, children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: _activeFilters > 0 ? accent : Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: Icon(Icons.tune_rounded,
                            size: 20.sp,
                            color: _activeFilters > 0 ? Colors.white : ink),
                      ),
                      if (_activeFilters > 0)
                        Positioned(
                          top: -4.h, right: -4.w,
                          child: Container(
                            width: 18.w, height: 18.h,
                            decoration: BoxDecoration(
                              color: ink, shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white, width: 1.5),
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

        // ── Active filter chips ──────────────────────────────────────────────
        if (_activeFilters > 0)
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
            child: Wrap(spacing: 8.w, runSpacing: 6.h, children: [
              if (_category != null)
                _ActiveChip(
                    label: _category!,
                    onRemove: () => setState(() => _category = null)),
              if (_district != null)
                _ActiveChip(
                    label: _district!,
                    onRemove: () => setState(() => _district = null)),
              if (_unescoOnly)
                _ActiveChip(
                    label: 'UNESCO only',
                    onRemove: () => setState(() => _unescoOnly = false)),
              if (_sortBy == 'fee_asc')
                _ActiveChip(
                    label: 'Fee: Low → High',
                    onRemove: () => setState(() => _sortBy = 'default')),
              if (_sortBy == 'fee_desc')
                _ActiveChip(
                    label: 'Fee: High → Low',
                    onRemove: () => setState(() => _sortBy = 'default')),
            ]),
          ),

        // ── List ─────────────────────────────────────────────────────────────
        Expanded(
          child: BlocBuilder<SitesBloc, SitesState>(
            builder: (context, state) {
              if (state is SitesLoading) {
                return Center(
                    child: CircularProgressIndicator(color: accent));
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
                                    color: accent,
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
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
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
      ]),
    );
  }
}

// ── Site card ─────────────────────────────────────────────────────────────────

class _SiteCard extends StatelessWidget {
  final String imageUrl, name, category, district, feeNPR, feeSAARC;
  final bool   isUnesco;
  const _SiteCard({
    required this.imageUrl,
    required this.name,
    required this.category,
    required this.district,
    required this.isUnesco,
    required this.feeNPR,
    required this.feeSAARC,
  });

  static const ink    = Color(0xFF2D1B10);
  static const accent = Color(0xFFCD6E4E);
  static const teal   = Color(0xFF2D6A6A);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Image ──────────────────────────────────────────────────────────
        Stack(children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            child: ProxyImage(
              imageUrl: imageUrl,
              width: double.infinity,
              height: 180.h,
              borderRadiusValue: 0,
              thumb: true,
            ),
          ),

          // Dark gradient at bottom of image
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              height: 80.h,
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(0.r)),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // UNESCO badge (top-left)
          if (isUnesco)
            Positioned(
              top: 12.h, left: 12.w,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                    color: teal,
                    borderRadius: BorderRadius.circular(6.r)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.verified_rounded,
                      color: Colors.white, size: 11.sp),
                  SizedBox(width: 4.w),
                  Text('UNESCO',
                      style: GoogleFonts.dmSans(
                          fontSize: 10.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5)),
                ]),
              ),
            ),

          // Category badge (top-right)
          if (category.isNotEmpty)
            Positioned(
              top: 12.h, right: 12.w,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(category,
                    style: GoogleFonts.dmSans(
                        fontSize: 10.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
              ),
            ),

          // District pill pinned to gradient (bottom-left)
          if (district.isNotEmpty)
            Positioned(
              bottom: 10.h, left: 12.w,
              child: Row(children: [
                Icon(Icons.location_on_rounded,
                    color: Colors.white70, size: 12.sp),
                SizedBox(width: 3.w),
                Text(district,
                    style: GoogleFonts.dmSans(
                        fontSize: 12.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w500)),
              ]),
            ),
        ]),

        // ── Info row ───────────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Name
                Expanded(
                  child: Text(name,
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                          color: ink,
                          height: 1.25)),
                ),

                SizedBox(width: 12.w),

                // Fee column
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Rs. $feeNPR',
                              style: GoogleFonts.dmSans(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: accent)),
                          Text('SAARC Rs. $feeSAARC',
                              style: GoogleFonts.dmSans(
                                  fontSize: 10.sp,
                                  color: Colors.grey[500])),
                        ]),
                  ),
                ]),
              ]),
        ),
      ]),
    );
  }
}

// ── Active filter chip ────────────────────────────────────────────────────────

class _ActiveChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _ActiveChip({required this.label, required this.onRemove});

  static const accent = Color(0xFFCD6E4E);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label,
            style: GoogleFonts.dmSans(
                fontSize: 12.sp,
                color: accent,
                fontWeight: FontWeight.w600)),
        SizedBox(width: 4.w),
        GestureDetector(
          onTap: onRemove,
          child: Icon(Icons.close, size: 13.sp, color: accent),
        ),
      ]),
    );
  }
}

// ── Filter bottom sheet ───────────────────────────────────────────────────────

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
  static const ink    = Color(0xFF2D1B10);
  static const accent = Color(0xFFCD6E4E);

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

    // derive unique values from data
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 32.h),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          // Handle
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 12.h, bottom: 20.h),
              width: 40.w, height: 4.h,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r)),
            ),
          ),

          // Title + Reset
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Filter Sites',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: ink)),
            TextButton(
              onPressed: _reset,
              child: Text('Reset all',
                  style: GoogleFonts.dmSans(
                      fontSize: 13.sp, color: Colors.grey[500])),
            ),
          ]),

          SizedBox(height: 24.h),

          // ── UNESCO toggle ────────────────────────────────────────────────
          _SectionLabel('Special'),
          SizedBox(height: 10.h),
          GestureDetector(
            onTap: () => setState(() => _unescoOnly = !_unescoOnly),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(
                  horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: _unescoOnly
                    ? const Color(0xFF2D6A6A).withValues(alpha: 0.08)
                    : Colors.grey[50],
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                    color: _unescoOnly
                        ? const Color(0xFF2D6A6A)
                        : Colors.grey.shade300,
                    width: _unescoOnly ? 1.5 : 1),
              ),
              child: Row(children: [
                Icon(Icons.verified_rounded,
                    size: 18.sp,
                    color: _unescoOnly
                        ? const Color(0xFF2D6A6A)
                        : Colors.grey[400]),
                SizedBox(width: 10.w),
                Text('UNESCO World Heritage Sites only',
                    style: GoogleFonts.dmSans(
                        fontSize: 13.sp,
                        fontWeight: _unescoOnly
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _unescoOnly
                            ? const Color(0xFF2D6A6A)
                            : Colors.grey[700])),
                const Spacer(),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 22.w, height: 22.h,
                  decoration: BoxDecoration(
                    color: _unescoOnly
                        ? const Color(0xFF2D6A6A)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: _unescoOnly
                            ? const Color(0xFF2D6A6A)
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

          SizedBox(height: 24.h),

          // ── Category ────────────────────────────────────────────────────
          if (_categories.isNotEmpty) ...[
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
                onTap: () =>
                    setState(() => _category = _category == c ? null : c),
              )),
            ]),
            SizedBox(height: 24.h),
          ],

          // ── District ─────────────────────────────────────────────────────
          if (_districts.isNotEmpty) ...[
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
                onTap: () =>
                    setState(() => _district = _district == d ? null : d),
              )),
            ]),
            SizedBox(height: 24.h),
          ],

          // ── Sort by ───────────────────────────────────────────────────────
          _SectionLabel('Sort By Entry Fee'),
          SizedBox(height: 10.h),
          Row(children: [
            _SelectChip(
                label: 'Default',
                selected: _sortBy == 'default',
                onTap: () => setState(() => _sortBy = 'default')),
            SizedBox(width: 8.w),
            _SelectChip(
                label: 'Fee ↑',
                selected: _sortBy == 'fee_asc',
                onTap: () => setState(() => _sortBy = 'fee_asc')),
            SizedBox(width: 8.w),
            _SelectChip(
                label: 'Fee ↓',
                selected: _sortBy == 'fee_desc',
                onTap: () => setState(() => _sortBy = 'fee_desc')),
          ]),

          SizedBox(height: 32.h),

          // ── Apply ─────────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity, height: 52.h,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_category, _district, _unescoOnly, _sortBy);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text('Apply Filters',
                  style: GoogleFonts.dmSans(
                      fontSize: 15.sp, fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      ),
    );
  }
}


class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Text(text,
        style: GoogleFonts.dmSans(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D1B10))),
  );
}

class _SelectChip extends StatelessWidget {
  final String       label;
  final bool         selected;
  final VoidCallback onTap;
  const _SelectChip(
      {required this.label, required this.selected, required this.onTap});

  static const accent = Color(0xFFCD6E4E);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: selected ? accent : Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
            color: selected ? accent : Colors.grey.shade300),
        boxShadow: selected
            ? [BoxShadow(
            color: accent.withValues(alpha: 0.25),
            blurRadius: 6, offset: const Offset(0, 2))]
            : [],
      ),
      child: Text(label,
          style: GoogleFonts.dmSans(
              fontSize: 13.sp,
              fontWeight:
              selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? Colors.white : Colors.grey[700])),
    ),
  );
}

String getFirstImageUrl(List<String> urls) =>
    urls.isNotEmpty ? urls.first : '';