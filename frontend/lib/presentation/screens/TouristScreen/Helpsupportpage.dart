import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  static const _brown  = Color(0xFF4A4A4A);
  static const _cream  = Color(0xFFFAF7F2);
  static const _dark   = Color(0xFF2D1B10);

  int? _expandedIndex;

  final List<Map<String, String>> _faqs = [
    {
      'q': 'How do I book a homestay?',
      'a': 'Browse homestays from the home screen, tap on one you like, select your dates, rooms and guests, then proceed to the booking summary. You can pay at arrival or via Khalti once the owner confirms.',
    },
    {
      'q': 'How do quiz points work?',
      'a': 'Play the Nepal Heritage Quiz from your profile page. You earn 10 points per correct answer. Every 10 points = Rs. 5 discount on your next booking. You get 3 attempts per day and can use points for up to 20% off.',
    },
    {
      'q': 'Can I cancel a booking?',
      'a': 'You can cancel a booking from My Bookings before the owner confirms it. Once confirmed, please contact the homestay owner directly. Refund policies vary by homestay.',
    },
    {
      'q': 'How does Khalti payment work?',
      'a': 'Select Khalti when booking. After the owner confirms your booking, go to My Bookings and tap "Pay with Khalti" to complete the secure online payment.',
    },
    {
      'q': 'How do I get a Verified Profile badge?',
      'a': 'Add both your full name and phone number in Edit Profile. Once both are filled, your profile automatically gets the green Verified badge.',
    },
    {
      'q': 'What if the owner does not confirm my booking?',
      'a': 'If a booking stays pending for too long, it may be automatically cancelled. You can also cancel it yourself from My Bookings and book a different homestay.',
    },
    {
      'q': 'How do I save a homestay?',
      'a': 'Tap the heart icon on any homestay card or detail page to save it. Access all your saved homestays from Profile → Your Saved.',
    },
    {
      'q': 'Is my personal data safe?',
      'a': 'Yes. Lokyatra uses industry-standard encryption for passwords and secure storage for personal information. We never sell your data to third parties.',
    },
  ];

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
        title: Text('Help & Support',
            style: GoogleFonts.playfairDisplay(
                fontSize: 20.sp, fontWeight: FontWeight.bold, color: _dark)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Hero banner
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF817F7F), Color(0xFF0C0C0C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(children: [
              Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('How can we help?',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 20.sp, fontWeight: FontWeight.bold,
                        color: Colors.white)),
                SizedBox(height: 8.h),
                Text('Find answers to common questions\nor reach out to our team.',
                    style: GoogleFonts.dmSans(
                        fontSize: 13.sp, color: Colors.white70, height: 1.4)),
              ])),
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.support_agent_rounded,
                    color: Colors.white, size: 36.sp),
              ),
            ]),
          ),

          SizedBox(height: 24.h),

          // Contact cards
          Text('Contact Us',
              style: GoogleFonts.dmSans(fontSize: 16.sp,
                  fontWeight: FontWeight.bold, color: _dark)),
          SizedBox(height: 12.h),

          Row(children: [
            Expanded(child: _ContactCard(
              icon: Icons.email_outlined,
              label: 'Email',
              value: 'support@lokyatra.com.np',
              color: Colors.blue[700]!,
              onTap: () => _launch('mailto:karkisaroj3012@gmail.com'),
            )),
            SizedBox(width: 12.w),
            Expanded(child: _ContactCard(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: '+977-9765411112',
              color: Colors.green[700]!,
              onTap: () => _launch('tel:+9765411112'),
            )),
          ]),

          SizedBox(height: 10.h),

          _ContactCard(
            icon: Icons.access_time_rounded,
            label: 'Support Hours',
            value: 'Sunday – Friday  •  9:00 AM – 6:00 PM (NST)',
            color: Colors.orange[700]!,
            onTap: null,
            fullWidth: true,
          ),

          SizedBox(height: 28.h),

          // FAQ section
          Text('Frequently Asked Questions',
              style: GoogleFonts.dmSans(fontSize: 16.sp,
                  fontWeight: FontWeight.bold, color: _dark)),
          SizedBox(height: 12.h),

          ...List.generate(_faqs.length, (i) {
            final isOpen = _expandedIndex == i;
            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: isOpen
                      ? _brown.withValues(alpha: 0.4)
                      : Colors.grey.shade200,
                ),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 4.h),
                  childrenPadding: EdgeInsets.fromLTRB(
                      16.w, 0, 16.w, 14.h),
                  leading: Container(
                    width: 32.w, height: 32.h,
                    decoration: BoxDecoration(
                      color: isOpen
                          ? _brown.withValues(alpha: 0.1)
                          : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: Icon(
                      isOpen
                          ? Icons.remove_rounded
                          : Icons.add_rounded,
                      size: 16.sp,
                      color: isOpen ? _brown : Colors.grey[500],
                    )),
                  ),
                  title: Text(_faqs[i]['q']!,
                      style: GoogleFonts.dmSans(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: _dark)),
                  onExpansionChanged: (v) =>
                      setState(() => _expandedIndex = v ? i : null),
                  initiallyExpanded: isOpen,
                  children: [
                    Text(_faqs[i]['a']!,
                        style: GoogleFonts.dmSans(
                            fontSize: 13.sp,
                            color: Colors.grey[600],
                            height: 1.5)),
                  ],
                ),
              ),
            );
          }),

          SizedBox(height: 24.h),

          // Still need help
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(children: [
              Icon(Icons.chat_bubble_outline_rounded,
                  size: 32.sp, color: _brown),
              SizedBox(height: 10.h),
              Text('Still need help?',
                  style: GoogleFonts.dmSans(
                      fontSize: 15.sp, fontWeight: FontWeight.bold,
                      color: _dark)),
              SizedBox(height: 6.h),
              Text('Our support team is here for you.\nDrop us an email and we\'ll get back within 24 hours.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                      fontSize: 12.sp, color: Colors.grey[500], height: 1.5)),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.email_outlined, size: 16.sp),
                  label: Text('Email Support',
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
                  onPressed: () => _launch('mailto:karkisaroj3012@gmail.com'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brown,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              ),
            ]),
          ),

          SizedBox(height: 20.h),
        ]),
      ),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      final display = url.startsWith('mailto')
          ? 'No email app found. Contact: ${url.replaceFirst('mailto:', '')}'
          : 'Could not open link.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(display, style: GoogleFonts.dmSans()),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ));
    }
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;
  final bool fullWidth;

  const _ContactCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(children: [
        Container(
          width: 38.w, height: 38.h,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, size: 18.sp, color: color),
        ),
        SizedBox(width: 12.w),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: GoogleFonts.dmSans(
                  fontSize: 11.sp, color: Colors.grey[500])),
          SizedBox(height: 2.h),
          Text(value,
              style: GoogleFonts.dmSans(
                  fontSize: 12.sp, fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D1B10))),
        ])),
      ]),
    ),
  );
}