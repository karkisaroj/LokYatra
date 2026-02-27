import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/datasources/quiz_remote_datasource.dart';

class QuizHistoryPage extends StatefulWidget {
  const QuizHistoryPage({super.key});

  @override
  State<QuizHistoryPage> createState() => _QuizHistoryPageState();
}

class _QuizHistoryPageState extends State<QuizHistoryPage> {
  static const _brown     = Color(0xFF8B5E3C);
  static const _cream     = Color(0xFFFAF7F2);
  static const _dark      = Color(0xFF2D1B10);
  static const _terracotta = Color(0xFFCD6E4E);

  bool _loading = true;
  int  _totalPoints   = 0;
  int  _attemptsToday = 0;
  int  _attemptsLeft  = 3;
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await QuizRemoteDatasource().getHistory();
      if (res.statusCode == 200 && mounted) {
        final d = res.data as Map<String, dynamic>;
        setState(() {
          _totalPoints   = d['totalPoints']   as int? ?? 0;
          _attemptsToday = d['attemptsToday'] as int? ?? 0;
          _attemptsLeft  = d['attemptsLeft']  as int? ?? 3;
          _history       = (d['history'] as List? ?? [])
              .map((e) => Map<String, dynamic>.from(e as Map)).toList();
        });
      }
    } catch (e) {
      debugPrint('Quiz history error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _fmtDate(dynamic raw) {
    if (raw == null) return '';
    try {
      final d = DateTime.parse(raw.toString()).toLocal();
      const m = ['Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${m[d.month-1]} ${d.day}, ${d.year}  '
          '${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
    } catch (_) { return ''; }
  }

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
        title: Text('Points & Quiz History',
            style: GoogleFonts.playfairDisplay(
                fontSize: 20.sp, fontWeight: FontWeight.bold, color: _dark)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        color: _brown,
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(20.w),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Total points banner
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5E3C), Color(0xFFCD6E4E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(children: [
                    Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Points Earned',
                              style: GoogleFonts.dmSans(
                                  fontSize: 13.sp, color: Colors.white70)),
                          SizedBox(height: 6.h),
                          Text('$_totalPoints pts',
                              style: GoogleFonts.playfairDisplay(
                                  fontSize: 36.sp, fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          SizedBox(height: 6.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 5.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              '≈ Rs. ${(_totalPoints / 2).toStringAsFixed(0)} discount value',
                              style: GoogleFonts.dmSans(
                                  fontSize: 12.sp, color: Colors.white),
                            ),
                          ),
                        ])),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.emoji_events_rounded,
                          color: Colors.amber[300], size: 44.sp),
                    ),
                  ]),
                ),

                SizedBox(height: 16.h),

                // Stats row
                Row(children: [
                  Expanded(child: _StatCard(
                    label: 'Today\'s Attempts',
                    value: '$_attemptsToday / 3',
                    icon: Icons.today_rounded,
                    color: _terracotta,
                  )),
                  SizedBox(width: 12.w),
                  Expanded(child: _StatCard(
                    label: 'Attempts Left',
                    value: '$_attemptsLeft',
                    icon: Icons.replay_rounded,
                    color: Colors.green[700]!,
                  )),
                  SizedBox(width: 12.w),
                  Expanded(child: _StatCard(
                    label: 'Total Attempts',
                    value: '${_history.length}',
                    icon: Icons.history_rounded,
                    color: Colors.blue[700]!,
                  )),
                ]),

                SizedBox(height: 16.h),

                // Redemption info card
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(children: [
                    Icon(Icons.lightbulb_outline_rounded,
                        size: 18.sp, color: Colors.amber[700]),
                    SizedBox(width: 10.w),
                    Expanded(child: Text(
                      '10 pts = Rs. 5 discount at booking · Max 20% off per booking',
                      style: GoogleFonts.dmSans(
                          fontSize: 12.sp, color: Colors.amber[900]),
                    )),
                  ]),
                ),

                SizedBox(height: 24.h),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Quiz History',
                          style: GoogleFonts.dmSans(fontSize: 16.sp,
                              fontWeight: FontWeight.bold, color: _dark)),
                      Text('${_history.length} attempt${_history.length != 1 ? 's' : ''}',
                          style: GoogleFonts.dmSans(
                              fontSize: 12.sp, color: Colors.grey[500])),
                    ]),

                SizedBox(height: 12.h),

                if (_history.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.h),
                      child: Column(children: [
                        Icon(Icons.quiz_outlined,
                            size: 56.sp, color: Colors.grey[300]),
                        SizedBox(height: 12.h),
                        Text('No quiz attempts yet',
                            style: GoogleFonts.dmSans(fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[400])),
                        SizedBox(height: 6.h),
                        Text('Play the Nepal quiz to earn points!',
                            style: GoogleFonts.dmSans(
                                fontSize: 12.sp, color: Colors.grey[400])),
                      ]),
                    ),
                  )
                else
                  ..._history.asMap().entries.map((entry) {
                    final i   = entry.key;
                    final a   = entry.value;
                    final score = a['score']          as int? ?? 0;
                    final total = a['totalQuestions'] as int? ?? 10;
                    final pts   = a['pointsEarned']   as int? ?? 0;
                    final pct   = total > 0 ? score / total : 0.0;

                    final Color chipColor;
                    final String grade;
                    if (pct >= 0.8) {
                      chipColor = Colors.green; grade = 'Excellent';
                    } else if (pct >= 0.5) {
                      chipColor = Colors.orange; grade = 'Good';
                    } else {
                      chipColor = Colors.red; grade = 'Try again';
                    }

                    return Container(
                      margin: EdgeInsets.only(bottom: 10.h),
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Row(children: [
                        Container(
                          width: 50.w, height: 50.h,
                          decoration: BoxDecoration(
                            color: chipColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(child: Text(
                            '$score/$total',
                            style: GoogleFonts.dmSans(
                              fontSize: 13.sp, fontWeight: FontWeight.bold,
                              color: chipColor,
                            ),
                          )),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Text('Attempt #${_history.length - i}',
                                    style: GoogleFonts.dmSans(
                                        fontSize: 13.sp, fontWeight: FontWeight.w600,
                                        color: _dark)),
                                SizedBox(width: 8.w),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: chipColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Text(grade,
                                      style: GoogleFonts.dmSans(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold,
                                          color: chipColor)),
                                ),
                              ]),
                              SizedBox(height: 3.h),
                              Text(_fmtDate(a['attemptedAt']),
                                  style: GoogleFonts.dmSans(
                                      fontSize: 11.sp, color: Colors.grey[500])),
                            ])),
                        Column(crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 5.h),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(color: Colors.amber.shade200),
                                ),
                                child: Text('+$pts pts',
                                    style: GoogleFonts.dmSans(
                                        fontSize: 12.sp, fontWeight: FontWeight.bold,
                                        color: Colors.amber[800])),
                              ),
                              SizedBox(height: 4.h),
                              Text('Rs. ${(pts / 2).toStringAsFixed(0)} value',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 10.sp, color: Colors.grey[400])),
                            ]),
                      ]),
                    );
                  }),

                SizedBox(height: 20.h),
              ]),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({
    required this.label, required this.value,
    required this.icon,  required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(14.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Column(children: [
      Icon(icon, size: 22.sp, color: color),
      SizedBox(height: 6.h),
      Text(value, style: GoogleFonts.dmSans(
          fontSize: 16.sp, fontWeight: FontWeight.bold, color: color)),
      SizedBox(height: 2.h),
      Text(label, style: GoogleFonts.dmSans(
          fontSize: 10.sp, color: Colors.grey[500]),
          textAlign: TextAlign.center),
    ]),
  );
}