import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/datasources/quiz_remote_datasource.dart';

class AdminQuizzesPage extends StatefulWidget {
  const AdminQuizzesPage({super.key});
  @override
  State<AdminQuizzesPage> createState() => _AdminQuizzesPageState();
}

class _AdminQuizzesPageState extends State<AdminQuizzesPage> {
  static const _slate = Color(0xFF3D5A80);
  static const _bg    = Color(0xFFF4F6F9);

  List<Map<String, dynamic>> _questions = [];
  bool   _loading = true;
  String _search  = '';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await QuizRemoteDatasource().adminGetQuestions();
      if (res.statusCode == 200 && mounted) {
        setState(() => _questions = (res.data as List)
            .map((e) => Map<String, dynamic>.from(e as Map)).toList());
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  List<Map<String, dynamic>> get _filtered {
    if (_search.isEmpty) return _questions;
    final q = _search.toLowerCase();
    return _questions.where((item) =>
    item['question'].toString().toLowerCase().contains(q) ||
        item['category'].toString().toLowerCase().contains(q)).toList();
  }

  void _openForm({Map<String, dynamic>? existing}) async {
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (_) => _QuestionFormPage(existing: existing)));
    if (result == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Container(
      color: _bg,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                style: GoogleFonts.dmSans(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search questions...',
                  hintStyle: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey[400]),
                  filled: true, fillColor: Colors.white,
                  prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey[400]),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add, size: 18),
              label: Text('Add', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _slate, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ]),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(children: [
            Text('${_filtered.length} question${_filtered.length != 1 ? 's' : ''}',
                style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey[500])),
            const Spacer(),
            GestureDetector(
                onTap: _load,
                child: Icon(Icons.refresh_rounded, size: 18, color: Colors.grey[500])),
          ]),
        ),

        Expanded(
          child: _filtered.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.quiz_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text('No questions found',
                style: GoogleFonts.dmSans(fontSize: 15, color: Colors.grey[500])),
          ]))
              : RefreshIndicator(
            onRefresh: _load,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final q = _filtered[i];
                final options = (q['options'] as List?)?.cast<String>() ?? [];
                final correctIdx= q['correctIndex'] ?? 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(child: Text(q['question'].toString(),
                          style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: const Color(0xFF1A2B3C)))),
                      TextButton(
                        onPressed: () => _openForm(existing: q),
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            foregroundColor: _slate),
                        child: Text('Edit',
                            style: GoogleFonts.dmSans(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ]),

                    if ((q['category'] ?? '').toString().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _slate.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('${q['category']}',
                            style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: _slate,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],

                    const SizedBox(height: 10),

                    ...List.generate(options.length, (index) {
                      final isCorrect = index == correctIdx;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(children: [
                          Icon(
                            isCorrect
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 16,
                            color: isCorrect
                                ? Colors.green[600]
                                : Colors.grey[400],
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(options[index],
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: isCorrect
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isCorrect
                                    ? Colors.green[700]
                                    : Colors.grey[700],
                              ))),
                        ]),
                      );
                    }),
                  ]),
                );
              },
            ),
          ),
        ),
      ]),
    );
  }
}

class _QuestionFormPage extends StatefulWidget {
  final Map<String, dynamic>? existing;
  const _QuestionFormPage({this.existing});
  @override
  State<_QuestionFormPage> createState() => _QuestionFormPageState();
}

class _QuestionFormPageState extends State<_QuestionFormPage> {
  static const _primary = Color(0xFF3D5A80);

  final _formKey      = GlobalKey<FormState>();
  final _questionCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final List<TextEditingController> _optionCtrls = List.generate(4, (_) => TextEditingController());

  int  _correctIndex = 0;
  bool _loading      = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final e = widget.existing!;
      _questionCtrl.text = e['question'] ?? '';
      _categoryCtrl.text = e['category'] ?? '';
      _correctIndex      = e['correctIndex'] ?? 0;
      final opts = (e['options'] as List?)?.cast<String>() ?? [];
      for (int i = 0; i < opts.length && i < 4; i++) {
        _optionCtrls[i].text = opts[i];
      }
    }
  }

  @override
  void dispose() {
    _questionCtrl.dispose();
    _categoryCtrl.dispose();
    for (final c in _optionCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final options = _optionCtrls
        .map((c) => c.text.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (options.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add at least 2 options')));
      return;
    }
    setState(() => _loading = true);
    final body = {
      'question':     _questionCtrl.text.trim(),
      'options':      options,
      'correctIndex': _correctIndex,
      'category':     _categoryCtrl.text.trim(),
      'isActive':     true,
    };
    final res = _isEdit
        ? await QuizRemoteDatasource()
        .adminUpdateQuestion(widget.existing!['id'], body)
        : await QuizRemoteDatasource().adminAddQuestion(body);
    setState(() => _loading = false);
    if (!mounted) return;
    if (res.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(_isEdit ? 'Edit Question' : 'Create Question',
            style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold, fontSize: 17)),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(height: 1, color: Colors.grey.shade200)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _label('Question'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _questionCtrl,
              maxLines: 3,
              style: GoogleFonts.dmSans(fontSize: 14),
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'Question required' : null,
              decoration: _inputDeco('Enter your question here...'),
            ),

            const SizedBox(height: 20),
            _label('Category'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _categoryCtrl,
              style: GoogleFonts.dmSans(fontSize: 14),
              decoration: _inputDeco('e.g. Nepal Heritage'),
            ),

            const SizedBox(height: 24),
            _label('Answer Options'),
            Text('Tap the circle to mark the correct answer',
                style: GoogleFonts.dmSans(
                    fontSize: 12, color: Colors.grey[500])),
            const SizedBox(height: 12),

            ...List.generate(4, (i) => _optionTile(i)),

            const SizedBox(height: 30),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                    : Text(
                    _isEdit ? 'Save Changes' : 'Add Question',
                    style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 0),
    child: Text(text,
        style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A2B3C))),
  );

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey[400]),
    filled: true,
    fillColor: Colors.white,
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none),
  );

  Widget _optionTile(int index) {
    final isCorrect = _correctIndex == index;
    final label     = String.fromCharCode(65 + index);

    return GestureDetector(
      onTap: () => setState(() => _correctIndex = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isCorrect ? Colors.green.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isCorrect ? Colors.green : Colors.grey.shade300),
        ),
        child: Row(children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isCorrect
                  ? Icons.check_circle_rounded
                  : Icons.circle_outlined,
              key: ValueKey(isCorrect),
              size: 22,
              color: isCorrect ? Colors.green : Colors.grey[400],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              color: isCorrect
                  ? Colors.green.withValues(alpha: 0.15)
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(label,
                  style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isCorrect ? Colors.green[800] : Colors.grey[600])),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: _optionCtrls[index],
              style: GoogleFonts.dmSans(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Option $label',
                hintStyle: GoogleFonts.dmSans(
                    fontSize: 13, color: Colors.grey[400]),
                border: InputBorder.none,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}