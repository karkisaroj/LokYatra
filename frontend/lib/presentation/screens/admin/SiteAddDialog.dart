import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokyatra_frontend/data/datasources/sites_remote_datasource.dart';
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

  // For category suggestions
  List<String> _categorySuggestions = [];
  bool _loadingCategories = true;
  final FocusNode _categoryFocusNode = FocusNode();
  bool _showSuggestions = false;

  final SitesRemoteDatasource _sitesRemote = SitesRemoteDatasource();

  @override
  void initState() {
    super.initState();
    _loadExistingCategories();

    // Listen to focus changes for suggestions
    _categoryFocusNode.addListener(() {
      if (_categoryFocusNode.hasFocus && _category.text.isNotEmpty) {
        setState(() => _showSuggestions = true);
      } else {
        setState(() => _showSuggestions = false);
      }
    });
  }

  Future<void> _loadExistingCategories() async {
    try {
      final response = await _sitesRemote.getSites();

      if (response.statusCode == 200) {
        final List<dynamic> sites = response.data;

        // Extract unique categories
        final Set<String> uniqueCategories = {};
        for (var site in sites) {
          final category = site['category'] as String?;
          if (category != null && category.isNotEmpty) {
            uniqueCategories.add(category);
          }
        }

        setState(() {
          _categorySuggestions = uniqueCategories.toList()..sort();
          _loadingCategories = false;
        });

        debugPrint('Loaded ${_categorySuggestions.length} existing categories');
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
      setState(() => _loadingCategories = false);
    }
  }

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
    _categoryFocusNode.dispose();
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

  void _removeFile(int index) {
    setState(() => _files.removeAt(index));
  }

  Future<void> _pickTime(TextEditingController c) async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t != null) {
      final hh = t.hour.toString().padLeft(2, '0');
      final mm = t.minute.toString().padLeft(2, '0');
      c.text = '$hh:$mm'; // HH:mm format
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // Parse numeric values
    double? nprFee = _feeNpr.text.trim().isEmpty
        ? null
        : double.tryParse(_feeNpr.text.trim());

    double? saarcFee = _feeSaarc.text.trim().isEmpty
        ? null
        : double.tryParse(_feeSaarc.text.trim());

    final fields = {
      'Name': _name.text.trim(),
      'Category': _category.text.trim(),
      'District': _district.text.trim(),
      'Address': _address.text.trim(),
      'ShortDescription': _short.text.trim(),
      'HistoricalSignificance': _historical.text.trim().isEmpty ? null : _historical.text.trim(),
      'CulturalImportance': _cultural.text.trim().isEmpty ? null : _cultural.text.trim(),
      'EntryFeeNPR': nprFee,
      'EntryFeeSAARC': saarcFee,
      'OpeningTime': _openTime.text.trim().isEmpty ? null : _openTime.text.trim(),
      'ClosingTime': _closeTime.text.trim().isEmpty ? null : _closeTime.text.trim(),
      'BestTimeToVisit': _bestTime.text.trim().isEmpty ? null : _bestTime.text.trim(),
      'IsUNESCO': _isUnesco,
    };

    // Remove null values
    fields.removeWhere((key, value) => value == null);

    debugPrint('Submitting site: $fields');

    // Add the site
    context.read<SitesBloc>().add(CreateSite(fields: fields, files: _files));

    // Don't close immediately - let the BlocListener handle it
  }

  List<String> _getFilteredSuggestions() {
    if (_category.text.isEmpty) return [];
    final query = _category.text.toLowerCase();
    return _categorySuggestions
        .where((cat) => cat.toLowerCase().contains(query))
        .take(5)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<SitesBloc>().state is SitesLoading;
    final screenW = MediaQuery.of(context).size.width;
    final dialogW = screenW > 900 ? 900.0 : screenW * 0.95;

    final filteredSuggestions = _getFilteredSuggestions();

    return AlertDialog(
      title: Row(
        children: [
          const Expanded(
            child: Text(
              'Add Cultural Site',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context, false),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      content: SizedBox(
        width: dialogW,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Site Name and Category
                Row(
                  children: [
                    Expanded(
                      child: _flexField(_name, 'Site Name *', required: true),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildCategoryFieldWithSuggestions(
                        filteredSuggestions,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Row 2: District and Address
                Row(
                  children: [
                    Expanded(
                      child: _flexField(_district, 'District *', required: true),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _flexField(_address, 'Address *', required: true),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Short Description
                _textArea(_short, 'Short Description *', required: true, maxLen: 500),
                const SizedBox(height: 12),

                // Historical and Cultural
                _textArea(_historical, 'Historical Significance', maxLen: 500),
                const SizedBox(height: 8),
                _textArea(_cultural, 'Cultural Importance', maxLen: 500),
                const SizedBox(height: 12),

                // Fees
                Row(
                  children: [
                    Expanded(child: _numberField(_feeNpr, 'Entry Fee (NPR)')),
                    const SizedBox(width: 12),
                    Expanded(child: _numberField(_feeSaarc, 'Entry Fee SAARC')),
                  ],
                ),
                const SizedBox(height: 8),

                // Times
                Row(
                  children: [
                    Expanded(child: _timeField(_openTime, 'Opening (HH:mm)')),
                    const SizedBox(width: 12),
                    Expanded(child: _timeField(_closeTime, 'Closing (HH:mm)')),
                  ],
                ),
                const SizedBox(height: 8),

                // Best Time and UNESCO
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _bestTime,
                        decoration: const InputDecoration(
                          labelText: 'Best Time to Visit',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Row(
                      children: [
                        const Text('UNESCO'),
                        Switch.adaptive(
                          value: _isUnesco,
                          onChanged: (v) => setState(() => _isUnesco = v),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Images
                const Text('Images'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: loading ? null : _pickFiles,
                      icon: const Icon(Icons.upload),
                      label: const Text('Choose Files'),
                    ),
                    ..._files.asMap().entries.map((entry) {
                      return Chip(
                        label: Text(entry.value.name),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => _removeFile(entry.key),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: loading ? null : _submit,
          child: loading
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Text('Add Site'),
        ),
      ],
    );
  }

  Widget _buildCategoryFieldWithSuggestions(List<String> filteredSuggestions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _category,
          focusNode: _categoryFocusNode,
          decoration: InputDecoration(
            labelText: 'Category *',
            border: const OutlineInputBorder(),
            suffixIcon: _loadingCategories
                ? const SizedBox(
              width: 20,
              height: 20,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
                : null,
          ),
          onChanged: (_) {
            setState(() {
              _showSuggestions = true;
            });
          },
          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
        ),

        // Suggestions dropdown
        if (_showSuggestions && filteredSuggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = filteredSuggestions[index];
                return ListTile(
                  dense: true,
                  title: Text(suggestion),
                  onTap: () {
                    setState(() {
                      _category.text = suggestion;
                      _showSuggestions = false;
                      _categoryFocusNode.unfocus();
                    });
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _flexField(TextEditingController c, String label, {bool required = false}) {
    return TextFormField(
      controller: c,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: required ? (v) => v == null || v.trim().isEmpty ? 'Required' : null : null,
    );
  }

  Widget _textArea(TextEditingController c, String label, {int maxLen = 500, bool required = false}) {
    return TextFormField(
      controller: c,
      maxLength: maxLen,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: required ? (v) => v == null || v.trim().isEmpty ? 'Required' : null : null,
    );
  }

  Widget _numberField(TextEditingController c, String label) {
    return TextFormField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return null;
        return double.tryParse(v) == null ? 'Enter a valid number' : null;
      },
    );
  }

  Widget _timeField(TextEditingController c, String label) {
    return TextFormField(
      controller: c,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.access_time),
      ),
      onTap: () => _pickTime(c),
      validator: (v) {
        if (v == null || v.isEmpty) return null;
        final ok = RegExp(r'^\d{2}:\d{2}$').hasMatch(v);
        return ok ? null : 'Use HH:mm format';
      },
    );
  }
}