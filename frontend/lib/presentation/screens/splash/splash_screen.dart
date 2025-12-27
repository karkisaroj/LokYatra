import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokyatra_frontend/presentation/screens/Onboarding/discover_heritage.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375,812),
      minTextAdapt: true,
      builder: (context , child){
        return MaterialApp(debugShowCheckedModeBanner: false,home: OnboardingHeritage(),);
      },
    );
  }
}
