import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/stories/story_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/stories/story_event.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/stories/story_state.dart';

class StoryAddDialog extends StatefulWidget {
  final int siteId;
  const StoryAddDialog({super.key, required this.siteId});
  @override
  State<StoryAddDialog> createState() => _StoryAddDialogState();
}

class _StoryAddDialogState extends State<StoryAddDialog> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _type = TextEditingController();
  final _readMin = TextEditingController(text: '5');
  final _full = TextEditingController();
  final _hist = TextEditingController();
  final _cult = TextEditingController();
  List<PlatformFile> _files = [];

  @override
  void dispose() {
    _title.dispose(); _type.dispose(); _readMin.dispose(); _full.dispose(); _hist.dispose(); _cult.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final res = await FilePicker.platform.pickFiles(
      allowMultiple: true, withData: true, type: FileType.custom, allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
    );
    if (res != null) setState(() => _files = res.files.take(3).toList());
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final fields = {
      'CulturalSiteId': widget.siteId,
      'Title': _title.text.trim(),
      'StoryType': _type.text.trim(),
      'EstimatedReadTimeMinutes': int.tryParse(_readMin.text.trim()) ?? 5,
      'FullContent': _full.text.trim(),
      'HistoricalContext': _hist.text.trim().isEmpty ? null : _hist.text.trim(),
      'CulturalSignificance': _cult.text.trim().isEmpty ? null : _cult.text.trim(),
    };
    context.read<StoryBloc>().add(CreateStory(fields: fields, files: _files));
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final dialogW = screenW > 900 ? 900.0 : screenW * 0.95;

    return BlocConsumer<StoryBloc, StoryState>(
      listener: (context, state) {
        if (state is StoryCreateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Story added')));
          Navigator.pop(context, true);
        }
        if (state is StoryError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final loading = state is StoryLoading;
        return AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(24, 20, 12, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          title: Row(
            children: [
              const Expanded(child: Text('Add New Cultural Story', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              IconButton(onPressed: () => Navigator.pop(context, false), icon: const Icon(Icons.close)),
            ],
          ),
          content: SizedBox(
            width: dialogW,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Basic Information', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(children: [Flexible(child: _field(_title, 'Story Title *', required: true)), const SizedBox(width: 12), Flexible(child: _field(_type, 'Story Type *', required: true))]),
                  const SizedBox(height: 8),
                  _fieldFull(_readMin, 'Estimated Read Time (minutes) *', required: true, type: TextInputType.number),
                  const SizedBox(height: 16),
                  const Text('Story Content', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _textArea('Full Story Content *', _full, maxLen: 5000, required: true),
                  const SizedBox(height: 16),
                  const Text('Cultural Context', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _textArea('Historical Context', _hist, maxLen: 500),
                  const SizedBox(height: 8),
                  _textArea('Moral Lesson / Cultural Significance', _cult, maxLen: 500),
                  const SizedBox(height: 16),
                  const Text('Story Images', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(border: Border.all(color: Colors.orange.shade200), borderRadius: BorderRadius.circular(12), color: Colors.orange.shade50.withOpacity(0.4)),
                    child: Wrap(spacing: 8, runSpacing: 8, children: [
                      ElevatedButton.icon(onPressed: loading ? null : _pickFiles, icon: const Icon(Icons.upload), label: const Text('Choose Files')),
                      ..._files.map((f) => Chip(label: Text(f.name))),
                    ]),
                  ),
                ]),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: loading ? null : _submit,
              child: loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Add Story'),
            ),
          ],
        );
      },
    );
  }

  Widget _field(TextEditingController c, String label, {bool required = false, TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: c,
      keyboardType: type,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      validator: required ? (v) => v == null || v.trim().isEmpty ? 'Required' : null : null,
    );
  }

  Widget _fieldFull(TextEditingController c, String label, {bool required = false, TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: c,
      keyboardType: type,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      validator: required ? (v) => v == null || v.trim().isEmpty ? 'Required' : null : null,
    );
  }

  Widget _textArea(String label, TextEditingController c, {int maxLen = 500, bool required = false}) {
    return TextFormField(
      controller: c,
      maxLength: maxLen,
      maxLines: 6,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      validator: required ? (v) => v == null || v.trim().isEmpty ? 'Required' : null : null,
    );
  }
}