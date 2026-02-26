import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/datasources/quiz_remote_datasource.dart';

class TouristAddQuizzes extends StatefulWidget {
  const TouristAddQuizzes({super.key});

  @override
  State<TouristAddQuizzes> createState() => _TouristAddQuizzesState();
}

class _TouristAddQuizzesState extends State<TouristAddQuizzes> {
  static const _slate = Color(0xFF3D5A80);
  static const _bg = Color(0xFFF4F6F9);

  List<Map<String, dynamic>> _questions = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  // LOAD QUESTIONS
  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await QuizRemoteDatasource().adminGetQuestions();
      if (res.statusCode == 200 && mounted) {
        setState(() {
          _questions = (res.data as List)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  // FILTER
  List<Map<String, dynamic>> get _filtered {
    if (_search.isEmpty) return _questions;
    final q = _search.toLowerCase();
    return _questions
        .where((item) =>
    item['question'].toString().toLowerCase().contains(q) ||
        item['category'].toString().toLowerCase().contains(q))
        .toList();
  }

  // OPEN FORM
  void _openForm({Map<String, dynamic>? existing}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _QuestionFormPage(existing: existing),
      ),
    );

    if (result == true) {
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: _bg,
      child: Column(
        children: [
          // Top Row
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _search = v),
                    decoration: InputDecoration(
                      hintText: "Search questions...",
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                ElevatedButton.icon(
                  onPressed: () => _openForm(),
                  icon: const Icon(Icons.add),
                  label: const Text("Add"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _slate,
                    foregroundColor: Colors.white,
                  ),
                )
              ],
            ),
          ),

          // List
          Expanded(
            child: _filtered.isEmpty
                ? Center(
              child: Text(
                "No questions found",
                style: GoogleFonts.dmSans(
                    fontSize: 16.sp, color: Colors.grey),
              ),
            )
                : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: _filtered.length,
                itemBuilder: (_, i) {
                  final q = _filtered[i];
                  final options =
                      (q['options'] as List?)?.cast<String>() ?? [];
                  final correctIdx = q['correctIndex'] ?? 0;

                  return Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          q['question'].toString(),
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          "Category: ${q['category']}",
                          style: GoogleFonts.dmSans(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8.h),

                        // Options Preview
                        ...List.generate(options.length, (index) {
                          final isCorrect = index == correctIdx;
                          return Padding(
                            padding: EdgeInsets.only(bottom: 4.h),
                            child: Row(
                              children: [
                                Icon(
                                  isCorrect
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  size: 16.sp,
                                  color: isCorrect
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    options[index],
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12.sp,
                                      fontWeight: isCorrect
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        SizedBox(height: 8.h),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () =>
                                _openForm(existing: q),
                            child: const Text("Edit"),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
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

  final _formKey = GlobalKey<FormState>();
  final _questionCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final List<TextEditingController> _optionCtrls =
  List.generate(4, (_) => TextEditingController());

  int _correctIndex = 0;
  bool _loading = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();

    if (_isEdit) {
      final e = widget.existing!;
      _questionCtrl.text = e['question'] ?? '';
      _categoryCtrl.text = e['category'] ?? '';
      _correctIndex = e['correctIndex'] ?? 0;

      final opts = (e['options'] as List?)?.cast<String>() ?? [];
      for (int i = 0; i < opts.length && i < 4; i++) {
        _optionCtrls[i].text = opts[i];
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final options = _optionCtrls
        .map((c) => c.text.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (options.length < 2) {
      _showSnack("Add at least 2 options");
      return;
    }

    setState(() => _loading = true);

    final body = {
      'question': _questionCtrl.text.trim(),
      'options': options,
      'correctIndex': _correctIndex,
      'category': _categoryCtrl.text.trim(),
      'isActive': true,
    };

    final res = _isEdit
        ? await QuizRemoteDatasource()
        .adminUpdateQuestion(widget.existing!['id'], body)
        : await QuizRemoteDatasource().adminAddQuestion(body);

    setState(() => _loading = false);

    if (res.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      _showSnack("Something went wrong");
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          _isEdit ? "Edit Question" : "Create Question",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [

            // QUESTION
            _sectionTitle("Question"),
            const SizedBox(height: 8),
            _inputField(
              controller: _questionCtrl,
              hint: "Enter your question here...",
              maxLines: 3,
              validator: (v) =>
              v == null || v.trim().isEmpty ? "Question required" : null,
            ),

            const SizedBox(height: 20),

            // CATEGORY
            _sectionTitle("Category"),
            const SizedBox(height: 8),
            _inputField(
              controller: _categoryCtrl,
              hint: "e.g. Nepal Heritage",
            ),

            const SizedBox(height: 24),

            // OPTIONS
            _sectionTitle("Answer Options"),
            const SizedBox(height: 12),

            ...List.generate(4, (i) => _optionTile(i)),

            const SizedBox(height: 30),

            // SAVE BUTTON
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                )
                    : Text(
                  _isEdit ? "Save Changes" : "Add Question",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- UI HELPERS ----------

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _optionTile(int index) {
    final isCorrect = _correctIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect ? Colors.green : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Radio<int>(
            value: index,
            groupValue: _correctIndex,
            activeColor: Colors.green,
            onChanged: (val) {
              setState(() => _correctIndex = val!);
            },
          ),
          Expanded(
            child: TextFormField(
              controller: _optionCtrls[index],
              decoration: InputDecoration(
                hintText: "Option ${String.fromCharCode(65 + index)}",
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}