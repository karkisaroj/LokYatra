import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutLokyatraPage extends StatelessWidget {
  const AboutLokyatraPage({super.key});

  static const _terracotta = Color(0xFFCD6E4E);
  static const _dark       = Color(0xFF2D1B10);
  static const _cream      = Color(0xFFFAF7F2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18.sp, color: _dark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('About LokYatra',
            style: GoogleFonts.playfairDisplay(
                fontSize: 20.sp, fontWeight: FontWeight.bold, color: _dark)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Hero section
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 40.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF686868), Color(0xFF0B0B0B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(children: [
              Container(
                width: 80.w, height: 80.h,
                decoration: BoxDecoration(
                  color: Colors.black87.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset("assets/images/lokyatra_logo.png"),
                ),
              ),
              SizedBox(height: 16.h),
              Text('LokYatra',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 30.sp, fontWeight: FontWeight.bold,
                      color: Colors.white)),
              SizedBox(height: 8.h),
              Text('Connecting Travelers with Nepal\'s\nAuthentic Cultural Heritage',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                      fontSize: 14.sp, color: Colors.white70, height: 1.5)),
              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: Text('Version 1.0.0',
                    style: GoogleFonts.dmSans(
                        fontSize: 12.sp, color: Colors.white60)),
              ),
            ]),
          ),

          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Section(
                    icon: Icons.flag_rounded,
                    iconColor: _terracotta,
                    title: 'Our Mission',
                    child: Text(
                      'LokYatra was built to bridge the gap between curious travelers and Nepal\'s rich homestay culture. We believe authentic travel goes beyond tourist attractions — it lives in the homes, kitchens, and stories of local families.\n\n'
                          'Our mission is to make Nepal\'s cultural heritage accessible to every traveler while empowering local homestay owners with technology to grow their businesses.',
                      style: GoogleFonts.dmSans(
                          fontSize: 13.sp, color: Colors.grey[700], height: 1.6),
                    ),
                  ),

                  SizedBox(height: 16.h),
                  _Section(
                    icon: Icons.star_rounded,
                    iconColor: Colors.amber[700]!,
                    title: 'What We Offer',
                    child: Column(children: [
                      _FeatureRow(Icons.home_outlined, 'Verified Homestays',
                          'Curated authentic homestays across Nepal\'s cultural regions'),
                      _FeatureRow(Icons.place_outlined, 'Heritage Sites',
                          'Discover nearby UNESCO and cultural heritage locations'),
                      _FeatureRow(Icons.menu_book_outlined, 'Local Stories',
                          'Read stories and traditions shared by local communities'),
                      _FeatureRow(Icons.quiz_outlined, 'Nepal Heritage Quiz',
                          'Learn about Nepal and earn points for booking discounts'),
                      _FeatureRow(Icons.account_balance_wallet_outlined, 'Secure Payments',
                          'Pay seamlessly via Khalti or cash at arrival'),
                    ]),
                  ),

                  SizedBox(height: 16.h),

                  _Section(
                    icon: Icons.bar_chart_rounded,
                    iconColor: Colors.blue[700]!,
                    title: 'LokYatra at a Glance',
                    child: Row(children: [
                      Expanded(child: _StatBox('Homestays', 'Across Nepal', Icons.home_rounded, _terracotta)),
                      SizedBox(width: 10.w),
                      Expanded(child: _StatBox('Heritage', 'Sites Listed', Icons.place_rounded, Colors.amber[700]!)),
                      SizedBox(width: 10.w),
                      Expanded(child: _StatBox('Secure', 'Payments', Icons.shield_rounded, Colors.green[700]!)),
                    ]),
                  ),

                  SizedBox(height: 16.h),

                  _Section(
                    icon: Icons.route_rounded,
                    iconColor: Colors.green[700]!,
                    title: 'How It Works',
                    child: Column(children: [
                      _StepRow('1', 'Browse', 'Explore homestays and heritage sites near you'),
                      _StepRow('2', 'Book', 'Select dates, meals, and payment method'),
                      _StepRow('3', 'Confirm', 'Owner reviews and confirms your booking'),
                      _StepRow('4', 'Experience', 'Enjoy authentic Nepali culture and hospitality'),
                      _StepRow('5', 'Earn', 'Play quizzes to earn points for your next discount'),
                    ]),
                  ),

                  SizedBox(height: 16.h),

                  _Section(
                    icon: Icons.favorite_rounded,
                    iconColor: Colors.red[500]!,
                    title: 'Our Values',
                    child: Column(children: [
                      _ValueCard(Icons.handshake_outlined, 'Community First',
                          'We put local homestay owners at the heart of everything we build.',
                          Colors.blue[700]!),
                      SizedBox(height: 8.h),
                      _ValueCard(Icons.security_outlined, 'Trust & Safety',
                          'Every booking is protected. Passwords are encrypted, payments are secure.',
                          Colors.green[700]!),
                      SizedBox(height: 8.h),
                      _ValueCard(Icons.language_outlined, 'Cultural Preservation',
                          'We celebrate Nepal\'s diverse heritage and help preserve it for future generations.',
                          _terracotta),
                    ]),
                  ),

                  SizedBox(height: 16.h),

                  _Section(
                    icon: Icons.link_rounded,
                    iconColor: Colors.purple[700]!,
                    title: 'Connect With Us',
                    child: Column(children: [
                      _LinkRow(Icons.email_outlined, 'contact@lokyatra.com.np',
                          'mailto:karkisaroj3012@gmail.com', Colors.blue[700]!),
                      SizedBox(height: 8.h),
                      _LinkRow(Icons.language_outlined, 'www.lokyatra.com.np',
                          'https://lokyatra.com.np', Colors.green[700]!),
                    ]),
                  ),

                  SizedBox(height: 24.h),

                  Center(child: Column(children: [
                    Container(
                      width: 40.w, height: 2.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text('Made with love for Nepal',
                        style: GoogleFonts.dmSans(
                            fontSize: 13.sp, color: Colors.grey[500])),
                    SizedBox(height: 4.h),
                    Text('© ${DateTime.now().year} LokYatra. All rights reserved.',
                        style: GoogleFonts.dmSans(
                            fontSize: 11.sp, color: Colors.grey[400])),
                    SizedBox(height: 4.h),
                    Text('FYP Project · Islington College',
                        style: GoogleFonts.dmSans(
                            fontSize: 11.sp, color: Colors.grey[400])),
                  ])),

                  SizedBox(height: 24.h),
                ]),
          ),
        ]),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;
  const _Section({
    required this.icon, required this.iconColor,
    required this.title, required this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(18.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          width: 36.w, height: 36.h,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, size: 18.sp, color: iconColor),
        ),
        SizedBox(width: 12.w),
        Text(title, style: GoogleFonts.dmSans(
            fontSize: 15.sp, fontWeight: FontWeight.bold,
            color: const Color(0xFF2D1B10))),
      ]),
      SizedBox(height: 16.h),
      child,
    ]),
  );
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _FeatureRow(this.icon, this.title, this.subtitle);

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: 12.h),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 18.sp, color: const Color(0xFF8B5E3C)),
      SizedBox(width: 12.w),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.dmSans(
                fontSize: 13.sp, fontWeight: FontWeight.w600,
                color: const Color(0xFF2D1B10))),
            SizedBox(height: 2.h),
            Text(subtitle, style: GoogleFonts.dmSans(
                fontSize: 12.sp, color: Colors.grey[500])),
          ])),
    ]),
  );
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const _StatBox(this.value, this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: color.withValues(alpha: 0.2)),
    ),
    child: Column(children: [
      Icon(icon, size: 22.sp, color: color),
      SizedBox(height: 6.h),
      Text(value, style: GoogleFonts.dmSans(
          fontSize: 12.sp, fontWeight: FontWeight.bold, color: color)),
      Text(label, style: GoogleFonts.dmSans(
          fontSize: 10.sp, color: Colors.grey[500]),
          textAlign: TextAlign.center),
    ]),
  );
}

class _StepRow extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  const _StepRow(this.number, this.title, this.subtitle);

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: 12.h),
    child: Row(children: [
      Container(
        width: 28.w, height: 28.h,
        decoration: BoxDecoration(
          color: const Color(0xFF8B5E3C),
          shape: BoxShape.circle,
        ),
        child: Center(child: Text(number,
            style: GoogleFonts.dmSans(
                fontSize: 12.sp, fontWeight: FontWeight.bold,
                color: Colors.white))),
      ),
      SizedBox(width: 12.w),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.dmSans(
                fontSize: 13.sp, fontWeight: FontWeight.w600,
                color: const Color(0xFF2D1B10))),
            Text(subtitle, style: GoogleFonts.dmSans(
                fontSize: 12.sp, color: Colors.grey[500])),
          ])),
    ]),
  );
}

class _ValueCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color color;
  const _ValueCard(this.icon, this.title, this.body, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(14.w),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: color.withValues(alpha: 0.2)),
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 20.sp, color: color),
      SizedBox(width: 12.w),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.dmSans(
                fontSize: 13.sp, fontWeight: FontWeight.bold, color: color)),
            SizedBox(height: 3.h),
            Text(body, style: GoogleFonts.dmSans(
                fontSize: 12.sp, color: Colors.grey[600], height: 1.4)),
          ])),
    ]),
  );
}

class _LinkRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;
  final Color color;
  const _LinkRow(this.icon, this.label, this.url, this.color);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () async {
      final _ = Uri.parse(url);

    },
    child: Row(children: [
      Icon(icon, size: 16.sp, color: color),
      SizedBox(width: 10.w),
      Text(label, style: GoogleFonts.dmSans(
          fontSize: 13.sp, color: color,
          decoration: TextDecoration.underline)),
    ]),
  );
}