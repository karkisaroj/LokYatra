import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lokyatra_frontend/core/services/sqlite_service.dart';
import 'package:lokyatra_frontend/presentation/screens/authentication/loginPage.dart';
import '../../../data/models/onboarding.dart';
import '../../splash/OnboardingDotsIndicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  static const _brown      = Color(0xFF8B5E3C);
  static const _dark       = Color(0xFF2D1B10);
  static const _cream      = Color(0xFFFAF7F2);
  static const _terracotta = Color(0xFFCD6E4E);

  final List<Onboarding> pages = [
    Onboarding(
      image: 'assets/images/onboarding1.png',
      title: 'Discover Heritage',
      subtitle: "Explore Nepal's Ancient Temples, mountains and Cultural Landmarks",
    ),
    Onboarding(
      image: 'assets/images/Homestay.png',
      title: 'Discover Homestay',
      subtitle: "Stay with local families near heritage sites and experience authentic culture",
    ),
    Onboarding(
      image: 'assets/images/learn&play.png',
      title: 'Learn & Play',
      subtitle: "Take quizzes, earn points, and get discounts on your next booking",
    ),
  ];

  Future<void> _markSeen() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_onboarding', true);
    } else {
      await SqliteService().put('has_seen_onboarding', true);
    }
  }

  Future<void> _goToLogin() async {
    await _markSeen();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  void _next() {
    if (_currentPage == pages.length - 1) {
      _goToLogin();
    } else {
      _controller.nextPage(duration: const Duration(milliseconds: 600), curve: Curves.easeOutExpo);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWeb = kIsWeb || width > 700;
    return isWeb ? _webLayout() : _mobileLayout();
  }

  // ── MOBILE ───────────────────────────────────────────────────────────────
  Widget _mobileLayout() {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(children: [
        SizedBox(
          height: size.height * 0.52,
          child: PageView.builder(
            controller: _controller,
            itemCount: pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, index) {
              return AnimatedBuilder(
                animation: _controller,
                builder: (_, child) {
                  double shift = 0;
                  if (_controller.position.haveDimensions) {
                    shift = (index - _controller.page!) * 50;
                  }
                  return Transform.translate(offset: Offset(shift, 0), child: child);
                },
                child: Stack(fit: StackFit.expand, children: [
                  Image.asset(pages[index].image, fit: BoxFit.cover, alignment: Alignment.bottomCenter,
                      errorBuilder: (_, __, ___) => Container(color: _cream,
                          child: const Icon(Icons.image_not_supported, size: 48, color: Colors.grey))),
                  Positioned(
                    left: 0, right: 0, bottom: 0,
                    height: size.height * 0.22,
                    child: const DecoratedBox(decoration: BoxDecoration(
                      gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          colors: [Color(0x00FFFFFF), Color(0x78FFFFFF), Color(0xC8FFFFFF), Colors.white]),
                    )),
                  ),
                ]),
              );
            },
          ),
        ),
        SizedBox(height: 32.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Column(key: ValueKey(_currentPage), children: [
              Text(pages[_currentPage].title,
                  style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.bold, color: _dark)),
              SizedBox(height: 10.h),
              Text(pages[_currentPage].subtitle, textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15.sp, color: Colors.black54, height: 1.5)),
            ]),
          ),
        ),
        const Spacer(),
        OnboardingDotsIndicator(currentPage: _currentPage, pageCount: pages.length),
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
          child: Row(children: [
            Expanded(child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black87,
                  elevation: 6, padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.grey.shade200))),
              onPressed: _goToLogin,
              child: Text("Skip", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
            )),
            const SizedBox(width: 16),
            Expanded(child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent,
                  elevation: 6, padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: _next,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                Text(_currentPage == pages.length - 1 ? "Get Started" : "Next",
                    style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_right_rounded, color: Colors.white, size: 18),
              ]),
            )),
          ]),
        ),
      ]),
    );
  }

  // ── WEB ──────────────────────────────────────────────────────────────────
  Widget _webLayout() {
    final size   = MediaQuery.of(context).size;
    final isWide = size.width > 1100;

    return Scaffold(
      backgroundColor: _cream,
      body: isWide ? _webWide(size) : _webNarrow(size),
    );
  }

  // Wide web (≥1100px) — split: left image panel, right content panel
  Widget _webWide(Size size) {
    return Row(children: [
      // ── LEFT — fullscreen image slideshow ─────────────────────────────
      Expanded(
        flex: 55,
        child: Stack(children: [
          PageView.builder(
            controller: _controller,
            itemCount: pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, index) => Stack(fit: StackFit.expand, children: [
              Image.asset(pages[index].image, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: _cream)),
              // Dark overlay for readability
              Container(color: Colors.black.withValues(alpha: 0.35)),
            ]),
          ),
          // Branding overlay on image
          Positioned(
            top: 40, left: 48,
            child: Row(children: [
              Container(width: 36, height: 36,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child:  Image.asset("assets/images/lokyatra_logo.png", fit: BoxFit.contain)),
               SizedBox(width: 12),
              const Text('LokYatra', style: TextStyle(color: Colors.white, fontSize: 22,
                  fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ]),
          ),
          // Caption on image
          Positioned(
            bottom: 60, left: 48, right: 48,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Column(key: ValueKey(_currentPage), crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Page indicator dots on left panel
                Row(children: List.generate(pages.length, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(right: 6),
                  height: 6, width: _currentPage == i ? 22 : 6,
                  decoration: BoxDecoration(
                    color: _currentPage == i ? Colors.white : Colors.white38,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ))),
                const SizedBox(height: 16),
                Text(pages[_currentPage].title,
                    style: const TextStyle(color: Colors.white, fontSize: 36,
                        fontWeight: FontWeight.bold, height: 1.1)),
                const SizedBox(height: 12),
                Text(pages[_currentPage].subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.6)),
              ]),
            ),
          ),
          // Prev / Next arrows on image
          Positioned(
            bottom: 40, right: 48,
            child: Row(children: [
              _ArrowBtn(icon: Icons.arrow_back_rounded, onTap: _currentPage > 0 ? () {
                _controller.previousPage(duration: const Duration(milliseconds: 600), curve: Curves.easeOutExpo);
              } : null),
              const SizedBox(width: 10),
              _ArrowBtn(icon: Icons.arrow_forward_rounded, onTap: () {
                if (_currentPage < pages.length - 1) {
                  _controller.nextPage(duration: const Duration(milliseconds: 600), curve: Curves.easeOutExpo);
                }
              }),
            ]),
          ),
        ]),
      ),

      // ── RIGHT — content panel ──────────────────────────────────────────
      Expanded(
        flex: 45,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 64),
          child: _webRightContent(),
        ),
      ),
    ]);
  }

  // Narrow web (700–1100px) — stacked layout, full width
  Widget _webNarrow(Size size) {
    return SingleChildScrollView(
      child: Column(children: [
        // Image banner
        Stack(children: [
          SizedBox(
            width: double.infinity,
            height: size.height * 0.45,
            child: PageView.builder(
              controller: _controller,
              itemCount: pages.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (_, index) => Stack(fit: StackFit.expand, children: [
                Image.asset(pages[index].image, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: _cream)),
                Container(color: Colors.black.withValues(alpha: 0.3)),
              ]),
            ),
          ),
          // Logo top-left
          Positioned(
            top: 32, left: 32,
            child: Row(children: [
              Container(width: 32, height: 32,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.temple_hindu_rounded, color: Color(0xFF8B5E3C), size: 20)),
              const SizedBox(width: 10),
              const Text('LokYatra', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ]),
          ),
          // Dots
          Positioned(
            bottom: 16, left: 0, right: 0,
            child: Row(mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 6, width: _currentPage == i ? 20 : 6,
                decoration: BoxDecoration(
                  color: _currentPage == i ? Colors.white : Colors.white38,
                  borderRadius: BorderRadius.circular(3),
                ),
              )),
            ),
          ),
        ]),
        // Content
        Container(color: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
            child: _webRightContent()),
      ]),
    );
  }

  Widget _webRightContent() {
    final isLast = _currentPage == pages.length - 1;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Steps indicator
        Row(children: List.generate(pages.length, (i) => Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _currentPage == i ? _brown : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('${i + 1}', style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold,
            color: _currentPage == i ? Colors.white : Colors.grey[400],
          )),
        ))),
        const SizedBox(height: 28),

        // Title
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: Text(pages[_currentPage].title,
            key: ValueKey(pages[_currentPage].title),
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: _dark, height: 1.15),
          ),
        ),
        const SizedBox(height: 16),

        // Subtitle
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: Text(pages[_currentPage].subtitle,
            key: ValueKey(pages[_currentPage].subtitle),
            style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.65),
          ),
        ),
        const SizedBox(height: 40),

        // Feature chips
        _FeatureChips(pageIndex: _currentPage),
        const SizedBox(height: 48),

        // Buttons
        Row(children: [
          if (!isLast) ...[
            Expanded(child: OutlinedButton(
              style: OutlinedButton.styleFrom(foregroundColor: Colors.grey[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: Colors.grey.shade300)),
              onPressed: _goToLogin,
              child: const Text('Skip for now', style: TextStyle(fontWeight: FontWeight.w600)),
            )),
            const SizedBox(width: 16),
          ],
          Expanded(
            flex: 2,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _terracotta, foregroundColor: Colors.white,
                elevation: 0, padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _next,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(isLast ? 'Get Started — It\'s Free' : 'Continue',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Icon(isLast ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded, size: 18),
              ]),
            ),
          ),
        ]),
        const SizedBox(height: 24),

        // Social proof
        Center(
          child: Text('Trusted by 2,000+ travellers exploring Nepal',
              style: TextStyle(fontSize: 13, color: Colors.grey[400])),
        ),
      ],
    );
  }
}

// ── Arrow button for image slideshow ─────────────────────────────────────────

class _ArrowBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _ArrowBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedOpacity(
      opacity: onTap == null ? 0.3 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    ),
  );
}

// ── Feature chips per page ────────────────────────────────────────────────────

class _FeatureChips extends StatelessWidget {
  final int pageIndex;
  const _FeatureChips({required this.pageIndex});

  static const _chips = [
    [' 700+ Heritage Sites', ' GPS Guided Tours', '  Entry Info'],
    [' Local Homestays', ' Verified Hosts', ' Easy Booking'],
    [' Culture Quizzes', ' Earn Rewards', 'Booking Discounts'],
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 10, runSpacing: 10,
      children: _chips[pageIndex].map((label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF7F2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE8DDD5)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF5C3D2E), fontWeight: FontWeight.w500)),
      )).toList(),
    );
  }
}