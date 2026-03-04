import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokyatra_frontend/presentation/screens/Onboarding/OnBoarding.dart';
import 'package:lokyatra_frontend/presentation/screens/OwnerScreen/HomestayListingsPage.dart';
import 'package:lokyatra_frontend/presentation/screens/OwnerScreen/OwnerBookingsPage.dart';
import 'package:lokyatra_frontend/presentation/screens/OwnerScreen/OwnerHome.dart';
import 'package:lokyatra_frontend/presentation/screens/OwnerScreen/Ownerbalancepage.dart';
import 'package:lokyatra_frontend/presentation/screens/OwnerScreen/Ownerprofilepage.dart';
import 'package:lokyatra_frontend/presentation/screens/OwnerScreen/OwnerChangePasswordPage.dart';
import 'package:lokyatra_frontend/presentation/screens/TouristScreen/TouristProfilePage.dart';
import 'package:lokyatra_frontend/presentation/screens/TouristScreen/touristHome.dart';
import 'package:lokyatra_frontend/presentation/screens/admin/AdminDashboard.dart';
import 'package:lokyatra_frontend/presentation/screens/authentication/loginPage.dart';
import 'package:lokyatra_frontend/presentation/screens/authentication/register.dart';
import 'package:lokyatra_frontend/presentation/splash/splash_screen.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/Booking/booking_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/Booking/booking_event.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/auth/auth_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/auth/auth_state.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/homestays/HomestayBloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/homestays/HomestayEvent.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/notification/notification_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_event.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/stories/story_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/user/user_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/user/user_event.dart';
import 'core/services/sqlite_service.dart';


final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('Starting app initialization...');

  try {
    debugPrint('Initializing SQLite...');
    await SqliteService().database;
    debugPrint('SQLite initialized successfully');
    await SqliteService().deleteOldCache();
    debugPrint('Old cache cleaned');
  } catch (e) {
    debugPrint('Error during initialization: $e');
  }

  runApp(const MyAppRunner());
}

class MyAppRunner extends StatelessWidget {
  const MyAppRunner({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(create: (_) => AuthBloc()),
            BlocProvider<SitesBloc>(create: (_) => SitesBloc()),
            BlocProvider<StoryBloc>(create: (_) => StoryBloc()),
            BlocProvider<HomestayBloc>(create: (_) => HomestayBloc()),
            BlocProvider<BookingBloc>(create: (_) => BookingBloc()),
            BlocProvider<UserBloc>(create: (_) => UserBloc()),
            BlocProvider<NotificationBloc>(create: (_) => NotificationBloc()),
          ],
          child: MaterialApp(
            navigatorKey: _navKey,
            debugShowCheckedModeBanner: false,
            title: 'LokYatra',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF6B4EFF)),
              useMaterial3: true,
            ),
            routes: {
              '/touristHome':         (context) => const TouristHome(),
              '/ownerHome':           (context) => const OwnerHome(),
              '/login':               (context) => const LoginPage(),
              '/splash':              (context) => const SplashScreen(),
              '/register':            (context) => const Register(),
              '/adminDashboard':      (context) => const AdminDashboard(),
              '/onboarding':          (context) => const OnboardingScreen(),
              '/TouristHome':         (context) => const TouristHome(),
              '/TouristProfilePage':  (context) => const TouristProfilePage(),
              '/ownerProfile':        (context) => const OwnerProfilePage(),
              '/ownerBalance':        (context) => const OwnerBalancePage(),
              '/ownerBookings':       (context) => const OwnerBookingsPage(),
              '/ownerListings':       (context) => const HomestayListingsPage(),
              '/change-password':     (context) => const OwnerChangePasswordPage(),
            },
            home: const SplashScreen(),
            builder: (context, appChild) {
              return BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AdminLoginSuccess) {
                    // Pre-load admin data so Reports, Users page have data ready
                    context.read<BookingBloc>().add(const LoadAllBookings());
                    context.read<UserBloc>().add(FetchUsers());
                    context.read<SitesBloc>().add(const LoadSites());
                    context.read<HomestayBloc>().add(const TouristLoadAllHomestays());
                    _navKey.currentState?.pushNamedAndRemoveUntil(
                        '/adminDashboard', (route) => false);
                  } else if (state is TouristLoginSuccess) {
                    _navKey.currentState?.pushNamedAndRemoveUntil(
                        '/touristHome', (route) => false);
                  } else if (state is OwnerLoginSuccess) {
                    _navKey.currentState?.pushNamedAndRemoveUntil(
                        '/ownerHome', (route) => false);
                  } else if (state is LogoutSuccess) {
                    _navKey.currentState?.pushNamedAndRemoveUntil(
                        '/login', (route) => false);
                  } else if (state is AuthError) {
                    final ctx = _navKey.currentContext ?? context;
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                child: appChild ?? const SizedBox.shrink(),
              );
            },
          ),
        );
      },
    );
  }
}