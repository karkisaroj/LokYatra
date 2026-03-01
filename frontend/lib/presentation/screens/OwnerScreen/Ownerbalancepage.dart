// lib/presentation/screens/OwnerScreen/OwnerBalancePage.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../state_management/Bloc/booking/booking_bloc.dart';
import '../../state_management/Bloc/booking/booking_event.dart';
import '../../state_management/Bloc/booking/booking_state.dart';

class OwnerBalancePage extends StatefulWidget {
  const OwnerBalancePage({super.key});

  @override
  State<OwnerBalancePage> createState() => _OwnerBalancePageState();
}

class _OwnerBalancePageState extends State<OwnerBalancePage> {
  late final BookingBloc _bookingBloc;

  OwnerRevenueLoaded? _revenue;
  List<Map<String, dynamic>> _bookings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _bookingBloc = BookingBloc()..add(const LoadOwnerBookings());
  }

  @override
  void dispose() {
    _bookingBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bookingBloc,
      child: BlocListener<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is OwnerBookingsLoaded) {
            setState(() => _bookings = state.bookings);
          }
          if (state is OwnerRevenueLoaded) {
            setState(() {
              _revenue = state;
              _loading = false;
            });
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFFAF7F2),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text('Balance & Earnings',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 20.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C1C))),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(height: 1, color: Colors.grey.shade200),
            ),
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _AvailableBalanceCard(revenue: _revenue),
                SizedBox(height: 14.h),
                _TransactionSummaryRow(revenue: _revenue, bookings: _bookings),
                SizedBox(height: 14.h),
                _PaymentMethodsSection(revenue: _revenue),
                SizedBox(height: 20.h),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Available Balance Card (Dark, Hero Style) ─────────────────────────────────

class _AvailableBalanceCard extends StatelessWidget {
  final OwnerRevenueLoaded? revenue;
  const _AvailableBalanceCard({required this.revenue});

  static const _darkSlate = Color(0xFF2C3A4A);

  @override
  Widget build(BuildContext context) {
    final available = revenue?.totalRevenue ?? 0.0;
    final thisMonth = revenue?.totalRevenue ?? 0.0; // You can adjust this to be current month only
    final growth = 18.9; // Example growth percentage — can be calculated from backend

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_darkSlate, Color(0xFF3D5A6F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
              color: _darkSlate.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Available Balance',
              style: GoogleFonts.dmSans(fontSize: 13.sp, color: Colors.white70)),
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.account_balance_wallet_rounded,
                size: 20.sp, color: Colors.white70),
          ),
        ]),

        SizedBox(height: 10.h),

        // Main balance amount
        Text('Rs. ${available.toStringAsFixed(0)}',
            style: GoogleFonts.playfairDisplay(
                fontSize: 40.sp, fontWeight: FontWeight.bold, color: Colors.white)),

        SizedBox(height: 16.h),

        // This Month + Growth
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('This Month',
                  style: GoogleFonts.dmSans(fontSize: 11.sp, color: Colors.white60)),
              SizedBox(height: 4.h),
              Text('Rs. ${thisMonth.toStringAsFixed(0)}',
                  style: GoogleFonts.dmSans(
                      fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('Monthly Growth',
                style: GoogleFonts.dmSans(fontSize: 11.sp, color: Colors.white60)),
            SizedBox(height: 4.h),
            Row(children: [
              Icon(Icons.trending_up_rounded, size: 14.sp, color: Colors.greenAccent),
              SizedBox(width: 4.w),
              Text('$growth%',
                  style: GoogleFonts.dmSans(
                      fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
            ]),
          ]),
        ]),
      ]),
    );
  }
}

// ── Transaction Summary Row (Total Received + Expected Soon) ──────────────────

class _TransactionSummaryRow extends StatelessWidget {
  final OwnerRevenueLoaded? revenue;
  final List<Map<String, dynamic>> bookings;
  const _TransactionSummaryRow({required this.revenue, required this.bookings});

  static const _cardBg = Color(0xFFFFFFFF);
  static const _divider = Color(0xFFEDE8E1);
  static const _green = Color(0xFF3D5A4F);
  static const _muted = Color(0xFF8A8279);

  @override
  Widget build(BuildContext context) {
    final totalReceived = revenue?.cashRevenue ?? 0.0 + (revenue?.khaltiRevenue ?? 0.0);
    final confirmedCount = bookings.where((b) => b['booking']?['status'] == 'Confirmed').length;

    // Expected Soon = pending from confirmed bookings
    final expectedSoon = bookings
        .where((b) =>
    b['booking']?['status'] == 'Confirmed' && b['booking']?['paymentStatus'] != 'Paid')
        .fold(0.0, (sum, b) => sum + ((b['booking']?['totalPrice'] as num?)?.toDouble() ?? 0));

    return Row(children: [
      Expanded(
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: _divider),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.check_circle_outlined, color: _green, size: 18.sp),
              ),
              SizedBox(width: 8.w),
              Text('Total Received',
                  style: GoogleFonts.dmSans(fontSize: 12.sp, color: _muted)),
            ]),
            SizedBox(height: 8.h),
            Text('Rs. ${totalReceived.toStringAsFixed(0)}',
                style: GoogleFonts.dmSans(
                    fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C1C))),
            SizedBox(height: 6.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text('3 transactions',
                  style: GoogleFonts.dmSans(fontSize: 11.sp, color: _green, fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
      ),
      SizedBox(width: 12.w),
      Expanded(
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: _divider),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child:
                Icon(Icons.hourglass_empty_rounded, color: Colors.orange[700], size: 18.sp),
              ),
              SizedBox(width: 8.w),
              Text('Expected Soon',
                  style: GoogleFonts.dmSans(fontSize: 12.sp, color: _muted)),
            ]),
            SizedBox(height: 8.h),
            Text('Rs. ${expectedSoon.toStringAsFixed(0)}',
                style: GoogleFonts.dmSans(
                    fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C1C))),
            SizedBox(height: 6.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text('$confirmedCount pending',
                  style: GoogleFonts.dmSans(
                      fontSize: 11.sp,
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
      ),
    ]);
  }
}

// ── Payment Methods Section ───────────────────────────────────────────────────

class _PaymentMethodsSection extends StatelessWidget {
  final OwnerRevenueLoaded? revenue;
  const _PaymentMethodsSection({required this.revenue});

  static const _cardBg = Color(0xFFFFFFFF);
  static const _divider = Color(0xFFEDE8E1);
  static const _ink = Color(0xFF1C1C1C);
  static const _muted = Color(0xFF8A8279);
  static const _khaltiPurple = Color(0xFF5C35AA);
  static const _cashGreen = Color(0xFF3D5A4F);

  @override
  Widget build(BuildContext context) {
    final khaltiAmount = revenue?.khaltiRevenue ?? 0.0;
    final cashAmount = revenue?.cashRevenue ?? 0.0;

    // Count transactions for each method (you'll need to calculate from bookings)
    final khaltiTransactions = 2; // example
    final cashTransactions = 1; // example

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.credit_card_rounded, size: 18.sp, color: const Color(0xFF5C4033)),
        SizedBox(width: 8.w),
        Text('Payment Methods',
            style: GoogleFonts.dmSans(fontSize: 14.sp, fontWeight: FontWeight.bold, color: _ink)),
      ]),
      SizedBox(height: 14.h),
      // Khalti Card
      Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _divider),
        ),
        child: Row(children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: _khaltiPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text('K',
                style: GoogleFonts.dmSans(
                    fontSize: 14.sp, fontWeight: FontWeight.bold, color: _khaltiPurple)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Khalti Payments',
                  style: GoogleFonts.dmSans(fontSize: 13.sp, fontWeight: FontWeight.w600, color: _ink)),
              Text('Digital wallet',
                  style: GoogleFonts.dmSans(fontSize: 11.sp, color: _muted)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('Rs. ${khaltiAmount.toStringAsFixed(0)}',
                style: GoogleFonts.dmSans(
                    fontSize: 14.sp, fontWeight: FontWeight.bold, color: _khaltiPurple)),
            Text('$khaltiTransactions txns',
                style: GoogleFonts.dmSans(fontSize: 10.sp, color: _muted)),
          ]),
        ]),
      ),
      SizedBox(height: 10.h),
      // Cash Card
      Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _divider),
        ),
        child: Row(children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: _cashGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.money_rounded, size: 16.sp, color: _cashGreen),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Cash Payments',
                  style: GoogleFonts.dmSans(fontSize: 13.sp, fontWeight: FontWeight.w600, color: _ink)),
              Text('On-site collection',
                  style: GoogleFonts.dmSans(fontSize: 11.sp, color: _muted)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('Rs. ${cashAmount.toStringAsFixed(0)}',
                style: GoogleFonts.dmSans(
                    fontSize: 14.sp, fontWeight: FontWeight.bold, color: _cashGreen)),
            Text('$cashTransactions txns',
                style: GoogleFonts.dmSans(fontSize: 10.sp, color: _muted)),
          ]),
        ]),
      ),
    ]);
  }
}