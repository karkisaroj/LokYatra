import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingDotsIndicator extends StatelessWidget {
  final int currentPage;
  final int pageCount;

  const OnboardingDotsIndicator({
    super.key,
    required this.currentPage,
    required this.pageCount,
  });

  Widget _buildDot(int index) {
    bool isActive = index == currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      height: 8.r,
      width: isActive ? 30.r : 8.r,
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFE5805B)
            : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(5.r),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) => _buildDot(index)),
    );
  }
}
