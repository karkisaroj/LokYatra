import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lokyatra_frontend/data/datasources/sites_remote_datasource.dart';

class SiteEditDialog extends StatefulWidget {
  final Map<String, dynamic> site;
  const SiteEditDialog({super.key, required this.site});

  @override
  State<SiteEditDialog> createState() => _SiteEditDialogState();
}

class _SiteEditDialogState extends State<SiteEditDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Text controllers - initialized with existing site data
  late final _nameController = TextEditingController(text: (widget.site['name'] ?? '').toString());
  late final _categoryController = TextEditingController(text: (widget.site['category'] ?? '').toString());
  late final _districtController = TextEditingController(text: (widget.site['district'] ?? '').toString());
  late final _addressController = TextEditingController(text: (widget.site['address'] ?? '').toString());
  late final _shortDescController = TextEditingController(text: (widget.site['shortDescription'] ?? '').toString());
  late final _historicalController = TextEditingController(text: (widget.site['historicalSignificance'] ?? '').toString());
  late final _culturalController = TextEditingController(text: (widget.site['culturalImportance'] ?? '').toString());
  late final _feeNprController = TextEditingController(text: (widget.site['entryFeeNPR'] ?? '').toString());
  late final _feeSaarcController = TextEditingController(text: (widget.site['entryFeeSAARC'] ?? '').toString());
  late final _openTimeController = TextEditingController(text: (widget.site['openingTime'] ?? '').toString());
  late final _closeTimeController = TextEditingController(text: (widget.site['closingTime'] ?? '').toString());
  late final _bestTimeController = TextEditingController(text: (widget.site['bestTimeToVisit'] ?? '').toString());
  late bool _isUnesco = (widget.site['isUNESCO'] ?? false) == true;

  // Images
  List<PlatformFile> _newFiles = [];
  late List<String> _existingImageUrls = _getExistingImageUrls();

  /// Gets the existing image URLs from site data using a simple loop
  List<String> _getExistingImageUrls() {
    List<String> urls = [];
    if (widget.site['imageUrls'] != null && widget.site['imageUrls'] is List) {
      for (var url in widget.site['imageUrls']) {
        if (url != null && url.toString().isNotEmpty) {
          urls.add(url.toString());
        }
      }
    }
    return urls;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _districtController.dispose();
    _addressController.dispose();
    _shortDescController.dispose();
    _historicalController.dispose();
    _culturalController.dispose();
    _feeNprController.dispose();
    _feeSaarcController.dispose();
    _openTimeController.dispose();
    _closeTimeController.dispose();
    _bestTimeController.dispose();
    super.dispose();
  }

  // ─── Pick files ───

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
    );
    if (result != null) {
      setState(() {
        _newFiles.addAll(result.files.take(5));
      });
    }
  }

  // ─── Pick time ───

  Future<void> _pickTime(TextEditingController controller) async {
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time != null) {
      String hours = time.hour.toString().padLeft(2, '0');
      String minutes = time.minute.toString().padLeft(2, '0');
      controller.text = '$hours:$minutes';
    }
  }

  // ─── Submit ───

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Get original image count
    int originalImageCount = 0;
    if (widget.site['imageUrls'] != null && widget.site['imageUrls'] is List) {
      originalImageCount = (widget.site['imageUrls'] as List).length;
    }

    // If user removed images but didn't add new ones, warn them
    if (_newFiles.isEmpty && _existingImageUrls.length != originalImageCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('To apply image removals, please upload at least one new image.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    Map<String, dynamic> fields = {
      'Name': _nameController.text.trim(),
      'Category': _categoryController.text.trim(),
      'District': _districtController.text.trim(),
      'Address': _addressController.text.trim(),
      'ShortDescription': _shortDescController.text.trim(),
      'HistoricalSignificance': _historicalController.text.trim().isEmpty ? null : _historicalController.text.trim(),
      'CulturalImportance': _culturalController.text.trim().isEmpty ? null : _culturalController.text.trim(),
      'EntryFeeNPR': _feeNprController.text.trim().isEmpty ? null : _feeNprController.text.trim(),
      'EntryFeeSAARC': _feeSaarcController.text.trim().isEmpty ? null : _feeSaarcController.text.trim(),
      'OpeningTime': _openTimeController.text.trim().isEmpty ? null : _openTimeController.text.trim(),
      'ClosingTime': _closeTimeController.text.trim().isEmpty ? null : _closeTimeController.text.trim(),
      'BestTimeToVisit': _bestTimeController.text.trim().isEmpty ? null : _bestTimeController.text.trim(),
      'IsUNESCO': _isUnesco,
    };

    try {
      final response = await SitesRemoteDatasource().updateSite(
        id: widget.site['id'] as int,
        fields: fields,
        files: _newFiles,
      );

      if (mounted) {
        setState(() => _isLoading = false);
      }

      if (response.statusCode == 200) {
        if (mounted) Navigator.pop(context, true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Update failed: ${response.statusCode}')),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error: $error')),
        );
      }
    }
  }

  // ─── Build ───

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double dialogWidth = screenWidth > 1000 ? 1000.0 : screenWidth * 0.95;

    return AlertDialog(
      title: Row(
        children: [
          const Expanded(child: Text('Edit Site', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          IconButton(onPressed: () => Navigator.pop(context, false), icon: const Icon(Icons.close)),
        ],
      ),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and Category
                Row(children: [
                  _buildTextField(_nameController, 'Name *', required: true),
                  const SizedBox(width: 12),
                  _buildTextField(_categoryController, 'Category *', required: true),
                ]),
                const SizedBox(height: 8),

                // District and Address
                Row(children: [
                  _buildTextField(_districtController, 'District *', required: true),
                  const SizedBox(width: 12),
                  _buildTextField(_addressController, 'Address *', required: true),
                ]),
                const SizedBox(height: 8),

                // Short Description
                _buildTextArea(_shortDescController, 'Short Description *', maxLength: 500, required: true),
                const SizedBox(height: 12),

                // Historical Significance
                _buildTextArea(_historicalController, 'Historical Significance', maxLength: 500),
                const SizedBox(height: 8),

                // Cultural Importance
                _buildTextArea(_culturalController, 'Cultural Importance', maxLength: 500),
                const SizedBox(height: 12),

                // Fees
                Row(children: [
                  _buildNumberField(_feeNprController, 'Entry Fee (NPR)'),
                  const SizedBox(width: 12),
                  _buildNumberField(_feeSaarcController, 'Entry Fee SAARC'),
                ]),
                const SizedBox(height: 8),

                // Times
                Row(children: [
                  _buildTimeField(_openTimeController, 'Opening (HH:mm)'),
                  const SizedBox(width: 12),
                  _buildTimeField(_closeTimeController, 'Closing (HH:mm)'),
                ]),
                const SizedBox(height: 8),

                // Best time + UNESCO
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _bestTimeController,
                      decoration: const InputDecoration(labelText: 'Best Time to Visit', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(children: [
                    const Text('UNESCO'),
                    Switch.adaptive(value: _isUnesco, onChanged: (value) => setState(() => _isUnesco = value)),
                  ]),
                ]),
                const SizedBox(height: 12),

                // Existing images
                const Text('Existing Images (remove if needed)'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _existingImageUrls.map((url) {
                    return Chip(
                      label: SizedBox(width: 160, child: Text(url, maxLines: 1, overflow: TextOverflow.ellipsis)),
                      onDeleted: () => setState(() => _existingImageUrls.remove(url)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // New images
                const Text('Upload New Images (replaces existing)'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _pickFiles,
                      icon: const Icon(Icons.upload),
                      label: const Text('Choose Files'),
                    ),
                    ..._newFiles.map((file) => Chip(label: Text(file.name))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Save Changes'),
        ),
      ],
    );
  }

  // ─── Helper widgets ───

  /// Text field inside a Row (uses Expanded)
  Widget _buildTextField(TextEditingController controller, String label, {bool required = false}) {
    return Expanded(
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: required
            ? (value) => (value == null || value.trim().isEmpty) ? 'Required' : null
            : null,
      ),
    );
  }

  /// Multi-line text area (full width)
  Widget _buildTextArea(TextEditingController controller, String label, {int maxLength = 500, bool required = false}) {
    return TextFormField(
      controller: controller,
      maxLength: maxLength,
      maxLines: 5,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      validator: required
          ? (value) => (value == null || value.trim().isEmpty) ? 'Required' : null
          : null,
    );
  }

  /// Number-only field inside a Row (uses Expanded)
  Widget _buildNumberField(TextEditingController controller, String label) {
    return Expanded(
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: (value) {
          if (value == null || value.isEmpty) return null; // optional
          return double.tryParse(value) == null ? 'Number only' : null;
        },
      ),
    );
  }

  /// Time picker field inside a Row (uses Expanded)
  Widget _buildTimeField(TextEditingController controller, String label) {
    return Expanded(
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.access_time),
        ),
        onTap: () => _pickTime(controller),
        validator: (value) {
          if (value == null || value.isEmpty) return null; // optional
          bool isValidFormat = RegExp(r'^\d{2}:\d{2}$').hasMatch(value);
          return isValidFormat ? null : 'Use HH:mm format';
        },
      ),
    );
  }
}