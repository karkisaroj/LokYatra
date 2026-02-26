// lib/presentation/screens/TouristScreen/QuizPage.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/services/sqlite_service.dart';
import '../../../data/datasources/quiz_remote_datasource.dart';

enum _QuizPhase { loading, error, home, playing, results }

class TouristQuizPage extends StatefulWidget {
  const TouristQuizPage({super.key});
  @override
  State<TouristQuizPage> createState() => _TouristQuizPageState();
}

class _TouristQuizPageState extends State<TouristQuizPage> {
  static const _brown = Color(0xFF8B5E3C);
  static const _cream = Color(0xFFFAF7F2);
  static const _dark  = Color(0xFF2D1B10);
  static const _gold  = Color(0xFFF5A623);

  _QuizPhase _phase = _QuizPhase.loading;

  // Home data
  int  _totalPoints   = 0;
  int  _attemptsToday = 0;
  int  _attemptsLeft  = 3;
  List<Map<String, dynamic>> _history = [];

  // Playing
  List<Map<String, dynamic>> _questions = [];
  int    _current   = 0;
  int    _timeLeft  = 20;
  Timer? _timer;
  final  Map<int, int> _answers = {};

  // Results
  Map<String, dynamic>? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() { _phase = _QuizPhase.loading; _error = null; });
    try {
      final res = await QuizRemoteDatasource().getHistory();
      if (!mounted) return;
      if (res.statusCode == 200) {
        final d = res.data as Map<String, dynamic>;
        setState(() {
          _totalPoints   = d['totalPoints']   as int? ?? 0;
          _attemptsToday = d['attemptsToday'] as int? ?? 0;
          _attemptsLeft  = d['attemptsLeft']  as int? ?? 3;
          _history       = (d['history'] as List? ?? [])
              .map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _phase = _QuizPhase.home;
        });
      } else {
        setState(() { _error = 'Could not load quiz'; _phase = _QuizPhase.error; });
      }
    } catch (e) {
      if (mounted) setState(() { _error = 'Network error: $e'; _phase = _QuizPhase.error; });
    }
  }

  Future<void> _startQuiz() async {
    setState(() { _phase = _QuizPhase.loading; _error = null; });
    try {
      final res = await QuizRemoteDatasource().getQuiz();
      if (!mounted) return;
      if (res.statusCode == 200) {
        final d = res.data as Map<String, dynamic>;
        _questions = (d['questions'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map)).toList();
        _current = 0;
        _answers.clear();
        setState(() => _phase = _QuizPhase.playing);
        _startTimer();
      } else {
        final msg = (res.data as Map?)?['message'] ?? 'Cannot start quiz';
        setState(() { _error = msg.toString(); _phase = _QuizPhase.error; });
      }
    } catch (e) {
      if (mounted) setState(() { _error = 'Error: $e'; _phase = _QuizPhase.error; });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 20;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) _nextQuestion();
    });
  }

  void _nextQuestion() {
    _timer?.cancel();
    if (_current < _questions.length - 1) {
      setState(() => _current++);
      _startTimer();
    } else {
      _submitAnswers();
    }
  }

  void _selectAnswer(int idx) {
    final qId = _questions[_current]['id'] as int;
    if (_answers.containsKey(qId)) return;
    setState(() => _answers[qId] = idx);
    Future.delayed(const Duration(milliseconds: 600), _nextQuestion);
  }

  Future<void> _submitAnswers() async {
    setState(() => _phase = _QuizPhase.loading);
    try {
      final payload = _questions.map((q) {
        final qId    = q['id'] as int;
        final selIdx = _answers[qId] ?? -1;
        return {'questionId': qId, 'selectedIndex': selIdx};
      }).toList();

      final res = await QuizRemoteDatasource().submitQuiz(payload);
      if (!mounted) return;

      if (res.statusCode == 200) {
        _result = Map<String, dynamic>.from(res.data as Map);
        final pts = _result!['totalPoints'] as int? ?? 0;
        await SqliteService().put('user_quiz_points', pts.toString());
        setState(() => _phase = _QuizPhase.results);
      } else {
        final msg = (res.data as Map?)?['message'] ?? 'Submission failed';
        setState(() { _error = msg.toString(); _phase = _QuizPhase.error; });
      }
    } catch (e) {
      if (mounted) setState(() { _error = 'Error: $e'; _phase = _QuizPhase.error; });
    }
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
          onPressed: () { _timer?.cancel(); Navigator.pop(context, _phase == _QuizPhase.results); },
        ),
        title: Text('Nepal Quiz',
            style: GoogleFonts.playfairDisplay(
                fontSize: 20.sp, fontWeight: FontWeight.bold, color: _dark)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        child: switch (_phase) {
          _QuizPhase.loading => const Center(child: CircularProgressIndicator()),
          _QuizPhase.error   => _buildError(),
          _QuizPhase.home    => _buildHome(),
          _QuizPhase.playing => _buildPlaying(),
          _QuizPhase.results => _buildResults(),
        },
      ),
    );
  }

  Widget _buildError() => Center(
    key: const ValueKey('error'),
    child: Padding(padding: EdgeInsets.all(28.w),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.error_outline, size: 56.sp, color: Colors.red[300]),
        SizedBox(height: 12.h),
        Text(_error ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(fontSize: 14.sp, color: Colors.grey[600])),
        SizedBox(height: 20.h),
        ElevatedButton(
          onPressed: _loadHistory,
          style: ElevatedButton.styleFrom(
              backgroundColor: _brown, foregroundColor: Colors.white, elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r))),
          child: Text('Try Again', style: GoogleFonts.dmSans()),
        ),
      ]),
    ),
  );

  Widget _buildHome() {
    final canPlay = _attemptsLeft > 0;
    return SingleChildScrollView(
      key: const ValueKey('home'),
      padding: EdgeInsets.all(20.w),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Points banner
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5E3C), Color(0xFFCD6E4E)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Points', style: GoogleFonts.dmSans(
                      fontSize: 13.sp, color: Colors.white70)),
                  SizedBox(height: 4.h),
                  Text('$_totalPoints pts',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 32.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 4.h),
                  Text('≈ Rs. ${(_totalPoints / 2).toStringAsFixed(0)} booking discount',
                      style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.white60)),
                ])),
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(Icons.emoji_events_rounded, color: _gold, size: 40.sp),
            ),
          ]),
        ),

        SizedBox(height: 14.h),

        // Attempts card
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Daily Attempts', style: GoogleFonts.dmSans(
                  fontSize: 13.sp, fontWeight: FontWeight.w600, color: _dark)),
              Text('$_attemptsToday / 3 used',
                  style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.grey[500])),
            ]),
            SizedBox(height: 10.h),
            Row(children: List.generate(3, (i) => Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 2 ? 6.w : 0),
                height: 8.h,
                decoration: BoxDecoration(
                  color: i < _attemptsToday ? Colors.red[300] : Colors.green[400],
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ))),
            SizedBox(height: 10.h),
            Row(children: [
              Icon(
                canPlay ? Icons.check_circle_rounded : Icons.do_not_disturb_rounded,
                size: 14.sp, color: canPlay ? Colors.green[700] : Colors.red[400],
              ),
              SizedBox(width: 6.w),
              Text(
                canPlay
                    ? '$_attemptsLeft attempt${_attemptsLeft > 1 ? 's' : ''} remaining today'
                    : 'All attempts used — come back tomorrow!',
                style: GoogleFonts.dmSans(
                    fontSize: 12.sp,
                    color: canPlay ? Colors.green[700] : Colors.red[400],
                    fontWeight: FontWeight.w500),
              ),
            ]),
          ]),
        ),

        SizedBox(height: 14.h),

        // How it works
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.amber.shade50, borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('How it works', style: GoogleFonts.dmSans(
                fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.amber[900])),
            SizedBox(height: 8.h),
            for (final s in [
              '10 random Nepal questions per quiz',
              '20 seconds to answer each question',
              '10 points for every correct answer',
              '3 attempts per day',
              '10 pts = Rs. 5 off at booking (max 20%)',
            ]) _HowRow(s),
          ]),
        ),

        SizedBox(height: 20.h),

        // Start button
        SizedBox(
          width: double.infinity, height: 52.h,
          child: ElevatedButton.icon(
            icon: Icon(canPlay ? Icons.play_arrow_rounded : Icons.lock_clock_rounded, size: 22.sp),
            label: Text(canPlay ? 'Start Quiz' : 'Come Back Tomorrow',
                style: GoogleFonts.dmSans(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            onPressed: canPlay ? _startQuiz : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _brown, foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              disabledForegroundColor: Colors.grey[500],
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            ),
          ),
        ),

        // History
        if (_history.isNotEmpty) ...[
          SizedBox(height: 24.h),
          Text('Recent Attempts', style: GoogleFonts.dmSans(
              fontSize: 15.sp, fontWeight: FontWeight.bold, color: _dark)),
          SizedBox(height: 10.h),
          ..._history.map((a) {
            final score = a['score'] as int? ?? 0;
            final total = a['totalQuestions'] as int? ?? 10;
            final pts   = a['pointsEarned'] as int? ?? 0;
            final pct   = total > 0 ? score / total : 0.0;
            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(children: [
                Container(
                  width: 44.w, height: 44.h,
                  decoration: BoxDecoration(
                    color: pct >= 0.7 ? Colors.green.shade50 : Colors.orange.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: Text('$score/$total',
                      style: GoogleFonts.dmSans(
                        fontSize: 12.sp, fontWeight: FontWeight.bold,
                        color: pct >= 0.7 ? Colors.green[700] : Colors.orange[700],
                      ))),
                ),
                SizedBox(width: 12.w),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('$score correct out of $total',
                      style: GoogleFonts.dmSans(fontSize: 13.sp,
                          fontWeight: FontWeight.w600, color: _dark)),
                  Text(_fmtDate(a['attemptedAt']),
                      style: GoogleFonts.dmSans(fontSize: 11.sp, color: Colors.grey[500])),
                ])),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50, borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text('+$pts pts', style: GoogleFonts.dmSans(
                      fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.amber[800])),
                ),
              ]),
            );
          }),
        ],
        SizedBox(height: 20.h),
      ]),
    );
  }

  Widget _buildPlaying() {
    if (_questions.isEmpty) return const SizedBox.shrink();
    final q       = _questions[_current];
    final qId     = q['id'] as int;
    final options = (q['options'] as List? ?? []).map((o) => o.toString()).toList();
    final selected = _answers[qId];

    return Column(
        key: ValueKey('playing-$_current'),
        children: [
          // Progress header
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 14.h),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Question ${_current + 1} of ${_questions.length}',
                    style: GoogleFonts.dmSans(
                        fontSize: 13.sp, fontWeight: FontWeight.w600, color: _dark)),
                Container(
                  width: 40.w, height: 40.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _timeLeft <= 5 ? Colors.red.shade50 : Colors.amber.shade50,
                  ),
                  child: Center(child: Text('$_timeLeft',
                      style: GoogleFonts.dmSans(
                        fontSize: 14.sp, fontWeight: FontWeight.bold,
                        color: _timeLeft <= 5 ? Colors.red[700] : Colors.amber[800],
                      ))),
                ),
              ]),
              SizedBox(height: 10.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: (_current + 1) / _questions.length,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(_brown),
                  minHeight: 6.h,
                ),
              ),
              SizedBox(height: 4.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: _timeLeft / 20.0,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(
                      _timeLeft <= 5 ? Colors.red : Colors.amber),
                  minHeight: 4.h,
                ),
              ),
            ]),
          ),

          Expanded(child: SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if ((q['category'] ?? '').toString().isNotEmpty)
                Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _brown.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(q['category'].toString(),
                      style: GoogleFonts.dmSans(
                          fontSize: 11.sp, fontWeight: FontWeight.bold, color: _brown)),
                ),

              Text(q['question'].toString(),
                  style: GoogleFonts.dmSans(
                      fontSize: 17.sp, fontWeight: FontWeight.w700,
                      color: _dark, height: 1.4)),

              SizedBox(height: 24.h),

              ...List.generate(options.length, (i) {
                final isSelected = selected == i;
                return GestureDetector(
                  onTap: selected == null ? () => _selectAnswer(i) : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(bottom: 10.h),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.shade50 : Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: isSelected ? Colors.blue.shade300 : Colors.grey.shade200,
                        width: 1.5,
                      ),
                    ),
                    child: Row(children: [
                      Container(
                        width: 30.w, height: 30.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? Colors.blue : _brown.withOpacity(0.08),
                        ),
                        child: Center(child: Text(String.fromCharCode(65 + i),
                            style: GoogleFonts.dmSans(
                              fontSize: 13.sp, fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : _brown,
                            ))),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(child: Text(options[i],
                          style: GoogleFonts.dmSans(
                            fontSize: 14.sp, fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.blue.shade800 : _dark,
                          ))),
                    ]),
                  ),
                );
              }),

              if (selected == null)
                Center(child: TextButton(
                  onPressed: _nextQuestion,
                  child: Text('Skip →', style: GoogleFonts.dmSans(
                      fontSize: 13.sp, color: Colors.grey[500])),
                )),
            ]),
          )),
        ]);
  }

  Widget _buildResults() {
    if (_result == null) return const SizedBox.shrink();
    final score   = _result!['score']       as int? ?? 0;
    final total   = _result!['total']        as int? ?? 10;
    final earned  = _result!['pointsEarned'] as int? ?? 0;
    final allPts  = _result!['totalPoints']  as int? ?? 0;
    final left    = _result!['attemptsLeft'] as int? ?? 0;
    final results = (_result!['results'] as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map)).toList();
    final pct = total > 0 ? score / total : 0.0;

    final Color hColor;
    final String hMsg;
    if (pct >= 0.8) {
      hColor = Colors.green; hMsg = 'Excellent! 🎉';
    } else if (pct >= 0.5) {
      hColor = Colors.orange; hMsg = 'Good job! 👍';
    } else {
      hColor = Colors.red; hMsg = 'Keep trying! 💪';
    }

    return SingleChildScrollView(
      key: const ValueKey('results'),
      padding: EdgeInsets.all(20.w),
      child: Column(children: [

        // Score card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: hColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: hColor.withOpacity(0.3)),
          ),
          child: Column(children: [
            Text(hMsg, style: GoogleFonts.playfairDisplay(
                fontSize: 24.sp, fontWeight: FontWeight.bold, color: hColor)),
            SizedBox(height: 16.h),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _ResultStat('$score/$total', 'Score', hColor),
              Container(width: 1, height: 40.h, color: Colors.grey.shade300),
              _ResultStat('+$earned', 'Points', Colors.amber[700]!),
              Container(width: 1, height: 40.h, color: Colors.grey.shade300),
              _ResultStat('$allPts', 'Total', _brown),
            ]),
          ]),
        ),

        if (earned > 0) ...[
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.amber.shade50, borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(children: [
              Icon(Icons.info_outline_rounded, size: 16.sp, color: Colors.amber[700]),
              SizedBox(width: 8.w),
              Expanded(child: Text(
                '+$earned pts added! Use them at booking for discounts — 10 pts = Rs. 5 off meals or accommodation.',
                style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.amber[900]),
              )),
            ]),
          ),
        ],

        SizedBox(height: 16.h),

        Text('Answer Review', style: GoogleFonts.dmSans(
            fontSize: 15.sp, fontWeight: FontWeight.bold, color: _dark)),
        SizedBox(height: 10.h),

        ...results.asMap().entries.map((entry) {
          final i    = entry.key;
          final r    = entry.value;
          final ok   = r['isCorrect'] as bool? ?? false;
          final opts = (r['options'] as List? ?? []).map((o) => o.toString()).toList();
          final selIdx  = r['selectedIndex'] as int? ?? -1;
          final corrIdx = r['correctIndex']  as int? ?? 0;

          return Container(
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                  color: ok ? Colors.green.shade200 : Colors.red.shade200),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(ok ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    size: 16.sp, color: ok ? Colors.green[700] : Colors.red[400]),
                SizedBox(width: 6.w),
                Text('Q${i + 1}', style: GoogleFonts.dmSans(
                    fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.grey[500])),
              ]),
              SizedBox(height: 6.h),
              Text(r['question'].toString(), style: GoogleFonts.dmSans(
                  fontSize: 13.sp, fontWeight: FontWeight.w600, color: _dark)),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.green.shade50, borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(children: [
                  Icon(Icons.check_rounded, size: 13.sp, color: Colors.green[700]),
                  SizedBox(width: 6.w),
                  Text('Correct: ${opts.isNotEmpty ? opts[corrIdx] : ''}',
                      style: GoogleFonts.dmSans(fontSize: 12.sp,
                          color: Colors.green[800], fontWeight: FontWeight.w600)),
                ]),
              ),
              if (!ok && selIdx >= 0 && selIdx < opts.length) ...[
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50, borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(children: [
                    Icon(Icons.close_rounded, size: 13.sp, color: Colors.red[400]),
                    SizedBox(width: 6.w),
                    Text('You chose: ${opts[selIdx]}',
                        style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.red[700])),
                  ]),
                ),
              ],
              if (!ok && selIdx == -1) ...[
                SizedBox(height: 4.h),
                Text('Skipped', style: GoogleFonts.dmSans(
                    fontSize: 12.sp, color: Colors.grey[500])),
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
              onPressed: _startQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: _brown, foregroundColor: Colors.white,
                elevation: 0, padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
              ),
            )),
            SizedBox(width: 10.w),
          ],
          Expanded(child: OutlinedButton.icon(
            icon: Icon(Icons.home_outlined, size: 18.sp),
            label: Text('Done', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
            onPressed: () { _timer?.cancel(); Navigator.pop(context, true); },
            style: OutlinedButton.styleFrom(
              foregroundColor: _brown, side: BorderSide(color: _brown),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
            ),
          )),
        ]),
        SizedBox(height: 20.h),
      ]),
    );
  }

  String _fmtDate(dynamic raw) {
    if (raw == null) return '';
    try {
      final d = DateTime.parse(raw.toString()).toLocal();
      const m = ['Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${m[d.month-1]} ${d.day}, ${d.year}';
    } catch (_) { return ''; }
  }
}

class _HowRow extends StatelessWidget {
  final String text;
  const _HowRow(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: 4.h),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('• ', style: TextStyle(color: Colors.amber[700], fontSize: 13.sp)),
      Expanded(child: Text(text, style: GoogleFonts.dmSans(
          fontSize: 12.sp, color: Colors.amber[900]))),
    ]),
  );
}

class _ResultStat extends StatelessWidget {
  final String value, label;
  final Color color;
  const _ResultStat(this.value, this.label, this.color);
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: GoogleFonts.dmSans(
        fontSize: 20.sp, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: GoogleFonts.dmSans(fontSize: 10.sp, color: Colors.grey[500])),
  ]);
}