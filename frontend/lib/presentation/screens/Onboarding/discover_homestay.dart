import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokyatra_frontend/presentation/screens/Onboarding/discover_play.dart';
import 'package:lokyatra_frontend/presentation/screens/authentication/register.dart';
import 'package:lokyatra_frontend/presentation/screens/splash/OnboardingDotsIndicator.dart';

class DiscoverHomestay extends StatefulWidget {
  const DiscoverHomestay({super.key});

  @override
  State<DiscoverHomestay> createState() => _DiscoverHomestayState();
}

class _DiscoverHomestayState extends State<DiscoverHomestay> {
  final int _currentPage=1;
  final int _totalPage=3;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top Image
          SizedBox(
            height: 0.55.sh,
            width: double.infinity,
            child: Stack(
              children: [
                Image.asset(
                  'assets/images/Homestay.png',
                  width: double.maxFinite,
                  fit: BoxFit.fill,
                  alignment: Alignment.topCenter,
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 110.h,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.white70,
                          Colors.white,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Text Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 14.h),
                Text(
                  "Discover Homestay",
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  "Stay With Local Families near heritage sites\nand experience authentic culture",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OnboardingDotsIndicator(
                currentPage: _currentPage,
                pageCount: _totalPage,
              ),
              SizedBox(height: 50,)
            ],
          ),
          // Bottom Navigation
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor:Colors.white,foregroundColor:Colors.black,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.all(Radius.circular(10))),
                  elevation: 14,padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),),

                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>register()));
                    },
                    child: Text("Skip", style: TextStyle(fontSize: 14.sp,color: Colors.black))),

                ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor:Colors.redAccent,foregroundColor:Colors.black,shape: const RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.all(Radius.circular(10))),elevation: 14,padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),),

                  onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>DiscoverPlay()));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Next", style: TextStyle(fontSize: 14.sp,color: Colors.white),selectionColor: Color(
                          0xFFFFFFFF)),

                      Icon(Icons.keyboard_arrow_right,color: Colors.white,)
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}
