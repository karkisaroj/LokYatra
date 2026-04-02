import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/services/sqlite_service.dart';
import 'package:lokyatra_frontend/presentation/screens/TouristScreen/QuizHistoryPage.dart';
import '../../../data/datasources/quiz_remote_datasource.dart';

enum Phase { loading, offline, error, home, playing, results }

class TouristQuizPage extends StatefulWidget {
  const TouristQuizPage({super.key});
  @override
  State<TouristQuizPage> createState() => _TouristQuizPageState();
}

class _TouristQuizPageState extends State<TouristQuizPage> {
  static const ink    = Color(0xFF2D1B10);
  static const accent = Color(0xFFCD6E4E);
  static const bg     = Color(0xFFFAF7F2);
  static const green  = Color(0xFF2E7D52);

  Phase phase        = Phase.loading;
  int   totalPoints  = 0;
  int   attToday     = 0;
  int   attLeft      = 3;
  List<Map<String, dynamic>> recent = [];

  List<Map<String, dynamic>> questions = [];
  int    current  = 0;
  int    timeLeft = 20;
  Timer? timer;
  final  Map<int, int> answers = {};

  Map<String, dynamic>? result;
  String? error;

  @override
  void initState() { super.initState(); loadHome(); }

  @override
  void dispose() { timer?.cancel(); super.dispose(); }

  Future<void> loadHome() async {
    setState(() { phase = Phase.loading; error = null; });
    final online = await SqliteService().isOnline();
    if (!online) {
      if (mounted) setState(() => phase = Phase.offline);
      return;
    }
    try {
      final res = await QuizRemoteDatasource().getHistory();
      if (!mounted) return;
      if (res.statusCode == 200) {
        final d = res.data as Map<String, dynamic>;
        setState(() {
          final list = (d['history'] as List? ?? [])
              .map((e) => Map<String, dynamic>.from(e as Map)).toList();
          final apiTotal = d['totalPoints'] as int? ?? 0;
          final sumFromHistory = list.fold<int>(0, (s, h) => s + (h['pointsEarned'] as int? ?? 0));

          totalPoints = apiTotal > 0 ? apiTotal : sumFromHistory;
          attToday    = d['attemptsToday'] as int? ?? 0;
          attLeft     = d['attemptsLeft']  as int? ?? 3;
          recent      = list;
          phase       = Phase.home;
        });
      } else {
        setState(() { error = 'Could not load quiz'; phase = Phase.error; });
      }
    } catch (e) {
      if (mounted) setState(() { error = 'Network error: $e'; phase = Phase.error; });
    }
  }

  Future<void> startQuiz() async {
    final online = await SqliteService().isOnline();
    if (!online) {
      if (mounted) setState(() => phase = Phase.offline);
      return;
    }
    setState(() { phase = Phase.loading; error = null; });
    try {
      final res = await QuizRemoteDatasource().getQuiz();
      if (!mounted) return;
      if (res.statusCode == 200) {
        final d = res.data as Map<String, dynamic>;
        questions = (d['questions'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map)).toList();
        current = 0;
        answers.clear();
        setState(() => phase = Phase.playing);
        startTimer();
      } else {
        final msg = (res.data as Map?)?['message'] ?? 'Cannot start quiz';
        setState(() { error = msg.toString(); phase = Phase.error; });
      }
    } catch (e) {
      if (mounted) setState(() { error = 'Error: $e'; phase = Phase.error; });
    }
  }

  void startTimer() {
    timer?.cancel();
    timeLeft = 20;
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => timeLeft--);
      if (timeLeft <= 0) nextQ();
    });
  }

  void nextQ() {
    timer?.cancel();
    if (current < questions.length - 1) {
      setState(() => current++);
      startTimer();
    } else {
      submitAnswers();
    }
  }

  void pick(int idx) {
    final qId = questions[current]['id'] as int;
    if (answers.containsKey(qId)) return;
    setState(() => answers[qId] = idx);
    Future.delayed(const Duration(milliseconds: 600), nextQ);
  }

  Future<void> submitAnswers() async {
    setState(() => phase = Phase.loading);
    try {
      final payload = questions.map((q) =>
      {'questionId': q['id'] as int, 'selectedIndex': answers[q['id'] as int] ?? -1}
      ).toList();
      final res = await QuizRemoteDatasource().submitQuiz(payload);
      if (!mounted) return;
      if (res.statusCode == 200) {
        result = Map<String, dynamic>.from(res.data as Map);
        await SqliteService().put(
            'user_quiz_points', '${result!['totalPoints'] ?? 0}');
        setState(() => phase = Phase.results);
      } else {
        final msg = (res.data as Map?)?['message'] ?? 'Submission failed';
        setState(() { error = msg.toString(); phase = Phase.error; });
      }
    } catch (e) {
      if (mounted) setState(() { error = 'Error: $e'; phase = Phase.error; });
    }
  }

  String fmtDate(dynamic raw) {
    if (raw == null) return '';
    try {
      final d = DateTime.parse(raw.toString()).toLocal();
      const mo = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${mo[d.month-1]} ${d.day}, ${d.year}';
    } catch (_) { return ''; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Nepal Quiz',
            style: GoogleFonts.playfairDisplay(
                fontSize: 20.sp, fontWeight: FontWeight.bold, color: ink)),
        actions: [
          if (phase == Phase.home)
            Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: TextButton.icon(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const QuizHistoryPage())),
                icon: Icon(Icons.history_rounded, size: 16.sp, color: accent),
                label: Text('History',
                    style: GoogleFonts.dmSans(
                        fontSize: 13.sp,
                        color: accent,
                        fontWeight: FontWeight.w600)),
              ),
            ),
        ],
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(height: 1, color: Colors.grey.shade200)),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        child: switch (phase) {
          Phase.loading => const Center(child: CircularProgressIndicator()),
          Phase.offline => buildOffline(),
          Phase.error   => buildError(),
          Phase.home    => buildHome(),
          Phase.playing => buildPlaying(),
          Phase.results => buildResults(),
        },
      ),
    );
  }

  Widget buildOffline() => Center(
    key: const ValueKey('offline'),
    child: Padding(
      padding: EdgeInsets.all(32.w),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
              color: Colors.grey.shade100, shape: BoxShape.circle),
          child: Icon(Icons.wifi_off_rounded, size: 52.sp, color: Colors.grey[500]),
        ),
        SizedBox(height: 24.h),
        Text('No Internet Connection',
            style: GoogleFonts.playfairDisplay(
                fontSize: 22.sp, fontWeight: FontWeight.bold, color: ink)),
        SizedBox(height: 12.h),
        Text(
          'The quiz requires an internet connection to load questions and save your points.',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
              fontSize: 14.sp, color: Colors.grey[500], height: 1.5),
        ),
        SizedBox(height: 28.h),
        SizedBox(
          width: double.infinity, height: 48.h,
          child: ElevatedButton.icon(
            icon: Icon(Icons.refresh_rounded, size: 18.sp),
            label: Text('Try Again',
                style: GoogleFonts.dmSans(
                    fontSize: 14.sp, fontWeight: FontWeight.bold)),
            onPressed: loadHome,
            style: ElevatedButton.styleFrom(
              backgroundColor: accent, foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r)),
            ),
          ),
        ),
      ]),
    ),
  );

  Widget buildError() => Center(
    key: const ValueKey('error'),
    child: Padding(
      padding: EdgeInsets.all(28.w),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.error_outline, size: 56.sp, color: Colors.red[300]),
        SizedBox(height: 12.h),
        Text(error ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
                fontSize: 14.sp, color: Colors.grey[500])),
        SizedBox(height: 20.h),
        ElevatedButton(
          onPressed: loadHome,
          style: ElevatedButton.styleFrom(
            backgroundColor: accent, foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r)),
          ),
          child: Text('Try Again',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
        ),
      ]),
    ),
  );

  Widget buildHome() {
    final canPlay = attLeft > 0;
    return SingleChildScrollView(
      key: const ValueKey('home'),
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
                  Text('Your Points',
                      style: GoogleFonts.dmSans(
                          fontSize: 12.sp, color: Colors.grey[500])),
                  SizedBox(height: 4.h),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text('$totalPoints pts',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                            color: ink)),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Rs. ${(totalPoints / 2).toStringAsFixed(0)} booking discount',
                    style: GoogleFonts.dmSans(
                        fontSize: 12.sp, color: Colors.grey[500]),
                  ),
                ])),
            SizedBox(width: 12.w),
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: accent.withValues(alpha: 0.2)),
              ),
              child: Icon(Icons.emoji_events_rounded,
                  color: accent, size: 36.sp),
            ),
          ]),
        ),

        SizedBox(height: 14.h),

        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Daily Attempts',
                      style: GoogleFonts.dmSans(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: ink)),
                  Text('$attToday / 3 used',
                      style: GoogleFonts.dmSans(
                          fontSize: 12.sp, color: Colors.grey[400])),
                ]),
            SizedBox(height: 10.h),
            Row(children: List.generate(3, (i) => Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 2 ? 6.w : 0),
                height: 7.h,
                decoration: BoxDecoration(
                  color: i < attToday
                      ? Colors.red[200]
                      : green.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ))),
            SizedBox(height: 10.h),
            Row(children: [
              Icon(
                canPlay
                    ? Icons.check_circle_rounded
                    : Icons.do_not_disturb_rounded,
                size: 14.sp,
                color: canPlay ? green : Colors.red[400],
              ),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  canPlay
                      ? '$attLeft attempt${attLeft > 1 ? 's' : ''} remaining today'
                      : 'All attempts used — come back tomorrow!',
                  style: GoogleFonts.dmSans(
                      fontSize: 12.sp,
                      color: canPlay ? green : Colors.red[400],
                      fontWeight: FontWeight.w500),
                ),
              ),
            ]),
          ]),
        ),

        SizedBox(height: 14.h),

        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('How it works',
                    style: GoogleFonts.dmSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: ink)),
                SizedBox(height: 8.h),
                for (final s in [
                  '10 random Nepal questions per quiz',
                  '20 seconds to answer each question',
                  '10 points for every correct answer',
                  '3 attempts per day maximum',
                  '10 pts = Rs. 5 off at booking (max 20%)',
                ]) _Bullet(s),
              ]),
        ),

        SizedBox(height: 20.h),

        SizedBox(
          width: double.infinity, height: 52.h,
          child: ElevatedButton.icon(
            icon: Icon(
              canPlay ? Icons.play_arrow_rounded : Icons.lock_clock_rounded,
              size: 22.sp,
            ),
            label: Text(
              canPlay ? 'Start Quiz' : 'Come Back Tomorrow',
              style: GoogleFonts.dmSans(
                  fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            onPressed: canPlay ? startQuiz : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[200],
              disabledForegroundColor: Colors.grey[400],
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r)),
            ),
          ),
        ),

        if (recent.isNotEmpty) ...[
          SizedBox(height: 28.h),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Attempts',
                    style: GoogleFonts.dmSans(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: ink)),
                TextButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const QuizHistoryPage())),
                  child: Text('View all',
                      style: GoogleFonts.dmSans(
                          fontSize: 12.sp,
                          color: accent,
                          fontWeight: FontWeight.w600)),
                ),
              ]),
          SizedBox(height: 8.h),
          ...recent.take(3).map((a) {
            final score = a['score']          as int? ?? 0;
            final total = a['totalQuestions'] as int? ?? 10;
            final pts = a['pointsEarned']   as int? ?? 0;
            final pct= total > 0 ? score / total : 0.0;
            final c= pct >= 0.7 ? green : accent;
            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(children: [
                Container(
                  width: 44.w, height: 44.w,
                  decoration: BoxDecoration(
                    color: c.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(color: c.withValues(alpha: 0.2)),
                  ),
                  child: Center(child: FittedBox(
                    child: Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Text('$score/$total',
                          style: GoogleFonts.dmSans(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: c)),
                    ),
                  )),
                ),
                SizedBox(width: 12.w),
                Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$score correct out of $total',
                          style: GoogleFonts.dmSans(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: ink)),
                      Text(fmtDate(a['attemptedAt']),
                          style: GoogleFonts.dmSans(
                              fontSize: 11.sp,
                              color: Colors.grey[400])),
                    ])),
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
              ]),
            );
          }),
        ],

        SizedBox(height: 20.h),
      ]),
    );
  }

  Widget buildPlaying() {
    if (questions.isEmpty) return const SizedBox.shrink();
    final q      = questions[current];
    final qId    = q['id'] as int;
    final opts   = (q['options'] as List? ?? []).map((o) => o.toString()).toList();
    final picked = answers[qId];
    final urgent = timeLeft <= 5;

    return Column(
      key: ValueKey('playing-$current'),
      children: [
        Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 14.h),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Question ${current + 1} of ${questions.length}',
                      style: GoogleFonts.dmSans(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: ink)),
                  Container(
                    width: 40.w, height: 40.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: urgent
                          ? Colors.red.withValues(alpha: 0.08)
                          : accent.withValues(alpha: 0.08),
                    ),
                    child: Center(child: Text('$timeLeft',
                        style: GoogleFonts.dmSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: urgent ? Colors.red[600] : accent))),
                  ),
                ]),
            SizedBox(height: 10.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: (current + 1) / questions.length,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(accent),
                minHeight: 5.h,
              ),
            ),
            SizedBox(height: 4.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: timeLeft / 20.0,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(
                    urgent ? Colors.red[400]! : accent),
                minHeight: 4.h,
              ),
            ),
          ]),
        ),

        Expanded(child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((q['category'] ?? '').toString().isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(q['category'].toString(),
                        style: GoogleFonts.dmSans(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: accent)),
                  ),

                Text(q['question'].toString(),
                    style: GoogleFonts.dmSans(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        color: ink,
                        height: 1.4)),

                SizedBox(height: 24.h),

                ...List.generate(opts.length, (i) {
                  final sel = picked == i;
                  return GestureDetector(
                    onTap: picked == null ? () => pick(i) : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(bottom: 10.h),
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: sel
                            ? accent.withValues(alpha: 0.06)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: sel ? accent : Colors.grey.shade200,
                          width: sel ? 1.5 : 1,
                        ),
                      ),
                      child: Row(children: [
                        Container(
                          width: 30.w, height: 30.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: sel
                                ? accent
                                : accent.withValues(alpha: 0.08),
                          ),
                          child: Center(child: Text(
                            String.fromCharCode(65 + i),
                            style: GoogleFonts.dmSans(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: sel ? Colors.white : accent),
                          )),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(child: Text(opts[i],
                            style: GoogleFonts.dmSans(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: ink))),
                      ]),
                    ),
                  );
                }),

                if (picked == null)
                  Center(child: TextButton(
                    onPressed: nextQ,
                    child: Text('Skip →',
                        style: GoogleFonts.dmSans(
                            fontSize: 13.sp,
                            color: Colors.grey[400])),
                  )),
              ]),
        )),
      ],
    );
  }

  Widget buildResults() {
    if (result == null) return const SizedBox.shrink();
    final score  = result!['score'] as int? ?? 0;
    final total  = result!['total'] as int? ?? 10;
    final pts    = result!['pointsEarned'] as int? ?? 0;
    final allPts = result!['totalPoints'] as int? ?? 0;
    final left   = result!['attemptsLeft'] as int? ?? 0;
    final list   = (result!['results'] as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map)).toList();
    final pct  = total > 0 ? score / total : 0.0;
    final c    = pct >= 0.8 ? green : pct >= 0.5 ? accent : Colors.red[600]!;
    final msg  = pct >= 0.8 ? 'Excellent!'
        : pct >= 0.5 ? 'Good job! '
        : 'Keep trying!';

    return SingleChildScrollView(
      key: const ValueKey('results'),
      padding: EdgeInsets.all(20.w),
      child: Column(children: [

        Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: c.withValues(alpha: 0.2)),
          ),
          child: Column(children: [
            Text(msg,
                style: GoogleFonts.playfairDisplay(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: c)),
            SizedBox(height: 16.h),
            IntrinsicHeight(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _Stat('$score/$total', 'Score', c),
                    VerticalDivider(color: Colors.grey.shade300),
                    _Stat('+$pts', 'Points', accent),
                    VerticalDivider(color: Colors.grey.shade300),
                    _Stat('$allPts', 'Total', ink),
                  ]),
            ),
          ]),
        ),

        if (pts > 0) ...[
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: green.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: green.withValues(alpha: 0.2)),
            ),
            child: Row(children: [
              Icon(Icons.check_circle_outline_rounded,
                  size: 16.sp, color: green),
              SizedBox(width: 8.w),
              Expanded(child: Text(
                '+$pts pts added! 10 pts = Rs. 5 off at booking.',
                style: GoogleFonts.dmSans(
                    fontSize: 12.sp, color: green),
              )),
            ]),
          ),
        ],

        SizedBox(height: 20.h),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Answer Review',
              style: GoogleFonts.dmSans(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: ink)),
          Text('$score/$total correct',
              style: GoogleFonts.dmSans(
                  fontSize: 12.sp, color: Colors.grey[400])),
        ]),
        SizedBox(height: 10.h),

        ...list.asMap().entries.map((entry) {
          final i       = entry.key;
          final r       = entry.value;
          final ok      = r['isCorrect']     as bool? ?? false;
          final opts    = (r['options'] as List? ?? [])
              .map((o) => o.toString()).toList();
          final selIdx  = r['selectedIndex'] as int? ?? -1;
          final corrIdx = r['correctIndex']  as int? ?? 0;

          return Container(
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: ok
                    ? green.withValues(alpha: 0.3)
                    : Colors.red.withValues(alpha: 0.25),
              ),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(
                      ok ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      size: 15.sp,
                      color: ok ? green : Colors.red[400],
                    ),
                    SizedBox(width: 6.w),
                    Text('Q${i + 1}',
                        style: GoogleFonts.dmSans(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[400])),
                  ]),
                  SizedBox(height: 6.h),
                  Text(r['question'].toString(),
                      style: GoogleFonts.dmSans(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: ink)),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: green.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: green.withValues(alpha: 0.2)),
                    ),
                    child: Row(children: [
                      Icon(Icons.check_rounded, size: 13.sp, color: green),
                      SizedBox(width: 6.w),
                      Expanded(child: Text(
                        'Correct: ${opts.isNotEmpty ? opts[corrIdx] : ''}',
                        style: GoogleFonts.dmSans(
                            fontSize: 12.sp,
                            color: green,
                            fontWeight: FontWeight.w600),
                      )),
                    ]),
                  ),
                  if (!ok && selIdx >= 0 && selIdx < opts.length) ...[
                    SizedBox(height: 6.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                            color: Colors.red.withValues(alpha: 0.2)),
                      ),
                      child: Row(children: [
                        Icon(Icons.close_rounded,
                            size: 13.sp, color: Colors.red[400]),
                        SizedBox(width: 6.w),
                        Expanded(child: Text(
                          'You chose: ${opts[selIdx]}',
                          style: GoogleFonts.dmSans(
                              fontSize: 12.sp, color: Colors.red[400]),
                        )),
                      ]),
                    ),
                  ],
                  if (!ok && selIdx == -1) ...[
                    SizedBox(height: 4.h),
                    Text('Skipped',
                        style: GoogleFonts.dmSans(
                            fontSize: 12.sp, color: Colors.grey[400])),
                  ],
                ]),
          );
        }),

        SizedBox(height: 20.h),
        Row(children: [
          if (left > 0) ...[
            Expanded(child: ElevatedButton.icon(
              icon: Icon(Icons.replay_rounded, size: 18.sp),
              label: Text('Play Again ($left left)',
                  style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
              onPressed: startQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent, foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r)),
              ),
            )),
            SizedBox(width: 10.w),
          ],
          Expanded(child: OutlinedButton.icon(
            icon: Icon(Icons.done_rounded, size: 18.sp),
            label: Text('Done',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
            onPressed: () { timer?.cancel(); loadHome(); },
            style: OutlinedButton.styleFrom(
              foregroundColor: accent,
              side: BorderSide(color: accent.withValues(alpha: 0.5)),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r)),
            ),
          )),
        ]),
        SizedBox(height: 20.h),
      ]),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: 5.h),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: EdgeInsets.only(top: 5.h, right: 8.w),
        child: Container(
          width: 4, height: 4,
          decoration: const BoxDecoration(
              color: Color(0xFFCD6E4E), shape: BoxShape.circle),
        ),
      ),
      Expanded(child: Text(text,
          style: GoogleFonts.dmSans(
              fontSize: 12.sp, color: Color(0xFF2D1B10)))),
    ]),
  );
}

class _Stat extends StatelessWidget {
  final String value, label;
  final Color color;
  const _Stat(this.value, this.label, this.color);
  @override
  Widget build(BuildContext context) => Column(children: [
    FittedBox(
      child: Text(value,
          style: GoogleFonts.dmSans(
              fontSize: 20.sp, fontWeight: FontWeight.bold, color: color)),
    ),
    Text(label,
        style: GoogleFonts.dmSans(
            fontSize: 10.sp, color: Colors.grey[500])),
  ]);
}