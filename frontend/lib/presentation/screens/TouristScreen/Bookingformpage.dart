import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/image_proxy.dart';

import 'Bookingsummarypage.dart';

class BookingFormPage extends StatefulWidget {
  final dynamic homestay;
  const BookingFormPage({super.key, required this.homestay});

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  static const _cream = Color(0xFFFAF7F2);
  static const _brown = Color(0xFF8B5E3C);
  static const _dark  = Color(0xFF2D1B10);

  DateTime? _checkIn;
  DateTime? _checkOut;
  int _rooms  = 1;
  int _guests = 1;
  final _specialRequests = TextEditingController();

  int get _maxRooms  => widget.homestay.numberOfRooms ?? 10;
  int get _maxGuests => widget.homestay.maxGuests ?? 20;

  Future<void> _pickDate(bool isCheckIn) async {
    final now   = DateTime.now();
    final first = isCheckIn ? now : (_checkIn ?? now).add(const Duration(days: 1));

    final picked = await showDatePicker(
      context: context,
      initialDate: first,
      firstDate: first,
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: _brown,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (picked == null) return;
    setState(() {
      if (isCheckIn) {
        _checkIn = picked;
        // Reset checkout if it's before new checkin
        if (_checkOut != null && !_checkOut!.isAfter(picked)) {
          _checkOut = null;
        }
      } else {
        _checkOut = picked;
      }
    });
  }

  String _formatDate(DateTime? d) {
    if (d == null) return 'mm/dd/yyyy';
    return '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';
  }

  void _proceed() {
    if (_checkIn == null || _checkOut == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please select check-in and check-out dates',
            style: GoogleFonts.dmSans()),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingSummaryPage(
          homestay:        widget.homestay,
          checkIn:         _checkIn!,
          checkOut:        _checkOut!,
          rooms:           _rooms,
          guests:          _guests,
          specialRequests: _specialRequests.text.trim(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _specialRequests.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.homestay.imageUrls?.isNotEmpty == true
        ? widget.homestay.imageUrls!.first
        : null;
    final name     = widget.homestay.name ?? '';
    final location = widget.homestay.location ?? '';

    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18.sp, color: _dark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Book Homestay',
            style: GoogleFonts.playfairDisplay(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: _dark)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Homestay summary card
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: ProxyImage(
                      imageUrl: imageUrl,
                      width: 72.w,
                      height: 72.h,
                      borderRadiusValue: 0,
                      thumb: true,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: GoogleFonts.playfairDisplay(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: _dark)),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 13.sp, color: Colors.grey[500]),
                            SizedBox(width: 2.w),
                            Text('Near $location',
                                style: GoogleFonts.dmSans(
                                    fontSize: 12.sp,
                                    color: Colors.grey[500])),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                            'Rs. ${widget.homestay.pricePerNight?.toStringAsFixed(0) ?? "0"}/night',
                            style: GoogleFonts.dmSans(
                                fontSize: 13.sp,
                                color: _brown,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Check In
            _FormLabel('Check In *'),
            SizedBox(height: 6.h),
            _DateField(
              value: _formatDate(_checkIn),
              onTap: () => _pickDate(true),
              isSet: _checkIn != null,
            ),

            SizedBox(height: 14.h),

            // Check Out
            _FormLabel('Check Out *'),
            SizedBox(height: 6.h),
            _DateField(
              value: _formatDate(_checkOut),
              onTap: () => _pickDate(false),
              isSet: _checkOut != null,
            ),

            SizedBox(height: 14.h),

            // Rooms stepper
            _FormLabel('Rooms *'),
            SizedBox(height: 6.h),
            _StepperCard(
              label: 'Number of rooms',
              sublabel: 'Max $_maxRooms rooms available',
              value: _rooms,
              onDecrement: _rooms > 1
                  ? () => setState(() => _rooms--)
                  : null,
              onIncrement: _rooms < _maxRooms
                  ? () => setState(() => _rooms++)
                  : null,
            ),

            SizedBox(height: 14.h),

            // Guests stepper
            _FormLabel('Guests *'),
            SizedBox(height: 6.h),
            _StepperCard(
              label: 'Number of guests',
              sublabel: 'Max $_maxGuests guests',
              value: _guests,
              onDecrement: _guests > 1
                  ? () => setState(() => _guests--)
                  : null,
              onIncrement: _guests < _maxGuests
                  ? () => setState(() => _guests++)
                  : null,
            ),

            SizedBox(height: 14.h),

            // Special requests
            _FormLabel('Special Requests (optional)'),
            SizedBox(height: 6.h),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _specialRequests,
                maxLines: 4,
                style: GoogleFonts.dmSans(fontSize: 13.sp),
                decoration: InputDecoration(
                  hintText:
                  'e.g. Vegetarian meals only, early check-in, ground floor room...',
                  hintStyle: GoogleFonts.dmSans(
                      fontSize: 13.sp, color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14.w),
                ),
              ),
            ),

            SizedBox(height: 28.h),

            // Continue button
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: _proceed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brown,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r)),
                ),
                child: Text('Continue to Summary',
                    style: GoogleFonts.dmSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700)),
              ),
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _FormLabel extends StatelessWidget {
  final String label;
  const _FormLabel(this.label);

  @override
  Widget build(BuildContext context) => Text(label,
      style: GoogleFonts.dmSans(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2D1B10)));
}

class _DateField extends StatelessWidget {
  final String value;
  final VoidCallback onTap;
  final bool isSet;
  const _DateField(
      {required this.value, required this.onTap, this.isSet = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSet
                ? const Color(0xFF8B5E3C).withValues(alpha: 0.4)
                : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month_outlined,
                size: 20.sp,
                color: isSet
                    ? const Color(0xFF8B5E3C)
                    : Colors.grey[400]),
            SizedBox(width: 12.w),
            Text(value,
                style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    color: isSet
                        ? const Color(0xFF2D1B10)
                        : Colors.grey[400])),
          ],
        ),
      ),
    );
  }
}

class _StepperCard extends StatelessWidget {
  final String label;
  final String sublabel;
  final int value;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  const _StepperCard({
    required this.label,
    required this.sublabel,
    required this.value,
    this.onDecrement,
    this.onIncrement,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.dmSans(
                        fontSize: 13.sp, color: Colors.grey[500])),
                Text(sublabel,
                    style: GoogleFonts.dmSans(
                        fontSize: 11.sp, color: Colors.grey[400])),
              ],
            ),
          ),
          // Stepper controls
          Row(
            children: [
              _StepBtn(
                icon: Icons.remove,
                onTap: onDecrement,
              ),
              SizedBox(width: 16.w),
              Text('$value',
                  style: GoogleFonts.dmSans(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D1B10))),
              SizedBox(width: 16.w),
              _StepBtn(
                icon: Icons.add,
                onTap: onIncrement,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _StepBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34.w,
        height: 34.h,
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFF8B5E3C).withValues(alpha: 0.1)
              : Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            size: 18.sp,
            color: enabled
                ? const Color(0xFF8B5E3C)
                : Colors.grey[300]),
      ),
    );
  }
}