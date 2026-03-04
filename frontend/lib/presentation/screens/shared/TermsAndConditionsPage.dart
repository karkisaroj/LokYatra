import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsAndConditionsPage extends StatefulWidget {
  final bool isRegistration;

  const TermsAndConditionsPage({super.key, this.isRegistration = false});

  @override
  State<TermsAndConditionsPage> createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  final _scrollCtrl = ScrollController();
  bool _hasScrolledToBottom = false;

  static const _dark       = Color(0xFF2D1B10);
  static const _cream      = Color(0xFFFAF7F2);
  static const _terracotta = Color(0xFFCD6E4E);
  static const _brown      = Color(0xFF5C4033);
  static const _slate      = Color(0xFF2C3A4A);

  @override
  void initState() {
    super.initState();
    if (!widget.isRegistration) {
      _hasScrolledToBottom = true;
    }
    _scrollCtrl.addListener(() {
      if (!_hasScrolledToBottom) {
        final pos = _scrollCtrl.position;
        if (pos.pixels >= pos.maxScrollExtent - 40) {
          setState(() => _hasScrolledToBottom = true);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width  = MediaQuery.of(context).size.width;
    final isWide = width > 700;

    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: _dark),
          onPressed: () => Navigator.pop(context,
              widget.isRegistration ? false : null),
        ),
        title: Text(
          'Terms & Conditions',
          style: GoogleFonts.playfairDisplay(
              fontSize: isWide ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: _dark),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
        actions: [
          if (widget.isRegistration)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _hasScrolledToBottom
                        ? Colors.green.shade50
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _hasScrolledToBottom
                          ? Colors.green.shade300
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                      _hasScrolledToBottom
                          ? Icons.check_circle_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 14,
                      color: _hasScrolledToBottom
                          ? Colors.green[700]
                          : Colors.grey[500],
                    ),
                    const SizedBox(width: 4),

                  ]),
                ),
              ),
            ),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: isWide ? 780 : double.infinity),
              child: SingleChildScrollView(
                controller: _scrollCtrl,
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 48 : 20,
                  vertical: 24,
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      _HeaderBanner(isWide: isWide),
                      SizedBox(height: isWide ? 32 : 24),

                      _Section(
                        number: '1',
                        title:  'Cancellation Policy',
                        icon:   Icons.event_busy_outlined,
                        color:  _terracotta,
                        children: [
                          _PolicyCard(
                            icon:  Icons.check_circle_outline_rounded,
                            color: Colors.green,
                            title: 'Free Cancellation — 24 Hour Grace Period',
                            body:  'You may cancel any booking free of charge within '
                                '24 hours of making the booking, provided the '
                                'check-in date is more than 48 hours away.',
                          ),
                          const SizedBox(height: 12),
                          _PolicyCard(
                            icon:  Icons.cancel_outlined,
                            color: Colors.red,
                            title: 'No Cancellation After Grace Period',
                            body:  'Once the 24-hour grace period has passed, '
                                'cancellations are not permitted through the app. '
                                'You must contact the homestay owner directly to '
                                'discuss any changes.',
                          ),
                          const SizedBox(height: 12),
                          _PolicyCard(
                            icon:  Icons.warning_amber_rounded,
                            color: Colors.orange,
                            title: 'Check-in Within 48 Hours',
                            body:  'If your check-in is within 48 hours of booking, '
                                'the booking is immediately non-cancellable to '
                                'protect homestay owners from last-minute losses.',
                          ),
                          const SizedBox(height: 12),
                          _InfoBox(
                            text: 'LokYatra does not process automatic refunds. '
                                'All payment disputes must be resolved directly '
                                'between the tourist and the homestay owner.',
                            color: _slate,
                          ),
                        ],
                      ),

                      SizedBox(height: isWide ? 32 : 24),

                      _Section(
                        number: '2',
                        title:  'Privacy Policy',
                        icon:   Icons.privacy_tip_outlined,
                        color:  _slate,
                        children: [
                          _SubHeading('Data We Collect'),
                          _BulletItem('Your name, email address, and phone number '
                              'provided during registration.'),
                          _BulletItem('Profile photos you upload voluntarily.'),
                          _BulletItem('Booking history and payment method '
                              'preferences (Cash or Khalti).'),
                          _BulletItem('Quiz attempt history and points earned.'),
                          _BulletItem('Device information for app functionality.'),

                          const SizedBox(height: 16),
                          _SubHeading('How We Use Your Data'),
                          _BulletItem('To connect tourists with homestay owners '
                              'for authentic cultural experiences.'),
                          _BulletItem('To process and manage bookings through '
                              'the LokYatra platform.'),
                          _BulletItem('To calculate and award quiz points and '
                              'booking discounts.'),
                          _BulletItem('To send in-app notifications about your '
                              'bookings and account activity.'),
                          _BulletItem('We do not sell your personal data to '
                              'third parties.'),

                          const SizedBox(height: 16),
                          _SubHeading('Data Storage'),
                          _BulletItem('Your data is stored securely on our '
                              'servers located in Nepal.'),
                          _BulletItem('Payment transactions via Khalti are '
                              'processed by Khalti Digital Wallet '
                              '(Nepal) and governed by their privacy '
                              'policy.'),
                          _BulletItem('You may request deletion of your account '
                              'and associated data by contacting support.'),
                        ],
                      ),

                      SizedBox(height: isWide ? 32 : 24),

                      _Section(
                        number: '3',
                        title:  'User Responsibilities',
                        icon:   Icons.person_outline_rounded,
                        color:  _brown,
                        children: [
                          _SubHeading('All Users'),
                          _BulletItem('You must provide accurate and truthful '
                              'information during registration.'),
                          _BulletItem('You are responsible for maintaining the '
                              'confidentiality of your account password.'),
                          _BulletItem('You agree not to use LokYatra for any '
                              'unlawful or fraudulent purpose.'),
                          _BulletItem('You agree to treat all other users — '
                              'tourists and owners — with respect.'),

                          const SizedBox(height: 16),
                          _SubHeading('Tourists'),
                          _BulletItem('You agree to honour confirmed bookings '
                              'and arrive on the agreed dates.'),
                          _BulletItem('You agree to respect the homestay '
                              'property, cultural customs, and rules '
                              'set by the owner.'),
                          _BulletItem('Quiz points earned are non-transferable '
                              'and may only be used for booking '
                              'discounts on LokYatra.'),
                          _BulletItem('You agree to pay the full booking amount '
                              'in the method selected (Cash or Khalti).'),

                          const SizedBox(height: 16),
                          _SubHeading('Homestay Owners'),
                          _BulletItem('You agree to provide accurate descriptions '
                              'and photos of your homestay.'),
                          _BulletItem('You agree to honour confirmed bookings '
                              'and provide the accommodation as listed.'),
                          _BulletItem('You agree to treat all guests with '
                              'fairness and without discrimination.'),
                          _BulletItem('You are responsible for ensuring your '
                              'homestay complies with local laws and '
                              'tourism regulations in Nepal.'),
                        ],
                      ),

                      SizedBox(height: isWide ? 32 : 24),

                      _Footer(),

                      // Extra bottom padding so last content clears the button bar
                      if (widget.isRegistration) const SizedBox(height: 16),
                    ]),
              ),
            ),
          ),
        ),

        if (widget.isRegistration)
          _AcceptBar(
            unlocked: _hasScrolledToBottom,
            onDecline: () => Navigator.pop(context, false),
            onAccept:  () => Navigator.pop(context, true),
          ),
      ]),
    );
  }
}


class _HeaderBanner extends StatelessWidget {
  final bool isWide;
  const _HeaderBanner({required this.isWide});

  static const _dark       = Color(0xFF2D1B10);
  static const _terracotta = Color(0xFFCD6E4E);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isWide ? 32 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_dark, _dark.withValues(alpha: 0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isWide ? 20 : 16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _terracotta.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.gavel_rounded,
                color: _terracotta, size: 24),
          ),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('LokYatra',
                style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: isWide ? 22 : 18,
                    fontWeight: FontWeight.bold)),
            Text('Terms & Conditions',
                style: GoogleFonts.dmSans(
                    color: Colors.white70, fontSize: 13)),
          ]),
        ]),
        const SizedBox(height: 16),
        Text(
          'Please read these terms carefully before using LokYatra. '
              'By creating an account, you agree to be bound by these terms.',
          style: GoogleFonts.dmSans(
              color: Colors.white60,
              fontSize: isWide ? 14 : 12,
              height: 1.6),
        ),
        const SizedBox(height: 12),
        Text('Effective Date: January 1, 2025  ·  Version 1.0',
            style: GoogleFonts.dmSans(
                color: Colors.white38, fontSize: 11)),
      ]),
    );
  }
}

class _Section extends StatelessWidget {
  final String number, title;
  final IconData icon;
  final Color color;
  final List<Widget> children;

  const _Section({
    required this.number,
    required this.title,
    required this.icon,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Container(
      padding: EdgeInsets.all(isWide ? 28 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isWide ? 20 : 16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 10, offset: const Offset(0, 4),
        )],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(
            '$number.  $title',
            style: GoogleFonts.playfairDisplay(
              fontSize: isWide ? 19 : 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D1B10),
            ),
          )),
        ]),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 48),
          child: Container(height: 2, width: 40,
              color: color.withValues(alpha: 0.4)),
        ),
        const SizedBox(height: 20),
        ...children,
      ]),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, body;

  const _PolicyCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 12),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D1B10))),
          const SizedBox(height: 4),
          Text(body, style: GoogleFonts.dmSans(
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.5)),
        ])),
      ]),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String text;
  final Color color;
  const _InfoBox({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.info_outline_rounded, size: 16, color: color),
        const SizedBox(width: 10),
        Expanded(child: Text(text,
            style: GoogleFonts.dmSans(
                fontSize: 12, color: color, height: 1.5))),
      ]),
    );
  }
}

class _SubHeading extends StatelessWidget {
  final String text;
  const _SubHeading(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text,
        style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D1B10))),
  );
}

class _BulletItem extends StatelessWidget {
  final String text;
  const _BulletItem(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(top: 6, right: 10),
        child: Container(
          width: 5, height: 5,
          decoration: const BoxDecoration(
            color: Color(0xFFCD6E4E),
            shape: BoxShape.circle,
          ),
        ),
      ),
      Expanded(child: Text(text,
          style: GoogleFonts.dmSans(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.5))),
    ]),
  );
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Contact & Questions',
            style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D1B10))),
        const SizedBox(height: 8),
        Text(
          'For questions about these terms, cancellations, or privacy '
              'concerns, please contact us at support@lokyatra.app or through '
              'the Help & Support section in your profile.',
          style: GoogleFonts.dmSans(
              fontSize: 12, color: Colors.grey[600], height: 1.6),
        ),
        const SizedBox(height: 12),
        Text('LokYatra · Nepal Cultural Tourism Platform',
            style: GoogleFonts.dmSans(
                fontSize: 11, color: Colors.grey[400])),
      ]),
    );
  }
}

class _AcceptBar extends StatelessWidget {
  final bool unlocked;
  final VoidCallback onDecline;
  final VoidCallback onAccept;

  const _AcceptBar({
    required this.unlocked,
    required this.onDecline,
    required this.onAccept,
  });

  static const _dark       = Color(0xFF2D1B10);

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Container(
      padding: EdgeInsets.fromLTRB(
          isWide ? 48 : 20, 12, isWide ? 48 : 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 12, offset: const Offset(0, -4),
        )],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isWide ? 560 : double.infinity),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (!unlocked) ...[
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: 16, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  'Scroll to the bottom to accept',
                  style: GoogleFonts.dmSans(
                      fontSize: 12, color: Colors.grey[400]),
                ),
              ]),
              const SizedBox(height: 10),
            ],
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDecline,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Decline',
                      style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                ),
              ),
              const SizedBox(width: 12),
              // Accept
              Expanded(
                flex: 2,
                child: AnimatedOpacity(
                  opacity: unlocked ? 1.0 : 0.4,
                  duration: const Duration(milliseconds: 300),
                  child: ElevatedButton.icon(
                    onPressed: unlocked ? onAccept : null,
                    icon: const Icon(Icons.check_rounded,
                        size: 18, color: Colors.white),
                    label: Text('I Accept the Terms',
                        style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: unlocked ? _dark : Colors.grey,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}