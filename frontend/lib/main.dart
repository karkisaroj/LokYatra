import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokyatra_frontend/presentation/screens/OwnerScreen/OwnerHome.dart';
import 'package:lokyatra_frontend/presentation/screens/TouristScreen/touristHome.dart';
import 'package:lokyatra_frontend/presentation/screens/admin/admin_dashboard.dart';
import 'package:lokyatra_frontend/presentation/screens/authentication/loginPage.dart';
import 'package:lokyatra_frontend/presentation/screens/authentication/register.dart';
import 'package:lokyatra_frontend/presentation/splash/splash_screen.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/auth/auth_bloc.dart';

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
        return BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(),
          child: MaterialApp(
            routes: {
              '/touristHome':(context)=>const TouristHome(),
              '/ownerHome':(context)=>const OwnerHome(),
              '/login':(context)=>const LoginPage(),
              '/splash':(context)=>const SplashScreen(),
              '/register':(context)=>const Register(),
              '/adminDashboard':(context)=>const AdminDashboard(),
            },
            debugShowCheckedModeBanner: false,
            home: SplashScreen(),
          ),
        );
      },
    );
  }
}
