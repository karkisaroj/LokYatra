import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/auth/auth_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/auth/auth_event.dart';
import '../../state_management/Bloc/homestays/HomestayBloc.dart';
import 'HomestayListingsPage.dart';

class OwnerHome extends StatefulWidget {
  const OwnerHome({super.key});

  @override
  State<OwnerHome> createState() => _OwnerHomeState();
}

class _OwnerHomeState extends State<OwnerHome> {
  int _currentTab = 0;
  late final List<Widget> _pages;

  static const _brown = Color(0xFF5C4033);

  @override
  void initState() {
    super.initState();
    _pages = [
      const _HomePage(),
      BlocProvider(
        create: (_) => HomestayBloc(),
        child: const HomestayListingsPage(),
      ),
      _comingSoon('Bookings', Icons.calendar_today_outlined),
      _comingSoon('Balance', Icons.account_balance_wallet_outlined),
      const _ProfilePage(),
    ];
  }

  Widget _comingSoon(String label, IconData icon) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 64.sp, color: Colors.grey[300]),
        SizedBox(height: 16.h),
        Text(label,
            style: GoogleFonts.playfairDisplay(
                fontSize: 22.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 8.h),
        Text('Coming Soon',
            style: GoogleFonts.dmSans(
                fontSize: 14.sp, color: Colors.grey)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => Scaffold(
        body: IndexedStack(index: _currentTab, children: _pages),
        bottomNavigationBar: _BottomNav(
          currentIndex: _currentTab,
          onTap: (i) => setState(() => _currentTab = i),
          selectedColor: _brown,
        ),
      ),
    );
  }
}

// ── Bottom Nav ──────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color selectedColor;

  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.selectedColor,
  });

  static const _items = [
    (Icons.home_rounded, Icons.home_outlined, 'Home'),
    (Icons.holiday_village, Icons.holiday_village_outlined, 'Listings'),
    (Icons.calendar_month, Icons.calendar_month_outlined, 'Bookings'),
    (Icons.account_balance_wallet, Icons.account_balance_wallet_outlined, 'Balance'),
    (Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, -3)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58.h,
          child: Row(
            children: List.generate(_items.length, (i) {
              final selected = currentIndex == i;
              final (active, inactive, label) = _items[i];
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          selected ? active : inactive,
                          key: ValueKey(selected),
                          size: 22.sp,
                          color: selected ? selectedColor : Colors.grey[400],
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        label,
                        style: GoogleFonts.dmSans(
                          fontSize: 10.sp,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                          color: selected ? selectedColor : Colors.grey[400],
                        ),
                      ),
                      SizedBox(height: 3.h),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        height: 2.h,
                        width: selected ? 18.w : 0,
                        decoration: BoxDecoration(
                          color: selectedColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Home Page ───────────────────────────────────────────────────────────────

class _HomePage extends StatelessWidget {
  const _HomePage();

  static const _brown = Color(0xFF5C4033);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Good morning 👋',
                        style: GoogleFonts.dmSans(
                            fontSize: 13.sp, color: Colors.grey[500])),
                    SizedBox(height: 2.h),
                    Text('Owner Dashboard',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D1B10))),
                  ],
                ),
                CircleAvatar(
                  radius: 22.r,
                  backgroundColor: _brown.withValues(alpha: 0.1),
                  child: Icon(Icons.person_rounded,
                      color: _brown, size: 26.sp),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            Row(
              children: [
                _StatCard(icon: Icons.home, label: 'Listings', value: '—'),
                SizedBox(width: 10.w),
                _StatCard(icon: Icons.calendar_today, label: 'This Month', value: '—'),
                SizedBox(width: 10.w),
                _StatCard(icon: Icons.star_rounded, label: 'Avg Rating', value: '—'),
              ],
            ),
            SizedBox(height: 24.h),

            Text('Quick Actions',
                style: GoogleFonts.dmSans(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D1B10))),
            SizedBox(height: 12.h),
            Row(
              children: [
                _QuickAction(icon: Icons.add_home_rounded, label: 'Add\nHomestay', color: _brown),
                SizedBox(width: 10.w),
                _QuickAction(icon: Icons.list_alt_rounded, label: 'My\nListings', color: const Color(0xFF795548)),
                SizedBox(width: 10.w),
                _QuickAction(icon: Icons.bar_chart_rounded, label: 'Analytics', color: const Color(0xFF8D6E63)),
              ],
            ),
            SizedBox(height: 24.h),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF5C4033), Color(0xFF8D6E63)]),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Complete your profile',
                            style: GoogleFonts.playfairDisplay(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        SizedBox(height: 4.h),
                        Text('Add photos to attract more guests.',
                            style: GoogleFonts.dmSans(
                                fontSize: 12.sp, color: Colors.white70)),
                      ],
                    ),
                  ),
                  Icon(Icons.tips_and_updates_rounded,
                      color: Colors.white60, size: 36.sp),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18.sp, color: const Color(0xFF5C4033)),
            SizedBox(height: 8.h),
            Text(value,
                style: GoogleFonts.dmSans(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D1B10))),
            SizedBox(height: 2.h),
            Text(label,
                style: GoogleFonts.dmSans(
                    fontSize: 10.sp, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _QuickAction({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22.sp, color: color),
            SizedBox(height: 6.h),
            Text(label,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
      ),
    );
  }
}

// ── Profile Page ─────────────────────────────────────────────────────────────

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  static const _brown = Color(0xFF5C4033);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            CircleAvatar(
              radius: 48.r,
              backgroundColor: _brown.withValues(alpha: 0.1),
              child: Icon(Icons.person_rounded, size: 52.sp, color: _brown),
            ),
            SizedBox(height: 14.h),
            Text('My Profile',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 20.sp, fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D1B10))),
            SizedBox(height: 4.h),
            Text('Homestay Owner',
                style: GoogleFonts.dmSans(
                    fontSize: 13.sp, color: Colors.grey[500])),
            SizedBox(height: 28.h),

            _menuItem(context, Icons.person_outline_rounded, 'Edit Profile', () {}),
            _menuItem(context, Icons.notifications_outlined, 'Notifications', () {}),
            _menuItem(context, Icons.help_outline_rounded, 'Help & Support', () {}),
            _menuItem(context, Icons.info_outline_rounded, 'About LokYatra', () {}),

            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.read<AuthBloc>().add(LogoutButtonClicked());
                  Navigator.pushReplacementNamed(context, '/login');
                },
                icon: Icon(Icons.logout_rounded, size: 18.sp),
                label: Text('Logout',
                    style: GoogleFonts.dmSans(
                        fontSize: 14.sp, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red[600],
                  side: BorderSide(color: Colors.red.shade300),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
      BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: _brown.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 18.sp, color: _brown),
        ),
        title: Text(label,
            style:
            GoogleFonts.dmSans(fontSize: 14.sp, fontWeight: FontWeight.w500)),
        trailing:
        Icon(Icons.chevron_right_rounded, color: Colors.grey[400], size: 20.sp),
      ),
    );
  }
}