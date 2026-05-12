import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/sqlite_service.dart';
import '../../../data/datasources/quiz_remote_datasource.dart';

class QuizHistoryPage extends StatefulWidget {
  const QuizHistoryPage({super.key});
  @override
  State<QuizHistoryPage> createState() => _QuizHistoryPageState();
}

class _QuizHistoryPageState extends State<QuizHistoryPage> {
  static const ink    = Color(0xFF2D1B10);
  static const accent = Color(0xFFCD6E4E);
  static const bg     = Color(0xFFFAF7F2);
  static const green  = Color(0xFF2E7D52);

  bool loading    = true;
  int  earned     = 0;
  int  usable     = 0;
  int  today      = 0;
  int  remaining  = 3;
  List<Map<String, dynamic>> history = [];

  @override
  void initState() { super.initState(); load(); }

  Future<void> load() async {
    setState(() => loading = true);
    try {
      final cached = await SqliteService().get('user_quiz_points');
      if (mounted) setState(() => usable = int.tryParse(cached ?? '0') ?? 0);
      final res = await QuizRemoteDatasource().getHistory();
      if (res.statusCode == 200 && mounted) {
        final d    = res.data as Map<String, dynamic>;
        final list = (d['history'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map)).toList();
        final sum       = list.fold<int>(0, (s, h) => s + (h['pointsEarned'] as int? ?? 0));
        final apiTotal  = d['totalPoints']  as int? ?? 0;
        final apiUsable = d['usablePoints'] as int? ?? d['remainingPoints'] as int?;
        setState(() {
          history   = list;
          earned    = apiTotal > 0 ? apiTotal : sum;
          usable    = apiUsable ?? usable;
          today     = d['attemptsToday'] as int? ?? 0;
          remaining = d['attemptsLeft']  as int? ?? 3;
        });
        await SqliteService().put('user_quiz_points', usable.toString());
      }
    } catch (e) { debugPrint('$e'); }
    finally { if (mounted) setState(() => loading = false); }
  }

  String fmt(dynamic raw) {
    if (raw == null) return '';
    try {
      final d = DateTime.parse(raw.toString()).toLocal();
      const mo = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${mo[d.month-1]} ${d.day}, ${d.year}  '
          '${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
    } catch (_) { return ''; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18.sp, color: ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Points & History',
            style: GoogleFonts.playfairDisplay(
                fontSize: 20.sp, fontWeight: FontWeight.bold, color: ink)),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(height: 1, color: Colors.grey.shade200)),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        color: accent,
        onRefresh: load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(20.w),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(22.w),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: accent.withValues(alpha: 0.2)),
              ),
              child: Row(children: [
                Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Points Earned',
                          style: GoogleFonts.dmSans(
                              fontSize: 12.sp, color: Colors.grey[500])),
                      SizedBox(height: 6.h),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text('$earned pts',
                            style: GoogleFonts.playfairDisplay(
                                fontSize: 34.sp,
                                fontWeight: FontWeight.bold,
                                color: ink)),
                      ),
                      SizedBox(height: 10.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                              color: accent.withValues(alpha: 0.3)),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.stars_rounded,
                              size: 13.sp, color: accent),
                          SizedBox(width: 6.w),
                          Flexible(
                            child: Text(
                              'Usable: $usable pts  ·  Rs. ${(usable / 2).toStringAsFixed(0)} off',
                              style: GoogleFonts.dmSans(
                                  fontSize: 12.sp, color: ink),
                            ),
                          ),
                        ]),
                      ),
                    ])),
                SizedBox(width: 12.w),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: accent.withValues(alpha: 0.2)),
                  ),
                  child: Icon(Icons.emoji_events_rounded,
                      color: accent, size: 38.sp),
                ),
              ]),
            ),

            SizedBox(height: 16.h),

            Row(children: [
              Expanded(child: _StatCard(
                  label: "Today's", value: '$today/3',
                  icon: Icons.today_rounded, color: accent)),
              SizedBox(width: 10.w),
              Expanded(child: _StatCard(
                  label: 'Remaining', value: '$remaining',
                  icon: Icons.replay_rounded, color: green)),
              SizedBox(width: 10.w),
              Expanded(child: _StatCard(
                  label: 'Total', value: '${history.length}',
                  icon: Icons.history_rounded,
                  color: Colors.grey[500]!)),
            ]),

            SizedBox(height: 16.h),

            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(children: [
                Icon(Icons.info_outline_rounded,
                    size: 16.sp, color: accent),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    '10 pts = Rs. 5 discount at booking  ·  Max 20% off',
                    style: GoogleFonts.dmSans(
                        fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                ),
              ]),
            ),

            SizedBox(height: 24.h),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Quiz History',
                      style: GoogleFonts.dmSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: ink)),
                  Text(
                    '${history.length} attempt${history.length != 1 ? 's' : ''}',
                    style: GoogleFonts.dmSans(
                        fontSize: 12.sp, color: Colors.grey[400]),
                  ),
                ]),

            SizedBox(height: 12.h),

            if (history.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: Column(children: [
                    Icon(Icons.quiz_outlined,
                        size: 56.sp, color: Colors.grey[300]),
                    SizedBox(height: 12.h),
                    Text('No quiz attempts yet',
                        style: GoogleFonts.dmSans(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[400])),
                    SizedBox(height: 6.h),
                    Text('Play the Nepal quiz to earn points!',
                        style: GoogleFonts.dmSans(
                            fontSize: 12.sp,
                            color: Colors.grey[400])),
                  ]),
                ),
              )
            else
              ...List.generate(history.length, (i) {
                final a     = history[i];
                final score = a['score']          as int? ?? 0;
                final total = a['totalQuestions'] as int? ?? 10;
                final pts   = a['pointsEarned']   as int? ?? 0;
                final pct   = total > 0 ? score / total : 0.0;
                final c     = pct >= 0.8 ? green
                    : pct >= 0.5 ? accent
                    : Colors.red[600]!;
                final grade = pct >= 0.8 ? 'Excellent'
                    : pct >= 0.5 ? 'Good'
                    : 'Try again';

                return Container(
                  margin: EdgeInsets.only(bottom: 10.h),
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2))],
                  ),
                  child: Row(children: [
                    Container(
                      width: 52.w, height: 52.w,
                      decoration: BoxDecoration(
                        color: c.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: c.withValues(alpha: 0.25),
                            width: 1.5),
                      ),
                      child: Center(
                        child: FittedBox(
                          child: Padding(
                            padding: EdgeInsets.all(6.w),
                            child: Text('$score/$total',
                                style: GoogleFonts.dmSans(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                    color: c)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Flexible(
                              child: Text('Attempt #${history.length - i}',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: ink),
                                  overflow: TextOverflow.ellipsis),
                            ),
                            SizedBox(width: 6.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 7.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: c.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(grade,
                                  style: GoogleFonts.dmSans(
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.bold,
                                      color: c)),
                            ),
                          ]),
                          SizedBox(height: 4.h),
                          Text(fmt(a['attemptedAt']),
                              style: GoogleFonts.dmSans(
                                  fontSize: 10.sp,
                                  color: Colors.grey[400])),
                        ])),
                    SizedBox(width: 8.w),
                    Column(crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 5.h),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                  color: accent.withValues(alpha: 0.2)),
                            ),
                            child: Text('+$pts pts',
                                style: GoogleFonts.dmSans(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: accent)),
                          ),
                          SizedBox(height: 4.h),
                          Text('Rs. ${(pts / 2).toStringAsFixed(0)}',
                              style: GoogleFonts.dmSans(
                                  fontSize: 10.sp,
                                  color: Colors.grey[400])),
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
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({
    required this.label, required this.value,
    required this.icon,  required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, size: 16.sp, color: color),
      ),
      SizedBox(height: 8.h),
      FittedBox(
        child: Text(value,
            style: GoogleFonts.dmSans(
                fontSize: 15.sp, fontWeight: FontWeight.bold, color: color)),
      ),
      SizedBox(height: 2.h),
      Text(label,
          style: GoogleFonts.dmSans(
              fontSize: 10.sp, color: Colors.grey[500]),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis),
    ]),
  );
}