import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/presentation/screens/OwnerScreen/HomestayListingsPage.dart';
import '../../state_management/Bloc/homestays/HomestayBloc.dart';
import 'Ownerhomepage.dart';
import 'Ownerprofilepage.dart';

class OwnerHome extends StatefulWidget {
  const OwnerHome({super.key});

  @override
  State<OwnerHome> createState() => _OwnerHomeState();
}

class _OwnerHomeState extends State<OwnerHome> {
  int _currentTab = 0;
  late final HomestayBloc _homestayBloc;

  static const _brown = Color(0xFF5C4033);

  @override
  void initState() {
    super.initState();
    // Single bloc shared across Home tab and Listings tab
    _homestayBloc = HomestayBloc();
  }

  @override
  void dispose() {
    _homestayBloc.close();
    super.dispose();
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
            style:
            GoogleFonts.dmSans(fontSize: 14.sp, color: Colors.grey)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => BlocProvider.value(
        // Provide the SAME bloc instance to all tabs
        value: _homestayBloc,
        child: Scaffold(
          body: IndexedStack(
            index: _currentTab,
            children: [
              const OwnerHomePage(),
              const HomestayListingsPage(), // your existing file
              _comingSoon('Bookings', Icons.calendar_today_outlined),
              _comingSoon('Balance', Icons.account_balance_wallet_outlined),
              const OwnerProfilePage(),
            ],
          ),
          bottomNavigationBar: _BottomNav(
            currentIndex: _currentTab,
            onTap: (i) => setState(() => _currentTab = i),
            selectedColor: _brown,
          ),
        ),
      ),
    );
  }
}

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
            offset: const Offset(0, -3),
          ),
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
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.normal,
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