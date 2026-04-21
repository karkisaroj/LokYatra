import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/services/image_proxy.dart';
import '../../state_management/Bloc/homestays/HomestayBloc.dart';
import '../../state_management/Bloc/homestays/HomestayEvent.dart';
import '../../state_management/Bloc/homestays/HomestayState.dart';
import 'TouristHomestayDetailPage.dart';

// ── Shared palette (matches sites page) ──────────────────────
const _ink    = Color(0xFF2D1B10);
const _accent = Color(0xFFCD6E4E);
const _cream  = Color(0xFFFAF7F2);
const _border = Color(0xFFE8DDD5);

class TouristStayPage extends StatefulWidget {
  const TouristStayPage({super.key});

  @override
  State<TouristStayPage> createState() => _TouristStayPageState();
}

class _TouristStayPageState extends State<TouristStayPage> {
  String      _search    = '';
  RangeValues _priceRange = const RangeValues(0, 10000);
  String      _sortBy    = 'default';
  int?        _minRooms;

  int get _activeFilters =>
      (_priceRange.start > 0 || _priceRange.end < 10000 ? 1 : 0) +
      (_sortBy != 'default' ? 1 : 0) +
      (_minRooms != null ? 1 : 0);

  @override
  void initState() {
    super.initState();
    context.read<HomestayBloc>().add(const TouristLoadAllHomestays());
  }

  void _openFilters(List<dynamic> all) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        all: all,
        priceRange: _priceRange,
        sortBy: _sortBy,
        minRooms: _minRooms,
        onApply: (price, sort, rooms) => setState(() {
          _priceRange = price;
          _sortBy     = sort;
          _minRooms   = rooms;
        }),
      ),
    );
  }

  List<dynamic> _applyFilters(List<dynamic> raw) {
    var list = raw.where((h) {
      if (!h.isVisible) return false;
      if (_search.isNotEmpty) {
        final name = (h.name as String).toLowerCase();
        final loc  = (h.location as String).toLowerCase();
        if (!name.contains(_search.toLowerCase()) &&
            !loc.contains(_search.toLowerCase())) return false;
      }
      final price = (h.pricePerNight as num).toDouble();
      if (price < _priceRange.start || price > _priceRange.end) return false;
      if (_minRooms != null && (h.numberOfRooms as int) < _minRooms!) return false;
      return true;
    }).toList();

    if (_sortBy == 'price_asc') {
      list.sort((a, b) =>
          (a.pricePerNight as num).compareTo(b.pricePerNight as num));
    } else if (_sortBy == 'price_desc') {
      list.sort((a, b) =>
          (b.pricePerNight as num).compareTo(a.pricePerNight as num));
    }
    return list;
  }

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
                  Text('Find Your Stay',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.bold,
                          color: _ink)),
                  SizedBox(height: 2.h),
                  Text('Traditional homestays near heritage sites',
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
                      hintText: 'Search homestays…',
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
              BlocBuilder<HomestayBloc, HomestayState>(
                builder: (context, state) {
                  final all = state is TouristAllHomestaysLoaded
                      ? state.homestays
                      : [];
                  final active = _activeFilters > 0;
                  return GestureDetector(
                    onTap: () => _openFilters(all),
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

        // ── Active filter chips ───────────────────────────────
        if (_activeFilters > 0)
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
            child: Wrap(spacing: 8.w, runSpacing: 6.h, children: [
              if (_priceRange.start > 0 || _priceRange.end < 10000)
                _ActiveChip(
                  label:
                      'Rs. ${_priceRange.start.toInt()}–${_priceRange.end.toInt()}',
                  onRemove: () =>
                      setState(() => _priceRange = const RangeValues(0, 10000)),
                ),
              if (_sortBy == 'price_asc')
                _ActiveChip(
                    label: 'Price: Low → High',
                    onRemove: () => setState(() => _sortBy = 'default')),
              if (_sortBy == 'price_desc')
                _ActiveChip(
                    label: 'Price: High → Low',
                    onRemove: () => setState(() => _sortBy = 'default')),
              if (_minRooms != null)
                _ActiveChip(
                    label: '$_minRooms+ Rooms',
                    onRemove: () => setState(() => _minRooms = null)),
            ]),
          ),

        // ── List ─────────────────────────────────────────────
        Expanded(
          child: RefreshIndicator(
            color: _accent,
            onRefresh: () async {
              context.read<HomestayBloc>().add(const TouristLoadAllHomestays());
            },
            child: BlocBuilder<HomestayBloc, HomestayState>(
              builder: (context, state) {
                if (state is HomestayLoading) {
                  return Center(
                      child: CircularProgressIndicator(
                          color: _accent, strokeWidth: 2));
                }
                if (state is TouristAllHomestaysLoaded) {
                  final filtered = _applyFilters(state.homestays);
        
                  if (filtered.isEmpty) {
                    return ListView(
                      children: [
                        SizedBox(height: 150.h),
                        Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.hotel_outlined,
                                    size: 48.sp, color: Colors.grey[300]),
                                SizedBox(height: 12.h),
                                Text('No homestays match your filters',
                                    style: GoogleFonts.dmSans(
                                        color: Colors.grey[400], fontSize: 14.sp)),
                                SizedBox(height: 8.h),
                                TextButton(
                                  onPressed: () => setState(() {
                                    _search     = '';
                                    _priceRange = const RangeValues(0, 10000);
                                    _sortBy     = 'default';
                                    _minRooms   = null;
                                  }),
                                  child: Text('Clear all filters',
                                      style: GoogleFonts.dmSans(
                                          color: _accent,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ]),
                        ),
                      ],
                    );
                  }
        
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
                          child: Text(
                              '${filtered.length} homestay${filtered.length == 1 ? '' : 's'} found',
                              style: GoogleFonts.dmSans(
                                  fontSize: 13.sp, color: Colors.grey[500])),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                            itemCount: filtered.length,
                            itemBuilder: (context, i) {
                              final h = filtered[i];
                              return RepaintBoundary(
                                child: _StayCard(
                                  homestay: h,
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              TouristHomestayDetailPage(
                                                  homestay: h.toJson()))),
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


// ── Stay Card ─────────────────────────────────────────────────
class _StayCard extends StatelessWidget {
  final dynamic   homestay;
  final VoidCallback onTap;
  const _StayCard({required this.homestay, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imageUrl  = homestay.imageUrls?.isNotEmpty == true
        ? homestay.imageUrls!.first as String
        : null;
    final nearSite  = homestay.nearCulturalSite != null
        ? 'Near ${homestay.nearCulturalSite!.name}'
        : (homestay.location ?? '') as String;
    final category  = (homestay.category ?? '') as String;
    final rooms     = homestay.numberOfRooms as int? ?? 1;
    final guests    = homestay.maxGuests as int? ?? rooms * 2;
    final price     = homestay.pricePerNight as num? ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 20.h),
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

          // ── Image ──────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
            child: SizedBox(
              height: 185.h,
              child: Stack(children: [
                ProxyImage(
                  imageUrl: imageUrl,
                  width: double.infinity,
                  height: 185.h,
                  borderRadiusValue: 0,
                  thumb: true,
                ),

                // Subtle gradient at bottom
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.45, 1.0],
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                  ),
                ),

                // Category badge — bottom left on image
                if (category.isNotEmpty)
                  Positioned(
                    bottom: 12.h, left: 12.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 9.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(category,
                          style: GoogleFonts.dmSans(
                              fontSize: 10.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),

                // Fav button — top right
                Positioned(
                  top: 10.h, right: 10.w,
                  child: Container(
                    padding: EdgeInsets.all(7.w),
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: Icon(Icons.favorite_border_rounded,
                        size: 16.sp, color: Colors.grey[500]),
                  ),
                ),
              ]),
            ),
          ),

          // ── Info ───────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 13.h, 14.w, 14.h),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

              // Name
              Text(homestay.name ?? '',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: _ink,
                      height: 1.2)),

              SizedBox(height: 6.h),

              // Location + meta pills in one row
              Row(children: [
                Icon(Icons.location_on_outlined,
                    size: 13.sp, color: Colors.grey[500]),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(nearSite,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(
                          fontSize: 12.sp, color: Colors.grey[500])),
                ),
              ]),

              SizedBox(height: 8.h),

              // Rooms + guests chips
              Row(children: [
                _MetaPill(icon: Icons.bed_outlined, label: '$rooms rooms'),
                SizedBox(width: 6.w),
                _MetaPill(
                    icon: Icons.group_outlined, label: '$guests guests'),
              ]),

              SizedBox(height: 12.h),
              Divider(color: Colors.grey.shade100, height: 1),
              SizedBox(height: 12.h),

              // Price + Book row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('from',
                        style: GoogleFonts.dmSans(
                            fontSize: 11.sp, color: Colors.grey[500])),
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: 'Rs. ${price.toStringAsFixed(0)}',
                          style: GoogleFonts.dmSans(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: _accent),
                        ),
                        TextSpan(
                          text: ' / night',
                          style: GoogleFonts.dmSans(
                              fontSize: 11.sp,
                              color: Colors.grey[500]),
                        ),
                      ]),
                    ),
                  ]),

                  ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _ink,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 11.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                    ),
                    child: Text('Book Now',
                        style: GoogleFonts.dmSans(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String   label;
  const _MetaPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
    decoration: BoxDecoration(
      color: _cream,
      borderRadius: BorderRadius.circular(6.r),
      border: Border.all(color: _border),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12.sp, color: Colors.grey[600]),
      SizedBox(width: 4.w),
      Text(label,
          style: GoogleFonts.dmSans(
              fontSize: 11.sp,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500)),
    ]),
  );
}


// ── Active filter chip ────────────────────────────────────────
class _ActiveChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _ActiveChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) => Container(
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


// ── Filter bottom sheet ───────────────────────────────────────
class _FilterSheet extends StatefulWidget {
  final List<dynamic> all;
  final RangeValues   priceRange;
  final String        sortBy;
  final int?          minRooms;
  final void Function(RangeValues, String, int?) onApply;

  const _FilterSheet({
    required this.all,
    required this.priceRange,
    required this.sortBy,
    required this.minRooms,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late RangeValues _price;
  late String _sort;
  late int?   _rooms;
  double _maxPrice = 10000;

  @override
  void initState() {
    super.initState();
    _price = widget.priceRange;
    _sort  = widget.sortBy;
    _rooms = widget.minRooms;
    if (widget.all.isNotEmpty) {
      final top = widget.all
          .map((h) => (h.pricePerNight as num).toDouble())
          .reduce((a, b) => a > b ? a : b);
      _maxPrice = (top / 1000).ceil() * 1000;
      if (_price.end > _maxPrice) {
        _price = RangeValues(_price.start, _maxPrice);
      }
    }
  }

  void _reset() => setState(() {
    _price = RangeValues(0, _maxPrice);
    _sort  = 'default';
    _rooms = null;
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Padding(
      // Avoid keyboard
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ConstrainedBox(
        // Never exceed 85% of screen height — scrolls if needed
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            // Drag handle
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

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Filter Stays',
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
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // Price range
                    _SectionLabel('Price per Night'),
                    SizedBox(height: 8.h),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                      _PriceTag('Rs. ${_price.start.toInt()}'),
                      _PriceTag('Rs. ${_price.end.toInt()}'),
                    ]),
                    SizedBox(height: 4.h),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor:   _accent,
                        inactiveTrackColor: _accent.withValues(alpha: 0.15),
                        thumbColor:         _accent,
                        overlayColor:       _accent.withValues(alpha: 0.12),
                        rangeThumbShape:
                            const RoundRangeSliderThumbShape(
                                enabledThumbRadius: 10),
                        trackHeight: 4,
                      ),
                      child: RangeSlider(
                        min: 0,
                        max: _maxPrice,
                        divisions: (_maxPrice / 500).toInt(),
                        values: _price,
                        onChanged: (v) => setState(() => _price = v),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Sort by
                    _SectionLabel('Sort By'),
                    SizedBox(height: 10.h),
                    Wrap(spacing: 8.w, runSpacing: 8.h, children: [
                      _SelectChip(
                          label: 'Default',
                          selected: _sort == 'default',
                          onTap: () => setState(() => _sort = 'default')),
                      _SelectChip(
                          label: 'Price ↑  Low first',
                          selected: _sort == 'price_asc',
                          onTap: () => setState(() => _sort = 'price_asc')),
                      _SelectChip(
                          label: 'Price ↓  High first',
                          selected: _sort == 'price_desc',
                          onTap: () => setState(() => _sort = 'price_desc')),
                    ]),

                    SizedBox(height: 24.h),

                    // Minimum rooms
                    _SectionLabel('Minimum Rooms'),
                    SizedBox(height: 10.h),
                    Wrap(spacing: 8.w, runSpacing: 8.h, children: [
                      _SelectChip(
                          label: 'Any',
                          selected: _rooms == null,
                          onTap: () => setState(() => _rooms = null)),
                      for (final r in [1, 2, 3, 5])
                        _SelectChip(
                            label: '$r+',
                            selected: _rooms == r,
                            onTap: () => setState(() => _rooms = r)),
                    ]),

                    SizedBox(height: 28.h),

                    SizedBox(
                      width: double.infinity, height: 52.h,
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onApply(_price, _sort, _rooms);
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

class _PriceTag extends StatelessWidget {
  final String text;
  const _PriceTag(this.text);

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
    decoration: BoxDecoration(
      color: _cream,
      borderRadius: BorderRadius.circular(8.r),
      border: Border.all(color: _border),
    ),
    child: Text(text,
        style: GoogleFonts.dmSans(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: _ink)),
  );
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
