// lib/presentation/screens/TouristScreen/payment_option_tile.dart
// Reusable payment method selector tile.
// Used in BookingSummaryPage — can be reused anywhere else needed.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentOptionTile extends StatelessWidget {
  final String label;
  final String sublabel;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  /// Override the selected/border/icon colour (default = brown)
  final Color? accentColor;

  /// Optional badge text shown in top-right corner e.g. "Online"
  final String? badge;
  final Color? badgeColor;

  const PaymentOptionTile({
    super.key,
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.accentColor,
    this.badge,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? const Color(0xFF8B5E3C);

    return GestureDetector(
      onTap: onTap,
      child: Stack(children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: selected ? accent.withValues(alpha: 0.06) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: selected ? accent : Colors.grey.shade200,
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Row(children: [
            // Icon circle
            Container(
              width: 40.w, height: 40.h,
              decoration: BoxDecoration(
                color: selected ? accent.withValues(alpha: 0.12) : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20.sp,
                  color: selected ? accent : Colors.grey[500]),
            ),
            SizedBox(width: 12.w),

            // Labels
            Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: GoogleFonts.dmSans(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: selected ? accent : const Color(0xFF2D1B10),
                  )),
              SizedBox(height: 2.h),
              Text(sublabel,
                  style: GoogleFonts.dmSans(
                      fontSize: 11.sp, color: Colors.grey[500])),
            ])),

            // Check mark when selected
            if (selected)
              Icon(Icons.check_circle_rounded, size: 20.sp, color: accent),
          ]),
        ),

        // Optional badge (top-right)
        if (badge != null)
          Positioned(
            top: 8.h, right: 8.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: (badgeColor ?? accent).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                    color: (badgeColor ?? accent).withValues(alpha: 0.3)),
              ),
              child: Text(badge!,
                  style: GoogleFonts.dmSans(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: badgeColor ?? accent,
                  )),
            ),
          ),
      ]),
    );
  }
}