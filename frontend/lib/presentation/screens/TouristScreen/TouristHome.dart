import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/image_proxy.dart';
import 'package:lokyatra_frontend/data/models/Homestay.dart';
import 'package:lokyatra_frontend/presentation/screens/TouristScreen/TouristProfilePage.dart';
import '../../../data/models/TouristSite.dart';
import '../../state_management/Bloc/homestays/HomestayBloc.dart';
import '../../state_management/Bloc/homestays/HomestayEvent.dart';
import '../../state_management/Bloc/homestays/HomestayState.dart';
import '../../state_management/Bloc/sites/sites_bloc.dart';
import '../../state_management/Bloc/sites/sites_event.dart';
import '../../state_management/Bloc/sites/sites_state.dart';
import 'CategoryResultPage.dart';
import 'TouristSitesDetails.dart';
import 'Touriststaypage.dart';
import 'TouristHomestayDetailPage.dart';
import 'Touristsitespage.dart';
import 'TouristSearchPage.dart';

class TouristHome extends StatefulWidget {
  const TouristHome({super.key});

  @override
  State<TouristHome> createState() => _TouristHomeState();
}

class _TouristHomeState extends State<TouristHome> {
  int _currentIndex = 0;
  static const _terracotta = Color(0xFFCD6E4E);
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const _HomeTab(),
      const TouristSitesPage(),
      const Center(child: Text('Quiz coming soon')),
      const TouristStayPage(),
      TouristProfilePage()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          // FIX: Reset and reload homestays when returning to home tab
          if (index == 0) {
            // Use microtask to ensure this runs after the build is complete
            Future.microtask(() {
              if (mounted) {
                // First reset the state to clear any nearby homestays data
                context.read<HomestayBloc>().add(const ResetHomestayState());
                // Then reload all homestays
                context.read<HomestayBloc>().add(const TouristLoadAllHomestays());
              }
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _terracotta,
        unselectedItemColor: Colors.grey[400],
        backgroundColor: Colors.white,
        selectedLabelStyle: GoogleFonts.dmSans(
            fontSize: 11.sp, fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.dmSans(
            fontSize: 11.sp, fontWeight: FontWeight.w500),
        elevation: 20,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map_rounded),
              label: 'Sites'),
          BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_outlined),
              activeIcon: Icon(Icons.emoji_events_rounded),
              label: 'Quiz'),
          BottomNavigationBarItem(
              icon: Icon(Icons.hotel_outlined),
              activeIcon: Icon(Icons.hotel_rounded),
              label: 'Stay'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> with AutomaticKeepAliveClientMixin {
  static const _dark = Color(0xFF2D1B10);
  final _searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true; // Keep the state alive

  @override
  void initState() {
    super.initState();
    context.read<SitesBloc>().add(LoadSites());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This runs when dependencies change, but we need something else
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Explore Nepal',
                              style: GoogleFonts.dmSans(
                                  fontSize: 14.sp, color: Colors.grey[600])),
                          Text('LokYatra',
                              style: GoogleFonts.playfairDisplay(
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.bold,
                                  color: _dark)),
                        ],
                      ),
                      CircleAvatar(
                        radius: 22.r,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: const NetworkImage(
                            'https://cdn-icons-png.flaticon.com/512/3135/3135715.png'),
                      )
                    ],
                  ),
                  SizedBox(height: 20.h),
                  _SearchBar(
                    controller: _searchController,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TouristSearchPage()),
                      );
                    },
                  ),
                  SizedBox(height: 24.h),
                  Text('Browse by Category',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: _dark)),
                  SizedBox(height: 16.h),
                  const _CategorySection(),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: _SectionHeader(title: 'Popular Sites', onSeeAll: () {}),
                ),
                SizedBox(height: 12.h),
                BlocBuilder<SitesBloc, SitesState>(
                  builder: (context, state) {
                    if (state is SitesLoading) {
                      return SizedBox(
                          height: 240.h,
                          child: const Center(child: CircularProgressIndicator()));
                    }
                    if (state is SitesLoaded) {
                      return SizedBox(
                        height: 250.h,
                        child: ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          scrollDirection: Axis.horizontal,
                          itemCount: state.sites.take(5).length,
                          separatorBuilder: (context, index) => SizedBox(width: 16.w),
                          itemBuilder: (context, index) {
                            final site = state.sites[index];
                            return _HorizontalSiteCard(
                              site: site,
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
                              ).then((_) {
                                // When returning from site detail, reload homestays
                                if (mounted) {
                                  debugPrint('🏠 Returning from site detail - reloading homestays');
                                  context.read<HomestayBloc>().add(const ResetHomestayState());
                                  context.read<HomestayBloc>().add(const TouristLoadAllHomestays());
                                }
                              }),
                            );
                          },
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 32.h, 20.w, 12.h),
              child: _SectionHeader(title: 'Popular Stays', onSeeAll: () {}),
            ),
          ),
          SliverToBoxAdapter(
            child: BlocBuilder<HomestayBloc, HomestayState>(
              builder: (context, state) {
                if (state is HomestayLoading) {
                  return SizedBox(
                      height: 200.h,
                      child: const Center(child: CircularProgressIndicator()));
                }
                if (state is TouristAllHomestaysLoaded) {
                  debugPrint('🏠 Home showing ${state.homestays.length} homestays');
                  final visible = state.homestays.where((h) => h.isVisible).take(5).toList();
                  if (visible.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                      child: Text('No homestays available',
                          style: GoogleFonts.dmSans(color: Colors.grey)),
                    );
                  }
                  return Column(
                    children: visible.map((h) {
                      return _HomestayCard(
                        homestay: h,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  TouristHomestayDetailPage(homestay: h.toJson())),
                        ).then((_) {
                          // When returning from homestay detail, reload homestays
                          if (mounted) {
                            debugPrint('🏠 Returning from homestay detail - reloading homestays');
                            context.read<HomestayBloc>().add(const TouristLoadAllHomestays());
                          }
                        }),
                      );
                    }).toList(),
                  );
                }
                // Show nothing for other states (like nearby homestays or initial state)
                return const SizedBox.shrink();
              },
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 40.h)),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onTap;

  const _SearchBar({required this.controller, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: TextField(
          controller: controller,
          enabled: false, // Make it read-only/disabled so tap passes to GestureDetector
          style: GoogleFonts.dmSans(fontSize: 14.sp),
          decoration: InputDecoration(
            hintText: 'Search for sites, homestays...',
            hintStyle: GoogleFonts.dmSans(fontSize: 14.sp, color: Colors.grey[400]),
            prefixIcon: Icon(Icons.search, color: const Color(0xFFCD6E4E), size: 22.sp),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          ),
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection();

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'Temple', 'icon': Icons.temple_hindu_outlined, 'type': 'Site'},
      {'name': 'Palace', 'icon': Icons.account_balance_outlined, 'type': 'Site'},
      {'name': 'Stupa', 'icon': Icons.landscape_outlined, 'type': 'Site'},
      {'name': 'Museum', 'icon': Icons.museum_outlined, 'type': 'Site'},
      {'name': 'Homestay', 'icon': Icons.home_work_outlined, 'type': 'Stay'},
      {'name': 'Traditional', 'icon': Icons.cottage_outlined, 'type': 'Stay'},
    ];

    return SizedBox(
      height: 90.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => SizedBox(width: 16.w),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return _CategoryCard(
            name: cat['name'] as String,
            icon: cat['icon'] as IconData,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryResultsPage(
                    category: cat['name'] as String,
                    type: cat['type'] as String,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryCard({required this.name, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28.sp, color: const Color(0xFF2D1B10)),
            SizedBox(height: 8.h),
            Text(name,
                style: GoogleFonts.dmSans(
                    fontSize: 12.sp, fontWeight: FontWeight.w500, color: const Color(0xFF2D1B10))),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: GoogleFonts.playfairDisplay(
                fontSize: 20.sp, fontWeight: FontWeight.bold, color: const Color(0xFF2D1B10))),
        TextButton(
          onPressed: onSeeAll,
          child: Text('See All',
              style: GoogleFonts.dmSans(
                  fontSize: 13.sp, color: const Color(0xFFCD6E4E), fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class _HorizontalSiteCard extends StatelessWidget {
  final Map<String, dynamic> site;
  final VoidCallback onTap;
  const _HorizontalSiteCard({required this.site, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imageUrl = getFirstImageUrl(site['imageUrls']);
    final name = site['name'] as String? ?? 'Unnamed Site';
    final district = site['district'] as String? ?? 'Nepal';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: ProxyImage(
                imageUrl: imageUrl, width: 180.w, height: 250.h, borderRadiusValue: 0, thumb: true,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.white70, size: 14.sp),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(district,
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.white70),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _HomestayCard extends StatelessWidget {
  final Homestay homestay;
  final VoidCallback onTap;
  const _HomestayCard({required this.homestay, required this.onTap});

  static const _terracotta = Color(0xFFCD6E4E);

  @override
  Widget build(BuildContext context) {
    final imageUrl = homestay.imageUrls.isNotEmpty ? homestay.imageUrls.first : null;
    final nearSite = (homestay.nearCulturalSite?.name ?? '').isNotEmpty
        ? 'Near ${homestay.nearCulturalSite?.name}' : homestay.location ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                  child: ProxyImage(
                    imageUrl: imageUrl, width: double.infinity, height: 200.h, borderRadiusValue: 0, thumb: true,
                  ),
                ),
                Positioned(
                  top: 12.h, right: 12.w,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                    child: Icon(Icons.favorite_border_rounded, size: 20.sp, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(homestay.name,
                            style: GoogleFonts.playfairDisplay(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star_rounded, color: Colors.amber[600], size: 18.sp),
                          SizedBox(width: 4.w),
                          Text('4.8', style: GoogleFonts.dmSans(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(nearSite, style: GoogleFonts.dmSans(fontSize: 13.sp, color: Colors.grey[600])),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${homestay.numberOfRooms} Rooms • ${homestay.maxGuests} Guests',
                        style: GoogleFonts.dmSans(fontSize: 13.sp, color: Colors.grey[500]),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(text: 'Rs. ${homestay.pricePerNight.toStringAsFixed(0)}',
                                style: GoogleFonts.dmSans(fontSize: 18.sp, color: _terracotta, fontWeight: FontWeight.w800)),
                            TextSpan(text: ' / night',
                                style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.grey[500])),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
