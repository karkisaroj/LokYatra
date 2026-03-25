import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/data/models/Homestay.dart';
import 'package:lokyatra_frontend/presentation/widgets/Helpers/NotificationsPage.dart';
import 'package:lokyatra_frontend/presentation/screens/TouristScreen/QuizPage.dart';
import 'package:lokyatra_frontend/presentation/screens/TouristScreen/TouristProfilePage.dart';
import '../../../core/services/constants.dart';
import '../../../core/services/image_proxy.dart';
import '../../../core/services/sqlite_service.dart';
import '../../../data/datasources/User_remote_datasource.dart';
import '../../../data/models/Site.dart';
import '../../state_management/Bloc/booking/booking_bloc.dart';
import '../../state_management/Bloc/booking/booking_event.dart';
import '../../state_management/Bloc/homestays/HomestayBloc.dart';
import '../../state_management/Bloc/homestays/HomestayEvent.dart';
import '../../state_management/Bloc/homestays/HomestayState.dart';
import '../../state_management/Bloc/notification/notification_bloc.dart';
import '../../state_management/Bloc/notification/notification_event.dart';
import '../../state_management/Bloc/sites/sites_bloc.dart';
import '../../state_management/Bloc/sites/sites_event.dart';
import '../../state_management/Bloc/sites/sites_state.dart';
import '../../widgets/Helpers/Favouritebutton.dart';
import 'CategoryResultPage.dart';
import 'TouristSitesDetails.dart';
import 'Touriststaypage.dart';
import 'TouristHomestayDetailPage.dart';
import 'Touristsitespage.dart';
import 'TouristSearchPage.dart';

String _formatLocation(String? location) {
  if (location == null || location.isEmpty) return 'Nepal';
  List<String> parts = location.split(',').map((e) => e.trim()).toList();
  if (parts.length <= 2) return location;
  return "${parts[parts.length - 2]}, ${parts.last}";
}

class TouristHome extends StatefulWidget {
  const TouristHome({super.key});

  @override
  State<TouristHome> createState() => _TouristHomeState();
}

class _TouristHomeState extends State<TouristHome> {
  int _tab = 0;
  late final BookingBloc _bookingBloc;

  static const _dark = Color(0xFF1E1C1C);

  @override
  void initState() {
    super.initState();
    _bookingBloc = BookingBloc()..add(const LoadMyBookings());
  }

  @override
  void dispose() {
    _bookingBloc.close();
    super.dispose();
  }

  void _goToTab(int index) {
    setState(() => _tab = index);
    if (index == 0 && mounted) {
      context.read<HomestayBloc>().add(const ResetHomestayState());
      context.read<HomestayBloc>().add(const TouristLoadAllHomestays());
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      FocusScope(child: _HomeTab(onTabSwitch: _goToTab)),
      FocusScope(child: const TouristSitesPage()),
      FocusScope(child: const TouristQuizPage()),
      FocusScope(child: const TouristStayPage()),
      FocusScope(
        child: BlocProvider.value(
          value: _bookingBloc,
          child: const TouristProfilePage(),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: _tab, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: _goToTab,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _dark,
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
  final void Function(int) onTabSwitch;
  const _HomeTab({required this.onTabSwitch});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  static const _dark = Color(0xFF2D1B10);
  String? _profileImage;

  @override
  void initState() {
    super.initState();
    context.read<SitesBloc>().add(LoadSites());
    context.read<NotificationBloc>().add(const StartNotificationPolling());
    _loadProfile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<HomestayBloc>().add(const TouristLoadAllHomestays());
      }
    });
  }

  Future<void> _loadProfile() async {
    final db = SqliteService();
    final cached = await db.get('user_image');
    if (mounted) setState(() => _profileImage = cached);

    if (!await db.isOnline()) return;
    try {
      final res = await UserRemoteDatasource().getCurrentUser();
      if (res.statusCode == 200) {
        final img =
            (res.data as Map<String, dynamic>)['profileImage'] as String? ??
                '';
        if (img.isNotEmpty && img != cached) {
          await db.put('user_image', img);
          if (mounted) setState(() => _profileImage = img);
        }
      }
    } catch (e) {
      debugPrint('profile load error: $e');
    }
  }

  String _resolveImageUrl(String url) {
    if (url.startsWith('http')) return url;
    final path = url.startsWith('/') ? url.substring(1) : url;
    return '$apiBaseUrl$path';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        color: const Color(0xFFCD6E4E),
        onRefresh: () async {
          context.read<SitesBloc>().add(LoadSites());
          context.read<HomestayBloc>().add(const TouristLoadAllHomestays());
          context.read<NotificationBloc>().add(const LoadNotifications());
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding:
                EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
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
                                      fontSize: 14.sp,
                                      color: Colors.grey[600])),
                              Text('LokYatra',
                                  style: GoogleFonts.playfairDisplay(
                                      fontSize: 28.sp,
                                      fontWeight: FontWeight.bold,
                                      color: _dark)),
                            ]),
                        Row(children: [
                          const BellButton(),
                          SizedBox(width: 8.w),
                          GestureDetector(
                            onTap: () => widget.onTabSwitch(4),
                            child: CircleAvatar(
                              radius: 22.r,
                              backgroundColor: Colors.grey[300],
                              child: ClipOval(
                                child: _profileImage != null &&
                                    _profileImage!.isNotEmpty
                                    ? Image.network(
                                  _resolveImageUrl(_profileImage!),
                                  width: 44.r,
                                  height: 44.r,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Icon(
                                      Icons.person_rounded,
                                      color: Colors.grey[600],
                                      size: 28.sp),
                                )
                                    : Icon(Icons.person_rounded,
                                    color: Colors.grey[600],
                                    size: 28.sp),
                              ),
                            ),
                          ),
                        ]),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const TouristSearchPage())),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4))
                          ],
                        ),
                        child: AbsorbPointer(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search for sites, homestays...',
                              hintStyle: GoogleFonts.dmSans(
                                  fontSize: 14.sp, color: Colors.grey[400]),
                              prefixIcon: Icon(Icons.search,
                                  color: const Color(0xFFCD6E4E),
                                  size: 22.sp),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 16.h),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text('Browse by Category',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: _dark)),
                    SizedBox(height: 16.h),
                    const _Categories(),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(children: [
                _SectionHeader(
                    title: 'Popular Sites',
                    onSeeAll: () => widget.onTabSwitch(1)),
                SizedBox(height: 12.h),
                BlocBuilder<SitesBloc, SitesState>(
                  builder: (context, state) {
                    if (state is SitesLoading) {
                      return SizedBox(
                          height: 210.h,
                          child: const Center(
                              child: CircularProgressIndicator()));
                    }
                    if (state is SitesLoaded) {
                      return SizedBox(
                        height: 210.h,
                        child: ListView.separated(
                          padding:
                          EdgeInsets.symmetric(horizontal: 20.w),
                          scrollDirection: Axis.horizontal,
                          itemCount: state.sites.take(5).length,
                          separatorBuilder: (_, _) =>
                              SizedBox(width: 14.w),
                          itemBuilder: (context, i) {
                            final site = state.sites[i];
                            return _SiteCard(
                              site: site,
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value:
                                      context.read<HomestayBloc>(),
                                      child: TouristSiteDetailPage(
                                          site: site),
                                    ),
                                  )),
                            );
                          },
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ]),
            ),
            SliverToBoxAdapter(
              child: _SectionHeader(
                  title: 'Popular Stays',
                  topPadding: 32,
                  onSeeAll: () => widget.onTabSwitch(3)),
            ),
            SliverToBoxAdapter(
              child: BlocBuilder<HomestayBloc, HomestayState>(
                builder: (context, state) {
                  if (state is HomestayLoading) {
                    return SizedBox(
                        height: 200.h,
                        child: const Center(
                            child: CircularProgressIndicator()));
                  }
                  if (state is TouristAllHomestaysLoaded) {
                    final visible = state.homestays
                        .where((h) => h.isVisible)
                        .take(5)
                        .toList();
                    if (visible.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 20.h),
                        child: Text('No homestays available',
                            style: GoogleFonts.dmSans(
                                color: Colors.grey)),
                      );
                    }
                    return Column(
                      children: visible
                          .map((h) => _HomestayCard(
                        homestay: h,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  TouristHomestayDetailPage(
                                      homestay: h.toJson()),
                            )),
                      ))
                          .toList(),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 40.h)),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  final double topPadding;

  const _SectionHeader(
      {required this.title,
        required this.onSeeAll,
        this.topPadding = 0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, topPadding.h, 20.w, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: GoogleFonts.playfairDisplay(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D1B10))),
          TextButton(
            onPressed: onSeeAll,
            child: Text('See All',
                style: GoogleFonts.dmSans(
                    fontSize: 13.sp,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _Categories extends StatelessWidget {
  const _Categories();
  static const _items = [
    (name: 'Temple',     icon: Icons.temple_hindu_outlined,    type: 'Site'),
    (name: 'Palace',     icon: Icons.account_balance_outlined, type: 'Site'),
    (name: 'Stupa',      icon: Icons.landscape_outlined,       type: 'Site'),
    (name: 'Museum',     icon: Icons.museum_outlined,          type: 'Site'),
    (name: 'Homestay',   icon: Icons.home_work_outlined,       type: 'Stay'),
    (name: 'Traditional',icon: Icons.cottage_outlined,         type: 'Stay'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _items.length,
        separatorBuilder: (_, _) => SizedBox(width: 12.w),
        itemBuilder: (context, i) {
          final item = _items[i];
          return GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => CategoryResultsPage(
                        category: item.name, type: item.type))),
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
                    Icon(item.icon,
                        size: 28.sp, color: const Color(0xFF2D1B10)),
                    SizedBox(height: 8.h),
                    Text(item.name,
                        style: GoogleFonts.dmSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF2D1B10))),
                  ]),
            ),
          );
        },
      ),
    );
  }
}

class _SiteCard extends StatelessWidget {
  final CulturalSite site;
  final VoidCallback onTap;
  const _SiteCard({required this.site, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final image        = site.imageUrls.isNotEmpty ? site.imageUrls.first : '';
    final name         = site.name ?? 'Unnamed Site';
    final cleanLocation = _formatLocation(site.district);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.09),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(16.r)),
                  child: ProxyImage(
                      imageUrl: image,
                      width: 160.w,
                      height: 120.h,
                      borderRadiusValue: 0,
                      thumb: true),
                ),
                if (site.isUNESCO == true)
                  Positioned(
                    top: 8.h, left: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 6.w, vertical: 3.h),
                      decoration: BoxDecoration(
                          color: const Color(0xFF2D6A6A),
                          borderRadius: BorderRadius.circular(4.r)),
                      child: Text('UNESCO',
                          style: GoogleFonts.dmSans(
                              fontSize: 9.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding:
                EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D1B10),
                            height: 1.25)),
                    Row(children: [
                      Icon(Icons.location_on_outlined,
                          size: 11.sp, color: Colors.grey[500]),
                      SizedBox(width: 2.w),
                      Expanded(
                          child: Text(cleanLocation,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.dmSans(
                                  fontSize: 11.sp,
                                  color: Colors.grey[500]))),
                    ]),
                    Text(
                      (site.entryFeeNPR != null && site.entryFeeNPR! > 0)
                          ? 'Rs. ${site.entryFeeNPR!.toStringAsFixed(0)}'
                          : 'Free Entry',
                      style: GoogleFonts.dmSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color:
                        (site.entryFeeNPR != null &&
                            site.entryFeeNPR! > 0)
                            ? const Color(0xFF070707)
                            : const Color(0xFF434242),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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

  @override
  Widget build(BuildContext context) {
    final image = homestay.imageUrls.isNotEmpty
        ? homestay.imageUrls.first
        : null;
    String displayLocation;
    if ((homestay.nearCulturalSite?.name ?? '').isNotEmpty) {
      displayLocation = 'Near ${homestay.nearCulturalSite!.name}';
    } else {
      displayLocation = _formatLocation(homestay.location);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 15,
                offset: const Offset(0, 8))
          ],
        ),
        child:
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            ClipRRect(
              borderRadius:
              BorderRadius.vertical(top: Radius.circular(20.r)),
              child: ProxyImage(
                  imageUrl: image,
                  width: double.infinity,
                  height: 200.h,
                  borderRadiusValue: 0,
                  thumb: true),
            ),
            Positioned(
                top: 12.h,
                right: 12.w,
                child: FavouriteButton(homestayId: homestay.id)),
          ]),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(homestay.name,
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6.h),
                  Text(displayLocation,
                      style: GoogleFonts.dmSans(
                          fontSize: 13.sp, color: Colors.grey[600])),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          '${homestay.numberOfRooms} Rooms • ${homestay.maxGuests} Guests',
                          style: GoogleFonts.dmSans(
                              fontSize: 13.sp, color: Colors.grey[500])),
                      RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text:
                                'Rs. ${homestay.pricePerNight.toStringAsFixed(0)}',
                                style: GoogleFonts.dmSans(
                                    fontSize: 18.sp,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w800)),
                            TextSpan(
                                text: ' / night',
                                style: GoogleFonts.dmSans(
                                    fontSize: 12.sp,
                                    color: Colors.grey[500])),
                          ])),
                    ],
                  ),
                ]),
          ),
        ]),
      ),
    );
  }
}