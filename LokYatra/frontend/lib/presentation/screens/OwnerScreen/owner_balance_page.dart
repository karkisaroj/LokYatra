import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../state_management/Bloc/Booking/booking_bloc.dart';
import '../../state_management/Bloc/Booking/booking_event.dart';
import '../../state_management/Bloc/Booking/booking_state.dart';

const _cream        = Color(0xFFFAF7F2);
const _ink          = Color(0xFF1C1C1C);
const _cardBg       = Color(0xFFFFFFFF);
const _divider      = Color(0xFFEDE8E1);
const _muted        = Color(0xFF8A8279);
const _darkSlate    = Color(0xFF2C3A4A);
const _green        = Color(0xFF3D5A4F);
const _khaltiPurple = Color(0xFF5C35AA);
const _brown        = Color(0xFF5C4033);

class OwnerBalancePage extends StatefulWidget {
  const OwnerBalancePage({super.key});
  @override
  State<OwnerBalancePage> createState() => _OwnerBalancePageState();
}

class _OwnerBalancePageState extends State<OwnerBalancePage> {
  late final BookingBloc _bloc;
  OwnerRevenueLoaded? _revenue;
  List<Map<String, dynamic>> _bookings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _bloc = BookingBloc()..add(const LoadOwnerBookings());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 700;

    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is OwnerBookingsLoaded) setState(() => _bookings = state.bookings);
          if (state is OwnerRevenueLoaded)  setState(() { _revenue = state; _loading = false; });
        },
        child: Scaffold(
          backgroundColor: _cream,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text('Balance & Earnings',
                style: GoogleFonts.playfairDisplay(
                    fontSize: wide ? 20 : 20, fontWeight: FontWeight.bold, color: _ink)),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(height: 1, color: Colors.grey.shade200),
            ),
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: wide ? 860 : double.infinity),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                      horizontal: wide ? 24 : 16,
                      vertical:   wide ? 24 : 20),
                  child: wide ? _wideLayout() : _narrowLayout(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _narrowLayout() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _BalanceCard(revenue: _revenue, wide: false),
    const SizedBox(height: 14),
    _SummaryRow(revenue: _revenue, bookings: _bookings, wide: false),
    const SizedBox(height: 14),
    _PaymentMethods(revenue: _revenue, wide: false),
    const SizedBox(height: 20),
  ]);

  Widget _wideLayout() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _BalanceCard(revenue: _revenue, wide: true),
    const SizedBox(height: 20),
    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: _SummaryRow(revenue: _revenue, bookings: _bookings, wide: true)),
      const SizedBox(width: 20),
      Expanded(child: _PaymentMethods(revenue: _revenue, wide: true)),
    ]),
    const SizedBox(height: 20),
  ]);
}

class _BalanceCard extends StatelessWidget {
  final OwnerRevenueLoaded? revenue;
  final bool wide;
  const _BalanceCard({required this.revenue, required this.wide});

  @override
  Widget build(BuildContext context) {
    final available = revenue?.totalRevenue ?? 0.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(wide ? 20 : 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_darkSlate, Color(0xFF3D5A6F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(wide ? 18 : 18),
        boxShadow: [
          BoxShadow(color: _darkSlate.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Available Balance',
              style: GoogleFonts.dmSans(fontSize: wide ? 13 : 13, color: Colors.white70)),
          Container(
            padding: EdgeInsets.all(wide ? 9 : 9),
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: const Icon(Icons.account_balance_wallet_rounded, size: 18, color: Colors.white70),
          ),
        ]),
        SizedBox(height: wide ? 10 : 8),
        Text('Rs. ${available.toStringAsFixed(0)}',
            style: GoogleFonts.playfairDisplay(
                fontSize: wide ? 34 : 34, fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: wide ? 16 : 14),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('This Month',
                style: GoogleFonts.dmSans(fontSize: wide ? 11 : 11, color: Colors.white60)),
            SizedBox(height: wide ? 4 : 4),
            Text('Rs. ${available.toStringAsFixed(0)}',
                style: GoogleFonts.dmSans(
                    fontSize: wide ? 15 : 15, fontWeight: FontWeight.bold, color: Colors.white)),
          ])),
        ]),
      ]),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final OwnerRevenueLoaded? revenue;
  final List<Map<String, dynamic>> bookings;
  final bool wide;
  const _SummaryRow({required this.revenue, required this.bookings, required this.wide});

  @override
  Widget build(BuildContext context) {
    final cashRev   = revenue?.cashRevenue   ?? 0.0;
    final khaltiRev = revenue?.khaltiRevenue ?? 0.0;
    final total     = cashRev + khaltiRev;
    final confCount = bookings.where((b) => b['booking']?['status'] == 'Confirmed').length;
    final expected  = bookings
        .where((b) =>
    b['booking']?['status'] == 'Confirmed' &&
        b['booking']?['paymentStatus'] != 'Paid')
        .fold(0.0, (sum, b) => sum + ((b['booking']?['totalPrice'] as num?)?.toDouble() ?? 0));

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: _SummaryCard(
        wide: wide,
        icon: Icons.check_circle_outlined,
        iconColor: _green,
        label: 'Total Received',
        amount: total,
        tag: '${revenue?.paidBookings ?? 0}',
        tagColor: _green,
      )),
      SizedBox(width: wide ? 14 : 10),
      Expanded(child: _SummaryCard(
        wide: wide,
        icon: Icons.hourglass_empty_rounded,
        iconColor: Colors.orange.shade700,
        label: 'Expected Soon',
        amount: expected,
        tag: '$confCount pending',
        tagColor: Colors.orange.shade700,
      )),
    ]);
  }
}

class _SummaryCard extends StatelessWidget {
  final bool wide;
  final IconData icon;
  final Color iconColor;
  final String label, tag;
  final double amount;
  final Color tagColor;
  const _SummaryCard({
    required this.wide, required this.icon, required this.iconColor,
    required this.label, required this.amount, required this.tag, required this.tagColor,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(wide ? 16 : 14),
    decoration: BoxDecoration(
      color: _cardBg,
      borderRadius: BorderRadius.circular(wide ? 16 : 14),
      border: Border.all(color: _divider),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          padding: EdgeInsets.all(wide ? 8 : 7),
          decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, color: iconColor, size: wide ? 16 : 16),
        ),
        SizedBox(width: wide ? 8 : 7),
        Flexible(child: Text(label,
            style: GoogleFonts.dmSans(fontSize: wide ? 11 : 11, color: _muted),
            overflow: TextOverflow.ellipsis)),
      ]),
      SizedBox(height: wide ? 10 : 8),
      Text('Rs. ${amount.toStringAsFixed(0)}',
          style: GoogleFonts.dmSans(
              fontSize: wide ? 16 : 16, fontWeight: FontWeight.bold, color: _ink)),
      SizedBox(height: wide ? 8 : 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
            color: tagColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10)),
        child: Text(tag,
            style: GoogleFonts.dmSans(
                fontSize: wide ? 10 : 10, color: tagColor, fontWeight: FontWeight.w600)),
      ),
    ]),
  );
}

class _PaymentMethods extends StatelessWidget {
  final OwnerRevenueLoaded? revenue;
  final bool wide;
  const _PaymentMethods({required this.revenue, required this.wide});

  @override
  Widget build(BuildContext context) {
    final khaltiAmt = revenue?.khaltiRevenue ?? 0.0;
    final cashAmt   = revenue?.cashRevenue   ?? 0.0;
    final paidTotal = revenue?.paidBookings  ?? 0;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.credit_card_rounded, size: 16, color: _brown),
        const SizedBox(width: 7),
        Text('Payment Methods',
            style: GoogleFonts.dmSans(
                fontSize: wide ? 13 : 13, fontWeight: FontWeight.bold, color: _ink)),
      ]),
      SizedBox(height: wide ? 14 : 12),
      _PayRow(
        wide: wide,
        leading: Container(
          padding: EdgeInsets.all(wide ? 10 : 9),
          decoration: BoxDecoration(
              color: _khaltiPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Text('K',
              style: GoogleFonts.dmSans(
                  fontSize: wide ? 13 : 13, fontWeight: FontWeight.bold, color: _khaltiPurple)),
        ),
        title: 'Khalti Payments',
        subtitle: 'Digital wallet',
        amount: khaltiAmt,
        txns: paidTotal,
        amountColor: _khaltiPurple,
      ),
      SizedBox(height: wide ? 12 : 10),
      _PayRow(
        wide: wide,
        leading: Container(
          padding: EdgeInsets.all(wide ? 10 : 9),
          decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.money_rounded, size: 15, color: _green),
        ),
        title: 'Cash Payments',
        subtitle: 'On-site collection',
        amount: cashAmt,
        txns: paidTotal,
        amountColor: _green,
      ),
    ]);
  }
}

class _PayRow extends StatelessWidget {
  final bool wide;
  final Widget leading;
  final String title, subtitle;
  final double amount;
  final int txns;
  final Color amountColor;
  const _PayRow({
    required this.wide, required this.leading, required this.title,
    required this.subtitle, required this.amount, required this.txns, required this.amountColor,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(wide ? 16 : 14),
    decoration: BoxDecoration(
      color: _cardBg,
      borderRadius: BorderRadius.circular(wide ? 16 : 14),
      border: Border.all(color: _divider),
    ),
    child: Row(children: [
      leading,
      SizedBox(width: wide ? 13 : 11),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: GoogleFonts.dmSans(
                fontSize: wide ? 13 : 13, fontWeight: FontWeight.w600, color: _ink)),
        Text(subtitle,
            style: GoogleFonts.dmSans(fontSize: wide ? 11 : 11, color: _muted)),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('Rs. ${amount.toStringAsFixed(0)}',
            style: GoogleFonts.dmSans(
                fontSize: wide ? 13 : 13, fontWeight: FontWeight.bold, color: amountColor)),
        Text('$txns',
            style: GoogleFonts.dmSans(fontSize: wide ? 10 : 10, color: _muted)),
      ]),
    ]),
  );
}