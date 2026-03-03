import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../state_management/Bloc/Booking/booking_bloc.dart';
import '../../state_management/Bloc/Booking/booking_event.dart';
import '../../state_management/Bloc/Booking/booking_state.dart';

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
                    fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C1C))),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(height: 1, color: Colors.grey.shade200),
            ),
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _AvailableBalanceCard(revenue: _revenue),
                const SizedBox(height: 14),
                _TransactionSummaryRow(revenue: _revenue, bookings: _bookings),
                const SizedBox(height: 14),
                _PaymentMethodsSection(revenue: _revenue),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _AvailableBalanceCard extends StatelessWidget {
  final OwnerRevenueLoaded? revenue;
  const _AvailableBalanceCard({required this.revenue});

  static const _darkSlate = Color(0xFF2C3A4A);

  @override
  Widget build(BuildContext context) {
    final available = revenue?.totalRevenue ?? 0.0;
    final thisMonth = revenue?.totalRevenue ?? 0.0;
    const growth = 18.9;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_darkSlate, Color(0xFF3D5A6F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: _darkSlate.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Available Balance',
              style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white70)),
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.account_balance_wallet_rounded,
                size: 18, color: Colors.white70),
          ),
        ]),
        const SizedBox(height: 8),
        Text('Rs. ${available.toStringAsFixed(0)}',
            style: GoogleFonts.playfairDisplay(
                fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('This Month',
                  style: GoogleFonts.dmSans(fontSize: 11, color: Colors.white60)),
              const SizedBox(height: 4),
              Text('Rs. ${thisMonth.toStringAsFixed(0)}',
                  style: GoogleFonts.dmSans(
                      fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('Monthly Growth',
                style: GoogleFonts.dmSans(fontSize: 11, color: Colors.white60)),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.trending_up_rounded, size: 13, color: Colors.greenAccent),
              const SizedBox(width: 4),
              Text('$growth%',
                  style: GoogleFonts.dmSans(
                      fontSize: 15, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
            ]),
          ]),
        ]),
      ]),
    );
  }
}

class _TransactionSummaryRow extends StatelessWidget {
  final OwnerRevenueLoaded? revenue;
  final List<Map<String, dynamic>> bookings;
  const _TransactionSummaryRow({required this.revenue, required this.bookings});

  static const _cardBg  = Color(0xFFFFFFFF);
  static const _divider = Color(0xFFEDE8E1);
  static const _green   = Color(0xFF3D5A4F);
  static const _muted   = Color(0xFF8A8279);

  @override
  Widget build(BuildContext context) {
    final cashRev   = revenue?.cashRevenue   ?? 0.0;
    final khaltiRev = revenue?.khaltiRevenue ?? 0.0;
    final totalReceived = cashRev + khaltiRev;

    final confirmedCount = bookings
        .where((b) => b['booking']?['status'] == 'Confirmed')
        .length;

    final expectedSoon = bookings
        .where((b) =>
    b['booking']?['status'] == 'Confirmed' &&
        b['booking']?['paymentStatus'] != 'Paid')
        .fold(0.0, (sum, b) =>
    sum + ((b['booking']?['totalPrice'] as num?)?.toDouble() ?? 0));

    return Row(children: [
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _divider),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.check_circle_outlined, color: _green, size: 16),
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text('Total Received',
                    style: GoogleFonts.dmSans(fontSize: 11, color: _muted),
                    overflow: TextOverflow.ellipsis),
              ),
            ]),
            const SizedBox(height: 8),
            Text('Rs. ${totalReceived.toStringAsFixed(0)}',
                style: GoogleFonts.dmSans(
                    fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C1C))),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('${revenue?.paidBookings ?? 0} txns',
                  style: GoogleFonts.dmSans(
                      fontSize: 10, color: _green, fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _divider),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(Icons.hourglass_empty_rounded, color: Colors.orange[700], size: 16),
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text('Expected Soon',
                    style: GoogleFonts.dmSans(fontSize: 11, color: _muted),
                    overflow: TextOverflow.ellipsis),
              ),
            ]),
            const SizedBox(height: 8),
            Text('Rs. ${expectedSoon.toStringAsFixed(0)}',
                style: GoogleFonts.dmSans(
                    fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C1C))),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$confirmedCount pending',
                  style: GoogleFonts.dmSans(
                      fontSize: 10, color: Colors.orange[700], fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
      ),
    ]);
  }
}

class _PaymentMethodsSection extends StatelessWidget {
  final OwnerRevenueLoaded? revenue;
  const _PaymentMethodsSection({required this.revenue});

  static const _cardBg        = Color(0xFFFFFFFF);
  static const _divider       = Color(0xFFEDE8E1);
  static const _ink           = Color(0xFF1C1C1C);
  static const _muted         = Color(0xFF8A8279);
  static const _khaltiPurple  = Color(0xFF5C35AA);
  static const _cashGreen     = Color(0xFF3D5A4F);

  @override
  Widget build(BuildContext context) {
    final khaltiAmount = revenue?.khaltiRevenue ?? 0.0;
    final cashAmount   = revenue?.cashRevenue   ?? 0.0;
    final paidTotal    = revenue?.paidBookings   ?? 0;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.credit_card_rounded, size: 16, color: Color(0xFF5C4033)),
        const SizedBox(width: 7),
        Text('Payment Methods',
            style: GoogleFonts.dmSans(
                fontSize: 13, fontWeight: FontWeight.bold, color: _ink)),
      ]),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _divider),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: _khaltiPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('K',
                style: GoogleFonts.dmSans(
                    fontSize: 13, fontWeight: FontWeight.bold, color: _khaltiPurple)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Khalti Payments',
                  style: GoogleFonts.dmSans(
                      fontSize: 13, fontWeight: FontWeight.w600, color: _ink)),
              Text('Digital wallet',
                  style: GoogleFonts.dmSans(fontSize: 11, color: _muted)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('Rs. ${khaltiAmount.toStringAsFixed(0)}',
                style: GoogleFonts.dmSans(
                    fontSize: 13, fontWeight: FontWeight.bold, color: _khaltiPurple)),
            Text('$paidTotal txns',
                style: GoogleFonts.dmSans(fontSize: 10, color: _muted)),
          ]),
        ]),
      ),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _divider),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: _cashGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.money_rounded, size: 15, color: _cashGreen),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Cash Payments',
                  style: GoogleFonts.dmSans(
                      fontSize: 13, fontWeight: FontWeight.w600, color: _ink)),
              Text('On-site collection',
                  style: GoogleFonts.dmSans(fontSize: 11, color: _muted)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('Rs. ${cashAmount.toStringAsFixed(0)}',
                style: GoogleFonts.dmSans(
                    fontSize: 13, fontWeight: FontWeight.bold, color: _cashGreen)),
            Text('$paidTotal txns',
                style: GoogleFonts.dmSans(fontSize: 10, color: _muted)),
          ]),
        ]),
      ),
    ]);
  }
}