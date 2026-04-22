import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../data/datasources/khalti_remote_datasource.dart';

class KhaltiPaymentPage extends StatefulWidget {
  final int    bookingId;
  final double amount;
  final String homestayName;

  const KhaltiPaymentPage({
    super.key,
    required this.bookingId,
    required this.amount,
    required this.homestayName,
  });

  @override
  State<KhaltiPaymentPage> createState() => _KhaltiPaymentPageState();
}

class _KhaltiPaymentPageState extends State<KhaltiPaymentPage> {
  static const _dark       = Color(0xFF2D1B10);
  static const _terracotta = Color(0xFFCD6E4E);
  static const _khaltiPurple = Color(0xFF5C2D91);

  static const _returnHost = 'lokyatra.app';

  WebViewController? _webController;
  bool    _initiating = true;
  bool    _verifying  = false;
  String? _error;
  String? _pidx;

  @override
  void initState() {
    super.initState();
    _initiatePayment();
  }


  Future<void> _initiatePayment() async {
    setState(() { _initiating = true; _error = null; });
    try {
      final res = await KhaltiRemoteDatasource().initiatePayment(widget.bookingId);
      if (!mounted) return;

      if (res.statusCode == 200) {
        final data       = res.data as Map<String, dynamic>;
        final paymentUrl = data['paymentUrl'] as String? ?? '';
        _pidx            = data['pidx']       as String?;

        if (paymentUrl.isEmpty) {
          setState(() { _error = 'No payment URL returned'; _initiating = false; });
          return;
        }
        _setupWebView(paymentUrl);
        setState(() => _initiating = false);
      } else {
        final resData = res.data as Map<String, dynamic>?;
        final message = resData?['message']?.toString() ?? 'Failed (${res.statusCode})';
        final detail  = resData?['detail']?.toString()  ?? '';
        final full    = detail.isNotEmpty
            ? '$message\n\nKhalti says:\n$detail'
            : message;
        debugPrint('=== KHALTI INITIATE ERROR ===\nStatus: ${res.statusCode}\n$full');
        setState(() { _error = full; _initiating = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _error = 'Network error: $e'; _initiating = false; });
    }
  }


  void _setupWebView(String url) {
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (req) {
          final uri = Uri.tryParse(req.url);
          if (uri?.host == _returnHost) {
            _handleReturn(req.url);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        onPageStarted: (url) {
          final uri = Uri.tryParse(url);
          if (uri?.host == _returnHost) _handleReturn(url);
        },
      ))
      ..loadRequest(Uri.parse(url));
  }

  void _handleReturn(String url) {
    final uri           = Uri.tryParse(url);
    final pidxFromUrl   = uri?.queryParameters['pidx'];
    final statusFromUrl = uri?.queryParameters['status'];

    if (statusFromUrl == 'User canceled') {
      _showCancelled();
      return;
    }

    final pidxToVerify = pidxFromUrl ?? _pidx;
    if (pidxToVerify != null) _verifyPayment(pidxToVerify);
  }


  Future<void> _verifyPayment(String pidx) async {
    if (_verifying) return;
    setState(() => _verifying = true);
    try {
      final res = await KhaltiRemoteDatasource().verifyPayment(pidx);
      if (!mounted) return;

      if (res.statusCode == 200) {
        final data = res.data as Map<String, dynamic>;
        _showSuccess(data['totalPaid']);
      } else {
        final msg = (res.data as Map<String, dynamic>?)?['message']
            ?? 'Verification failed (${res.statusCode})';
        setState(() { _error = msg.toString(); _verifying = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _error = 'Verification error: $e'; _verifying = false; });
    }
  }


  void _showSuccess(dynamic amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9), shape: BoxShape.circle),
            child: Icon(Icons.check_rounded, color: Colors.green[700], size: 44.sp),
          ),
          SizedBox(height: 20.h),
          Text('Payment Successful!',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 22.sp, fontWeight: FontWeight.bold, color: _dark)),
          SizedBox(height: 8.h),
          Text('Rs. ${(amount as num?)?.toStringAsFixed(0) ?? widget.amount.toStringAsFixed(0)}',
              style: GoogleFonts.dmSans(
                  fontSize: 22.sp, fontWeight: FontWeight.w800,
                  color: Colors.green[700])),
          SizedBox(height: 4.h),
          Text('paid via Khalti for\n${widget.homestayName}',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(fontSize: 13.sp, color: Colors.grey[600])),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, true); // return paid=true to bookings page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
              child: Text('Back to Bookings',
                  style: GoogleFonts.dmSans(fontWeight: FontWeight.bold,
                      fontSize: 15.sp)),
            ),
          ),
        ]),
      ),
    );
  }

  void _showCancelled() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Payment cancelled.', style: GoogleFonts.dmSans()),
      backgroundColor: Colors.orange[700],
      behavior: SnackBarBehavior.floating,
    ));
    Navigator.pop(context, false);
  }

  void _confirmCancel() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Cancel Payment?',
            style: GoogleFonts.playfairDisplay(
                fontSize: 18.sp, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to cancel this payment?',
            style: GoogleFonts.dmSans(fontSize: 13.sp, color: Colors.grey[600])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Continue Paying',
                style: GoogleFonts.dmSans(
                    color: _khaltiPurple, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, false);
            },
            child: Text('Cancel',
                style: GoogleFonts.dmSans(color: Colors.grey[600])),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: _dark, size: 22.sp),
          onPressed: _confirmCancel,
        ),
        title: Row(children: [
          Container(
            width: 28.w, height: 28.h,
            decoration: BoxDecoration(
              color: _khaltiPurple,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Center(child: Text('K',
                style: GoogleFonts.dmSans(
                    fontSize: 14.sp, fontWeight: FontWeight.bold,
                    color: Colors.white))),
          ),
          SizedBox(width: 10.w),
          Text('Khalti Payment',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 18.sp, fontWeight: FontWeight.bold, color: _dark)),
        ]),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: Stack(children: [

        if (_initiating)
          Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircularProgressIndicator(color: _khaltiPurple),
            SizedBox(height: 16.h),
            Text('Connecting to Khalti…',
                style: GoogleFonts.dmSans(fontSize: 14.sp, color: Colors.grey[600])),
          ])),

        if (_error != null && !_initiating && !_verifying)
          Center(child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.error_outline, size: 56.sp, color: Colors.red[300]),
              SizedBox(height: 16.h),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                      fontSize: 14.sp, color: Colors.grey[600])),
              SizedBox(height: 20.h),
              ElevatedButton.icon(
                icon: const Icon(Icons.replay_rounded),
                label: Text('Try Again', style: GoogleFonts.dmSans()),
                onPressed: _initiatePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _terracotta,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                ),
              ),
            ]),
          )),

        if (!_initiating && _error == null && _webController != null)
          WebViewWidget(controller: _webController!),

        if (_verifying)
          Container(
            color: Colors.black54,
            child: Center(child: Container(
              margin: EdgeInsets.symmetric(horizontal: 40.w),
              padding: EdgeInsets.all(28.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                CircularProgressIndicator(color: _khaltiPurple),
                SizedBox(height: 16.h),
                Text('Verifying payment…',
                    style: GoogleFonts.dmSans(
                        fontSize: 14.sp, fontWeight: FontWeight.w600)),
                SizedBox(height: 4.h),
                Text('Please wait',
                    style: GoogleFonts.dmSans(
                        fontSize: 12.sp, color: Colors.grey[500])),
              ]),
            )),
          ),

      ]),
    );
  }
}