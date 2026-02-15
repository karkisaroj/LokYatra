import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_event.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_state.dart';

class SiteAddDialog extends StatefulWidget {
  const SiteAddDialog({super.key});
  @override
  State<SiteAddDialog> createState() => _SiteAddDialogState();
}

class _SiteAddDialogState extends State<SiteAddDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _category = TextEditingController();
  final _district = TextEditingController();
  final _address = TextEditingController();
  final _short = TextEditingController();

  final _historical = TextEditingController();
  final _cultural = TextEditingController();

  final _feeNpr = TextEditingController();
  final _feeSaarc = TextEditingController();

  final _openTime = TextEditingController();
  final _closeTime = TextEditingController();

  final _bestTime = TextEditingController();
  bool _isUnesco = false;

  List<PlatformFile> _files = [];

  @override
  void dispose() {
    _name.dispose();
    _category.dispose();
    _district.dispose();
    _address.dispose();
    _short.dispose();
    _historical.dispose();
    _cultural.dispose();
    _feeNpr.dispose();
    _feeSaarc.dispose();
    _openTime.dispose();
    _closeTime.dispose();
    _bestTime.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final res = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
    );
    if (res != null) setState(() => _files = res.files.take(5).toList());
  }

  Future<void> _pickTime(TextEditingController c) async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t != null) {
      final hh = t.hour.toString().padLeft(2, '0');
      final mm = t.minute.toString().padLeft(2, '0');
      c.text = '$hh:$mm'; // strict HH:mm matching backend
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final fields = {
      'Name': _name.text.trim(),
      'Category': _category.text.trim(),
      'District': _district.text.trim(),
      'Address': _address.text.trim(),
      'ShortDescription': _short.text.trim(),

      'HistoricalSignificance': _historical.text.trim().isEmpty ? null : _historical.text.trim(),
      'CulturalImportance': _cultural.text.trim().isEmpty ? null : _cultural.text.trim(),

      'EntryFeeNPR': _feeNpr.text.trim().isEmpty ? null : _feeNpr.text.trim(),     // backend parses decimal
      'EntryFeeSAARC': _feeSaarc.text.trim().isEmpty ? null : _feeSaarc.text.trim(),

      'OpeningTime': _openTime.text.trim().isEmpty ? null : _openTime.text.trim(), // "HH:mm" string (backend expects string)
      'ClosingTime': _closeTime.text.trim().isEmpty ? null : _closeTime.text.trim(),

      'BestTimeToVisit': _bestTime.text.trim().isEmpty ? null : _bestTime.text.trim(),
      'IsUNESCO': _isUnesco,
    };

    context.read<SitesBloc>().add(CreateSite(fields: fields, files: _files));
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<SitesBloc>().state is SitesLoading;
    final screenW = MediaQuery.of(context).size.width;
    final dialogW = screenW > 900 ? 900.0 : screenW * 0.95;

    return AlertDialog(
      title: Row(
        children: [
          const Expanded(child: Text('Add Cultural Site', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          IconButton(onPressed: () => Navigator.pop(context, false), icon: const Icon(Icons.close)),
        ],
      ),
      content: SizedBox(
        width: dialogW,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [_flexField(_name, 'Name *', required: true), const SizedBox(width: 12), _flexField(_category, 'Category *', required: true)]),
              const SizedBox(height: 8),
              Row(children: [_flexField(_district, 'District *', required: true), const SizedBox(width: 12), _flexField(_address, 'Address *', required: true)]),
              const SizedBox(height: 8),
              _textArea(_short, 'Short Description *', required: true, maxLen: 500),
              const SizedBox(height: 12),

              _textArea(_historical, 'Historical Significance', maxLen: 500),
              const SizedBox(height: 8),
              _textArea(_cultural, 'Cultural Importance', maxLen: 500),
              const SizedBox(height: 12),

              Row(children: [
                Expanded(child: _numberField(_feeNpr, 'Entry Fee (NPR)')),
                const SizedBox(width: 12),
                Expanded(child: _numberField(_feeSaarc, 'Entry Fee SAARC')),
              ]),
              const SizedBox(height: 8),

              Row(children: [
                Expanded(child: _timeField(_openTime, 'Opening (HH:mm)')),
                const SizedBox(width: 12),
                Expanded(child: _timeField(_closeTime, 'Closing (HH:mm)')),
              ]),
              const SizedBox(height: 8),

              Row(children: [
                Expanded(child: TextFormField(controller: _bestTime, decoration: const InputDecoration(labelText: 'Best Time to Visit', border: OutlineInputBorder()))),
                const SizedBox(width: 12),
                Switch.adaptive(value: _isUnesco, onChanged: (v) => setState(() => _isUnesco = v)),
              ]),
              const SizedBox(height: 12),

              const Text('Images'),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                ElevatedButton.icon(onPressed: loading ? null : _pickFiles, icon: const Icon(Icons.upload), label: const Text('Choose Files')),
                ..._files.map((f) => Chip(label: Text(f.name))),
              ]),
            ]),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: loading ? null : () async {
            _submit();
            Navigator.pop(context, true);
          },
          child: loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Add Site'),
        ),
      ],
    );
  }

  Widget _flexField(TextEditingController c, String label, {bool required = false}) {
    return Expanded(
      child: TextFormField(
        controller: c,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: required ? (v) => v == null || v.trim().isEmpty ? 'Required' : null : null,
      ),
    );
  }

  Widget _textArea(TextEditingController c, String label, {int maxLen = 500, bool required = false}) {
    return TextFormField(
      controller: c,
      maxLength: maxLen,
      maxLines: 5,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      validator: required ? (v) => v == null || v.trim().isEmpty ? 'Required' : null : null,
    );
  }

  Widget _numberField(TextEditingController c, String label) {
    return TextFormField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      validator: (v) {
        if (v == null || v.isEmpty) return null;
        return double.tryParse(v) == null ? 'Number only' : null;
      },
    );
  }

  Widget _timeField(TextEditingController c, String label) {
    return TextFormField(
      controller: c,
      readOnly: true,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), suffixIcon: const Icon(Icons.access_time)),
      onTap: () => _pickTime(c),
      validator: (v) {
        if (v == null || v.isEmpty) return null;
        final ok = RegExp(r'^\d{2}:\d{2}$').hasMatch(v);
        return ok ? null : 'HH:mm';
      },
    );
  }
}