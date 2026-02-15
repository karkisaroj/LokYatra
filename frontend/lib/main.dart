import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Screens
import 'package:lokyatra_frontend/presentation/screens/Onboarding/OnBoarding.dart';
import 'package:lokyatra_frontend/presentation/screens/OwnerScreen/OwnerHome.dart';
import 'package:lokyatra_frontend/presentation/screens/TouristScreen/touristHome.dart';
import 'package:lokyatra_frontend/presentation/screens/admin/AdminDashboard.dart';
import 'package:lokyatra_frontend/presentation/screens/authentication/loginPage.dart';
import 'package:lokyatra_frontend/presentation/screens/authentication/register.dart';
import 'package:lokyatra_frontend/presentation/splash/splash_screen.dart';

// Blocs
import 'package:lokyatra_frontend/presentation/state_management/Bloc/auth/auth_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/auth/auth_state.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/stories/story_bloc.dart';

final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

void main() {
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
            // Provide Sites and Stories blocs app-wide so pages can read them
            BlocProvider<SitesBloc>(create: (_) => SitesBloc()),
            BlocProvider<StoryBloc>(create: (_) => StoryBloc()),
          ],
          child: MaterialApp(
            navigatorKey: _navKey,
            debugShowCheckedModeBanner: false,
            title: 'LokYatra',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B4EFF)),
              useMaterial3: true,
            ),
            routes: {
              '/touristHome': (context) => const TouristHome(),
              '/ownerHome': (context) => const OwnerHome(),
              '/login': (context) => const LoginPage(),
              '/splash': (context) => const SplashScreen(),
              '/register': (context) => const Register(),
              '/adminDashboard': (context) => const AdminDashboard(),
              '/onboarding': (context) => const OnboardingScreen(),
            },
            home: const SplashScreen(),
            builder: (context, appChild) {
              // Global auth navigation and messages
              return BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AdminLoginSuccess) {
                    _navKey.currentState?.pushNamedAndRemoveUntil('/adminDashboard', (route) => false);
                  } else if (state is TouristLoginSuccess) {
                    _navKey.currentState?.pushNamedAndRemoveUntil('/touristHome', (route) => false);
                  } else if (state is OwnerLoginSuccess) {
                    _navKey.currentState?.pushNamedAndRemoveUntil('/ownerHome', (route) => false);
                  } else if (state is LogoutSuccess) {
                    _navKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
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