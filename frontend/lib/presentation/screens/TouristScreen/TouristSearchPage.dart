import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/image_proxy.dart';
import 'package:lokyatra_frontend/data/models/Homestay.dart';
import 'package:lokyatra_frontend/data/models/TouristSite.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/homestays/HomestayBloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/homestays/HomestayState.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_state.dart';
import 'TouristHomestayDetailPage.dart';
import 'TouristSitesDetails.dart';

class TouristSearchPage extends StatefulWidget {
  const TouristSearchPage({super.key});

  @override
  State<TouristSearchPage> createState() => _TouristSearchPageState();
}

class _TouristSearchPageState extends State<TouristSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  static const _terracotta = Color(0xFFCD6E4E);
  static const _dark = Color(0xFF2D1B10);
  static const _cream = Color(0xFFFAF7F2);

  // Mock data for recent/popular searches
  final List<String> _recentSearches = [
    'Pashupatinath',
    'Homestay Boudha',
    'Unesco Sites',
    'Buddhanilkantha'
  ];

  final List<String> _popularSearches = [
    'Kathmandu Durbar Square',
    'Bhaktapur',
    'Swayambhunath',
    'Patan'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _dark, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Search',
            style: GoogleFonts.dmSans(
                color: _dark, fontSize: 18.sp, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (val) {
                  setState(() {
                    _query = val;
                  });
                },
                style: GoogleFonts.dmSans(fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: GoogleFonts.dmSans(
                      fontSize: 14.sp, color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: Colors.grey[500], size: 22.sp),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.close,
                        color: Colors.grey[500], size: 20.sp),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                ),
              ),
            ),
          ),
          Expanded(
            child: _query.isEmpty ? _buildSuggestions() : _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentSearches.isNotEmpty) ...[
            Text('Recent Searches',
                style: GoogleFonts.dmSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: _dark)),
            SizedBox(height: 12.h),
            ..._recentSearches.map((term) => _RecentSearchItem(
              term: term,
              onTap: () {
                _searchController.text = term;
                setState(() => _query = term);
              },
              onRemove: () {
                setState(() {
                  _recentSearches.remove(term);
                });
              },
            )),
            SizedBox(height: 24.h),
          ],
          Text('Popular Searches',
              style: GoogleFonts.dmSans(
                  fontSize: 16.sp, fontWeight: FontWeight.w500, color: _dark)),
          SizedBox(height: 12.h),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: _popularSearches.asMap().entries.map((entry) {
                final index = entry.key;
                final term = entry.value;
                return Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.location_on_outlined,
                          color: Colors.grey[600], size: 20.sp),
                      title: Text(term,
                          style: GoogleFonts.dmSans(
                              fontSize: 14.sp, color: _dark)),
                      onTap: () {
                        _searchController.text = term;
                        setState(() => _query = term);
                      },
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                      visualDensity: VisualDensity.compact,
                    ),
                    if (index != _popularSearches.length - 1)
                      Divider(height: 1, color: Colors.grey.shade100),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return CustomScrollView(
      slivers: [
        // Sites Results
        BlocBuilder<SitesBloc, SitesState>(
          builder: (context, state) {
            if (state is SitesLoaded) {
              final results = state.sites.where((site) {
                final name = (site['name'] ?? '').toString().toLowerCase();
                final location =
                (site['location'] ?? '').toString().toLowerCase();
                final q = _query.toLowerCase();
                return name.contains(q) || location.contains(q);
              }).toList();

              if (results.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: Text('Sites',
                            style: GoogleFonts.dmSans(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: _dark)),
                      );
                    }
                    final site = results[index - 1];
                    return _SearchResultItem(
                      title: site['name'] ?? '',
                      subtitle: site['location'] ?? '',
                      imageUrl: getFirstImageUrl(site['imageUrls']),
                      type: 'Site',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<HomestayBloc>(),
                            child: TouristSiteDetailPage(
                              site: TouristSite.fromJson(site),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: results.length + 1,
                ),
              );
            }
            return const SliverToBoxAdapter(child: SizedBox.shrink());
          },
        ),

        SliverToBoxAdapter(child: SizedBox(height: 20.h)),

        // Homestays Results
        BlocBuilder<HomestayBloc, HomestayState>(
          builder: (context, state) {
            if (state is TouristAllHomestaysLoaded) {
              final results = state.homestays.where((h) {
                if (!h.isVisible) return false;
                final name = h.name.toLowerCase();
                final location = h.location.toLowerCase();
                final q = _query.toLowerCase();
                return name.contains(q) || location.contains(q);
              }).toList();

              if (results.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: Text('Homestays',
                            style: GoogleFonts.dmSans(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: _dark)),
                      );
                    }
                    final homestay = results[index - 1];
                    return _SearchResultItem(
                      title: homestay.name,
                      subtitle: homestay.location,
                      imageUrl: homestay.imageUrls.isNotEmpty
                          ? homestay.imageUrls.first
                          : null,
                      type: 'Stay',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TouristHomestayDetailPage(
                              homestay: homestay.toJson()),
                        ),
                      ),
                    );
                  },
                  childCount: results.length + 1,
                ),
              );
            }
            return const SliverToBoxAdapter(child: SizedBox.shrink());
          },
        ),
      ],
    );
  }
}

class _RecentSearchItem extends StatelessWidget {
  final String term;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _RecentSearchItem(
      {required this.term, required this.onTap, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.history, color: Colors.black87, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(term,
                  style: GoogleFonts.dmSans(
                      fontSize: 14.sp, color: const Color(0xFF2D1B10))),
            ),
            GestureDetector(
              onTap: onRemove,
              child: Icon(Icons.close, color: Colors.grey[400], size: 18.sp),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String type;
  final VoidCallback onTap;

  const _SearchResultItem({
    required this.title,
    required this.subtitle,
    this.imageUrl,
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: ProxyImage(
                imageUrl: imageUrl,
                width: 60.w,
                height: 60.h,
                borderRadiusValue: 8,
                thumb: true,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D1B10))),
                  SizedBox(height: 4.h),
                  Text(subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(
                          fontSize: 12.sp, color: Colors.grey[600])),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF7F2),
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(type,
                  style: GoogleFonts.dmSans(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700])),
            ),
          ],
        ),
      ),
    );
  }
}
