import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/services/image_proxy.dart';
import '../../state_management/Bloc/homestays/HomestayBloc.dart';
import '../../state_management/Bloc/homestays/HomestayEvent.dart';
import '../../state_management/Bloc/homestays/HomestayState.dart';
import 'TouristHomestayDetailPage.dart';

class TouristStayPage extends StatefulWidget {
  const TouristStayPage({super.key});

  @override
  State<TouristStayPage> createState() => _TouristStayPageState();
}

class _TouristStayPageState extends State<TouristStayPage> {
  static const ink    = Color(0xFF2D1B10);
  static const accent = Color(0xFF3A3A3A);

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
        onApply: (price, sort, rooms) {
          setState(() {
            _priceRange = price;
            _sortBy     = sort;
            _minRooms   = rooms;
          });
        },
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
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Find Your Stay',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: ink)),
            SizedBox(height: 12.h),
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
                      hintText: 'Search homestays...',
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
              BlocBuilder<HomestayBloc, HomestayState>(
                builder: (context, state) {
                  final all = state is TouristAllHomestaysLoaded
                      ? state.homestays
                      : [];
                  return GestureDetector(
                    onTap: () => _openFilters(all),
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
                            color:
                            _activeFilters > 0 ? Colors.white : ink),
                      ),
                      if (_activeFilters > 0)
                        Positioned(
                          top: -4.h, right: -4.w,
                          child: Container(
                            width: 18.w, height: 18.h,
                            decoration: BoxDecoration(
                              color: ink,
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

        if (_activeFilters > 0)
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
            child: Wrap(spacing: 8.w, runSpacing: 6.h, children: [
              if (_priceRange.start > 0 || _priceRange.end < 10000)
                _FilterChip(
                  label:
                  'Rs. ${_priceRange.start.toInt()}–${_priceRange.end.toInt()}',
                  onRemove: () =>
                      setState(() => _priceRange = const RangeValues(0, 10000)),
                ),
              if (_sortBy == 'price_asc')
                _FilterChip(
                    label: 'Price: Low → High',
                    onRemove: () => setState(() => _sortBy = 'default')),
              if (_sortBy == 'price_desc')
                _FilterChip(
                    label: 'Price: High → Low',
                    onRemove: () => setState(() => _sortBy = 'default')),
              if (_minRooms != null)
                _FilterChip(
                    label: '$_minRooms+ Rooms',
                    onRemove: () => setState(() => _minRooms = null)),
            ]),
          ),

        Expanded(
          child: BlocBuilder<HomestayBloc, HomestayState>(
            builder: (context, state) {
              if (state is HomestayLoading) {
                return Center(
                    child: CircularProgressIndicator(color: accent));
              }
              if (state is TouristAllHomestaysLoaded) {
                final filtered = _applyFilters(state.homestays);

                if (filtered.isEmpty) {
                  return Center(
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
                        padding:
                        EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
                        child: Text(
                            '${filtered.length} homestay${filtered.length == 1 ? '' : 's'} found',
                            style: GoogleFonts.dmSans(
                                fontSize: 13.sp, color: Colors.grey[500])),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final h = filtered[i];
                            return _StayCard(
                              homestay: h,
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          TouristHomestayDetailPage(
                                              homestay: h.toJson()))),
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

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _FilterChip({required this.label, required this.onRemove});

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

class _FilterSheet extends StatefulWidget {
  final List<dynamic> all;
  final RangeValues priceRange;
  final String sortBy;
  final int? minRooms;
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
  static const ink    = Color(0xFF2D1B10);
  static const accent = Color(0xFFCD6E4E);

  late RangeValues _price;
  late String _sort;
  late int? _rooms;
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 32.h),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(
          child: Container(
            margin: EdgeInsets.only(top: 12.h, bottom: 20.h),
            width: 40.w, height: 4.h,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r)),
          ),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Filter Stays',
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
        _SectionLabel('Price per Night'),
        SizedBox(height: 8.h),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _PriceTag('Rs. ${_price.start.toInt()}'),
          _PriceTag('Rs. ${_price.end.toInt()}'),
        ]),
        SizedBox(height: 4.h),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: accent,
            inactiveTrackColor: accent.withValues(alpha: 0.15),
            thumbColor: accent,
            overlayColor: accent.withValues(alpha: 0.12),
            rangeThumbShape:
            const RoundRangeSliderThumbShape(enabledThumbRadius: 10),
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
        _SectionLabel('Sort By'),
        SizedBox(height: 10.h),
        Row(children: [
          _SortChip(label: 'Default',
              selected: _sort == 'default',
              onTap: () => setState(() => _sort = 'default')),
          SizedBox(width: 8.w),
          _SortChip(label: 'Price ↑',
              selected: _sort == 'price_asc',
              onTap: () => setState(() => _sort = 'price_asc')),
          SizedBox(width: 8.w),
          _SortChip(label: 'Price ↓',
              selected: _sort == 'price_desc',
              onTap: () => setState(() => _sort = 'price_desc')),
        ]),
        SizedBox(height: 24.h),
        _SectionLabel('Minimum Rooms'),
        SizedBox(height: 10.h),
        Row(children: [
          _SortChip(label: 'Any',
              selected: _rooms == null,
              onTap: () => setState(() => _rooms = null)),
          SizedBox(width: 8.w),
          for (final r in [1, 2, 3, 5]) ...[
            _SortChip(label: '$r+',
                selected: _rooms == r,
                onTap: () => setState(() => _rooms = r)),
            SizedBox(width: 8.w),
          ],
        ]),
        SizedBox(height: 32.h),
        SizedBox(
          width: double.infinity, height: 52.h,
          child: ElevatedButton(
            onPressed: () {
              widget.onApply(_price, _sort, _rooms);
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

class _PriceTag extends StatelessWidget {
  final String text;
  const _PriceTag(this.text);

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
    decoration: BoxDecoration(
      color: const Color(0xFFFAF7F2),
      borderRadius: BorderRadius.circular(8.r),
      border: Border.all(color: const Color(0xFFE8DDD5)),
    ),
    child: Text(text,
        style: GoogleFonts.dmSans(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D1B10))),
  );
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SortChip(
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
            blurRadius: 6,
            offset: const Offset(0, 2))]
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

class _StayCard extends StatelessWidget {
  final dynamic homestay;
  final VoidCallback onTap;
  const _StayCard({required this.homestay, required this.onTap});

  static const ink    = Color(0xFF2D1B10);
  static const accent = Color(0xFF3C3C3C);

  @override
  Widget build(BuildContext context) {
    final imageUrl = homestay.imageUrls?.isNotEmpty == true
        ? homestay.imageUrls!.first
        : null;
    final nearSite = homestay.nearCulturalSite != null
        ? 'Near ${homestay.nearCulturalSite!.name}'
        : homestay.location ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            ClipRRect(
              borderRadius:
              BorderRadius.vertical(top: Radius.circular(16.r)),
              child: ProxyImage(
                imageUrl: imageUrl,
                width: double.infinity,
                height: 180.h,
                borderRadiusValue: 0,
                thumb: true,
              ),
            ),
            Positioned(
              top: 12.h, right: 12.w,
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: Icon(Icons.favorite_border_rounded,
                    size: 18.sp, color: Colors.grey[600]),
              ),
            ),
          ]),
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(homestay.name ?? '',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: ink)),
                  SizedBox(height: 4.h),
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
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                          '${homestay.numberOfRooms ?? 1} rooms',
                          style: GoogleFonts.dmSans(
                              fontSize: 11.sp,
                              color: accent,
                              fontWeight: FontWeight.w600)),
                    ),
                  ]),
                  SizedBox(height: 10.h),
                  Divider(color: Colors.grey.shade100),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('From',
                                style: GoogleFonts.dmSans(
                                    fontSize: 11.sp, color: Colors.grey[500])),
                            Text(
                                'Rs. ${homestay.pricePerNight?.toStringAsFixed(0) ?? "0"}/night',
                                style: GoogleFonts.dmSans(
                                    fontSize: 16.sp,
                                    color: accent,
                                    fontWeight: FontWeight.w700)),
                            Text('+13% VAT',
                                style: GoogleFonts.dmSans(
                                    fontSize: 10.sp, color: Colors.grey[400])),
                          ]),
                      ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 10.h),
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