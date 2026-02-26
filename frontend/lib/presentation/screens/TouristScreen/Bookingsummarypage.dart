// lib/presentation/screens/TouristScreen/BookingSummaryPage.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/datasources/booking_remote_datasource.dart';
import '../../../data/datasources/User_remote_datasource.dart';
import 'payment_option_tile.dart'; // ← reusable widget

class BookingSummaryPage extends StatefulWidget {
  final dynamic homestay;
  final DateTime checkIn;
  final DateTime checkOut;
  final int rooms;
  final int guests;
  final String specialRequests;

  const BookingSummaryPage({
    super.key,
    required this.homestay,
    required this.checkIn,
    required this.checkOut,
    required this.rooms,
    required this.guests,
    required this.specialRequests,
  });

  @override
  State<BookingSummaryPage> createState() => _BookingSummaryPageState();
}

class _BookingSummaryPageState extends State<BookingSummaryPage> {
  static const _cream        = Color(0xFFFAF7F2);
  static const _brown        = Color(0xFF8B5E3C);
  static const _dark         = Color(0xFF2D1B10);
  static const _khaltiPurple = Color(0xFF5C2D91);

  static const _breakfastPricePerDay = 600.0;
  static const _dinnerPricePerDay    = 1200.0;

  bool _includeBreakfast = false;
  bool _includeDinner    = false;
  bool _usePoints        = false;
  bool _khaltiSelected   = false;
  bool _loading          = false;
  bool _pointsLoading    = true;

  int _availablePoints = 0;

  @override
  void initState() {
    super.initState();
    _loadPoints();
  }

  Future<void> _loadPoints() async {
    try {
      final res = await UserRemoteDatasource().getCurrentUser();
      if (res.statusCode == 200 && mounted) {
        final data = res.data as Map<String, dynamic>;
        setState(() {
          _availablePoints = data['quizPoints'] as int? ?? 0;
          _pointsLoading   = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _pointsLoading = false);
    }
  }

  // ── Computed values ───────────────────────────────────────────────────────

  int get _nights => widget.checkOut.difference(widget.checkIn).inDays;

  double get _roomTotal =>
      (widget.homestay.pricePerNight ?? 0) * widget.rooms * _nights;

  double get _breakfastTotal =>
      _includeBreakfast ? _breakfastPricePerDay * _nights : 0;

  double get _dinnerTotal =>
      _includeDinner ? _dinnerPricePerDay * _nights : 0;

  double get _subTotal => _roomTotal + _breakfastTotal + _dinnerTotal;

  int get _redeemablePoints {
    final maxDiscount = _subTotal * 0.20;
    final maxPoints   = (maxDiscount * 10).floor();
    return _availablePoints < maxPoints ? _availablePoints : maxPoints;
  }

  double get _pointsDiscount => _usePoints ? _redeemablePoints / 10.0 : 0;
  double get _totalPrice     => _subTotal - _pointsDiscount;

  String _fmt(double v) => 'Rs. ${v.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},',
  )}';

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _confirm() async {
    setState(() => _loading = true);
    try {
      final mealNotes = [
        if (_includeBreakfast) 'Breakfast included',
        if (_includeDinner) 'Dinner included',
        if (widget.specialRequests.isNotEmpty) widget.specialRequests,
      ].join('. ');

      final res = await BookingRemoteDatasource().createBooking(
        homestayId:      widget.homestay.id,
        checkIn:         widget.checkIn,
        checkOut:        widget.checkOut,
        rooms:           widget.rooms,
        guests:          widget.guests,
        pointsToRedeem:  _usePoints ? _redeemablePoints : 0,
        paymentMethod:   _khaltiSelected ? 'Khalti' : 'PayAtArrival',
        specialRequests: mealNotes,
      );

      if (!mounted) return;
      if (res.statusCode == 200) {
        _showSuccess();
      } else {
        final msg = (res.data as Map<String, dynamic>?)?['message']
            ?? 'Booking failed (${res.statusCode})';
        _showError(msg.toString());
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9), shape: BoxShape.circle),
            child: Icon(Icons.check_rounded, color: Colors.green[700], size: 40.sp),
          ),
          SizedBox(height: 16.h),
          Text('Booking Requested!',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 20.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          Text(
            _khaltiSelected
                ? 'Once the owner confirms your booking, a "Pay with Khalti" button will appear in My Bookings.'
                : 'Your booking is pending owner confirmation. Pay cash when you check in.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(fontSize: 13.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              style: ElevatedButton.styleFrom(
                backgroundColor: _brown,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
              ),
              child: Text('Back to Home',
                  style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.dmSans()),
      backgroundColor: Colors.red[700],
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

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
        title: Text('Booking Summary',
            style: GoogleFonts.playfairDisplay(
                fontSize: 18.sp, fontWeight: FontWeight.bold, color: _dark)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Stay details ─────────────────────────────────────────────────
          _SummaryCard(
            title: 'Stay Details',
            child: Column(children: [
              _SummaryRow('Homestay',  widget.homestay.name ?? ''),
              _SummaryRow('Check-in',  _fmtDate(widget.checkIn)),
              _SummaryRow('Check-out', _fmtDate(widget.checkOut)),
              _SummaryRow('Nights',    '$_nights night${_nights != 1 ? 's' : ''}'),
              _SummaryRow('Rooms',     '${widget.rooms} room${widget.rooms > 1 ? 's' : ''}'),
              _SummaryRow('Guests',    '${widget.guests} guest${widget.guests > 1 ? 's' : ''}'),
            ]),
          ),

          SizedBox(height: 14.h),

          // ── Meals ────────────────────────────────────────────────────────
          _SummaryCard(
            title: 'Meals (optional)',
            child: Column(children: [
              _MealOption(
                label:    'Breakfast ($_nights day${_nights != 1 ? 's' : ''})',
                sublabel: 'Rs. ${_breakfastPricePerDay.toInt()} per day',
                value:    _fmt(_breakfastPricePerDay * _nights),
                checked:  _includeBreakfast,
                onChanged: (v) => setState(() => _includeBreakfast = v ?? false),
              ),
              SizedBox(height: 8.h),
              _MealOption(
                label:    'Dinner ($_nights day${_nights != 1 ? 's' : ''})',
                sublabel: 'Rs. ${_dinnerPricePerDay.toInt()} per day',
                value:    _fmt(_dinnerPricePerDay * _nights),
                checked:  _includeDinner,
                onChanged: (v) => setState(() => _includeDinner = v ?? false),
              ),
            ]),
          ),

          SizedBox(height: 14.h),

          // ── Quiz points ──────────────────────────────────────────────────
          _SummaryCard(
            title: 'Quiz Points',
            child: _pointsLoading
                ? const Center(child: CircularProgressIndicator())
                : _availablePoints == 0
                ? Row(children: [
              Icon(Icons.stars_outlined,
                  size: 16.sp, color: Colors.grey[400]),
              SizedBox(width: 8.w),
              Expanded(child: Text(
                'No quiz points yet. Play the quiz on your profile to earn discounts!',
                style: GoogleFonts.dmSans(
                    fontSize: 12.sp, color: Colors.grey[500]),
              )),
            ])
                : Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MealOption(
                    label:    'Use $_redeemablePoints pts  →  ${_fmt(_redeemablePoints / 10.0)} off',
                    sublabel: 'Max 20% discount · 10 pts = Rs. 1',
                    value:    '-${_fmt(_redeemablePoints / 10.0)}',
                    valueColor: _brown,
                    checked:  _usePoints,
                    onChanged: (v) => setState(() => _usePoints = v ?? false),
                  ),
                  SizedBox(height: 6.h),
                  Text('Available: $_availablePoints pts',
                      style: GoogleFonts.dmSans(
                          fontSize: 11.sp, color: Colors.grey[500])),
                ]),
          ),

          SizedBox(height: 14.h),

          // ── Price breakdown ──────────────────────────────────────────────
          _SummaryCard(
            title: 'Price Breakdown',
            child: Column(children: [
              _SummaryRow(
                  'Room (${widget.rooms} × $_nights night${_nights != 1 ? 's' : ''})',
                  _fmt(_roomTotal)),
              if (_includeBreakfast) _SummaryRow('Breakfast', _fmt(_breakfastTotal)),
              if (_includeDinner)    _SummaryRow('Dinner',    _fmt(_dinnerTotal)),
              if (_usePoints)
                _SummaryRow('Points Discount', '-${_fmt(_pointsDiscount)}',
                    valueColor: Colors.green[700]),
              Divider(color: Colors.grey.shade200, height: 20.h),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Total',
                    style: GoogleFonts.dmSans(fontSize: 15.sp,
                        fontWeight: FontWeight.w700, color: _dark)),
                Text(_fmt(_totalPrice),
                    style: GoogleFonts.dmSans(fontSize: 18.sp,
                        fontWeight: FontWeight.w800, color: _brown)),
              ]),
              SizedBox(height: 4.h),
              Align(
                alignment: Alignment.centerRight,
                child: Text('+13% VAT may apply',
                    style: GoogleFonts.dmSans(
                        fontSize: 10.sp, color: Colors.grey[400])),
              ),
            ]),
          ),

          SizedBox(height: 14.h),

          // ── Payment method ───────────────────────────────────────────────
          _SummaryCard(
            title: 'Payment Method',
            child: Column(children: [

              // Cash on arrival
              PaymentOptionTile(
                label:    'Pay at Arrival',
                sublabel: 'Pay cash when you check in',
                icon:     Icons.payments_outlined,
                selected: !_khaltiSelected,
                onTap:    () => setState(() => _khaltiSelected = false),
              ),

              SizedBox(height: 10.h),

              // Khalti — fully live
              PaymentOptionTile(
                label:       'Pay via Khalti',
                sublabel:    'Secure online payment after owner confirms',
                icon:        Icons.account_balance_wallet_outlined,
                selected:    _khaltiSelected,
                accentColor: _khaltiPurple,
                badge:       'Online',
                badgeColor:  _khaltiPurple,
                onTap:       () => setState(() => _khaltiSelected = true),
              ),

              // Info note when Khalti selected
              if (_khaltiSelected) ...[
                SizedBox(height: 10.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: Colors.purple.shade200),
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 14.sp, color: Colors.purple[700]),
                        SizedBox(width: 8.w),
                        Expanded(child: Text(
                          'Your booking will be sent to the owner. Once confirmed, go to My Bookings → tap "Pay with Khalti" to complete payment.',
                          style: GoogleFonts.dmSans(
                              fontSize: 12.sp, color: Colors.purple[800]),
                        )),
                      ]),
                ),
              ],
            ]),
          ),

          SizedBox(height: 28.h),

          // ── Confirm button ───────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: _loading ? null : _confirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: _khaltiSelected ? _khaltiPurple : _brown,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r)),
              ),
              child: _loading
                  ? const CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2)
                  : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(
                  _khaltiSelected
                      ? Icons.account_balance_wallet_outlined
                      : Icons.check_rounded,
                  size: 18.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  _khaltiSelected
                      ? 'Request Booking (Pay via Khalti)'
                      : 'Confirm Booking',
                  style: GoogleFonts.dmSans(
                      fontSize: 15.sp, fontWeight: FontWeight.w700),
                ),
              ]),
            ),
          ),

          SizedBox(height: 20.h),
        ]),
      ),
    );
  }

  String _fmtDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

// ── Private sub-widgets ───────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SummaryCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title,
          style: GoogleFonts.dmSans(fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D1B10))),
      SizedBox(height: 12.h),
      child,
    ]),
  );
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _SummaryRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: 8.h),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Flexible(child: Text(label,
          style: GoogleFonts.dmSans(fontSize: 13.sp, color: Colors.grey[600]))),
      SizedBox(width: 10.w),
      Text(value,
          style: GoogleFonts.dmSans(fontSize: 13.sp, fontWeight: FontWeight.w600,
              color: valueColor ?? const Color(0xFF2D1B10))),
    ]),
  );
}

class _MealOption extends StatelessWidget {
  final String label;
  final String sublabel;
  final String value;
  final Color? valueColor;
  final bool checked;
  final ValueChanged<bool?> onChanged;
  const _MealOption({
    required this.label, required this.sublabel,
    required this.value, this.valueColor,
    required this.checked, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
    decoration: BoxDecoration(
      color: checked
          ? const Color(0xFF8B5E3C).withOpacity(0.05)
          : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(10.r),
      border: Border.all(
        color: checked
            ? const Color(0xFF8B5E3C).withOpacity(0.3)
            : Colors.grey.shade200,
      ),
    ),
    child: Row(children: [
      Checkbox(
        value: checked,
        onChanged: onChanged,
        activeColor: const Color(0xFF8B5E3C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
      ),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.dmSans(
                fontSize: 13.sp, fontWeight: FontWeight.w600)),
            if (sublabel.isNotEmpty)
              Text(sublabel, style: GoogleFonts.dmSans(
                  fontSize: 11.sp, color: Colors.grey[500])),
          ])),
      Text(value, style: GoogleFonts.dmSans(
          fontSize: 13.sp, fontWeight: FontWeight.w600,
          color: valueColor ?? const Color(0xFF2D1B10))),
    ]),
  );
}