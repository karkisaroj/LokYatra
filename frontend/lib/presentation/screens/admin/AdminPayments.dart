import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../state_management/Bloc/Booking/booking_bloc.dart';
import '../../state_management/Bloc/Booking/booking_event.dart';
import '../../state_management/Bloc/Booking/booking_state.dart';

class AdminPayments extends StatefulWidget {
  const AdminPayments({super.key});
  @override
  State<AdminPayments> createState() => _AdminPaymentsState();
}

class _AdminPaymentsState extends State<AdminPayments> {
  static const _slate      = Color(0xFF3D5A80);
  static const _terracotta = Color(0xFFCD6E4E);
  static const _bg         = Color(0xFFF4F6F9);

  String _filter = 'All';
  String _status = 'All';
  String _search = '';

  Map<String, dynamic> _inner(Map<String, dynamic> b) =>
      (b['booking'] as Map?)?.cast<String, dynamic>() ?? b;

  String _payMethod(Map<String, dynamic> b) =>
      (_inner(b)['paymentMethod'] ?? 'Cash').toString();

  String _status_(Map<String, dynamic> b) =>
      (_inner(b)['status'] ?? 'Pending').toString();

  double _price(Map<String, dynamic> b) =>
      ((_inner(b)['totalPrice'] ?? _inner(b)['amount'] ?? 0) as num).toDouble();

  String _createdAt(Map<String, dynamic> b) =>
      (_inner(b)['createdAt'] ?? '').toString();

  String _fmtDate(String raw) {
    if (raw.isEmpty) return '—';
    try {
      final d = DateTime.parse(raw).toLocal();
      const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${d.day} ${m[d.month - 1]} ${d.year}';
    } catch (_) { return raw; }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingBloc>().add(const LoadAllBookings());
    });
  }

  List<Map<String, dynamic>> _filtered(List<Map<String, dynamic>> all) {
    return all.where((b) {
      final pay     = _payMethod(b).toLowerCase();
      final stat    = _status_(b);
      final tourist = (b['touristName'] ?? '').toString().toLowerCase();
      final home    = (b['homestayName'] ?? '').toString().toLowerCase();
      final matchPay    = _filter == 'All' || pay.contains(_filter.toLowerCase());
      final matchStatus = _status == 'All' || stat == _status;
      final matchSearch = _search.isEmpty ||
          tourist.contains(_search.toLowerCase()) ||
          home.contains(_search.toLowerCase());
      return matchPay && matchStatus && matchSearch;
    }).toList()
      ..sort((a, b) => _createdAt(b).compareTo(_createdAt(a)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        if (state is BookingLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final all      = state is AllBookingsLoaded ? state.bookings : <Map<String, dynamic>>[];
        final filtered = _filtered(all);

        final totalRevenue = all.fold<double>(0, (s, b) => s + _price(b));
        final khaltiRev    = all.where((b) => _payMethod(b).toLowerCase() == 'khalti')
            .fold<double>(0, (s, b) => s + _price(b));
        final cashRev      = all.where((b) => _payMethod(b).toLowerCase() != 'khalti')
            .fold<double>(0, (s, b) => s + _price(b));
        final completedRev = all.where((b) => _status_(b) == 'Completed')
            .fold<double>(0, (s, b) => s + _price(b));

        return Container(
          color: _bg,
          child: Column(children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: LayoutBuilder(builder: (_, cons) {
                final half = (cons.maxWidth - 10) / 2;
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _StatTile(label: 'Total Revenue',  value: _fmt(totalRevenue), color: _slate,             icon: Icons.payments_rounded,        width: cons.maxWidth),
                    _StatTile(label: 'Khalti',         value: _fmt(khaltiRev),    color: Colors.purple[600]!, icon: Icons.credit_card_rounded,     width: half),
                    _StatTile(label: 'Cash / Arrival', value: _fmt(cashRev),      color: Colors.green[700]!,  icon: Icons.money_rounded,           width: half),
                    _StatTile(label: 'Collected',      value: _fmt(completedRev), color: _terracotta,         icon: Icons.check_circle_rounded,    width: half),
                    _StatTile(label: 'Transactions',   value: '${all.length}',    color: Colors.teal[700]!,   icon: Icons.receipt_long_rounded,    width: half),
                  ],
                );
              }),
            ),


            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: Column(children: [

                SizedBox(
                  height: 42,
                  child: TextField(
                    onChanged: (v) => setState(() => _search = v),
                    style: GoogleFonts.dmSans(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search tourist or homestay…',
                      hintStyle: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey[400]),
                      filled: true, fillColor: _bg,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    _FilterChip(label: 'All Methods', selected: _filter == 'All',    onTap: () => setState(() => _filter = 'All')),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'Khalti', selected: _filter == 'Khalti', color: Colors.purple[600]!, onTap: () => setState(() => _filter = 'Khalti')),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'Cash',   selected: _filter == 'Cash',   color: Colors.green[700]!,  onTap: () => setState(() => _filter = 'Cash')),
                    const SizedBox(width: 16),
                    Container(width: 1, height: 22, color: Colors.grey.shade200),
                    const SizedBox(width: 16),
                    ...['All','Pending','Confirmed','Completed','Cancelled'].map((s) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _FilterChip(
                        label: s == 'All' ? 'All Status' : s,
                        selected: _status == s,
                        color: _statusColor(s),
                        onTap: () => setState(() => _status = s),
                      ),
                    )),
                  ]),
                ),
              ]),
            ),
            const Divider(height: 1),


            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(children: [
                Text('${filtered.length} payment${filtered.length != 1 ? 's' : ''}',
                    style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey[500])),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.read<BookingBloc>().add(const LoadAllBookings()),
                  child: Icon(Icons.refresh_rounded, size: 18, color: _slate),
                ),
              ]),
            ),


            Expanded(
              child: filtered.isEmpty
                  ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.receipt_long_outlined, size: 52, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text('No payments found', style: GoogleFonts.dmSans(fontSize: 15, color: Colors.grey[500])),
              ]))
                  : RefreshIndicator(
                color: _slate,
                onRefresh: () async => context.read<BookingBloc>().add(const LoadAllBookings()),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _PaymentCard(
                    data: filtered[i],
                    inner: _inner,
                    payMethod: _payMethod,
                    status: _status_,
                    price: _price,
                    fmtDate: _fmtDate,
                    createdAt: _createdAt,
                  ),
                ),
              ),
            ),
          ]),
        );
      },
    );
  }

  static String _fmt(double n) {
    if (n >= 1000000) return 'Rs. ${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000)    return 'Rs. ${(n / 1000).toStringAsFixed(1)}K';
    return 'Rs. ${n.toStringAsFixed(0)}';
  }

  Color _statusColor(String s) => switch (s) {
    'Pending'   => Colors.orange[700]!,
    'Confirmed' => Colors.green[600]!,
    'Completed' => Colors.blue[600]!,
    'Cancelled' => Colors.grey[600]!,
    _           => _slate,
  };
}


class _PaymentCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final Map<String, dynamic> Function(Map<String, dynamic>) inner;
  final String Function(Map<String, dynamic>) payMethod;
  final String Function(Map<String, dynamic>) status;
  final double Function(Map<String, dynamic>) price;
  final String Function(String) fmtDate;
  final String Function(Map<String, dynamic>) createdAt;

  static const _dark  = Color(0xFF1A2B3C);

  const _PaymentCard({
    required this.data, required this.inner, required this.payMethod,
    required this.status, required this.price, required this.fmtDate,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    final b        = inner(data);
    final method   = payMethod(data);
    final stat     = status(data);
    final amt      = price(data);
    final date     = fmtDate(createdAt(data));
    final tourist  = (data['touristName']  ?? 'Tourist').toString();
    final homestay = (data['homestayName'] ?? 'Homestay').toString();
    final id       = b['id'] ?? 0;

    final isKhalti    = method.toLowerCase() == 'khalti';
    final methodColor = isKhalti ? Colors.purple[600]! : Colors.green[700]!;

    final (statusColor, statusBg) = switch (stat) {
      'Completed' => (Colors.blue[700]!,   Colors.blue.shade50),
      'Confirmed' => (Colors.green[700]!,  Colors.green.shade50),
      'Pending'   => (Colors.orange[700]!, Colors.orange.shade50),
      'Cancelled' => (Colors.grey[600]!,   Colors.grey.shade100),
      _           => (Colors.red[700]!,    Colors.red.shade50),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Row(children: [
            Icon(Icons.tag_rounded, size: 12, color: Colors.grey[400]),
            const SizedBox(width: 3),
            Text('#$id',  style: GoogleFonts.dmSans(fontSize: 11, color: Colors.grey[500])),
            const SizedBox(width: 8),
            Text(date,    style: GoogleFonts.dmSans(fontSize: 11, color: Colors.grey[400])),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
              child: Text(stat, style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
            ),
          ]),
          const SizedBox(height: 10),
          Divider(height: 1, color: Colors.grey.shade100),
          const SizedBox(height: 10),


          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tourist, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: _dark)),
              const SizedBox(height: 2),
              Row(children: [
                Icon(Icons.home_outlined, size: 12, color: Colors.grey[400]),
                const SizedBox(width: 3),
                Expanded(child: Text(homestay, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(fontSize: 11, color: Colors.grey[500]))),
              ]),
            ])),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: methodColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: methodColor.withValues(alpha: 0.25)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(isKhalti ? Icons.credit_card_rounded : Icons.money_rounded, size: 12, color: methodColor),
                  const SizedBox(width: 4),
                  Text(isKhalti ? 'Khalti' : 'Cash',
                      style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.bold, color: methodColor)),
                ]),
              ),
              const SizedBox(height: 5),
              Text('Rs. ${amt.toStringAsFixed(0)}',
                  style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFFCD6E4E))),
            ]),
          ]),
        ]),
      ),
    );
  }
}


class _StatTile extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  final double width;
  const _StatTile({required this.label, required this.value, required this.color, required this.icon, required this.width});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.dmSans(fontSize: 10, color: Colors.grey[500]),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
              child: Text(value, style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF1A2B3C)))),
        ])),
      ]),
    ),
  );
}


class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap, this.color = const Color(0xFF3D5A80)});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? color : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? color : Colors.grey.shade300),
      ),
      child: Text(label, style: GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        color: selected ? Colors.white : Colors.grey[600],
      )),
    ),
  );
}